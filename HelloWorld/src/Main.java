
public class Main {

	public static void main(String[] args) {
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
		
		System.out.println(message);
		// Count me
		//
		return 1 ;
	}

}
