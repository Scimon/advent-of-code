sub MAIN($file) {
    my @grid = $file.IO.lines.map( *.comb );

    my $count = 0;
    for ^@grid.elems -> $y {
        for ^@grid[$y].elems -> $x {
            next unless @grid[$y][$x] ~~ 'A';
            $count++ if
            ( ( @grid[$y-1][$x-1] ~~ 'M' && @grid[$y+1][$x+1] ~~ 'S' ) || (@grid[$y-1][$x-1] ~~ 'S' && @grid[$y+1][$x+1] ~~ 'M' ) ) &&
            ( ( @grid[$y+1][$x-1] ~~ 'M' && @grid[$y-1][$x+1] ~~ 'S' ) || (@grid[$y+1][$x-1] ~~ 'S' && @grid[$y-1][$x+1] ~~ 'M' ) );
        }
    }
    say $count;
}
