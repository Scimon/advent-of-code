#!/usr/bin/env raku

multi sub MAIN( 1, $file ) {
    say [+] $file.IO.lines.map( -> $l { (first-digit($l) * 10) + last-digit($l) } );
}

multi sub MAIN( 2, $file ) {
    say [+] $file.IO.lines.map( -> $l { (first-digit-str($l) * 10) + last-digit-str($l) } ).map( -> $s { $s.say; $s } );
}



sub first-digit( $string ) {
    $string.comb.first( /\d/ );
}
sub last-digit( $string ) {
    $string.comb.reverse.first( /\d/ );
}

my %map = ( 'one' => 1, 'two' => 2, 'three' => 3,
            'four' => 4, 'five' => 5, 'six' => 6,
            'seven' => 7, 'eight' => 8, 'nine' => 9,
            '1' => 1, '2' => 2, '3' => 3, '4' => 4,
            '5' => 5, '6' => 6, '7' => 7, '8' => 8,
          '9' => 9 );

my $digit-match = / \d || 'one' || 'two' ||
                      'three' || 'four' || 'five' ||
                      'six' || 'seven' || 'eight' ||
                      'nine' /;

sub last-digit-str($string) {
    %map{$string.match( /^ .* ( $digit-match ) / )[0]};
}

sub first-digit-str($string) {
    %map{$string.match( / ( $digit-match ) .* $/ )[0]};
}

sub digit-string( @list ) {
    %map{@list.first( / \d || 'one' || 'two' ||
                      'three' || 'four' || 'five' ||
                      'six' || 'seven' || 'eight' ||
                      'nine' / )};
}
