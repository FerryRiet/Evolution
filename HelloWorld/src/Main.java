
public class Main {

	public static void main(String[] args) {
		/*
		 * 
		 */
		int doo = 10 ;
		// should count one
		if ( doo == 10 ) {
			System.out.println("do == 10");
		}
		else {
			System.out.println("do == 10");			
		}
		new Main().printIt("Hello world!\n");
	}
	public int printIt(String message) {
		int tada = 10 ;
		
		switch (tada) {
		case 1: 		System.out.println(message);
		case 2: 		System.out.println(message);
		case 3: 		System.out.println(message);
		case 4: 		System.out.println(message);
		case 5: 		System.out.println(message);
		}
		if ( true == false  ) {
			System.out.println("Nice feature");
		}
		else {
			System.out.println("Well done");
		}
		System.out.println(message);
		// Count me
		//
		return 1 ;
	}
}
