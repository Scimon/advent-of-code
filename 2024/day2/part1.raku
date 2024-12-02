sub MAIN( $in ) {
    my @l = $in.IO.lines.map( { $_.split(" ") } );
    say [+] @l.map( { $_.rotor(2 => -1).map( -> ($a,$b) {$a-$b} ) } )
    .map( { + so all( one( 0 < all($_) < 4, -4 < all($_) < 0 ) ) } );
    }
