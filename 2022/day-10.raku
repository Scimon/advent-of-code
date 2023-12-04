#!/usr/bin/env test

multi sub MAIN('TEST') {
    use Test;
    my @small-test = ['noop','addx 3','addx -5'];
    my @cycles = process-rules( @small-test );
    is-deeply @cycles, [1,1,1,1,4,4,-1];
    @cycles = process-rules( 'day-10-test.txt'.IO.lines );
    is @cycles[20], 21;
    is @cycles[60], 19;
    is @cycles[100], 18;
    is @cycles[140], 21;
    is @cycles[180], 16;
    is @cycles[220], 18;
    is picked-signal-strengths( 'day-10-test.txt'.IO.lines ), 13140;
    done-testing;
}

multi sub MAIN(1) {
    picked-signal-strengths( 'day-10-input.txt'.IO.lines ).say;
}

multi sub MAIN(2) {
    draw-output(  process-rules('day-10-input.txt'.IO.lines) );
}


sub picked-signal-strengths( @rules ) {
    my @idxs = (20,60, 100, 140, 180, 220);
    return [+] ( process-rules( @rules )[|@idxs] Z* @idxs);
}

sub process-rules( @rules ) {
    my $x = 1;
    my @cycles = [$x,$x];
    for @rules -> $rule {
        given $rule {
            when 'noop' {
                @cycles.push($x);
            }
            when /'addx '(.*)/ {
                my $val = $0;
                @cycles.push($x);
                $x+=$val;
                @cycles.push($x);
            }
        }
    }
    return @cycles;
}

sub draw-output( @cycles ) {
    my @out = [];
    my $c = 0;
    for (1..240) -> $i {
        my $draw = ' ';
        $draw = '#' if $c ~~ (@cycles[$i] + any(-1,0,1));
        @out.push($draw);
        $c++;
        if ( $i %% 40 ) {
            say @out.join('');
            @out = [];
            $c = 0;
        }
    }

}

multi sub MAIN('TEST-OUTPUT') {
    my @cycles = process-rules( 'day-10-test.txt'.IO.lines );
    say ((|(1..9),0).join('')) x 4;
    draw-output(@cycles);
}
