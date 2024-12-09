use lib "../../lib";
use Point;

multi sub MAIN('p1', $file, :v(:$verbose) = False ) {
    my %antennas;
    my %antinodes;
    my $y = 0;
    my $x = 0;
    for $file.IO.lines -> $line {
        $x = 0;
        for $line.comb('') -> $point {
            if ($point !~~ '.' ) {
                %antennas{$point} //= [];
                %antennas{$point}.push( Point.new(:$x, :$y) );
            }
            $x++;
        }
        $y++;
    }
    my $p-min = Point.new(x => 0, y => 0);
    my $p-max = Point.new(x => $x-1, y => $y-1);
    for %antennas.keys -> $frequency {
        my $points = %antennas{$frequency};
        $points.say if $verbose;
        while ($points.elems > 1) {
            my $first = $points.shift;
            $first.say if $verbose;
            for @($points) -> $second {
                $second.say if $verbose;
                my $vec = $first.sub($second);
                $vec.say if $verbose;
                $first.add($vec).say if $verbose;
                $second.sub($vec).say if $verbose;
                %antinodes{$first.add($vec).gist} = True if $first.add($vec).in-bounds($p-min, $p-max);
                %antinodes{$second.sub($vec).gist} = True if $second.sub($vec).in-bounds($p-min, $p-max);
            }
        }
    }
    %antinodes.say if $verbose;
    %antinodes.keys.elems.say;
}

multi sub MAIN('p2', $file, :v(:$verbose) = False ) {
    my %antennas;
    my %antinodes;
    my $y = 0;
    my $x = 0;
    for $file.IO.lines -> $line {
        $x = 0;
        for $line.comb('') -> $point {
            if ($point !~~ '.' ) {
                %antennas{$point} //= [];
                %antennas{$point}.push( Point.new(:$x, :$y) );
                %antinodes{Point.new(:$x, :$y).gist} = True;
            }
            $x++;
        }
        $y++;
    }
    my $p-min = Point.new(x => 0, y => 0);
    my $p-max = Point.new(x => $x-1, y => $y-1);
    for %antennas.keys -> $frequency {
        my $points = %antennas{$frequency};
        while ($points.elems > 1) {
            my $first = $points.shift;
            for @($points) -> $second {
                my $vec = $first.sub($second);
                my $test = $first.add($vec);
                while ( $test.in-bounds($p-min, $p-max) ) {
                    %antinodes{$test.gist} = True;
                    $test = $test.add($vec);
                }
                $test = $second.sub($vec);
                while ( $test.in-bounds($p-min, $p-max) ) {
                    %antinodes{$test.gist} = True;
                    $test = $test.sub($vec);
                }
            }
        }
    }
    if ( $verbose ) {
        for (^$y) -> $cy {
            my @out;
            for (^$x) -> $cx {
                @out.push( %antinodes{"{$cx}x{$cy}"} ?? '#' !! '.' );
            }
            @out.join("").say;
        }
    }
    %antinodes.say if $verbose;
    %antinodes.keys.elems.say;
}

