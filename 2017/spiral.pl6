use v6.c;

multi sub generator($x,0) { 1 }
multi sub generator($x,$i) { generator($x,$i-1) + 8*($i-1) + $x }

sub MAIN( $target ) {
    
    my &l = &generator.assuming(1);
    my &u = &generator.assuming(3);
    my &r = &generator.assuming(5);
    my &d = &generator.assuming(7);

    my $found = False;
    my $idx = 0;

    
    LOOP: while True {
        for ( &l, &u, &r, &d ) -> &func {
            my $s = &func($idx);
            if ( $s <= $target <= $s+$idx ) {
                say $idx + ( $target - $s );
                last LOOP;
            }
        }
        $idx++;
        last LOOP if $idx > 1000;
    }
}
