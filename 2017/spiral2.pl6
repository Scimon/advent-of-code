use v6.c;

sub MAIN( $target ) {

    my @directions = lazy gather { loop { take (1,0);take(0,1);take(-1,0);take(0,-1) } };
    my @count = 1,1,{$^a == $^b ?? $^a+1 !! $^b}...*;
    
    my %cells = ( "0,0" => 1 );
    my $x = 0;
    my $y = 0;
    my $i = 0;
    
    LOOP: while True {
        my @range = @directions[$i] xx @count[$i];
        for @range -> ( $dx, $dy ) {
            $x += $dx;
            $y += $dy;
            %cells{"$x,$y"} = [+] ( (-1..1) X (-1..1) ).grep( -> ($dx,$dy) { ! ($dx == $dy == 0) } ).map( -> ($dx,$dy) { 0 + %cells{"{$x+$dx},{$y+$dy}"} with %cells{"{$x+$dx},{$y+$dy}"} } ).grep( * );
            if ( %cells{"$x,$y"} > $target ) {
                say %cells{"$x,$y"};
                last LOOP;
            }
        }
        $i++;
    }
}


