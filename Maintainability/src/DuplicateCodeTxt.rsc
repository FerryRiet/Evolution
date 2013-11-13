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

int linesOccupied(loc s) {
	return  s.end.line - s.begin.line + 1 ;
}

int linesListOccupied(list[Statement] stlist) {
	int len = 0 ;
	for (Statement st <- stlist) {
		len += linesOccupied(st @ src) ;
	} 
	return len ;
}
int findOccurances(list[str] fragment, list[str] alls) {
	int ocs = 0 ;
  	for ( [*_,*fragment,*_] := alls ) {
			ocs += 1;
	}
	ocs = size(KMPallMatches(alls,fragment)) ;
	return ocs ;
}
int findOccurancesV1(list[str] fragment, list[str] alls) {
	int ocs = 0 ;
	ocs = size(KMPallMatches(alls,fragment)) ;
	return ocs ;
}

bool debug = false ;

list[str] readAndStrip(loc doc) {
     str content = "" ;
            
     content = readFile(doc) ;
     
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
     for ( /<word:[\ \t]*>/ := content ) {
	 	content = replaceFirst(content,word," ") ;
	 }
     if (debug) 
	 	println("***** \n<content>\n*****" ) ;
     //return [ line  | line:/^.*\S.*$/ <- split("\n", content )];
     return [ line  | line <- split("\n", content )];
}



void doItVsave(set[Declaration] ASTSet, M3 M3Model) {
   list[str] allCode = [];
   list[str] all2Code = [];
   list[str] ripoff ;
   list[str] p ;
 
	int listCount = 0 ;
	int i = 1 ;
	for ( loc  fileLoc <- files(M3Model) ) {
	    list[str] fileContent ;
	    list[str] file2Content ;
		fileContent = readAndStrip(fileLoc) ;
		file2Content = readFileLines(fileLoc) ;
		allCode += fileContent ;
		all2Code += file2Content ;
	} 
	showSource(allCode) ;
	//debug = true ;
	if (debug ) {
		for ( str s <- allCode ) {
			iprintln(s) ;
		}
		for ( str s <- all2Code ) {
			iprintln(s) ;
		}
		//return ;
	}
	ripoff = allCode ;
	workingSet = allCode ;
	for ( str oneLine <- allCode ) {
	    print(".") ;
	  	ripoff = drop(1,ripoff) ;
	  	cutAgain = true ;
	  	while ( cutAgain ) {
	  		i = 5	 ;
		  	cutAgain = false ;
		  	print("-") ;
	  		if ( findOccurances([oneLine],workingSet) >= 2 ) { 
	  			print(";") ;
  	 			p = [oneLine] ;
  	 			while ( findOccurances(p,workingSet) >= 2 ) {
  	 				i+= 1 ;
  	 				if ( size(ripoff) > i ) {
  	 					p = [oneLine] + head(ripoff,i) ;
  	 				}
  	 				else break ;
  	 			}
  	 			if ( i-1 >= 6 )  {
  	 				print("x") ;
  	 				if ( debug == false ) print("\n__________ Original ______________\n") ;
  	 				if ( debug == false ) showSource(workingSet) ;
  	 				if ( debug == false ) print("\n-------Fragment--------- \n") ;
  	 				x = head(p,i);
  	 				if ([*L , x , *M , x , *R ] := workingSet)
						workingSet = L + x + M + R; 
  	 				if ( debug == false ) showSource(x) ;
  	 				if ( debug == false ) print("\n__________ result ______________\n") ;
  	 				if ( debug == false ) showSource(workingSet) ;
  	 				cutAgain = true ;
  	 			}
	  	  	}
	  	}
	  }
	  real allS = toReal(size(allCode)) ;
	  real WS = toReal(size(workingSet)) ;
	  
	  println("\nPercentage code duplication: <round(((allS - WS)/allS) * 100.0)>%") ;
	  println("e.g. <size(allCode) - size(workingSet)> lines duplicated." ) ;
	  return ;
}

void doItV2(set[Declaration] ASTSet, M3 M3Model) {
   list[str] allCode = [];
   list[str] ripoff ;
   list[str] p ;
 
	int listCount = 0 ;
	int i = 1 ;
	for ( loc  fileLoc <- files(M3Model) ) {
	    list[str] fileContent ;
		fileContent = readAndStrip(fileLoc) ;
		allCode += fileContent ;
	} 
	ripoff = allCode ;
	workingSet = allCode ;
	for ( str oneLine <- allCode ) {
	  	ripoff = drop(1,ripoff) ;
	  	cutAgain = true ;
	  	while ( cutAgain ) {
	  		i = 5	 ;
		  	cutAgain = false ;
	  		if ( findOccurances([oneLine],workingSet) >= 2 ) { 
  	 			p = [oneLine] ;
  	 			while ( findOccurances(p,workingSet) >= 2 ) {
  	 				i+= 1 ;
  	 				if ( size(ripoff) > i ) {
  	 					p = [oneLine] + head(ripoff,i) ;
  	 				}
  	 				else break ;
  	 			}
  	 			if ( i-1 >= 6 )  {
  	 				x = head(p,i);
  	 				if ([*L , x , *M , x , *R ] := workingSet)
						workingSet = L + x + M + R; 
  	 				cutAgain = true ;
  	 			}
	  	  	}
	  	}
	  }
	  real allS = toReal(size(allCode)) ;
	  real WS = toReal(size(workingSet)) ;
	  
	  println("\nPercentage code duplication: <round(((allS - WS)/allS) * 100.0)>%") ;
	  println("e.g. <size(allCode) - size(workingSet)> lines duplicated." ) ;
	  return ;
}

// Note to self in smallsql0 file TestOrderBy.java contains multiple clones.
void findDuplicatesV2(loc location) {
  set[Declaration] ASTSet = {} ;  
  M3  M3Model ;
  //ASTSet  = createAstsFromEclipseProject(|project://Simple1| ,true) ;
  M3Model = createM3FromEclipseProject(location) ;      
  doItV2(ASTSet,M3Model) ;    
}
