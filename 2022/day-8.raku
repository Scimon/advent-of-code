#!/usr/bin/env raku

multi sub MAIN( 'TEST' ) {
    use Test;
    my @trees = read-trees( 'day-8-test.txt' );
    is visible-count( @trees ), 21;
    is score( @trees, 2, 1 ), 4;
    is score( @trees, 2, 3 ), 8;
    is high-score( 'day-8-test.txt' ), 8;
    done-testing;
}

multi sub MAIN( 1, $f ) {
    visible-count( read-trees( $f ) ).say;
}

multi sub MAIN( 2, $f ) {
    high-score( $f ).say;
}

sub read-trees ($f) {
    $f.IO.lines.map(*.comb.list).list;
}

sub high-score($f) {
    my @trees = read-trees($f);
    my $grid_h = @trees.elems;
    my $grid_w = @trees[0].elems;
    
    return (^$grid_w X, ^$grid_h).race.map( -> ($x, $y) { score(@trees,$x,$y); } ).max;
}

sub score(@trees,$x,$y) {
    my $grid_h = @trees.elems;
    my $grid_w = @trees[0].elems;

    my $height = @trees[$y][$x];
    my @left = @trees[$y][^$x].reverse Z=> 1..$grid_w;
    my $left = @left.elems > 0 ?? @left.first({ $_.key >= $height }).value || @left[*-1].value !! 0;
    my @right = @trees[$y][$x+1..*] Z=> 1..$grid_w;
    my $right = @right.elems > 0 ?? @right.first({ $_.key >= $height }).value || @right[*-1].value !! 0;
    my @up = @trees[^$y].map(*.[$x]).reverse Z=> 1..$grid_h;
    my $up = @up.elems > 0 ?? @up.first({ $_.key >= $height }).value || @up[*-1].value !! 0;
    my @down = @trees[$y+1..*].map(*.[$x]) Z=> 1..$grid_h;
    my $down = @down.elems > 0 ?? @down.first({ $_.key >= $height }).value || @down[*-1].value !! 0;

    return $left * $right * $up * $down;
}

sub visible-count(@trees) {
    my $grid_h = @trees.elems;
    my $grid_w = @trees[0].elems;

    my $visible = 0;

    for ^$grid_h -> $y {
        CHECK:
        for ^$grid_w -> $x {
            my $height = @trees[$y][$x];
            if $height > all(|@trees[$y][^$x]) { $visible++; next CHECK; }
            if $height > all(|@trees[$y][$x+1..*]) { $visible++; next CHECK; }
            if $height > all(|@trees[^$y].map(*.[$x])) { $visible++; next CHECK; }
            if $height > all(|@trees[$y+1..*].map(*.[$x])) { $visible++; next CHECK; }
        }
    }

    return $visible;
}
