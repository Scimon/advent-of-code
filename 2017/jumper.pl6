use v6.c;

sub MAIN( $file ) {
    my @list = $file.IO.lines.map( *.Int ).Array;
    my $idx = 0;
    my $count = 0;

    while ( -1 < $idx < @list.elems ) {
        #say @list.join(" ");
        my $ni = $idx + @list[$idx];
        #@list[$idx]++;
        @list[$idx] = @list[$idx] >= 3 ?? @list[$idx]-1 !! @list[$idx]+1;
        $idx = $ni;
        $count++;
    }
    say $count;
}
