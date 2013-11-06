module Maintainability

import IO;
import analysis::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::Core;
import String;
import List;
import Set;
import lang::java::jdt::m3::Core;

int countCyclicComplexity(Statement M) {
	int cyclic = 0 ;
	visit (M) {
	       case \if(_,_)      : cyclic += 1 ;
	       case \if(_,_,_)    : cyclic += 1 ; // includes else
		   case \case(_)      : cyclic += 1 ;
     	   case \while(_,_)   : cyclic += 1 ;
           case \do(_,_)      : cyclic += 1 ;
           case \for(_,_,_,_) : cyclic += 1 ;
           case \try(_,_)     : cyclic += 1 ;
           case \try(_,_,_)   : cyclic += 1 ; // Includes finally 
     	   case \catch(_,_)   : cyclic += 1 ; 
	}
	return cyclic ;
}

void DoIt() {
		int cyclicCount = 0 ;
	    int methodCount = 0 ;
	 
	    list[tuple[str,int,int]] aresult = [] ;

	    ASTSet  = createAstsFromEclipseProject(|project://HelloWorld| , true) ;
	    M3Model = createM3FromEclipseProject(|project://HelloWorld|) ;	    

	    top-down-break visit (ASTSet) {
	    	    case c:constructor(NAME,_,_,N) : {
						cyclicCount = countCyclicComplexity(N) ;
			            aresult = aresult + <NAME,calcMethodLinesV2(M3Model,c @ decl),cyclicCount> ;
	    	    }
		        case m:method(_,NAME,_,_,N) : {
		            	methodCount = methodCount + 1  ;	
		            	cyclicCount = countCyclicComplexity(N) ;
			            aresult = aresult + <NAME,calcMethodLinesV2(M3Model,m @ decl),cyclicCount> ;
		        }
	     }
		
	     totalLines = countProjectTotalLocV2(M3Model) ;
	     print("Total lines of code : ") ; println(totalLines) ;

	     print("Total number of methods : ") ; println(methodCount) ;
	
	     totalCommentedLines = countProjectCommentedLocV2(M3Model) ;
	     print("Total lines of comment lines : " ) ; println(totalCommentedLines) ;

	     totalEmptyLines = countProjectEmptyLocV2(M3Model) ;
	     print("Total number of empty lines: " ) ; println(totalEmptyLines) ;	
	     println(aresult) ;

}

int calcMethodLinesV2(M3 M3Model,loc cu) {
    str content = "" ;
	int count = 0 ;
	for ( doc <- M3Model@declarations[cu] ){
		content = readFile(doc) ;
	}
	// Fase 1 remove comments
	str p = visit(content){
   		case /<word:\/\*(.|[\r\n])*\*\/>/ => "" 
   		case /<word:\/\/.*>/              => "" 
   		//case /<word:^\s*>/              => ""  // causes Rascal to loop 100%
   	};
   	// Fase 2 drop blank lines and finally count remaining lines
   	count =  (0 | it + 1 | /^.*\S.*$/ <- split("\n", p ));
	return count ;
}

int countProjectCommentedLocV2(M3 model)    = (0 | it + countCommentedLocV2(model, cu) | cu <- files(model));
int countProjectTotalLocV2(M3 model)        = (0 | it + countFileEndLocV2(model, cu)   | cu <- files(model));
int countProjectEmptyLocV2(M3 projectModel) = (0 | it + countEmptyLocV2(projectModel, cu) | cu <- files(projectModel));

int countCommentedLoc(M3 projectModel, loc cu)   =  (0 | it + (doc.end.line - doc.begin.line + 1 - checkForSourceLines(doc)) | doc <- projectModel@documentation[cu]); 
int countCommentedLocV2(M3 projectModel, loc cu) = 	(0 | it + 1 | loc doc <- projectModel@declarations[cu], /^\s*\/\/.*$/ <- split("\n", readFile(doc)));
int countEmptyLocV2(M3 projectModel, loc cu) 
    = 	(0 | it + 1 | loc doc <- projectModel@declarations[cu], /^\s*$/ <- split("\n", removeCommentsV2(readFile(doc), projectModel, cu)));

int countFileBeginLocV2(M3 projectModel, loc cu) {
   loc src = Set::getOneFrom(projectModel@declarations[cu]) ;
   return src.begin.line ;
}

int countFileEndLocV2(M3 projectModel, loc cu) {
   loc src = Set::getOneFrom(projectModel@declarations[cu]) ;
   return src.end.line ;
}

// TODO: The next two functions need a total rewrite
int checkForSourceLines(loc commentLoc) {
	str comment = readFile(commentLoc);
	
	// We will check to see if there are any source code in the commented lines
	loc commentedLines = commentLoc;
	// start from start of the line
	commentedLines.begin.column = 0;
	// increase to the next line to cover the full line
	commentedLines.end.line += 1;
	// we won't take any character from the next line
	commentedLines.end.column = 0;
	
	list[str] contents = readFileLines(commentedLines);

	str commentedLinesSrc = intercalate("\n", contents);
	
	// since we look till the start of the next line, we need to make sure we remove the extra \n from the end	
	if (isEmpty(last(contents)))
		commentedLinesSrc = replaceLast(commentedLinesSrc, "\n" , "");
	
	return size(split(comment, trim(commentedLinesSrc)));
}

// Next function only works on a complete file not on code fragments
str removeCommentsV2(str contents, M3 projectModel, loc cu) {
  list[str] listContents = split("\n", contents);
  list[str] result = listContents;
  for (loc commentLoc <- projectModel@documentation[cu]) {
    result = result - slice(listContents, commentLoc.begin.line - 1, commentLoc.end.line - commentLoc.begin.line + 1);
  }
  return intercalate("\n", result);
}
