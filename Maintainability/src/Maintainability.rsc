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

import DuplicateCodeTxt;

bool debug = false ;

//int countCyclicComplexity(Statement M) {
tuple[int complexity, int assertCount] countCyclicComplexity(Statement M) {
      int cyclic = 1 ;
      int assertCount = 0 ;
      visit (M) {
            case \if(_,_)            : cyclic += 1 ;
            case \if(_,_,_)          : cyclic += 1 ; // includes else
            case \case(_)            : cyclic += 1 ;
            case \while(_,_)         : cyclic += 1 ;
            case \do(_,_)            : cyclic += 1 ; // path back to start discusion point.
            case \for(_,_,_,_)       : cyclic += 1 ;
            case \foreach(_,_,_)     : cyclic += 1 ;
//            case \try(_,_)           : cyclic += 0 ;
//            case \try(_,_,_)         : cyclic += 0 ; // Includes finally 
            case \catch(_,_)         : cyclic += 1 ; 
            case \conditional(_,_,_) : cyclic += 1 ;   //  if then else
            case \assert(_)          : assertCount += 1 ;
            case \assert(_,_)        : assertCount += 1 ;
      }
      return <cyclic,assertCount> ;
}

list[tuple[str name,loc location ,int lines,int ccomplexity,int assertCount]] getCyclic(M3 M3Model, set[Declaration] ASTset) {
	list[tuple[str name,loc location ,int lines,int ccomplexity,int assertCount]] aresult = [] ; // <Name, location, lines, complexity>
    tuple[int complexity,int assertCount] cyclicCount ;
    top-down-break visit (ASTset) {
           case c:constructor(NAME,_,_,N) : {
                  cyclicCount = countCyclicComplexity(N) ;
                  aresult = aresult + <NAME,c @ decl,calcMethodLinesV2(M3Model,c @ decl),cyclicCount.complexity,cyclicCount.assertCount> ;
           }
           case m:method(_,NAME,_,_,N) : {
                  cyclicCount = countCyclicComplexity(N) ;
                  aresult = aresult + <NAME,m @ decl,calcMethodLinesV2(M3Model,m @ decl),cyclicCount.complexity,cyclicCount.assertCount> ;
           }
      }
      return aresult ;
}
        

