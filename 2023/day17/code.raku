#!/usr/bin/env raku

use lib '../../lib';
use Point;
use Grid;
use Direction;

class Move {
    use Direction;

    has Int $.x;
    has Int $.y;
    has Int $.score;
    has Direction $.move;
    has Int $.move-count;

    method Str { "{$!x}x{$!y}:{$.score}" };
    method m-dist(Point $p) {
        abs($.x - $p.x) + abs($.y - $p.y);
    }

}

class Block does Point {
    has Int() $.score;
    has Int $.best-score;
    has Direction $.best-move;
    has Int $.best-count;
    
    method Str { $!score }
    method gist { "{$!x}x{$!y}" }
    submethod BUILD( :$!x, :$!y, :val($!score) ) {}

    method incoming(Move $move) {
        my $new-score = $!score + $move.score;
        if ( ( $!best-score // Inf ) >= $new-score ) {
            $!best-score = $new-score;
#            $!best-move = $move.move;
#            $!best-count = $move.move-count;
            return True;
        }
        return False;
#        if ( $!best-score < $new-score ) { return False }
#        if ( ( $!best-count // Inf ) > $move.move-count ) {
#            $!best-move = $move.move;
#            $!best-count = $move.move-count;
#            return True;
#        }
#        return True;
    }

    my %move-opts = ( Up => [Up, Left, Right],
                      Down => [Down, Right, Left],
                      Left => [Left, Up, Down],
                      Right => [Right, Down, Up] );

    my %move-vals = ( Up => (0,-1), Down => (0,1),
                      Left => (-1,0), Right => (1,0) );

    method neighbours($city) {
        %move-vals.keys.map(
            -> $dir {
                my $diff = %move-vals{$dir};
                my ( $x, $y ) = ( $!x + $diff[0], $!y + $diff[1] );
                next unless $city.in-bounds(:$x,:$y);
                $city.point-at(:$x,:$y);
            });
    }
    
    method moves(Move $move, Grid() $city) {
        my @ret;
        for (@(%move-opts{$move.move})) -> $dir {
            my $diff = %move-vals{$dir};
            my ( $x, $y ) = ( $!x + $diff[0], $!y + $diff[1] );
            next unless $city.in-bounds(:$x,:$y);
            my $score = $move.score + $!score;
            if ( $dir ~~ $move.move ) {
                next if $move.move-count >= 3;
                @ret.push(
                    Move.new( :$x, :$y, score => $score,
                              move => $dir, move-count => $move.move-count+1 )
                );
            } else {
                @ret.push(
                    Move.new( :$x, :$y, score => $score,
                              move => $dir, move-count => 1 )
                );
            }           
        }
        return @ret;
    }

}


class City does Grid[Block] {
    use Direction;

    method start {
        ( Move.new( x => 1, y => 0, score => 0, move => Right, move-count => 1 ),
          Move.new( x => 0, y => 1, score => 0, move => Down,  move-count => 1 ) )
    }

    method move-to( Move $move ) {
        my $block = self.point-at( x => $move.x, y => $move.y );
        if ( $block.incoming( $move ) ) {
            return $block.moves($move, self);
        }
        return [];
    }

