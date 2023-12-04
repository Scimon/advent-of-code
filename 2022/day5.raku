#!/usr/bin/env raku

constant TEST-FILE = './day5-test';

#| Testing
multi sub MAIN( 'TEST' ) {
    use Test;
    my ( $crates, $rules ) = parse-file( TEST-FILE );
    is-deeply $crates, [[],['N','Z'],['D','C','M'],['P']], 'Parsed crates correctly';
    is-deeply $rules, [[1,2,1],[3,1,3],[2,2,1],[1,1,2]], 'Parse rules correctly';
    my $new-crates = apply-rules( $crates, $rules );
    is-deeply $new-crates, [[],['C'],['M'],['Z','N','D','P']], 'Rules OK';
    is part-one-message( $new-crates ), 'CMZ', 'Got correct message';

    ( $crates, $rules ) = parse-file( TEST-FILE );
    $new-crates = apply-rules-two( $crates, $rules );
    is-deeply $new-crates, [[],['M'],['C'],['D','N','Z','P']], 'Rules OK';
    done-testing;
}


#| Part 1
multi sub MAIN( 1, $file = TEST-FILE ) {
    my ( $crates, $rules ) = parse-file( $file );
    my $new-crates = apply-rules( $crates, $rules );
    say part-one-message( $new-crates );
}

multi sub MAIN( 2, $file = TEST-FILE ) {
    my ( $crates, $rules ) = parse-file( $file );
    my $new-crates = apply-rules-two( $crates, $rules );
    say part-one-message( $new-crates );
}


sub parse-file( $path ) {
    my @parts = $path.IO.slurp.split("\n\n");

    my @crates = [[],];
    my @c-parse = @parts[0].lines;

    @c-parse.pop;

    for @c-parse.reverse -> $line {
        my @vals = $line.comb().rotor(3=>1).map(*[1]);
        my $idx = 1;
        for @vals -> $v {
            if ( $v ne ' ' ) {
                @crates[$idx].unshift($v);
            }
            $idx++;
        }
    }

    my @rules = @parts[1].lines.map( {
       $_ ~~ m/"move "(\d+)" from "(\d+)" to "(\d+)/;
       [$0.Int,$1.Int,$2.Int]
    } );
    
    return @crates, @rules;
}

sub apply-rules ( $crates is copy, $rules ) {
    for @$rules -> [ $num, $from, $to ] {
        for ^$num {
            $crates[$to].unshift($crates[$from].shift);
        }
    }
    return $crates;
}

sub apply-rules-two ( $crates is copy, $rules ) {
    for @$rules -> [ $num, $from, $to ] {
        $crates[$to].unshift(|$crates[$from].splice(0,$num));
    }
    return $crates;
}


sub part-one-message( $crates ) {
    $crates.grep(*.elems).map(*[0]).join("");
}
