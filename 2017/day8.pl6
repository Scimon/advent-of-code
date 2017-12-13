use v6.c;

sub MAIN( $input ) {
    
    my %registers;
    my %tests = tests();
    my $max = 0;
    
    for $input.IO.lines -> $line {
        my $match = $line ~~ /
        ^ (\S+) ' ' (dec|inc) ' ' ('-'?\d+)
        ' if ' (\S+) ' ' ('<'|'>'|'=='|'>='|'<='|'!=') ' ' ('-'?\d+)
        /;
        say $match;
        %registers{$match[0].Str} //= 0;
        %registers{$match[3].Str} //= 0;
        if ( %tests{$match[4].Str}( %registers{$match[3].Str}, $match[5].Int ) ) {
            if ( $match[1].Str eq 'dec' ) {
                %registers{$match[0].Str} -=  $match[2].Int;
            } else {
                %registers{$match[0].Str} +=  $match[2].Int;
            }
        }
        $max = %registers.values.max > $max ?? %registers.values.max !! $max;
    }
    say %registers;
    say %registers.values.max;
    say $max;
}

sub tests {
    my %tests;
    %tests{'=='} = * == *;
    %tests{'!='} = * != *;
    %tests{'<'} = * < *;
    %tests{'<='} = * <= *;
    %tests{'>'} = * > *;
    %tests{'>='} = * >= *;
    return %tests;
}
