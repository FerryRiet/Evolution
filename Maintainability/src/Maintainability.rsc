module Maintainability

import IO;
import analysis::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::Core;
import String;
import List;
import Set;
import lang::java::jdt::m3::Core;
import util::Math;

int countCyclicComplexity(Statement M) {
      int cyclic = 1 ;
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

void Analyze(loc location) {
      int cyclicCount = 0 ;
      int methodCount = 0 ; // Used for debugging only
         
      list[tuple[str name,loc location ,int lines,int ccomplexity]] aresult = [] ; // <Name, location, lines, complexity>

      ASTSet  = createAstsFromEclipseProject(location , true) ;
      M3Model = createM3FromEclipseProject(location) ;          

      top-down-break visit (ASTSet) {
               case c:constructor(NAME,_,_,N) : {
                      cyclicCount = countCyclicComplexity(N) ;
                      aresult = aresult + <NAME,c @ decl,calcMethodLinesV2(M3Model,c @ decl),cyclicCount> ;
               }
               case m:method(_,NAME,_,_,N) : {
                      methodCount = methodCount + 1  ;        
                      cyclicCount = countCyclicComplexity(N) ;
                      aresult = aresult + <NAME,m @ decl,calcMethodLinesV2(M3Model,m @ decl),cyclicCount> ;
               }
      }
      totalLines = countProjectTotalLocV2(M3Model) ;
      totalEmptyLines = countProjectEmptyLocV2(M3Model) ;
      
      effectiveLinesOfCode = countEffectiveLocV2(M3Model)  ;
      
      println("======================= Metrics results ==============================");
      println("Lines of Code");
      println(" Total: <totalLines>");
      println(" Total White lines: <totalEmptyLines>");
      println(" Effective lines: <effectiveLinesOfCode>");
      println(" Total number of methods : <methodCount>") ;

      print(" Manyear to build: ");
      if(effectiveLinesOfCode <= 66000) {
        println("(0-8) ++");
      }
      else if (effectLinesOfCode > 66000 && effectLinesOfCode<=246000) {
        println("(8-30) +");
      }
      else if(effectLinesOfCode > 246000 && effectLinesOfCode<=665000) {
        println("(30-80) o");
      }
      else if(effectLinesOfCode > 665000 && effectLinesOfCode<=1310000) {
        println("(80-160) -");
      }
      else if(effectLinesOfCode > 1310000) {
          println("(\>160) --");
      } 
      int lowLines = 0 ;
      int midLines = 0 ;
      int complexLines = 0 ;
      int untestableLines = 0 ;
      if (debug) 
           iprintln(aresult) ;
      
      for ( tuple[str name,loc location ,int lines,int ccomplexity] mresult <- aresult ) {
      		if ( mresult.ccomplexity <= 10 ) lowLines += mresult.lines ;
      		else if ( mresult.ccomplexity >  10  && mresult.ccomplexity <= 20 ) midLines +=  mresult.lines ;
      		else if ( mresult.ccomplexity >  21  && mresult.ccomplexity <= 50 ) complexLines +=  mresult.lines ;
      		else if ( mresult.ccomplexity >  50 ) { untestableLines +=  mresult.lines ; } 
      }
      int totalUnitLines = 0 ;
      totalUnitLines = lowLines + midLines + complexLines + untestableLines ;
      
      real lowPerc = toReal(lowLines) / toReal(totalUnitLines) ;
      real midPerc = toReal(midLines) / toReal(totalUnitLines) ;
      real comPerc = toReal(complexLines) / toReal(totalUnitLines) ;
      real untPerc = toReal(untestableLines) / toReal(totalUnitLines) ;

      println("----------------------- Complexity results --------------------------");
       
      print  (" Low complexity code nr of lines : <lowLines> \n Medium complecity code nr of lines : <midLines>\n") ;
      println(" Nr of complex code lines : <complexLines> \n Nr of untestable code lines : <untestableLines>") ;
      println("\n Total nr of executable unit lines : <lowLines + midLines + complexLines + untestableLines>  \n") ;

	  print  (" Low complexity code <round(lowPerc * 100.0) > % Mid complexity code <round(midPerc * 100.0) > % " ) ;
	  println("Complex code <round(comPerc * 100.0)> % Untestable code <round(untPerc * 100.0)> %" ) ;
	  

}


bool debug = false ;

int calcMethodLinesV2(M3 M3Model,loc cu) {
     str content = "" ;
     //return 10 ;
     // TODO: check type and remove the iterator there should only be one entry
     for ( doc <- M3Model@declarations[cu] ){ 
            content = readFile(doc) ;
     }
     // Replace strings
     for ( /<word:\"(.|\\.)*\">/ := content ) {
	 	content = replaceFirst(content,word,"\"\"") ;
	 }
     for ( /<word:\/\/.*>/ := content ) {
	 	content = replaceFirst(content,word,"") ;
	 }
	 // Thank you stack exchange 
     //for ( /<word:(?=(?:[^"\\]*(?:\\.|"(?:[^"\\]*\\.)*[^"\\]*"))*[^"]*$)\\*\/\*(?s).*?\*\/>/ := content ) {
     for ( /<word:\/\*(?s).*?\*\/>/ := content ) {
	 	content = replaceFirst(content,word,"") ;
	 }
     for ( /<word:[\r\n]\s*[\r\n]>/ := content ) {
	 	content = replaceFirst(content,word,"\n") ;
	 }
     for ( /<word:[\ \t]*>/ := content ) {
	 	content = replaceFirst(content,word," ") ;
	 }
     if (debug) 
	 	println("***** \n<content>\n*****" ) ;
     return (0 | it + 1 | /^.*\S.*$/ <- split("\n", content ));
}

int countProjectTotalLocV2(M3 model)        = (0 | it + countFileEndLocV2(model, cu)   | cu <- files(model));
int countEffectiveLocV2(M3 model)           = (0 | it + calcMethodLinesV2(model, cu)   | cu <- files(model));
int countProjectEmptyLocV2(M3 projectModel) = (0 | it + countEmptyLocV2(projectModel, cu) | cu <- files(projectModel));

int countEmptyLocV2(M3 projectModel, loc cu) 
    =   (0 | it + 1 | loc doc <- projectModel@declarations[cu], /^\s*$/ <- readFileLines(doc));

int countFileBeginLocV2(M3 projectModel, loc cu) {
   loc src = Set::getOneFrom(projectModel@declarations[cu]) ;
   return src.begin.line ;
}

int countFileEndLocV2(M3 projectModel, loc cu) {
   loc src = Set::getOneFrom(projectModel@declarations[cu]) ;
   return src.end.line ;
}

//|project://smallsql0.21_src|