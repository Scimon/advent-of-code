#!/usr/bin/env raku

class Pos {
    has Int $.x = 0;
    has Int $.y = 0;

    method dist (Pos $o) {
        return ( ($.x-$o.x)**2 + ($.y-$o.y)**2).sqrt;
    }

    method touching (Pos $o) {
        -1 <= all( $.x-$o.x, $.y-$o.y) <= 1;  
    }

    method add (Pos $o) {
        return Pos.new( x => $.x + $o.x, y => $.y + $o.y );
    }

    method towards (Pos $o) {
        return Pos.new(
            x => $.x + ($o.x > $.x ?? 1 !! ($o.x < $.x ?? -1 !! 0 ) ),
            y => $.y + ($o.y > $.y ?? 1 !! ($o.y < $.y ?? -1 !! 0 ) ),
        );
    }
    
    method gist { "{$.x}x{$.y}" }
}

multi sub infix:<+> ( Pos $a, Pos $b ) {
    $a.add($b);
}

role SnakeRopePos {
    has Pos $.pos = Pos.new();
    has @.pos-log;
    
    method log {
        @.pos-log.push($!pos.gist);
    }
    
    submethod TWEAK {
        self.log();
    }

    method gist { "{$.pos.gist}" }
}

class SnakeRopeHead does SnakeRopePos {
    my %moves = (
        'U' => Pos.new(:0x, :y(-1)),
        'D' => Pos.new(:0x,:1y),
        'L' => Pos.new(:x(-1),:0y),
        'R' => Pos.new(:1x,:0y),
    );

    method move( $dir ) {
        $!pos += %moves{$dir};
        self.log();
        return self;
    }
}

class SnakeRopeBody does SnakeRopePos {
    has SnakeRopePos $.following;
    
    method move( $dir ) {
        $!pos.=towards($.following.pos)
                      unless $!pos.touching($.following.pos);
        self.log();
        return self;
    }
}

class SnakeRope {
    has SnakeRopeHead $.head;
    has @.body;

    method BUILD( :$length ) {
        $!head = SnakeRopeHead.new();
    }

    method TWEAK ( :$length ) {
        my $next = $!head;
        for ^$length {
            my $new = SnakeRopeBody.new(:following($next));
            @!body.push($new);
            $next = $new;
        }
        
    }

    method move( $dir, $count ) {
        for ^$count {
            $!head .= move( $dir );
            .=move( $dir ) for @!body;
        }
    }
    
    method tail-log {
        @!body[*-1].pos-log;
    }
    
    method gist {
        join( "=", ($.head, |@.body).map(*.gist) );
    }
}

sub moves($f) {
    $f.IO.lines.map( *.split(" ").list );
}

multi sub MAIN("TEST") {
    use Test;
    my $p1 = Pos.new(:0x,:0y);
    is $p1.dist(Pos.new(:0x,:1y)),1;
    is $p1.dist(Pos.new(:3x,:4y)),5;
    is ($p1 + Pos.new(:1x,:1y)).gist, '1x1';
    my $h = SnakeRopeHead.new();
    is $h.pos.gist, "0x0";    
    my $s1 = SnakeRope.new(:length(1));
    is $s1.gist, "0x0=0x0";
    is-deeply $s1.tail-log, ["0x0"];
    $s1.move('U',2);
    is $s1.gist, "0x-2=0x-1";
    my $snake = SnakeRope.new(:length(1));
    my $long-snake = SnakeRope.new(:length(9));
    for moves("day-9-test.txt") -> $move {
        $snake.move(|$move);
        $long-snake.move(|$move);
    }
    is $snake.gist, "2x-2=1x-2";
    is $snake.tail-log.Set.elems, 13;
    is $long-snake.gist, "2x-2=1x-2=2x-2=3x-2=2x-2=1x-1=0x0=0x0=0x0=0x0";
    is $long-snake.tail-log.Set.elems, 1;
    done-testing;
}

multi sub MAIN($length, $f) {
    my $snake = SnakeRope.new(:$length);
    for moves($f) -> $move {
        $snake.move(|$move);
    }
    say $snake.tail-log.Set.elems;
}
