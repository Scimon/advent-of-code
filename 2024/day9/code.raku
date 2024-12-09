multi sub MAIN('p1', $file, :v(:$verbose) = False ) {
    my @fragmented = read-file( $file );
    say @fragmented.join("") if $verbose;
    my @defragmented = de-frag( $verbose, @fragmented );
    say calc-checksum( @defragmented );
}

multi sub MAIN('p2', $file, :v(:$verbose) = False ) {
    my @files = read-file-two( $file );
    @files.say if $verbose;
    write-files(@files) if $verbose;
    my @defrag = de-frag-files( $verbose, @files );    
    say check-sum-files( @defrag );
}

sub check-sum-files( @files ) {
    my $total = 0;
    for @files -> $file {
        for $file<p>..^($file<p>+$file<s>) -> $i {
            $total += $i * $file<id>;
        }
    }
    return $total;
}

sub de-frag-files( $verbose, @files is copy ) {
    my @free = find-free(@files);
    note @free if $verbose;
    my $file-check = @files.max(*<id>)<id>;
    while ( $file-check >= 0 ) {
        note $file-check is $verbose;
        my $file = @files.grep( { $_<id> ~~ $file-check } )[0];
        for @free -> $space {
            last if $space<p> > $file<p>;
            if ( $space<s> >= $file<s> ) {
                $file<p> = $space<p>;
                $space<s> -= $file<s>;
                $space<p> += $file<s>;
                last;
            }
        }
        $file-check--;
    }
    write-files(@files) if $verbose;
    return @files;
}

sub find-free( @files ) {
    my @free;
    for @files.rotor(2 => -1) -> @pair {
        my $start = @pair[0]<p> + @pair[0]<s>;
        if ( $start != @pair[1]<p> ) {
            @free.push( { p => $start, s => @pair[1]<p> - $start } ); 
        }
    }
    return @free;
}

sub write-files( @files ) {
    my @out;
    my $p = 0;
    for @files -> $file {
        if ( $file<p> > $p ) {
            @out.push( |('.' xx ($file<p> - $p)) );
            $p = $file<p>;
        }
        @out.push( |($file<id> xx $file<s>.Int) );
        $p += $file<s>;
    }
    @out.join('').say;
}

sub read-file-two( $file ) {
    my $id = 0;
    my $pointer = 0;
    my $free = False;
    my @out;
    for $file.IO.slurp.comb -> $size {
        if ( ! $free ) {
            @out.push( { id => $id, p => $pointer, s => $size } );
            $id++;
        }
        $free = ! $free;
        $pointer += $size;
    }
    
    return @out;
}

sub calc-checksum( @files ) {
    my $total;
    for ^@files.elems -> $i {
        $total += @files[$i] * $i;
    }
    return $total;
}

sub de-frag( $verbose, @fragmented is copy ) {
    my $idx = 0;
    @fragmented.join("").say if $verbose;
    while ( $idx < @fragmented.elems ) {
        if ( @fragmented[$idx] ~~ ' ' ) {
            my $val = @fragmented.pop();
            while ($val ~~ ' ') { $val = @fragmented.pop(); }
            @fragmented[$idx] = $val;
            @fragmented.join("").say if $verbose;
        }
        $idx++;
    }
    return @fragmented;
}

sub read-file( $file ) {
    my $id = 0;
    my $free = False;
    my @out = [];
    for $file.IO.slurp.comb -> $size {
        if ( $free ) {
            @out.push( |( ' ' xx $size ) );
            $free = False;
        } else {
            @out.push( |( $id xx $size ) );
            $id++;
            $free = True;
        }
    }
    return @out;
}
