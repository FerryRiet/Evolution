module Maintainability

import IO;
import analysis::m3::Core;
import analysis::m3::metrics::LOC;
import lang::java::jdt::m3::AST;
import lang::java::m3::Core;
import String;
import Set;
import lang::java::jdt::m3::Core;

void DoIt() {

	    int ifs = 0 ;
	    int elifs = 0 ;
	    int cases = 0 ;
	    int trys = 0 ;
	    int fors = 0 ;
	    int whiles = 0 ;
	 	   int catches = 0 ;
		int cyclicCount = 0 ;
	    int methodCount = 0 ;
	 
	    list[tuple[str,int,int,int]] aresult = [] ;
	
	    AST     = createAstsFromEclipseProject(|project://HelloWorld| , true) ;
	    M3Model = createM3FromEclipseProject(|project://HelloWorld|) ;
        
	    top-down-break visit (AST) {
	    	    case c:constructor(CNAME,_,_,N) : {
	    	    	    println("constructor" ) ;
	    	    }
		        case m:method(_,NAME,_,_,N) : {
		            	methodCount = methodCount + 1  ;	
		            	cyclicCount = 0 ;
			            println(NAME) ;	
			            visit(N) {
					       case \if(_,_)      : cyclicCount = cyclicCount + 1 ;
		                   case \if(_,_,_)    : cyclicCount = cyclicCount + 1 ;
				           case \case(_)      : cyclicCount = cyclicCount + 1;
     			           case \while(_,_)   : cyclicCount = cyclicCount + 1;
     			           case \do(_,_)      : cyclicCount = cyclicCount + 1;
     			           case \for(_,_,_,_) : cyclicCount = cyclicCount + 1;
     			           case \try(_,_)     : cyclicCount = cyclicCount + 1;
     			           case \try(_,_,_)   : cyclicCount = cyclicCount + 1 ; // Includes finally 
     			           case \catch(_,_)   : cyclicCount = cyclicCount + 1 ;
    		        };
    		        aresult = aresult + <NAME,calcMethodLines(M3Model,m @ decl),cyclicCount,1> ;
		        }
	     }
		
	     totalLines = countProjectTotalLoc(M3Model) ;
	     print("Total lines of code : ") ; println(totalLines) ;

	     print("Total number of methods : ") ; println(methodCount) ;
	
	     totalCommentedLines = countProjectCommentedLoc(M3Model) ;
	     print("Total lines of comment lines : " ) ; println(totalCommentedLines) ;

	     totalEmptyLines = countProjectEmptyLoc(M3Model) ;
	     print("Total number of empty lines: " ) ; println(totalEmptyLines) ;	
	     println(aresult) ;
	     println(AST) ;

}


int countFileBeginLocV2(M3 projectModel, loc cu) {
   loc src = Set::getOneFrom(projectModel@declarations[cu]) ;
   return src.begin.line ;
}

int countFileEndLocV2(M3 projectModel, loc cu) {
   loc src = Set::getOneFrom(projectModel@declarations[cu]) ;
   return src.end.line ;
}

int countEmptyLocs(M3 projectModel, loc cu) 
      = 	(0 | it + 1 | loc doc <- projectModel@declarations[cu], /^\s*$/ <- split("\n", removeComments(readFile(doc), projectModel, cu)));
int countCommentedLocs(M3 projectModel, loc cu) 
      = 	(0 | it + 1 | loc doc <- projectModel@declarations[cu], /^\s*\/\/.*$/ <- split("\n", removeComments(readFile(doc), projectModel, cu)));

int calcMethodLines(M3 M3Model,loc location) {
	    int methodLines = 0 ;
	    methodLines = countFileEndLocV2(M3Model, location) - countFileBeginLocV2(M3Model, location) 
	                - countEmptyLocs(M3Model, location)    - countCommentedLocs(M3Model, location) + 1 ;
	    return methodLines;
}
