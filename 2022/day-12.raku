#!/usr/bin/env raku

constant ALPHA = ('a'..'z').join('');

multi sub MAIN('TEST') {
    use Test;
    my ($grid, $start, $end) = read-grid( "day-12-test.txt" );
    is-deeply $start, [0,0];
    is-deeply $end, [5,2];
    is $grid[0][0], 'a';
    is $grid[2][5], 'z';
    ok valid-move($grid,$start,[1,0]);
    ok ! valid-move($grid,$start,[-1,0]); 
    ok valid-move($grid,$start,[0,1]);
    ok ! valid-move($grid,$start,[0,-1]); 
    ok valid-move($grid,[3,2],[-1,0]);
    ok ! valid-move($grid,[3,2],[1,0]);
    ok valid-move($grid,[3,2],[0,-1]);
    ok valid-move($grid,[3,2],[0,1]);
    is dist($start, $end), 7;
    my @route = a-star($grid,$start,$end);
    is @route.elems, 32;
    done-testing;
}

multi sub MAIN(1,$f) {
    my ($grid, $start, $end) = read-grid( $f );
    my @route = a-star($grid,$start,$end);
    say @route.elems - 1;
}

multi sub MAIN(2,$f) {
    my ($grid, $start, $end) = read-grid( $f );
    my @starts = find-starts($grid);
    my @routes = @starts.map( {a-star($grid, $_, $end)} ); 
    say @routes.grep( *.elems ).sort( { $^a.elems <=> $^b.elems } )[0].elems - 1;    
}

sub find-starts($grid) {
    my @start = [];
    my $y = 0;
    for @($grid) -> @row {
        my $x = 0;
        for @row -> $cell {
            @start.push( [$x,$y] ) if $cell ~~ 'a';
            $x++;
        }
        $y++;
    }
    return @start;
}

sub dist($start, $end) {
    abs($start[0]-$end[0]) + abs($start[1]-$end[1]);
}

sub key($pos) {
    "{$pos.[0]}x{$pos.[1]}";
}

sub make-path(%routes,$current is copy) {
    my @path = [$current];
    while %routes{key($current)}:exists {
        $current = %routes{key($current)};
        @path.unshift($current);
    }
    return @path;
}

sub a-star($grid, $start, $end) {
    my &h = &dist.assuming(*,$end);
    
    my @moves = [$start];

    my %seen;

    my %g-score;
    %g-score{key($start)} = 0;

    my %f-score;
    %f-score{key($start)} = h($start);
    
    while @moves {
        @moves = @moves.sort( {
           (%f-score{key($^a)}//Inf) <=> (%f-score{key($^b)}//Inf)
        } ).Array;
        my $current = @moves.shift;
        if ( key($current) ~~ key($end) ) { return make-path(%seen,$current) }
        for ([0,1],[0,-1],[1,0],[-1,0]) -> $move {
            next unless valid-move($grid, $current, $move);
            my $neighbour = [ $current[0] + $move[0], $current[1] + $move[1] ];

            my $t-score = (%g-score{key($current)}//Inf) + 1;
            if $t-score < (%g-score{key($neighbour)} // Inf) {
                %seen{key($neighbour)} = $current;
                %g-score{key($neighbour)} = $t-score;
                %f-score{key($neighbour)} = $t-score + h($neighbour);
                if ! @moves.grep( { key($_) eq key($neighbour) } ) {
                    @moves.push($neighbour);
                }
            }
        }
    }

    return [];
}

sub valid-move( $grid, $pos, $move ) {
    return False if $pos[0] + $move[0] < 0;
    return False if $pos[0] + $move[0] > $grid[0].elems-1;
    return False if $pos[1] + $move[1] < 0;
    return False if $pos[1] + $move[1] > $grid.elems-1;
    my $cur = ALPHA.index($grid[$pos[1]][$pos[0]]);
    my $mov = ALPHA.index($grid[$pos[1]+$move[1]][$pos[0]+$move[0]]);
    return True if $mov < $cur;
    return True if $mov == $cur|$cur+1;
    return False;
}

sub read-grid($f) {
    my $grid = $f.IO.lines.map(*.comb.Array).Array;
    my ($start, $end);

    my $y = 0;
    for @($grid) -> $row {
        my $x=0;
        for @($row) -> $cell {
            given $cell {
                when 'S' { $start = [$x,$y]; $grid[$y][$x] = 'a' }
                when 'E' { $end = [$x,$y]; $grid[$y][$x] = 'z' }
            }
            $x++;
        }
        $y++;
    }
    return $grid, $start, $end;
}
