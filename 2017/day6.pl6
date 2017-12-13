use v6.c;

#my @mem = [0,2,7,0];
my $loops;
my @mem = "day6.txt".IO.slurp.words.map( *.Int );

sub find-loop( @in ) {
    my @working = @in.Array;
    my @seen = [];
    my $count = 0;

    while ( @working.join("-") !(elem) @seen ) { 
        @seen.push(@working.join("-"));
        $count++;
        my $i = 0;
        my $max = @working.max;
        my $seen = False;
        while ( $max > 0 ) {
            if ! $seen {
                if @working[$i] == $max {
                    @working[$i] = 0;
                    $seen = True;
                }
            } else {
                @working[$i]++;
                $max--;
            }
            $i++;
            $i = 0 if $i == @working.elems;
        }
        
    }

    return ( $count, @working );

}

( $loops, @mem ) = find-loop( @mem );
say $loops, ":", @mem[0];
( $loops, @mem ) = find-loop( @mem[0] );
say $loops, ":", @mem[0];
    
