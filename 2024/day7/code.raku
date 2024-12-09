multi sub MAIN( 'p1', $file, :v(:$verbose) = False ) {
    my $total = 0;
    for $file.IO.lines -> $line {
        my ($target, $rest) = $line.split(": ");
        my @parts = $rest.split(" ");
        
        say "{$target} <> {@parts.join(',')}" if $verbose;
        say can-make( $target.Int, @parts.map(*.Int) ) if $verbose;
        $total += $target if can-make( $target.Int, @parts.map(*.Int) );
    }
    say $total;
}

multi sub MAIN( 'p2', $file, :v(:$verbose) = False ) {
    my $total = 0;
    for $file.IO.lines -> $line {
        my ($target, $rest) = $line.split(": ");
        my @parts = $rest.split(" ");
        
        say "{$target} <> {@parts.join(',')}" if $verbose;
        say can-make-concat( $target.Int, @parts.map(*.Int) ) if $verbose;
        $total += $target if can-make-concat( $target.Int, @parts.map(*.Int) );
    }
    say $total;
}

multi sub can-make( Int $target, *@rest where @rest.elems > 1 ) {
    my $first = shift @rest;
    my $second = shift @rest;

    return can-make( $target, $first * $second, |@rest ) ||
           can-make( $target, $first + $second, |@rest );
}
multi sub can-make( Int $target, Int $single where $single ~~ $target ) { True }
multi sub can-make( Int $target, Int $single where $single !~~ $target ) { False }

multi sub can-make-concat( Int $target, *@rest where @rest.elems > 1 ) {
    my $first = shift @rest;
    my $second = shift @rest;

    return can-make-concat( $target, $first * $second, |@rest ) ||
           can-make-concat( $target, $first + $second, |@rest ) ||
           can-make-concat( $target, ($first ~ $second).Int, |@rest );
}
multi sub can-make-concat( Int $target, Int $single where $single ~~ $target ) { True }
multi sub can-make-concat( Int $target, Int $single where $single !~~ $target ) { False }

