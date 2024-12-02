sub MAIN( $in ) {
    my (@a,@b);
    for $in.IO.lines -> $l {
        my @l = $l.split("   ");
        @a.push(@l[0]);
        @b.push(@l[1])
    };
    say [+] (@a.sort Z- @b.sort).map( { abs($_) } )
}
