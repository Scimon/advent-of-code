use v6.c;

my $count;
for ^128 -> $delta {
    my $key = "amgozmfv-$delta";
    my $hash = knot-hash( $key ).parse-base(16);
    $count += bag( $hash.base(2).comb ){"1"};
    say $delta,":",$count;
}

say $count;

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
