
public class Main {

	public static void main(String[] args) {
		/*******************************************************************************
		 * Copyright (c) 2009-2013 CWI
		 * All rights reserved. This program and the accompanying materials
		 * are made available under the terms of the Eclipse Public License v1.0
		 * which accompanies this distribution, and is available at
		 * http://www.eclipse.org/legal/epl-v10.html
		 *

		*******************************************************************************/

		int doo = 10 ;
		
		String killThemBegin = " /*   " ;
		String killThemEnd   = " */   " ;
		String killLineComment = " // " ;
		
		
		// should count one
		if ( doo == 10 ) {
			System.out.println("do == 10");
		}
		
		else { /* test remove me*/ doo = 10 ;
			System.out.println("do == 10");			
		}
		
	}
//	public int printIt(String message) {
//		int tada = 10 ;/
//		
//		switch (tada) {
//		case 1: 		System.out.println(message);
//		case 2: 		System.out.println(message);
//		case 3: 		System.out.println(message);
//		case 4: 		System.out.println(message);
//		case 5: 		System.out.println(message);
//		}
//		if ( true == false  ) {
//			System.out.println("Nice feature");
//		}
//		else {
//			System.out.println("Well done");
//		}
//		System.out.println(message);
//		// Count me
//		//
//		return 1 ;
//	}
}
