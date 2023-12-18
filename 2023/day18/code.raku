#!/usr/bin/env raku

use lib '../../lib';
use Point;
use Grid;
use Direction;

class Trench does Point {
    has Str $.colour is built;
    method Str { '#' }
}

class Dig does Grid[Trench] {
    
    submethod BUILD( :@digs ) {
        $!points = Hash[Hash[Trench]].new;
        $!empty = '.';
        my %dirs = ( 'R' => (1,0),  'D' => (0,1),
                     'L' => (-1,0), 'U' => (0,-1) );
        
        my $x = 0;
        my $y = 0;
        my $colour = '#000000';
        self.add-point(Trench.new(:$x,:$y,:$colour));
        for (@digs) -> $dig {
            my $m = $dig.match(/^ ('R'||'D'||'L'||'U') \s+ (\d+) \s+ '(' (.+) ')' $/ );
            my $dir = $m[0].Str;
            my $count = $m[1].Int;
            $colour = $m[2].Str;
            for (^$count) {
                ( $x, $y ) = ( $x + %dirs{$dir}[0], $y + %dirs{$dir}[1] );
                self.add-point(Trench.new(:$x,:$y,:$colour));
                $!min-x = $x if $x <= ($!min-x//Inf);
                $!min-y = $y if $y <= ($!min-y//Inf);
                $!max-x = $x if $x >= ($!max-x//-Inf);
                $!max-y = $y if $y >= ($!max-y//-Inf);
            }
        }
    }

    method point-inside(:$x, :$y, :$edge = False) {
        return $edge if self.point-at(:$x,:$y);
        my $u = [+] ($!min-y..^$y).map( { self.point-at(:$x,y => $_) ?? 1 !! 0 });
        my $d = [+] ($y^..$!max-y).map( { self.point-at(:$x,y => $_) ?? 1 !! 0 });
        my $l = [+] ($!min-x..^$x).map( { self.point-at(x => $_,:$y) ?? 1 !! 0 });
        my $r = [+] ($x^..$!max-x).map( { self.point-at(x => $_,:$y) ?? 1 !! 0 });
        
        return ! [||] ($u,$d,$l,$r).map(* %% 2); 
    }

    method fill-start {
        for ($!min-y^..^$!max-y) -> $y {
            for ($!min-x^..^$!max-x) -> $x {
                return ${x => $x,y => $y} if self.point-inside(:$x,:$y);
            }
        }
    }

    method adj( :$x, :$y ) {
        my @o;
        for ( ${ x => $x, y => $y+1}, ${x=>$x+1, y => $y},
              ${ x => $x, y => $y-1}, ${x=>$x-1, y => $y} ) -> %d {
            @o.push(%d) unless self.point-at(|%d);
        }
        return @o;
    }
    
    method fill {
        my @to-do;
        @to-do.push( self.fill-start );
        while (@to-do) {
            my $p = @to-do.shift;
            next if self.point-at(|$p);
            self.add-point(Trench.new(|$p,colour => '#ffffff'));
            @to-do.push(|self.adj(|$p));
        }
        return self;
    }

    method volume {
        [+] $!points.values.map(*.values.elems);
    }
}

sub translate( Str $dig ) {
    my $m = $dig.match(/^ .+ '(#' (. ** 5)(.) ')' $/);
    my $dir = ('R','D','L','U')[$m[1].Str];
    my $dist = :16($m[0].Str).base(10);
    "$dir $dist (0)";
}

multi sub MAIN('test') {
    use Test;
    ok my $dig = Dig.new( digs => 'example'.IO.lines );
    is $dig.point-inside(x => 1,y => 1), True;
    is $dig.point-inside(x => 0,y => 0), False;
    is $dig.point-inside(x => 0,y => 3), False;
    is-deeply $dig.fill-start, { x => 1, y => 1 };
    $dig.say;
    is ( [+] ( ($dig.min-x..$dig.max-x) X, ($dig.min-y..$dig.max-y) ).race.grep(
        -> ($x,$y) { $dig.point-inside(:$x,:$y, edge => True ) }
    ).map({1}) ), 62;
    $dig.fill;
    is $dig.volume, 62;
    is translate( 'R 6 (#70c710)'), 'R 461937 (0)';
    $dig = Dig.new( digs => 'example'.IO.lines.map( { translate($_) } ) );

#    $dig.fill;
#    is $dig.volume, 952408144115;
    done-testing;    
}

multi sub MAIN('p1', $file) {
    Dig.new( digs => $file.IO.lines ).fill.volume.say;
}

#multi sub MAIN('p1', $file) {
#    Dig.new( digs => $file.IO.lines.map( { translate($_) } ).fill.volume.say;
#}

