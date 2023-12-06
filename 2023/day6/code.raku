#!/usr/bin/env raku

multi sub MAIN('test') {
    use Test;
    is-deeply read-file('example'), { times => ( 7, 15, 30 ), distances => ( 9, 40, 200 ) };
    is-deeply pos-races( 7 ).List, (6,10,12,12,10,6,0);
    is-deeply winning-races( 7, 9 ).List, (10,12,12,10);
    is-deeply read-file-two('example'), { time => 71530, distance => 940200 };
    is winners( 7, 9 ), 4;
    is winners( 15, 40 ), 8;
    is winners( 30, 200 ), 9;
    is winners( 71530, 940200 ), 71503;
    done-testing;
}

multi sub MAIN('p1', $file ) {
    my %races = read-file($file);
    
    say [*] (%races<times>.Seq Z, %races<distances>.Seq).map( -> ($t,$d) { winning-races($t,$d).elems } );
}

multi sub MAIN('p2', $file) {
    my %races = read-file-two($file);

    say winners( %races<time>, %races<distance> );
}

sub winners( $time, $distance ) {
    #pos-races($time).grep( { $_ > $distance } ).elems;

    my $winners = $time-1;
    my $test = 1;

    while ( ( ( $time-$test ) * $test) <= $distance ) {
        $test++;
        $winners -= 2;
    }
    return $winners;    
}

sub winning-races( $time, $distance ) {
    pos-races($time).grep( { $_ > $distance } );
}

sub pos-races( $time ) {
    (1..$time).hyper.map( { ($time-$_) * $_ } ); 
}

sub read-file($file) {
    return {
        times => read-line($file.IO.lines[0]),
        distances => read-line($file.IO.lines[1]),
    }
}

sub read-line($line) { $line.split(/":" \s+/)[1].split(/\s+/).map(*.Int).List }

sub read-file-two($file) {
    return {
        time => read-line($file.IO.lines[0]).join("").Int,
        distance => read-line($file.IO.lines[1]).join("").Int,
    }
}
