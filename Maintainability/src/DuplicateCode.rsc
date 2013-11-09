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
	//list[value] meth  = [ e | /Declaration  e <- ast , e == method(_,_,_) ] ;
	list[value] splat = [ e | /Statement    e <- ast ] ;
	return splat ;
}
void Show(M3 M3Model,loc cu) {
		 cu.begin.column = 0 ;	
	     content = readFile(cu) ;
	     println(content) ;
}

void doIt(set[Declaration] ASTSet, M3 M3Model) {
                 list[value] statiis ;
                 int i = 0 ;
                 for ( Declaration d <- ASTSet ) {
                 		statiis = splatIt(d)  ;
                        for ( Statement s <- statiis ) {
                        	delme = indexOf(statiis,s) ;
                        	li = delete(statiis,delme) ;
                        	if ( s in li  ) {
                        		print("Duplicate :") ;
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