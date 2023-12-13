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
#    is internal-points($g1,$s1), 1;

    is path($g1,'down',0,0), [<. . . . .>], 'p1';
    is path($g1,'down',0,1), [<. F | L .>], 'p2';
    is path($g1,'up',4,1),   [<. L | F .>], 'p3';
    is path($g1,'up',0,0), [< . >], 'p4';
    
    is crosses([< . >], 'up'), 0, 'c1';
    is crosses([< - >], 'up'), 1, 'c2';
    is crosses([< | >], 'up'), 0, 'c3';
    is crosses([< - >], 'left'), 0, 'c4';
    is crosses([< | >], 'left'), 1, 'c5';
    is crosses([< L F - - J 7>], 'up'), 2, 'c6';
    is crosses([< J - - F >], 'left'), 1, 'c7';
    is crosses([< . | L - 7 . F - J | .>], 'right'), 4, 'c8';

    
    for ( (
            'example1' => 1,
            'example3' => 4,
            'example4' => 8,
            example5 => 10
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

my $debug = False;

sub crosses ( @l, $dir ) {
    my $f-dir = $dir;
    given $dir {
        when 'up' { $f-dir = 'down'; @l = @l.reverse }
        when 'left' { $f-dir = 'right'; @l = @l.reverse; }
    }
    
    my $rem = $f-dir ~~ 'down' ?? '|' !! '-';
    my $skip-pairs = $f-dir ~~'down' ?? any( 'FL', '7J' ) !! any( '7F', 'LJ' );
    my $squish-pairs = $f-dir ~~ 'down' ?? any( 'FJ', '7L' ) !! any( 'FJ', 'L7' );
    
    @l .= grep( { $_ !~~ $rem } );
    say @l if $debug;
    my @skipped;
    my $skip = False;
    for (1..^@l.elems) -> $i {
        say $i,':',@l[$i-1..$i].join(''),':',$skip-pairs,':',$squish-pairs,':',$skip if $debug;
        if ( @l[$i-1..$i].join('') ~~ $squish-pairs ) {
            say "Squish" if $debug;
            next;
        }
        if ( @l[$i-1..$i].join('') ~~ $skip-pairs ) {
            say "Sk.." if $debug;
            $skip = True;
            next;
        }
        if ( $skip ) {
            say "..ip" if $debug;
            $skip = False;
            next;
        }
        @skipped.push(@l[$i-1]);
    }
    @skipped.push(@l[*-1]) if @l && !$skip;
    say @skipped if $debug;
    @skipped .= grep( { $_ !~~ '.' } );
    say @skipped if $debug;
    @skipped.elems;
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
            my @paths = ('up','down','left','right').map(
                            -> $dir {
                                $dir => path($grid,$dir,$r,$c);  
                            });
            my @crosses = @paths.map( -> $p { crosses($p.value,$p.key) } );
            next INNER if all(@crosses) %% 2;
            $internal++;
            @i-cells[$r][$c] = True;
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

sub path(@grid,$dir,$r,$c) {
    my @max = [@grid.elems-1, @grid[0].elems-1];
    my @p = [$r,$c];
    my %adjacent = adjacent(@p,@max);
    my @out = [@grid[@p[0]][@p[1]]];
    while (%adjacent{$dir}) {
        @p = %adjacent{$dir}.list;
        %adjacent = adjacent(@p,@max) if @p.elems;
        @out.push(@grid[@p[0]][@p[1]]);
    }

    return @out;
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
