module KMP
import IO ;
import List;

// Knuth, Donald; Morris, James H., jr; Pratt, Vaughan (1977). "Fast pattern matching in strings". 
// SIAM Journal on Computing 6 (2): 323–350. doi:10.1137/0206024. Zbl 0372.68005.

// Sometimes Rascal needs a lot of code B^}

list[int] prefixTable(list[str] P) {
  int pos = 2, m = 0;
  list[int] T = [] ;
  for ( str d <- P ) T = T + 0 ;
 
  T[0] = -1 ; 

  while (pos < size(P)) {
    if (P[pos - 1] == P[m]) {
      m += 1; 
      T[pos] = m;
      pos += 1 ;
    } 
    else {
      if ( 0 < T[m]) {
       m = T[m];
      } 
      else {
        pos+= 1; 
      }
    }
  }
  return T ;
}

list[int] KMPallMatches(list[str] haystack, list[str] needle) {
  int t = 0, p = 0;
  list[int] resultSet = [] ;
  
  if (size(haystack) < size(needle)) {
    return resultSet;
  }

  list[int] S = prefixTable(needle);  
  
  while ((p + t) < size(haystack)) {
    if (haystack[t + p] != needle[p]) {
      t = t + p - S[p];
      p = -1 < S[p] ? S[p] : 0;
    } 
    else {
    	if ((p) == (size(needle) - 1)) {
      		resultSet += t;
      		// Beware the next line is a mod reduces the resultset to 2 elements.
      		if ( size(resultSet) == 2 ) return resultSet ;
      		t += 1;
      		p = 0;
    	} 
    	else p += 1;
    }
  }
  return resultSet;
}
void testKMP() {
    n = [ "aap" , "noot" , "mies", "aap" , "noot" , "mies", "wim" , "sus" , "jet" , "jet" , "teun" , "gijs" , "boer"  ] ;
    s = ["mies"] ;
	println ("<KMPallMatches(n, s)> == [2,5]") ;  
    s = ["cies"] ;
	println ("<KMPallMatches(n, s)> == []") ;  
    s = ["noot" , "mies", "wim"] ;
	println ("<KMPallMatches(n, s)> == [4]") ;  
    s = ["aap"] ;
	println ("<KMPallMatches(n, s)> == [0,3]") ;  
    s = ["noot" , "mies", "aap" , "noot" , "mies", "wim" , "sus" , "jet" , "jet" , "teun" , "gijs"] ;
	println ("<KMPallMatches(n, s)> == [1]") ;  
    s = ["boer"] ;
	println ("<KMPallMatches(n, s)> == [12]") ;  
    s = ["gijs","boer"] ;
	println ("<KMPallMatches(n, s)> == [11]") ;  
}





