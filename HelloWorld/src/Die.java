import java.util.Random ;
// These lines don't count
/*
 * 
 * 
 * 
 */
// I hope..
public class Die {
	private int rolled ;
	private Random rand = new Random() ;
	public Die() {
		// Roll the dice with 
		// the most reliable random number equals 6
		rolled = 6 ;
	}
	public int roll() {
	    // One line with a comment and two empty lines.
		
		rolled = rand.nextInt(6) + 1 ;
		return rolled ;
	}
}
