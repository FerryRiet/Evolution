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

void doItV2(set[Declaration] ASTSet, M3 M3Model) {
   list[Statement] statiis ;
   list[Statement] ripoff ;
   list[Statement] p ;
   Statement h ;
   int listCount = 0 ;
   int i = 1 ;
   for ( Declaration d <- ASTSet ) {
      statiis = splatIt(d)  ;
      ripoff  = statiis ;

	  for ( Statement h <- statiis ) {
	  	 //p = head(ripoff) ;
	  	 //println(p @ src) ;
	  	 
	  	 ripoff = drop(1,ripoff) ;
	  	 //println(h) ;
	  	 //println(h @ src) ;
	  	 i = 1 ;
	  	 if ( h in (statiis - [h]) ) { 
	  	 		println("first match") ;
	  	 		println(h) ;
	  	 		println(head(ripoff,i)) ;
	  	 		
	  	 		p = [h] + head(ripoff,i) ;
	  	 		println(p) ;
	  	 		println(statiis) ;
	  	 		dod = p := statiis ;
	  	 		println(dod) ;
	  	 		dod = p[0] == statiis[0] ;
	  	 		println(dod) ;
	  	 		dod = p[1] == statiis[1] ;
	  	 		println(dod) ;
	  	 		while ( p := statiis  ) {
	  	 			println("Am i here (nope)") ;
	  	 			i+= 1 ;
	  	 			p = [h] + head(ripoff,i) ;
	  	 		}
	  	 		return ;
	  	 		//println([h] + [head(ripoff,i-1)]) ;
	  	 		
          		//print(linesOccupied(h @ src) );
          		//print(" lines duplicate :") ;
          		//println(h) ;
          		//Show(M3Model,h @ src) ;
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
          	if ( linesOccupied(s @ src) > 6 && s in li ) {
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