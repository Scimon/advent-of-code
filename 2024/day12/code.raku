use lib "../../lib";
use Point;
use Grid;

enum Dir (Up => { x => 0, y => -1}, Down => { x=> 0, y => 1}, Left => { x => -1, y => 0}, Right => { x => 1, y => 0 });

class Region {...}

class PlotPoint does Point {
    has Str $.val;
    has Grid $.grid;
    has Int $!perimeter;
    
    method Str { $!val }
    method gist { "{$!x}x{$!y}:{$!val}" }

    method area { 1 }
    method perimeter {
        return $!perimeter if defined $!perimeter;
        $!perimeter = 4 - $.grid.orth-adjacent(self).grep( { $_.val ~~ $.val } ).elems;
    }

    method point-dir (Dir $d) {
        my $check = Point.new( x => $.x + $d<x>, y => $.y + $d<y> );
        return if ! $.grid.in-bounds( x => $check.x, y => $check.y );
        return $.grid.point-at($check.x, $check.y);
    }

    method sides {
        my @sides;
        for (Up, Down, Left, Right) -> $dir {
            my $check = $.point-dir($dir);
            if $check {
                @sides.push($dir) if $check.val !~~ $.val
            } else {
                @sides.push($dir)
            }
        }
        return @sides;
    }
    
}

class PlotGrid does Grid[PlotPoint] {
    submethod BUILD( :@lines ) {
        $!empty = ' ';
        $!points = Hash[Hash[PlotPoint]].new;
        my $y = 0;
        for @lines -> $line {
            $!max-x //= $line.codes-1;
            my $x = 0;
            for $line.comb -> $val {
                if ( my $p = PlotPoint.new( :$x, :$y, :$val, grid => self ) ) {
                    self.add-point( $p );
                }
                $x++;
            }
            $y++;
        }
        $!max-y = $y-1;
    }

    method find-region( Point $p ) {
        my @area;
        my @to-check = [$p];
        my %seen;
        while @to-check {
            my $check = @to-check.shift;
            next if %seen{$check.gist};
            %seen{$check.gist} = True;
            @area.push($check);
            @to-check.push( |self.orth-adjacent($check).grep( { $_.val ~~ $check.val } ) );
        }
        return Region.new( points => @area, grid => self );
    }
}

class Region {
    has Grid $.grid;
    has @.points;
    has Int $!min-x;
    has Int $!min-y;
    has Int $!max-x;
    has Int $!max-y;
    
    method area { [+] @.points.map(*.area); }
    method perimeter { [+] @.points.map(*.perimeter) }

    method min-y {
        return $!min-y if defined $!min-y;
        $!min-y = @.points.min(*.y).y;
    }
    method min-x {
        return $!min-x if defined $!min-x;
        $!min-x = @.points.min(*.x).x;
    }
    method max-y {
        return $!max-y if defined $!max-y;
        $!max-y = @.points.max(*.y).y;
    }
    method max-x {
        return $!max-x if defined $!max-x;
        $!max-x = @.points.max(*.x).x;
    }

    method in-region(Point $p) {
        return so @.points.grep( { $_ ~~ $p } );
    }

    method sides {
        return self!horiz-side-scan + self!vert-side-scan;        
    }

    method !horiz-lines {
        gather {
            for $.min-y..$.max-y -> $y {
                for $.min-x..$.max-x -> $x {
                    take { x => $x, y => $y };
                }
                take 'END';
            }
        }
    }

    method !vert-lines {
        gather {
            for $.min-x..$.max-x -> $x {
                for $.min-y..$.max-y -> $y {
                    take { x => $x, y => $y };
                }
                take 'END';
            }
        }
    }

    method !scan ( @lines, Dir $side1, Dir $side2 ) {
        my $side1-seen = False;
        my $side2-seen = False;
        my $sides = 0;
        for @lines -> $p {
            if ( $p ~~ 'END' ) {
                $sides++ if $side1-seen;
                $sides++ if $side2-seen;
                $side1-seen = False;
                $side2-seen = False;
                next;
            }
            my $point =  $.grid.point-at($p<x>,$p<y>);
            if ( ! self.in-region($point) ) {
                $sides++ if $side1-seen;
                $sides++ if $side2-seen;
                $side1-seen = False;
                $side2-seen = False;
                next;
            }
            if $side1 ~~ any($point.sides) {
                $side1-seen = True;
            } else {
                $sides++ if $side1-seen;
                $side1-seen = False;
            }
            if $side2 ~~ any( $point.sides ) {
                $side2-seen = True;
            } else {
                $sides++ if $side2-seen;
                $side2-seen = False;
            }
        }
        return $sides;
    }
    
    method !horiz-side-scan {
        return self!scan( self!horiz-lines, Up, Down );
    }

    method !vert-side-scan {
        return self!scan( self!vert-lines, Left, Right );
    }

}

multi sub MAIN('p1', $file, :v(:$verbose) ) {
    my $grid = PlotGrid.new( lines => $file.IO.lines );
    my %seen;
    my $total = 0;
    for $grid.all-points -> $point {
        next if %seen{$point.gist};
        my $region = $grid.find-region( $point );
        %seen{$_.gist} = True for $region.points;
        my $area = $region.area;
        my $perimeter = $region.perimeter;
        say "{$point.gist} : {$area} x {$perimeter} -> {$area * $perimeter}" if $verbose;
        $total += ($area * $perimeter);
    }
    say $total;
}

multi sub MAIN('test') {
    my $grid = PlotGrid.new( lines => "example-small".IO.lines );

    $grid.say;
    
    my $region = $grid.find-region( $grid.point-at(2,1) );
    $region.sides.say;
}

multi sub MAIN('p2', $file, :v(:$verbose) ) {
    my $grid = PlotGrid.new( lines => $file.IO.lines );
    $grid.say if $verbose;

    my %seen;
    my $total = 0;
    for $grid.all-points -> $point {
        next if %seen{$point.gist};
        my $region = $grid.find-region( $point );
        %seen{$_.gist} = True for $region.points;
        my $area = $region.area;
        my $sides = $region.sides;
        say "{$point.gist} : {$area} x {$sides} -> {$area * $sides}" if $verbose;
        $total += ($area * $sides);
    }
    say $total;
}

