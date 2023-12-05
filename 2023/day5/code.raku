#!/usr/bin/env raku

multi sub MAIN('p1', $file) {

    my @values;
    my @n-values;
    for $file.IO.lines -> $row {
        given ($row) {
            when /^ 'seeds: ' (.+) $/ {
                @values = ($_ ~~ /^ 'seeds: ' (.+) $/)[0].split(' ').map(*.Int);
                @n-values = @values.map({0}).Array;
            }
            when /^ (\d+) ** 3 % ' ' $/ {
                my ( $d-start, $s-start, $len ) = $_.split(' ').map(*.Int);
                for ^(@values.elems) -> $i {
                    my $v = @values[$i];
                    if $v (elem) $s-start..^($s-start+$len) {
                        @n-values[$i] = $d-start + ( $v - $s-start );
                    }
                }
            }
            when / 'map:' / {
                for ^(@values.elems) -> $i {
                    @values[$i] = @n-values[$i] || @values[$i];
                    @n-values[$i] = 0;
                }             
            }
        }
    }

    for ^(@values.elems) -> $i {
        @values[$i] = @n-values[$i] || @values[$i];
    }
    @values.min.say;
}

multi sub MAIN('p2', $file) {

    my @values;
    my @n-values;
    for $file.IO.lines -> $row {
        given ($row) {
            when /^ 'seeds: ' (.+) $/ {
                @values = ($_ ~~ /^ 'seeds: ' (.+) $/)[0].split(' ')
                                                      .map(*.Int).rotor(2)
                .map( -> ($s, $l) { ($s..($s+$l-1)) } );
                @n-values = [];
                say @values, ":", @n-values;
            }
            when /^ (\d+) ** 3 % ' ' $/ {
                my ( $d-start, $s-start, $len ) = $_.split(' ').map(*.Int);
                my $s-range = ($s-start..($s-start+$len-1));
                @values = @values.map(
                    -> $v {
                        if $v.min <= $s-range.max && $s-range.min <= $v.max {
                            my $int-start = ($v.min <= $s-range.min ?? $s-range.min !! $v.min);
                            my $int-end = $v.min <= $s-range.min
                                                     ?? $v.max
                                                     !! (
                                $v.max >= $s-range.max
                                           ?? $s-range.max
                                           !! $v.max;
                            ) ;
                            my $int = ($int-start..$int-end);
                            my $int-mapped = $int + ($d-start - $s-start);
                            say "{$v.gist} : {$s-range.gist} : $d-start : {$int.gist} => {$int-mapped.gist}";

                            @n-values.push( $int-mapped );
                            my @out;
                            if ( $v.min < $s-range.min ) {
                                @out.push( $v.min..$s-range.min ); 
                            }
                            if ( $v.max > $s-range.max ) {
                                @out.push( $s-range.max..$v.max );
                            }
                            say @out;
                            |@out.grep(*.elems).List;
                        } else {
                            $v;
                        }
                    });
                say @values, " & ", @n-values;
            }
            when / 'map:' / {
                $_.say;
                @values = (|@values, |@n-values);
                @n-values = [];
                @values.say;
            }
            default { $_.say }
        }
    }

    @values = (|@values, |@n-values);
    say @values;
    @values.map( { $_[0] } ).min.say;
}

