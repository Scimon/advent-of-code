multi sub MAIN('p1', $file, :$verbose = False) {
    my ( $rules, $lists ) = parse-file($file);

    my $count = 0;
    for @($lists) -> @check {
        my $valid = valid-line( $rules, $verbose, @check );
        $count += @check[floor(@check.elems / 2)] if $valid;
    }
    say $count;
}

multi sub MAIN('p2', $file, :$verbose = False) {
    my ( $rules, $lists ) = parse-file($file);

    my $count = 0;
    for @($lists) -> @check {
        next if valid-line($rules, $verbose, @check );
        my @sorted = sort-line( $rules, @check );
        $count += @sorted[floor(@sorted.elems / 2)];
    }
    say $count;
}

sub sorter( $rules ) {
    return sub {
        return Order::Less if $^a (elem) $rules{$^b};
        return Order::More;
    };
}

sub sort-line( $rules, @check ) {
    return @check.sort( sorter($rules) );
}

sub valid-line( $rules, $verbose, @check ) {
    my $valid = True;
    @check.note if $verbose;
    for ^@check.elems -> $i {
        my $v = @check[$i];
        $valid = False if (@check[$i+1..*] && @check[$i+1..*] (<=) $rules{$v});
        note "{$v} : ({@check[$i+1..*]}) : ({$rules{$v}}) : {$valid}" if $verbose;
        $valid = False if @check[0..$i-1] !(<=) $rules{$v};
        note "{$v} : ({@check[0..$i-1]}) : ({$rules{$v}}) : {$valid}" if $verbose;
    }
    return $valid;    
}
    

sub parse-file($file) {
    my $rules;
    my $lists;
    
    for $file.IO.lines -> $line {
        given $line {
            when m/'|'/ {
                my ( $first, $second ) = $line.split("|");
                $rules{$second} //= [];
                $rules{$first} //= [];
                $rules{$second}.push($first);
                
            }
            when m/','/ {
                $lists.push($line.split(","));
            }
        }
    }
    
    return ( $rules, $lists );
}
