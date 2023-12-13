#!/usr/bin/env raku

multi sub MAIN('test') {
    use Test;
    my @pattern = <#...##..# 
                   #....#..#
                   ..##..###
                   #####.##.
                   #####.##.
                   ..##..###
                   #....#..#
                   >;
    is reflection-after(@pattern), 4, 'Example pattern reflection found';
    is smudged-reflection-after(@pattern), 1, 'Example pattern with smudge reflection at 3';
    is score-p1(@pattern), 400;
    @pattern = <#.##..##.
                ..#.##.#.
                ##......#
                ##......#
                ..#.##.#.
                ..##..##.
                #.#.##.#.
                >;
    is reflection-after(@pattern), Nil, 'Example pattern has no horizontal reflection';
    is smudged-reflection-after(@pattern), 3, 'Example pattern with smudge reflection at 1';
    is rotation(@pattern), <
    #.##..#
    ..##...
    ##..###
    #....#.
    .#..#.#
    .#..#.#
    #....#.
    ##..###
    ..##...
                           >;
    is reflection-after(rotation(@pattern)), 5, 'Rotated reflection found';
    is score-p1(@pattern), 5;

    is compare-diffs('...','...'),0;
    is compare-diffs('.#.','...'),1;
    is compare-diffs('...','##.'),2;
    
    done-testing;
}

multi sub MAIN($type, $file ) {
    my @acc;
    my $score;
    my &scorer = $type ~~ 'p1' ?? &score-p1 !! &score-p2; 

    for $file.IO.lines -> $line {
        if ( ! $line ) {
            say @acc.join("\n");
            say &scorer(@acc);
            $score += &scorer(@acc);
            @acc = [];
            next;
        }
        @acc.push($line);
    }
    say @acc.join("\n");
    say &scorer(@acc);
    $score += &scorer(@acc) if @acc;
    say $score;
}

sub compare-diffs(Str $first, Str $second) {
    [+] ( $first.comb Z!~~ $second.comb ).map(+*);
}

sub score-p1(@p) {
    my $r = reflection-after(@p);
    return 100 * $r if $r;
    return reflection-after(rotation(@p));
}

sub score-p2(@p) {
    my $r = smudged-reflection-after(@p);
    return 100 * $r if $r;
    return smudged-reflection-after(rotation(@p));
}

sub rotation(@p) {
    my @tmp = @p.map(*.comb);
    my @out;
    my $max = @tmp[0].elems;
    for ((0..^$max)) -> $idx {
        @out.push( @tmp.map(*[$idx]).join('') );
    }
    @out.list;
}

sub reflection-after(@p) {
    my $rows = @p.elems;
    for (1..^$rows) -> $row {
        my $len = $row > $rows/2 ?? $rows-$row !! $row;
        my @above = @p[(($row-$len)..^$row)].reverse;
        my @below = @p[($row..^($row+$len))];
        return $row if @above eqv @below;
    }
    return Nil;
}

sub smudged-reflection-after(@p) {
    my $rows = @p.elems;
    for (1..^$rows) -> $row {
        my $len = $row > $rows/2 ?? $rows-$row !! $row;
        my @above = @p[(($row-$len)..^$row)].reverse;
        my @below = @p[($row..^($row+$len))];
        return $row if ([+] (@above Z, @below).map( -> ($a,$b) { compare-diffs($a,$b) })) ~~ 1;
    }
    return Nil;
}
