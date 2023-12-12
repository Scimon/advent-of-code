#!/usr/bin/env raku

multi sub MAIN('test') {
    use Test;
    is next-value(0,3,6,9,12,15), 18;
    is next-value(1,3,6,10,15,21), 28;
    is next-value(10,13,16,21,30,45), 68;
    is diffs(0,3,6,9,12,15), (3,3,3,3,3);
    is diffs(3,3,3,3,3), (0,0,0,0);
    is next-value(0,0), 0;
    done-testing;
}

sub diffs( *@v ) {
    @v.rotor(2 => -1).map( -> ($a, $b) { $b - $a } );
}

multi sub next-value ( *@v where all(@v) == 0 ) { 0 }
multi sub next-value ( *@v ) {
    @v[*-1] + next-value( diffs( @v ) );
}

multi sub prev-value ( *@v where all(@v) == 0 ) { 0 }
multi sub prev-value ( *@v ) {
    @v[0] - prev-value( diffs( @v ) );
}

multi sub MAIN('p1', $file ) {
    say [+] $file.IO.lines.map(
        -> $l {
            next-value($l.split(" "))
        });
}

multi sub MAIN('p2', $file ) {
    say [+] $file.IO.lines.map(
        -> $l {
            prev-value($l.split(" "))
        });
}
