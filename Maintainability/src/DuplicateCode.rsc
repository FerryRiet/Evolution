module DuplicateCode

import IO;
import String;
import List;
import Set;

import analysis::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

void DoIt(set[Declaration] ASTSet, M3 M3Model) {
		 list[Statement] statiis ;

		 for ( Declaration d <- ASTSet ) {
		 	println(d) ;
		 } 
}

void findDuplicates() {
		set[Declaration] ASTSet = {} ; 	
		M3  M3Model ;
	
	    ASTSet  = createAstsFromEclipseProject(|project://HelloWorld| , true) ;
	    M3Model = createM3FromEclipseProject(|project://HelloWorld|) ;	
	    DoIt(ASTSet,M3Model) ;    
}