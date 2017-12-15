use v6.c;

my @blocks;
constant max = 128;

for ^max -> $delta {
    my $key = "amgozmfv-$delta";
#    my $key = "flqrgnkx-$delta";
    my $hash = sprintf "%0128s",knot-hash( $key ).parse-base(16).base(2);
    say $hash;
    @blocks.push( blocks( $hash ) );
}

my $next = 0;
for 0..^max-1 -> $row {
    my $next-row = $row + 1;
    for @blocks[$row].list -> @block {
        for @blocks[$next-row].list -> @next-block {
            if overlaps( @block[1], @block[2], @next-block[1], @next-block[2] ) {
                if @next-block[0] == 0 {
                    if ( @block[0] != 0 ) {
                        @next-block[0] = @block[0];
                    } else {
                        $next++;
                        @next-block[0] = $next;
                        @block[0] = $next;
                    }
                } else {
                    if ( @block[0] == 0 ) {
                        @block[0] = @next-block[0];
                    } else {
                        my $in = @block[0];
                        my $out = @next-block[0];
                        for @blocks -> @row {
                            for @row -> @cell {
                                @cell[0] = $in if @cell[0] == $out;  
                            }
                        }                     
                    }
                }
            } else {
                if ( @block[0] == 0 ) {
                    $next++;
                    @block[0] = $next;
                }
            }
        }
    }
}

for @blocks[max-1].list -> @block {
    if ( @block[0] == 0 ) {
        $next++;
        @block[0] = $next;
    }  
}

my @ids;
for ^max -> $row {
#    say @blocks[$row];
    for @blocks[$row].list -> @block {
        @ids.push( @block[0] );
    }
}

say set(@ids).keys.elems;

sub overlaps ( $s1, $e1, $s2, $e2 ) {
    $s1 <= $e2 && $s2 <= $e1;
}

sub blocks ( Str $row ) {
    my @list = $row.comb();
    my @out;

    my $start;
    for ^128 -> $idx {
        given @list[$idx] {
            when "1" {
                $start //= $idx;
            }
            when "0" {
                if defined $start {
                    @out.push( [0, $start, $idx -1 ] );
                    $start = Any;
                }
            }
        }
    }

    if defined $start {
        @out.push( [ 0, $start, 127 ] );  
    }
    return @out;
}

sub knot-hash ( Str $input ) {
    my @input = $input.comb.map( *.ord );
    constant length = 256;
    @input.push( 17, 31, 73, 47, 23 );
    
    my @list = ^length;
    my $idx = 0;
    my $skip = 0;
    
    
    for ^64 {
        for @input -> $len {
            my @temp = ( @list xx 2 ).flat;
            my @rev = @temp.splice($idx,$len).reverse;
            @temp.splice($idx,0,@rev);
            if ( $idx + $len > length ) {
                my $extra = ( $idx + $len ) - length;
                my @move = @temp.splice(length,$extra);
                @temp.splice(0,$extra,@move);
            }
            $idx+=$skip+$len;
            $skip++;
            while ( $idx > length ) {
                $idx -= length;
            }
            @list = @temp[^length];
        }
    }
        
    for ^16 {
        my $h = sprintf "%02s", ( [+^] @list.splice($_,16) ).base(16);
        @list.splice($_,0,$h);
    }
    
    return @list.join.lc;
}
