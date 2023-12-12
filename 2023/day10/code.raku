#!/usr/bin/env raku

multi sub MAIN('test') {
    use Test;
    is read-grid('example1'), ( (
        <. . . . .>,
        <. S - 7 .>,
        <. | . | .>,
        <. L - J .>,
        <. . . . .>,
                              ), (1,1) );
    is read-grid('example2')[1], (2,0);
    my ($g1,$s1) = read-grid('example1');
    is $s1, (1,1);
    is-deeply adjacent((0,0),(1,1)), {right => (0,1),down => (1,0)};
    is-deeply adjacent((1,1),(2,2)),
      {up => (0,1), right => (1,2), down => (2,1), left => (1,0)};
    is-deeply adjacent((2,2),(2,2)), {up => (1,2), left => (2,1)};
    is start-point($g1,$s1), 'F';
    is furthest-distance($g1, $s1)[0], 4;
    is internal-points($g1,$s1), 1;

    for ( (
#            'example1' => 1,
            'example3' => 4,
#            'example4' => 8,
#            example5 => 10
        ) ) -> $pair {
        my $file = $pair.key;
        my $expected = $pair.value;
        my ($g,$s) = read-grid($file);
        is  internal-points($g,$s), $expected;
        $g.map(*.join("")).join("\n").say;
    }
    done-testing;   
}

multi sub MAIN('p1', $file ) {
    my ($g1,$s1) = read-grid($file);
    say furthest-distance($g1, $s1)[0];
}

multi sub MAIN('p2', $file ) {
    my ($g1,$s1) = read-grid($file);
    say internal-points($g1,$s1);
}

sub internal-points($grid,$start) {
    my ($distance, %seen) = furthest-distance($grid, $start);
    my $internal = 0;
    my $max-r = $grid.elems-1;
    my $max-c = $grid[0].elems-1;
    for (0..$max-r) -> $r {
        INNER: for (0..$max-c) -> $c {
            next INNER if %seen{"{$r}x{$c}"};
            $grid[$r][$c] = '.';
        }
    }
    
    my @i-cells = [];
    for (0..$max-r) -> $r {
        @i-cells[$r] = [];
        INNER: for (0..$max-c) -> $c {
            next INNER if %seen{"{$r}x{$c}"};
            my $i = is-internal($grid,$r,$c);
            $internal++ if $i;
            @i-cells[$r][$c] = $i;
        }
    }

    for (0..$max-r) -> $r {
        INNER: for (0..$max-c) -> $c {
            next INNER if %seen{"{$r}x{$c}"};
            $grid[$r][$c] = @i-cells[$r][$c] ?? 'I' !! 'O'; 
        }
    }
    return $internal;
}

sub is-internal($grid,$r,$c) {

    my $check = "{$r}x{$c}" eq any("6x2");
    
    my %scores = (
        'up' =>    { '.-.' => 1, '.L|' => 1, '|F.' => 1 },
        'down' =>  { '.-.' => 1 },
        'left' =>  { '.|.' => 1 },
        'right' => { '.|.' => 1 },
    );

    my $max-r = $grid.elems-1;
    my $max-c = $grid[0].elems-1;
    my @scores = <up down left right>.map(
        -> $d {
            my @hops = hops( $grid, $r, $c, $max-r, $max-c, $d );
            @hops = @hops.grep(
                -> @tri { ! (all(@tri) ~~ '.') }
            ).map( -> @tri { @tri.join('') });
            my $score = [+] @hops.grep({ %scores{$d}{$_} })
                            .map({ %scores{$d}{$_} } );
            $score = -1 unless @hops.elems;
            say $r, 'x', $c, $d, @hops, $score if $check;
            $score;
        } );
    say @scores if $check;
    return False if any(@scores) == -1;
    return False if any(@scores) %% 2;
    return True;
}

sub hops($grid,$r,$c,$max-r,$max-c,$dir) {
    my @out;
    my @p = [$r,$c];
    my %adj = adjacent(@p,($max-r,$max-c)); 
    loop {
        @out.push($grid[@p[0]][@p[1]]);
        last unless %adj{$dir};
        @p = %adj{$dir}.Array;
        %adj = adjacent(@p,($max-r,$max-c)); 
    };
    return @out.rotor(3 => -2);
}

