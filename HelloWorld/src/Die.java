import java.util.Random ;

public class Die {
	private int rolled ;
	private Random rand = new Random() ;
	public Die() {
		rolled = 6 ;
	}
	public int roll() {
		rolled = rand.nextInt(6) + 1 ;
		return rolled ;
	}

}