void AnalyzeV1(loc location) {
      tuple[int complexity, int assertCount] cyclicCount ;
      
      int methodCount = 0 ; 
         
      list[tuple[str name,loc location ,int lines,int ccomplexity,int assertCount]] aresult = [] ; // <Name, location, lines, complexity>

      ASTSet  = createAstsFromEclipseProject(location , true) ;
      M3Model = createM3FromEclipseProject(location) ;          
	  
      
      totalLines = countProjectTotalLocV2(M3Model) ;
      totalEmptyLines = countProjectEmptyLocV2(M3Model) ;
      
      effectiveLinesOfCode = countEffectiveLocV2(M3Model)  ;
      
      println("=========================== Metrics: Lines ===================================================");
      println("Lines of Code");
      println(" Total: <totalLines>");
      println(" Total White lines: <totalEmptyLines>");
      println(" Effective lines: <effectiveLinesOfCode>");
      println(" Total number of methods : <methodCount>") ;

      println(" Volume score: <getVolumeRanking(effectiveLinesOfCode)>\n");
      
      
      int lowLines = 0 ;
      int midLines = 0 ;
      int complexLines = 0 ;
      int untestableLines = 0 ;
      int unit100plus = 0 ;
      int unit50plus = 0 ;
      int unit10plus = 0 ;
      int assertStatements = 0 ;
      
	  aresult = getCyclic(M3Model,ASTSet) ;	  
	  methodCount = size(aresult) ;
            
      if (debug) 
           iprintln(aresult) ;
      
      for ( tuple[str name,loc location ,int lines,int ccomplexity, int assertCount] mresult <- aresult ) {
			// Sum complexity numebers
      		if ( mresult.ccomplexity <= 10 ) lowLines += mresult.lines ;
      		else if ( mresult.ccomplexity >  10  && mresult.ccomplexity <= 20 ) midLines +=  mresult.lines ;
      		else if ( mresult.ccomplexity >  21  && mresult.ccomplexity <= 50 ) complexLines +=  mresult.lines ;
      		else if ( mresult.ccomplexity >  50 ) { untestableLines +=  mresult.lines ; }
      		
      		// Sum unit size numbers
       		if ( mresult.lines > 100 ) unit100plus += 1  ;
      		else if ( mresult.lines >  50 ) unit50plus += 1 ;
      		else if ( mresult.lines >  10 ) unit10plus += 1 ;
      		
      		// Sum assert statements
      		assertStatements += mresult.assertCount ;	 
      }
      
      int totalUnitLines = 0 ;
      totalUnitLines = lowLines + midLines + complexLines + untestableLines ;
      
      int lowPerc = (lowLines * 100) / totalUnitLines ;
      int midPerc = (midLines * 100) / totalUnitLines ;
      int comPerc = (complexLines * 100) / totalUnitLines ;
      int untPerc = (untestableLines * 100) / totalUnitLines ;

      println("--------------------------- Metrics : Complexity ---------------------------------------------");
       
      print  (" Low complexity code nr of lines : <lowLines> \n Medium complecity code nr of lines : <midLines>\n") ;
      println(" Nr of complex code lines : <complexLines> \n Nr of untestable code lines : <untestableLines>") ;
      println("\n Total nr of executable unit lines : <lowLines + midLines + complexLines + untestableLines>  \n") ;

	  print  (" Low complexity code <lowPerc> % Mid complexity code <midPerc> % " ) ;
	  println("Complex code <comPerc> % Untestable code <untPerc> %" ) ;

	  
	  complexityRanking = getRanking(untPerc, comPerc, midPerc) ;
	  println("\n Complexity score <complexityRanking> ." ) ;
	  
	  
      println("--------------------------- Metrics : Unit size ----------------------------------------------");
	  
	  
	  unitRanking = getRanking((unit100plus *100)/methodCount, (unit100plus *100)/methodCount, (unit100plus *100)/methodCount) ;
	  println("\n Unit size score <unitRanking> ." ) ;
		 	
      println("--------------------------- Metrics : Duplicate code -----------------------------------------");

      dupScore = findDuplicatesV2(M3Model) ;
	  //dupScore= 3  ;
	  dupRanking = rankDuplicates(dupScore)  ;
	  println("\n Percentage duplicated code <dupScore>%  ." ) ;
	  println(" Duplicated code ranking <dupRanking> ." ) ;

	  //dupRanking = "?"   ;

      println("--------------------------- Metrics : Unit tests ---------------------------------------------");

	  //println("AssertCount <assertStatements> ") ;
	  testRanking = "o" ;

      
      println("--------------------------- End report: Sig Maintainability model ----------------------------");
	  println("\n\t\tVolume\tComplexity\tDuplications\tUnit size\tUnit tests\tSIG MI") ;
	  
	  //rAvg = rankingAvg([getVolumeRanking(effectiveLinesOfCode),dupRanking,unitRanking,testRanking]) ;
	  rAvg = rankingAvg([getVolumeRanking(effectiveLinesOfCode),dupRanking,unitRanking]) ;
	  println("Analysability\t<getVolumeRanking(effectiveLinesOfCode)>\t  \t\t<dupRanking>\t\t<unitRanking>\t\t<testRanking>\t\t<rAvg>" ) ;

	  rAvg = rankingAvg([complexityRanking,dupRanking]) ;	  
	  println("Changeability\t  \t<complexityRanking>\t\t<dupRanking>\t\t  \t\t  \t\t<rAvg>" ) ;
	  
	  rAvg = testRanking ; 
	  println("Stability\t  \t  \t\t  \t\t  \t\t<testRanking>\t\t<rAvg>" ) ;
	  
	  //rAvg = rankingAvg([complexityRanking,unitRanking,testRanking]) ;
	  rAvg = rankingAvg([complexityRanking,unitRanking]) ;
	  println("Testability\t  \t<complexityRanking>\t\t  \t\t<unitRanking>\t\t<testRanking>\t\t<rAvg>" ) ;
	  
}

