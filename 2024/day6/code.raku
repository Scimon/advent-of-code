use lib '../../lib';
use Grid;
use Point;
use Direction;
class Blocker does Point {
    method Str { '#' }
}

class Guard does Point {
    has Direction $.direction;
}

class Map does Grid[Blocker] {
    has Guard $.guard;
    
    submethod BUILD( :@lines ) {
        $!points = Hash[Hash[Blocker]].new;
        $!empty = '.';
        my $y = 0;
        for @lines -> $line {
            $!max-x //= $line.codes-1;
            my $x = 0;
            for $line.comb -> $val {
                if ( $val ~~ '#' ) {
                    self.add-point( Blocker.new( :$x, :$y ) );
                }
                if ( $val ~~ '^' ) {
                    $!guard = Guard.new( :$x, :$y, direction => Up );
                }
                $x++;
            }
            $y++;
        }
        $!max-y = $y-1;
    }

    method move-guard() {
        my %moves = ( Up => { x => 0, y => -1 }, Down => { x => 0, y => 1 },
                      Left => { x => -1, y => 0 }, Right => { x => 1, y => 0 } ); 
        my %turns = ( Up => Right, Right => Down, Down => Left, Left => Up );
        my $next = { x => $.guard.x + %moves{$.guard.direction}<x>,
                     y => $.guard.y + %moves{$.guard.direction}<y> };
        if ( self.point-at( x => $next<x>, y => $next<y> ) ) {
            $!guard = Guard.new( x => $.guard.x, y => $.guard.y, direction => %turns{$.guard.direction} );
        } else {
            $!guard = Guard.new( x => $next<x>, y => $next<y>, direction => $.guard.direction );
        }
    }
}

multi sub MAIN('p1', $file, :$verbose = False ) {
    my $map = Map.new( lines => $file.IO.lines );
    say "{$map.guard.gist} : {$map.guard.direction.Str}" if $verbose;
    my %walked;
    while $map.in-bounds( x => $map.guard.x, y => $map.guard.y ) {
        %walked{$map.guard.gist} = True;
        $map.move-guard;
        say "{$map.guard.gist} : {$map.guard.direction.Str}" if $verbose;
    }
    say %walked.keys.elems;
}

multi sub MAIN('p2', $file ) {
    my $map = Map.new( lines => $file.IO.lines );
    my %walked;
    while $map.in-bounds( x => $map.guard.x, y => $map.guard.y ) {
        %walked{$map.guard.gist} = True;
        $map.move-guard;
    }
    
    %walked.keys.race.grep(
        -> $gist {
            my @p = $gist.split("x");
            my $point = Blocker.new( x => @p[0].Int, y => @p[1].Int );
            check-loop( $file, $point );
        }
    ).elems.say;

}

sub check-loop( $file, $point ) {
    my $map = Map.new( lines => $file.IO.lines );
    $map.add-point( $point );
    my %walked;
    while $map.in-bounds( x => $map.guard.x, y => $map.guard.y ) {
        %walked{"{$map.guard.gist}:{$map.guard.direction.Str}"} = True;
        $map.move-guard;
        return True if %walked{"{$map.guard.gist}:{$map.guard.direction.Str}"};
    }
    return False;        
}

multi sub MAIN('p2.1', $file ) {
    my $main = Map.new( lines => $file.IO.lines );
    my $map = $main.clone;
    my %walked;
    while $map.in-bounds( x => $map.guard.x, y => $map.guard.y ) {
        %walked{$map.guard.gist} = True;
        $map.move-guard;
    }
    
    %walked.keys.race.grep(
        -> $gist {
            my @p = $gist.split("x");
            my $point = Blocker.new( x => @p[0].Int, y => @p[1].Int );
            check-loop-two( $main.clone, $point );
        }
    ).elems.say;

}

sub check-loop-two( $map, $point ) {
    $map.add-point( $point );
    my %walked;
    while $map.in-bounds( x => $map.guard.x, y => $map.guard.y ) {
        %walked{"{$map.guard.gist}:{$map.guard.direction.Str}"} = True;
        $map.move-guard;
        return True if %walked{"{$map.guard.gist}:{$map.guard.direction.Str}"};
    }
    return False;        
}
