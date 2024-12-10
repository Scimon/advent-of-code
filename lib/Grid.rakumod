use Point;
unit role Grid[::T];

has $.points;
has Int $.min-x = 0;
has Int $.min-y = 0;
has Int $.max-x;
has Int $.max-y;
has Str $.empty = '';

submethod BUILD( :@lines ) {
    $!points = Hash[Hash[T]].new;
    my $y = 0;
    for @lines -> $line {
        $!max-x //= $line.codes-1;
        my $x = 0;
        for $line.comb -> $val {
            if ( my $p = T.new( :$x, :$y, :$val ) ) {
                self.add-point( $p );
            }
            $x++;
        }
        $y++;
    }
    $!max-y = $y-1;

}

method clone {
    my $new-points = Hash[Hash[T]].new;
    for $!points.keys -> $x {
        for $!points{$x}.keys -> $y {
            $new-points{$x} //= Hash[T].new;
            $new-points{$x}{$y} = $!points{$x}{$y}.clone;
        }
    }
    nextwith points => $new-points, |%_;
}

multi method point-at(:$x,:$y) {
    %.points{$x}{$y};
}
multi method point-at($x,$y) {
    %.points{$x}{$y};
}
multi method point-at(Str $p where * ~~ /^ \d+ 'x' \d+ $/) {
    my $m = $p.match( /^ (\d+) 'x' (\d+) $/ );
    self.point-at( x => $m[0].Int, y => $m[1].Int );
}

multi method orth-adjacent(Point :point(:$p) ) { self.orth-adjacent($p) }

multi method orth-adjacent(Point $p) {
    gather {
        for ( [-1,0], [1,0], [0,1],[0,-1] ) -> $d {
            if ( self.in-bounds( x => $p.x + $d[0], y => $p.y + $d[1] ) ) {
                take self.point-at( x => $p.x + $d[0], y => $p.y + $d[1] );
            }
        }
    }
}

method all-points() {
    gather {
        for $!min-y..$!max-y -> $y {
            for $!min-x..$!max-x -> $x {
                take self.point-at( :$x, :$y );
            }
        }
    }
}

method add-point($point) {
    $.points{$point.x} //= Hash[T].new;
    %.points{$point.x}{$point.y} = $point;
}

method remove-point($point) {
    %.points{$point.x}{$point.y}:delete;
}

method gist() {
    my @out = [];
    for ($!min-y..$!max-y) -> $y {
        my @row = [];
        for ($!min-x..$!max-x) -> $x {
            @row.push(self.point-at(:$x,:$y) ??
                      self.point-at(:$x,:$y).Str !!
                       $.empty );
        }
        @out.push(@row);
    }
    return @out.map(*.join('')).join("\n");
}

method in-bounds(:$x,:$y) { $!min-x <= $x <= $!max-x && $!min-y <= $y <= $!max-y; }
