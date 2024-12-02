sub MAIN( $in ) {
    my @l = $in.IO.lines.map( { $_.split(" ") } );
    say [+] @l.map( -> @l { full_check(@l) } );

}

sub full_check(@list) {
    return 1 if check(@list);
    for @list.combinations(@list.elems-1) -> @check {
        return 1 if check(@check);
    }
    return 0;
}

sub check( @list ) {
    my @c = @list.rotor(2 => -1).map( -> ($a,$b) {$a-$b} );
    return so all( one( 0 < all(@c) < 4, -4 < all(@c) < 0 ) );
}