str rankDuplicates(int dupPerc) {
	if ( dupPerc <= 3 ) return "++" ;
	else if ( dupPerc <= 5 ) return "+" ;
	else if ( dupPerc <= 10 ) return "o" ;
	else if ( dupPerc <= 20 ) return "-" ;
	return "--" ;
} 

str rankingAvg(list[str] ranks) {
		int sum = 0 ;
		for ( str s <- ranks ) {
			if ( s == "++" ) sum += 5 ;
			else if ( s == "+" ) sum += 4 ;
			else if ( s == "o" ) sum += 3 ;
			else if ( s == "-" ) sum += 2 ;
			else sum += 1 ;
		}
		sum = (sum+1) / size(ranks) ;
		switch (sum) {
			case 5 : return "++" ;
			case 4 : return "+" ;
			case 3 : return "o" ;
			case 2 : return "-" ;
			case 1 : return "--" ;
		}
}

str getVolumeRanking(int effectiveLinesOfCode) {
      if(effectiveLinesOfCode <= 66000)  return "++";
      else if (effectiveLinesOfCode <= 246000)  return "+";
      else if (effectiveLinesOfCode <= 665000)  return "o";
      else if (effectiveLinesOfCode <= 1310000) return "-";
      return "--";
}      
   
// Used fot both rankings 
str getRanking(int veryHigh, int high, int medium) {
	if (medium <= 25 && high <= 0  && veryHigh <= 0) return "++" ;
	else if (medium <= 30 && high <= 5  && veryHigh <= 0) return "+"  ;
	else if (medium <= 40 && high <= 10 && veryHigh <= 0) return "o"  ;
	else if (medium <= 50 && high <= 15 && veryHigh <= 5) return "-"  ;
	return "--" ;
}


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
// Total execution time 5h5m 
//--------------------------- Metrics : Unit tests ---------------------------------------------
//AssertCount 7 
//--------------------------- End report: Sig Maintainability model ----------------------------

//		            Volume	Complexity	Duplications	Unit size	Unit tests	SIG MI/
//Analysability	    ++	  		        o		        ++		    o		    +
//Changeability	  	        -		    o		  		  		 	            o
//Stability	  	  		  		  		                            o		    o
//Testability	  	        -		  		            ++		    o		    o
//ok


//=========================== Metrics: Lines ===================================================
//Lines of Code
// Total: 299728
// Total White lines: 56528
// Effective lines: 169094
// Total number of methods : 10299
// Volume score: +

//-------------------------- Metrics : Complexity ---------------------------------------------
// Low complexity code nr of lines : 99857 
// Medium complecity code nr of lines : 21073
// Nr of complex code lines : 15778 
// Nr of untestable code lines : 13402

// Total nr of executable unit lines : 150110  

// Low complexity code 66 % Mid complexity code 14 % Complex code 10 % Untestable code 8 %

// Complexity score -- .
//--------------------------- Metrics : Unit size ----------------------------------------------

// Unit size score - .
//--------------------------- Metrics : Duplicate code -----------------------------------------

// Percentage duplicated code 3%  .
// Duplicated code ranking ++ .
//--------------------------- Metrics : Unit tests ---------------------------------------------
//--------------------------- End report: Sig Maintainability model ----------------------------

//		Volume	Complexity	Duplications	Unit size	Unit tests	SIG MI
//Analysability	+	  		++		-		o		+
//Changeability	  	--		++		  		  		o
//Stability	  	  		  		  		o		o
//Testability	  	--		  		-		o		-


















