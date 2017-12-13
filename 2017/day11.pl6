use v6.c;

my ( $x,$y ) = (0,0);

my $max = 0;
my $max-pos;

for $*IN.slurp.chomp.split(',') -> $dir {
    ( $x, $y ) = take-step( $dir, $x, $y );
    if ( dist( $x, $y ) >= $max ) {
        $max-pos = ($x+0,$y+0);
        $max = dist( $x, $y );
    }
}
say ( $x, $y );
say $max-pos;
say $max;
( $x, $y ) = $max-pos;

my $steps = 0;

while dist( $x, $y ) != 0 {
    ($x,$y) = take-step(
        ( <n s ne se nw sw>
          .map( { $_ => dist( |take-step( $_, $x, $y ) ) } )
          .sort( { $^a.value <=> $^b.value } ) ).map( *.key )[0], $x, $y );  
    $steps++;
}

say $steps;

sub dist( $x, $y ) {
    return sqrt( ( $x * $x ) + ( $y * $y ) ); 
}

sub take-step ( $dir, $x is copy, $y is copy ) {
    my %dirs = (
        n => (-1,0),
        s => (1,0),
        ne => (0,-1),
        se => (1,-1),
        nw => (-1,1),
        sw => (0,1)
    );
    
    my ( $dx, $dy ) = %dirs{$dir};
    $x+=$dx;
    $y+=$dy;
    return ( $x, $y );
}