sub x-internal-points($g1,$s1) {
    my ($distance, %seen) = furthest-distance($g1, $s1);

    my %crosses = (
        up    => {
            '-O' => -1, '-I' => -1, '-.' => -1,
            'O-' => 1, 'I-' => 1, '.-' => 1,
            '--' => 2 , 'L7' => 1, 'JF' => 1,
            'F-' => 1, 'L-' => 1, '7-' => 1, 'J-' => 1,
            '-F' => 1, '-L' => 1, '-7' => 1, '-J' => 1,
        },
        down  => {
            '-O' => -1, '-I' => -1, '-.' => -1,
            'O-' => 1, 'I-' => 1, '.-' => 1,
            '--' => 2 , '7L' => 1, 'FJ' => 1,
            'F-' => 1, 'L-' => 1, '7-' => 1, 'J-' => 1,
            '-F' => 1, '-L' => 1, '-7' => 1, '-J' => 1,
        },
        left  => {
            '|O' => -1, '|I' => -1, '|.' => -1,
            'O|' => 1, 'I|' => 1, '.|' => 1,
            '||' => 2, '7L' => 1, 'JF' => 1,
            'F|' => 1, 'L|' => 1, '7|' => 1, 'J|' => 1,
            '|F' => 1, '|L' => 1, '|7' => 1, '|J' => 1,
        },
        right => {
            '|O' => -1, '|I' => -1, '|.' => -1,
            'O|' => 1, 'I|' => 1, '.|' => 1,
            '||' => 2,  'L7' => 1, 'FJ' => 1,
            'F|' => 1, 'L|' => 1, '7|' => 1, 'J|' => 1,
            '|F' => 1, '|L' => 1, '|7' => 1, '|J' => 1,
        },
    );
    my %opp = ( up => 'down', down => 'up',
                left => 'right', 'right' => 'left' );
    my $internal = 0;
    my $max-r = $g1.elems-1;
    my $max-c = $g1[0].elems-1;
    for (0..$max-r) -> $r {
        INNER: for (0..$max-c) -> $c {
            next INNER if %seen{"{$r}x{$c}"};
            $g1[$r][$c] = '.';
        }
    }
    
    for (0..$max-r) -> $r {
        INNER: for (0..$max-c) -> $c {
            next INNER if %seen{"{$r}x{$c}"};
            $g1[$r][$c] = 'O';
            my $check = "{$r}x{$c}" eq any("3x3","6x3");
            my @directions = <up right down left>.map(
                -> $dir {
                    my $crossed = 0;
                    my $ex = True;
                    my @p = [$r,$c];
                    my %adj = adjacent(@p,($max-r,$max-c));
                    RAY: loop {
                        last RAY unless %adj{$dir};
                        $ex = $ex && $g1[@p[0]][@p[1]] eq any('.','I','O');
                        %adj = adjacent(@p,($max-r,$max-c));
                        last unless %adj{$dir};
                        my @n = %adj{$dir}.Array;
                        my $pair = $g1[@p[0]][@p[1]] ~ $g1[@n[0]][@n[1]];
                        say @p,":",$dir,":",$pair,":",%crosses{$dir}{$pair} if $check;
                        $crossed+= %crosses{$dir}{$pair} if %crosses{$dir}{$pair};
                        @p = %adj{$dir}.Array;

                    };
                    $ex ?? -1 !! $crossed;
                });
            say $r, "x", $c, ":", @directions.join(",") if $check;
            next INNER if so any(@directions) == -1;
#            next INNER if so all(@directions) %% 2;
            next INNER if any(@directions) %% 2;
            $g1[$r][$c] = 'I';
            $internal++;
        }
    }
    $g1.map(*.join('')).join("\n").say;
    return $internal;
}

sub adjacent(@point,@max) {
    (
        up    => ( @point[0]-1, @point[1]   ),
        right => ( @point[0],   @point[1]+1 ),
        down  => ( @point[0]+1, @point[1]   ),
        left  => ( @point[0],   @point[1]-1 ),
        ).grep( { 0 <= $^a.value[0] <= @max[0] && 0 <= $^a.value[1] <= @max[1] } ).Hash;
}

sub routes(@grid,@p) {
    my %adj = adjacent(@p, ( @grid.elems-1, @grid[0].elems-1 ) );
    my @pos = do given @grid[@p[0]][@p[1]] {
        when ( '|' ) { qw<up down> }
        when ( '-' ) { qw<left right> }
        when ( 'L' ) { qw<up right> }
        when ( 'J' ) { qw<up left> }
        when ( '7' ) { qw<left down> }
        when ( 'F' ) { qw<right down> } 
    }
    @pos.map( { %adj{$_} } ) ;
}

sub start-point(@grid, @start) {
    my %adj = adjacent(@start, ( @grid.elems-1, @grid[0].elems-1 ));
    if ( %adj<up> && %adj<down> &&
         @grid[%adj<down>[0]][%adj<down>[1]] ~~ any(<| L J>) &&
         @grid[%adj<up>[0]][%adj<up>[1]] ~~ any(<| 7 F>) ) { return '|' }
    if ( %adj<left> && %adj<right> &&
         @grid[%adj<left>[0]][%adj<left>[1]] ~~ any(<- L F>) &&
         @grid[%adj<right>[0]][%adj<right>[1]] ~~ any(<- J 7>) ) { return '-' }
    if ( %adj<up> && %adj<right> &&
         @grid[%adj<right>[0]][%adj<right>[1]] ~~ any(<- 7 J>) &&
         @grid[%adj<up>[0]][%adj<up>[1]] ~~ any(<| 7 F>) ) { return 'L' }
    if ( %adj<up> && %adj<left> &&
         @grid[%adj<left>[0]][%adj<left>[1]] ~~ any(<- L F>) &&
         @grid[%adj<up>[0]][%adj<up>[1]] ~~ any(<| 7 F>) ) { return 'J' }
    if ( %adj<left> && %adj<down> &&
         @grid[%adj<down>[0]][%adj<down>[1]] ~~ any(<| L J>) &&
         @grid[%adj<left>[0]][%adj<left>[1]] ~~ any(<- L F>) ) { return '7' }
    if ( %adj<right> && %adj<down> &&
         @grid[%adj<down>[0]][%adj<down>[1]] ~~ any(<| L J>) &&
         @grid[%adj<right>[0]][%adj<right>[1]] ~~ any(<- 7 J>) ) { return 'F' }
}
   
sub read-grid($file) {
    my $row = 0;
    my @start;
    my @grid = $file.IO.lines.map(
        -> $l {
            if $l ~~ /'S'/ { @start = ($row,$l.index('S')) }
            $row++;
            $l.comb.Array;
        }).Array;
    return ( @grid, @start );
}

sub furthest-distance(@grid,@start) {
    my $distance = -1;
    my @points = ( @start, );
    my %seen = (@start.join('x') => True);
    @grid[@start[0]][@start[1]] = start-point(@grid, @start);
    while ( @points ) {
        $distance++;
        @points = @points.map( { |routes(@grid,$_) } ).grep( { ! %seen{$_.join('x')} } );
        %seen{$_.join('x')} = True for @points;
    }
    return $distance, %seen;
}
