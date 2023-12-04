#!/usr/bin/env raku

sub m-dist($x1,$y1,$x2,$y2) {
    return abs($x1-$x2)+abs($y1-$y2);
}

class Sensor {
    has $.x;
    has $.y;
    has $.bx;
    has $.by;

    method range {
        m-dist($!x,$!y,$!bx,$!by);
    }

    method in-range($x,$y) {
        m-dist($!x,$!y,$x,$y) <= self.range;
    }

    method covered {
        my $d = self.range;
        my @out = (($!x-$d..$!x+$d) X, ($!y-$d..$!y+$d)).race.grep({m-dist($!x,$!y,$_[0],$_[1]) <= $d});
        return @out;
    }

    method seen-row($row) {
        my $d = self.range;
        my @out = (($!x-$d..$!x+$d) X, $row).race.grep({m-dist($!x,$!y,$_[0],$_[1]) <= $d});
        return @out;
    }
    
    method parse( Str $in ) {
        $in ~~ m/'Sensor at x='
                 $<x>=('-'?\d+) ', y='
                 $<y>=('-'?\d+) ': closest beacon is at x='
                 $<bx>=('-'?\d+) ', y='
                 $<by>=('-'?\d+)/;
        
        return Sensor.new( :x(~$<x>.Int), :y(~$<y>),
                           :bx(~$<bx>.Int), :by(~$<by>) );
    }

    method gist {
        "Sensor at x={$!x}, y={$!y}: closest beacon is at x={$!bx}, y={$!by}"
    }
}

multi sub MAIN('TEST') {
    use Test;
    ok my $sensor = Sensor.parse('Sensor at x=2, y=18: closest beacon is at x=-2, y=15');
    is $sensor.x, 2;
    is $sensor.y, 18;
    is $sensor.bx, -2;
    is $sensor.by, 15;
    $sensor = Sensor.parse('Sensor at x=8, y=7: closest beacon is at x=2, y=10');
    is $sensor.range,9;
    $sensor = Sensor.new( :x(0), :y(0), :bx(1), :by(1) );
    is-deeply $sensor.covered, [             (-2,0),
                                     (-1,-1),(-1,0),(-1,1),
                                (0,-2),(0,-1),(0,0),(0,1),(0,2),
                                       (1,-1),(1,0),(1,1),
                                              (2,0) ];
    is-deeply $sensor.seen-row(1), [(-1,1),(0,1),(1,1)];
    ok $sensor.in-range(-2,0);
    ok ! $sensor.in-range(-2,-2);
    done-testing;
}

multi sub MAIN(1,$row,$f) {
    my @sensors = $f.IO.lines.map({ Sensor.parse($_) });
    my @checked;
    my @beacons;
    for @sensors -> $s {
        note $s.gist,":",$s.range;
        @beacons.push("{$s.bx},{$s.by}");
        @checked.push($_) for $s.seen-row($row).map({"{$_[0]},{$_[1]}"});
    }
    my @result = @checked ∖ @beacons;
    @result.keys.elems.say;
}

multi sub MAIN(2,$max,$f) {
    my @sensors = $f.IO.lines.map({ Sensor.parse($_) });

    my @running;
    
    for @sensors -> $around {
        my $check = start {
            my $outer = $around.range+1;
            for 0..$outer -> $diff {
                my @points = [
                    [ $around.x - $outer + $diff, $around.y - $diff],
                    [ $around.x + $outer + $diff, $around.y + $diff],
                    [ $around.x - $diff, $around.y - $outer + $diff],
                    [ $around.x + $diff, $around.y + $outer + $diff],
                ];
                note "{@points} : $outer => $diff";
                POINTS:
                for @points -> $p {
                    next if $p[0]|$p[1] > $max;
                    next if $p[0]|$p[1] < 0;
                    for @sensors -> $check {
                        next if $around.gist ~~ $check.gist;
                        next POINTS if $check.in-range(|$p);
                    }
                    say ($p[0] * 4000000) + $p[1];
                    exit;
                }
            }
        };
        @running.push($check); 
    }
    await @running;
}
