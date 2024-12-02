sub MAIN( $in ) {
    my (@a,@b);
    for $in.IO.lines -> $l {
        my @l = $l.split("   ");
        @a.push(@l[0]);
        @b.push(@l[1])
    };
    my $counts = Bag(@b);
    say [+] @a.map( { $_ * $counts{$_} } );
}
