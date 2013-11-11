module DuplicateCode

import IO;
import String;
import List;
import Set;

import analysis::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

list[Statement] splatIt(Declaration ast) {
	list[Statement] splat = [ e | /Statement e <- ast ] ;
	return splat ;
}
void showModelList(M3 M3Model, list[Statement] stmntList) {
	for ( Statement h <- stmntList) {
		Show(M3Model,h @src) ;
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
int findOccurances(list[Statement] fragment, list[Statement] alls) {
	int ocs = 0 ;
	iprintln(fragment) ;
	for ( [*_,*fragment,*_] := alls ) {
			ocs += 1;
	}
	return ocs ;
}
void doItV2(set[Declaration] ASTSet, M3 M3Model) {
   list[Statement] statiis ;
   list[Statement] ripoff ;
   list[Statement] p ;
 
   int listCount = 0 ;
   int i = 1 ;

   for ( Declaration d <- ASTSet ) {
      statiis = splatIt(d)  ;
      ripoff  = statiis ;

	  for ( Statement h <- statiis ) {
	  	 ripoff = drop(1,ripoff) ;
	  	 i = 1 ;
	  	 if ( h in (statiis - [h]) ) { 
	  	 		//println(findOccurances([h],statiis)) ;
	  	 		//Show(M3Model,h @src) ;
	  	 		//p = [h] + head(ripoff,i) ;
	  	 		
	  	 		//println(findOccurances(p,statiis)) ;
	  	 		//showModelList(M3Model,p) ;
	  	 		p = [h] ;
	  	 		while ( findOccurances(p,statiis) >= 2 ) {
	  	 			i+= 1 ;
	  	 			if ( size(ripoff) > i ) {
	  	 				p = [h] + head(ripoff,i) ;
	  	 			}
	  	 			else break ;
	  	 		}
	  	 		print("Duplicates :") ;
	  	 		showModelList(M3Model,head(p,i-1)) ;
	  	  }
	  }
	  return ;
   } 
   
}

void doIt(set[Declaration] ASTSet, M3 M3Model) {
   list[value] statiis ;
   list[value] ripoff ;
   
   int i = 0 ;
   for ( Declaration d <- ASTSet ) {
   		statiis = splatIt(d)  ;
          for ( Statement s <- statiis ) {
          	li = statiis - s ;
          	if ( linesOccupied(s @ src) >= 6 && s in li ) {
          		print(linesOccupied(s @ src) );
          		print(" lines duplicate :") ;
          		println(s) ;
          		Show(M3Model,s @ src) ;
          	}
          }	
          return ;
   } 
}

void findDuplicates() {
  set[Declaration] ASTSet = {} ;  
  M3  M3Model ;
  ASTSet  = createAstsFromEclipseProject(|project://Simple1| ,true) ;
  M3Model = createM3FromEclipseProject(|project://Simple1|) ;      
  doItV2(ASTSet,M3Model) ;    
}

int testIt() {
	list[int] m = [1,2,3,4,5,6,3,4,9] ;
	list[int] s = [4,9] ;
	
	// p = [*L] + s ;
	for( [*_,*s,*_]  := m) {
		println("match" ) ;
	}
	return 1 ;
}
	
