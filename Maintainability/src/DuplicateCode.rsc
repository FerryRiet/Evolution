module DuplicateCode

import IO;
import String;
import List;
import Set;

import analysis::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

list[value] splatIt(Declaration ast) {
	int i = 0 ;
	list[value] splat = [ e | /Statement e <- ast ] ;
	return splat ;
}
void Show(M3 M3Model,loc cu) {
		 cu.begin.column = 0 ;	
	     content = readFile(cu) ;
	     println(content) ;
}
int linesOccupied(loc s) {
	int len = 0 ;
	len = s.end.line - s.begin.line ;
	if ( len == 0 ) return 1 ;
	return len;
}
int lineListOccupied(list[Statement] stlist) {
	int len = 0 ;
	for (Statement st <- stlist) {
		len += linesOccupied(st @ src) ;
	} 
	return len ;
}

void doIt(set[Declaration] ASTSet, M3 M3Model) {
   list[value] statiis ;
   list[value] ripoff ;
   
   int i = 0 ;
   for ( Declaration d <- ASTSet ) {
   		statiis = splatIt(d)  ;
   		ripoff  = statiis ;
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
  doIt(ASTSet,M3Model) ;    
}