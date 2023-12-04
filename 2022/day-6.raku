#!/usr/bin/env raku

multi sub MAIN('TEST') {
    use Test;
    is start-point( 'mjqjpqmgbljsphdztnvjfqwrcgsmlb' ), 7;
    is start-point( 'bvwbjplbgvbhsrlpgdmjqwftvncz' ), 5;
    is start-point( 'nppdvjthqldpwncqszvftbrmjlhg' ), 6;
    is start-point( 'nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg' ), 10;
    is start-point( 'zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw' ), 11;
    is start-message( 'mjqjpqmgbljsphdztnvjfqwrcgsmlb' ), 19;
    is start-message( 'bvwbjplbgvbhsrlpgdmjqwftvncz' ), 23;
    is start-message( 'nppdvjthqldpwncqszvftbrmjlhg' ), 23;
    is start-message( 'nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg' ), 29;
    is start-message( 'zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw' ), 26;
    done-testing;
}

multi sub MAIN( 1, $f ) {
    start-point( $f.IO.slurp ).say;
}

multi sub MAIN( 2, $f ) {
    start-message( $f.IO.slurp ).say;
}

sub find-unique( $data, $length ) {
    my $idx = $length;
    for $data.comb.rotor( $length => 1-$length ) -> @set {
        return $idx if set(@set).keys == $length;
        $idx++;
    }
}

sub start-point( $data ) {
    return find-unique( $data, 4 );
}

sub start-message( $data ) {
    return find-unique( $data, 14 );
}
