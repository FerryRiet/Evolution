module Maintainability

import IO;
import analysis::m3::Core;
import analysis::m3::metrics::LOC;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import String;

void DoIt() {

	int ifs = 0 ;
	int elifs = 0 ;
	int methodCount = 0 ;
	
	 
	list[tuple[str,int,int,int]] aresult = [] ;
	
	AST     = createAstsFromEclipseProject(|project://HelloWorld| , true) ;
	M3Model = createM3FromEclipseProject(|project://HelloWorld|) ;

	top-down visit (AST) {
		case m:method(_,NAME,_,_,N) : {
			methodCount = methodCount + 1  ;	
			println(NAME) ;	
			visit(N) {
				case \if(_,_)      : ifs = ifs + 1 ;
				case \if(_,_,_)    : elifs = elifs + 1 ;
     			case \case(_)      : cases = cases + 1;
     			case \while(booleanLiteral(true),_): infinite_loops = infinite_loops+1;
     			case \while(_,_)   : while_loops = while_loops + 1;
     			case \do(_,_)      : do_while_loops = do_while_loops + 1;
     			case \for(_,_,_,_) : fors = fors + 1;
     			case \try(_,_)     : trys = trys + 1;
     			case \try(_,_,_)   : trys = trys + 1 ; // Includes finally 
     			case \catch(_,_)   : catches = catches + 1 ;
    		};
    		aresult = aresult + <NAME,calcMethodLines(M3Model,m @ decl),1,1> ;
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
}

int countFileBeginLoc(M3 projectModel, loc cu) = src.begin.line when {src} := projectModel@declarations[cu];
int countFileEndLoc(M3 projectModel, loc cu) = src.end.line when {src} := projectModel@declarations[cu];
int countEmptyLocs(M3 projectModel, loc cu) 
  =	(0 | it + 1 | loc doc <- projectModel@declarations[cu], /^\s*$/ <- split("\n", removeComments(readFile(doc), projectModel, cu)));
int countCommentedLocs(M3 projectModel, loc cu) 
  =	(0 | it + 1 | loc doc <- projectModel@declarations[cu], /^\s*\/\/.*$/ <- split("\n", removeComments(readFile(doc), projectModel, cu)));

int calcMethodLines(M3 M3Model,loc location) {
	int methodLines = 0 ;
	methodLines = countFileEndLoc(M3Model, location) - countFileBeginLoc(M3Model, location) 
	            - countEmptyLocs(M3Model, location)  - countCommentedLocs(M3Model, location) + 1 ;
	return methodLines;
}
