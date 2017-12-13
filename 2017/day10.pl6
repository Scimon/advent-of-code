use v6.c;

my @input = "130,126,1,11,140,2,255,207,18,254,246,164,29,104,0,224".comb.map( *.ord );
constant length = 256;

#my @input = 3, 4, 1, 5;
#onstant length = 5;

#my @input = "1,2,3".comb.map( *.ord );
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

say @list;

for ^16 {
    my $h = sprintf "%02s", ( [+^] @list.splice($_,16) ).base(16);
    say $h;
    @list.splice($_,0,$h);
}

say @list.join.lc;

