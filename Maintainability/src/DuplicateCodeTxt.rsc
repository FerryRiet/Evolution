module DuplicateCodeTxt

import IO;
import String;
import List;
import Set;

import analysis::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

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
//	iprintln(fragment) ;
//	for ( [*_,*fragment,*_] := alls ) {
//			ocs += 1;
//	}
	ocs = size(KMPallMatches(alls,fragment)) ;
	return ocs ;
}

bool debug = false ;

void doItV2(set[Declaration] ASTSet, M3 M3Model) {
   list[str] allCode = [];
   list[str] ripoff ;
   list[str] p ;
 
	int listCount = 0 ;
	int i = 1 ;
	for ( loc  fileLoc <- files(M3Model) ) {
	    list[str] fileContent ;
		if (debug) 
			println(fileLoc) ;
			
		fileContent = readFileLines(fileLoc) ;
		
		if (debug) 
			iprintln(fileContent) ;
		
		allCode += fileContent ;
		println(i) ; i +=1 ;
	} 
	//debug = true ;
	if (debug) 
		iprint(allCode) ;
	ripoff = allCode ;
	workingSet = allCode ;
	int live = 0 ;
	for ( str oneLine <- allCode ) {
	    live = live + 1;
	    print(".") ;
	  	ripoff = drop(1,ripoff) ;
	  	cutAgain = true ;
	  	while ( cutAgain ) {
	  		i = 1 ;
		  	cutAgain = false ;
		  	print("-") ;
	  		if ( oneLine in (workingSet - [oneLine]) ) { 
	  		    print(";") ;
	  	 		p = [oneLine] ;
	  	 		while ( findOccurances(p,workingSet) >= 2 ) {
	  	 			i+= 1 ;
	  	 			if ( size(ripoff) > i ) {
	  	 				p = [oneLine] + head(ripoff,i) ;
	  	 			}
	  	 			else break ;
	  	 		}
	  	 		if ( size(head(p,i-1)) >= 6 )  {
	  	 			if ( debug ) print("Duplicates :") ;
	  	 			if ( debug ) showSource(workingSet) ;
	  	 			x = head(p,i);
	  	 			if ([*L , x , *M , x , *R ] := workingSet)
						workingSet = L + x + M + R; 
	  	 			if ( debug == false ) showSource(head(p,i)) ;
	  	 			if ( debug ) showSource(workingSet) ;
	  	 			cutAgain = true ;
	  	 		}			
	  	  	}
	  	}
	  }
	  println(size(allCode) - size(workingSet) ) ;
	  return ;
}

// Note to self in smallsql0 file TestOrderBy.java contains multiple clones.
void findDuplicatesV2() {
  set[Declaration] ASTSet = {} ;  
  M3  M3Model ;
  //ASTSet  = createAstsFromEclipseProject(|project://Simple1| ,true) ;
  M3Model = createM3FromEclipseProject(|project://smallsql0.21_src|) ;      
  doItV2(ASTSet,M3Model) ;    
}
