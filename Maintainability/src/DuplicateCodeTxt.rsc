module DuplicateCodeTxt

import IO;
import String;
import List;
import Set;

import analysis::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import util::Math;
import ValueIO;

import KMP ;

list[Statement] splatIt(Declaration ast) {
					    list[Statement] splat = [ e | /Statement e <- ast ] ;
	    return splat ;
}
void showSource(list[str] stmntList) {
	    for ( str h <- stmntList) {
		        println(h)  ;
	    }
}

void Show(M3 M3Model,loc cu) {
		    cu.begin.column = 0 ;	
	    content = readFile(cu) ;
	    println(content) ;
}

int findOccurancesV0(list[str] fragment, list[str] alls) {
	int ocs = 0 ;
    for ( [*_,*fragment,*_] := alls ) {
       ocs += 1;
       if ( ocs == 2 ) return 2 ;
	}
	return ocs ;
}

int findOccurances(list[str] fragment, list[str] alls) {
	    int ocs = 0 ;
	    ocs = size(KMPallMatches(alls,fragment)) ;
	    return ocs ;
}

bool debug = false ;

list[str] readAndStrip(loc doc) {
    str content = "" ;
            
    content = readFile(doc) ;
    content = trim(content) ;
     
    // Replace strings
    for ( /<word:\"(.|\\.)*\">/ := content ) {
	        	content = replaceFirst(content,word,"\"\"") ;
	    }
    for ( /<word:\/\/.*>/ := content ) {
	 	       content = replaceFirst(content,word,"") ;
	    }
	    // Thank you stack exchange 
    for ( /<word:(?=(?:[^"\\]*(?:\\.|"(?:[^"\\]*\\.)*[^"\\]*"))*[^"]*$)\\*\/\*(?s).*?\*\/>/ := content ) {
     //for ( /<word:\/\*(?s).*?\*\/>/ := content ) {
	 	       content = replaceFirst(content,word,"") ;
	    }
    for ( /<word:[\r\n]\s*[\r\n]>/ := content ) {
	 	       content = replaceFirst(content,word,"\n") ;
	    }
    for ( /<word:\t>/ := content ) {
	 	       content = replaceFirst(content,word," ") ;
	    }
    if (debug) 
	 	       println("***** \n<content>\n*****" ) ;
    //return [ line  | line:/^.*\S.*$/ <- split("\n", content )];
    content = " "+ content ;
    return [ line  | line <- split("\n", content )];
}

void dumpToFile(loc location, list[str] d) {
    int count = 1 ;
    iprintToFile(location,"Start") ; 
    for ( str s <- d ) {
         appendToFile(location, "<count> : <s> \n") ;
   	     count += 1 ;
    }
}

int doItWork(M3 M3Model) {
    list[str] allCode = [""];
    list[str] all2Code = [];
    list[str] ripoff ;
    list[str] p ;
    lineCount = 01;
 
    int listCount = 0 ;
    int i = 1 ;
    //for ( loc fileLoc  <- methods(M3Model) ) { 
    for ( loc  fileLoc <- files(M3Model) ) {
   	    list[str] fileContent ;
        fileContent = readAndStrip(fileLoc) ;
        allCode += fileContent ;
    } 
	
    dumpToFile(|file:///Users/ferryrietveld/data.code|, allCode) ;
	if ( debug ) 
		println("Checking <size(allCode)> lines" ) ;
    
    ripoff = allCode ;
    workingSet = allCode ;

	for ( str oneLine <- allCode ) {
		if ( debug == false ) { 
			if ( lineCount % 10  == 0 ) print(".") ;
	   	    if ( lineCount % 100 == 0 ) println("<lineCount>") ;
			lineCount += 1 ;
		}	    		    
        ripoff = drop(1,ripoff) ;
        cutAgain = true ;
	    while ( cutAgain ) {
	         i = 5	 ;
	         cutAgain = false ;
	         if ( size(ripoff) > i && findOccurances([oneLine]+head(ripoff,i),workingSet) >= 2 ) { 
	        	  p = [oneLine] ;
  	              do  {
 	                  i+= 1 ;
              	  	  if ( size(ripoff) > i ) {
                  	       p = [oneLine] + head(ripoff,i) ;
			      	  }
			      	  else break ;
		      	  } while ( findOccurances(p,workingSet) >= 2 ) ;

                  if ( i-1 >= 6 )  {
	                  x = head(p,i);
	                  if ( debug ) print("x(<size(x)>)") ;
		              if ([*L , x , *M , x , *R ] := workingSet) {
	                     workingSet = L + x + M + R; 
	    		      	 cutAgain = true ;
	    		      }
                  }
  	        }
       }
     }
     real allS = toReal(size(allCode)) ;
     real WS = toReal(size(workingSet)) ;
     
     if ( debug ) {
		 dumpToFile(|file:///Users/ferryrietveld/data.after|, workingSet) ;
		 println("\nPercentage code duplication: <round(((allS - WS)/allS) * 100.0)>%") ;
		 println("e.g. <size(allCode) - size(workingSet)> lines duplicated." ) ;
     }
     return toInt(round(((allS - WS)/allS) * 100.0)) ;
}

// Note to self in smallsql0 file TestOrderBy.java contains multiple clones.
int findDuplicatesV2(M3 M3Model) {
    return doItWork(M3Model) ;    
}
