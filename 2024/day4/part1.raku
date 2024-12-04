sub MAIN($file) {
    my $SEARCH = ('X','M','A','S');
    my @lines = make-lines($file);
    my $count = 0;
    for @lines -> @test {
        $count += @test.rotor($SEARCH.elems => 1-$SEARCH.elems).grep(->@part { @part ~~ ( $SEARCH | $SEARCH.reverse ) } ).elems;
    }
    say $count;
}

sub make-lines( $file ) {

    my @horizontals;
    my @verticals;
    my @diagonals-left;
    my @diagonals-right;

    my $diagonals-idx = 0;
    for $file.IO.lines.map( *.comb ) -> @row {
        @horizontals.push(@row.clone.Array);
        for ^@row.elems -> $idx {
            my $rev-idx = @row.elems - $idx - 1;
            @verticals[$idx] //= [];
            @verticals[$idx].push(@row[$idx]);
            @diagonals-left[$diagonals-idx + $idx] //= [];
            @diagonals-left[$diagonals-idx + $idx].push(@row[$idx]);
            @diagonals-right[$diagonals-idx + $rev-idx] //= [];
            @diagonals-right[$diagonals-idx + $rev-idx].push(@row[$idx]);
            
        }
        $diagonals-idx++;
    }

    return (|@horizontals, |@verticals, |@diagonals-left, |@diagonals-right);
}