    method best-score {
        self.point-at(x => $!max-x, y => $!max-y).best-score;
    }
}

multi sub MAIN('test') {
    use Test;


    my $test = "123\n345\n456";
    my $city = City.new( lines => $test.lines );
    say $city;
    is $city.gist, $test, "Got the gist";
    is $city.max-x, 2, "Got the max x val OK";
    is $city.max-y, 2, "Got the max y val OK";
    is $city.point-at(:0x,:0y).gist, "0x0:1", "Got the point"; 
    
    is-deeply $city.start, (
        Move.new( x => 1, y => 0, score => 0, move => Right, move-count => 1 ),
        Move.new( x => 0, y => 1, score => 0, move => Down,  move-count => 1 ) );

    is-deeply $city.point-at(x=>0,y=>0).moves(
        Move.new(x => 0,y => 0,score => 0,move => Right,move-count => 1), $city
    ), [
        Move.new(x=>1,y=>0,score=>1,move => Right, move-count => 2),
        Move.new(x=>0,y=>1,score=>1,move => Down, move-count => 1)
       ], 'Got expected moves';
    
    is-deeply $city.move-to(
        Move.new( x => 1, y => 0, score => 0, move => Right, move-count => 1 )
    ), [
        Move.new( x => 2, y => 0, score => 2, move => Right, move-count => 2 ),
        Move.new( x => 1, y => 1, score => 2, move => Down, move-count => 1 )
    ], 'Got expected moves';

    $city = City.new( lines => $test.lines );
    my @opts = $city.start.Array;
    while (@opts) {
        my $move = @opts.shift;
        @opts.push( |$city.move-to($move) );
    }
    
    say $city.point-at(x => 2, y => 2).raku;
    
    done-testing;
}

sub make-path(%cameFrom, $current is copy) {
    my @path = [$current.gist];
    while (%cameFrom{$current.gist}) {
        $current = %cameFrom{$current.gist};
        @path.unshift($current);
    }
    return @path;
}

sub d(Block $current, Block $neighbour, %cameFrom, $city) {
    my $score = $neighbour.score;
    my @path = make-path(%cameFrom, $current).map({$city.point-at($_) });
    say "{$neighbour.gist} : $score";
    return $score if @path.elems < 4;
    return Inf if @path[*-2] ~~ $neighbour; 
    return Inf if abs(@path[*-1].x - @path[*-4].x) > 3;
    return Inf if abs(@path[*-1].y - @path[*-4].y) > 3;
    return $score;
}

sub a-star($city) {
    my $start = $city.point-at(x => 0, y => 0);
    my $end = $city.point-at(x => $city.max-x, y => $city.max-y);

    my @openSet = [$start];
    my %cameFrom;
    my %gScore = ( $start.gist => 0 );

    my %fscore = ( $start.gist => $start.m-dist($end) );

    while (@openSet) {
        %fscore.say;
        @openSet.= sort( { (%fscore{$^a.gist} // Inf ) <=> ( %fscore{$^b.gist} // Inf ) } ).Array;
        @openSet.say;
        my $current = @openSet.shift;
        $current.raku.say;
        if ($current.gist ~~ $end.gist) {
            return make-path( %cameFrom, $current );
        }
        for ($current.neighbours($city)) -> $neighbor {
            say 'n:',$neighbor.raku;
            my $tentative_gScore = %gScore{$current.gist} + d($current, $neighbor, %cameFrom, $city);
            say $current.gist,":", $tentative_gScore;
            say 'g:', %gScore;
            say 'c:', %cameFrom;
            if $tentative_gScore < ( %gScore{$neighbor.gist} // Inf ) {
                %cameFrom{$neighbor.gist} = $current.gist;
                %gScore{$neighbor.gist} = $tentative_gScore;
                %fscore{$neighbor.gist} = $tentative_gScore + $neighbor.m-dist($end);
                if (! @openSet.grep( { $_.gist ~~ $neighbor.gist } ) ) {
                    @openSet.push($neighbor)
                }
            }
        }
    }
}

multi sub MAIN('p1-a', $file) {
    my $city = City.new( lines => $file.IO.lines );
    my @path = a-star($city);
    say @path;
    say ( [+] @path.map( { $city.point-at($_).score } ) ) - $city.point-at('0x0').score;
}

multi sub MAIN('p1', $file) {
    my $city = City.new( lines => $file.IO.lines );
    my @opts = $city.start.Array;
    my %seen;
    my $c = 0;
    my $end = $city.point-at(x => $city.max-x, y => $city.max-y);
    while (@opts) {
        say ++$c,':',@opts.elems,':',@opts[0].score,':',@opts[0].m-dist($end),':',($city.best-score//Inf);
        my $move = @opts.shift;
        next if $move.score + $move.m-dist($end) > ($city.best-score//Inf);
        next if %seen{$move.Str};
        %seen{$move.Str}++;
        @opts.push( |$city.move-to($move).grep({$_.score + $_.m-dist($end) <= ($city.best-score//Inf)}) );
        @opts = @opts.sort( { $^a.m-dist($end) <=> $^b.m-dist($end)
#                            } )
#                 .grep( {
#                   $_.score + $_.m-dist($end) <= ($city.best-score//Inf)
                 }); 
    }
    %seen.keys.elems.say;
    say (($city.max-x+1) * ($city.max-y+1));
    $city.best-score.say;
}
