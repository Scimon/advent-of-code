#!/usr/bin/env raku

sub LEFT {...}
sub RIGHT {...}

class Tube {
    has $.width = 7;
    has %.filled;
    has @.jets;
    has $!j-index = 0;
    has $.highest = 0;

    method create( Str $jet-string ) {
        return Tube.new( jets => $jet-string.comb );
    }

    method jet {
        my $next = @.jets[$!j-index];
        $!j-index++;
        $!j-index = 0 if $!j-index ~~ @.jets.elems;
        return $next;
    }

    method end-rocks($x,$y,@rocks) {
        for @rocks -> [$dx, $dy] {
            %!filled{$x+$dx}{$y+$dy} = True;
            $!highest = $y+$dy+1 if $y+$dy+1 > $!highest;
        }
    }

    method draw($height = $.highest) {
        my @out;
        for ^$.width -> $x {
            for ^$height -> $y {
                @out[$height-$y-1] //= [];
                @out[$height-$y-1][$x] = %!filled{$x}{$y} ?? '#' !! '.';
            }
        }
        return @out;
    }
    
    method gist {
        $.draw($.highest).map(->@a {('|',|@a,'|').join('')}).join("\n") ~ "\n+-------+";
    }
}

role Rock {
    has $.x; # Left most point
    has $.y; # Bottom most point
   
    method rocks {...}
    multi method move($dir, Tube $t) {
        my ($dx, $dy);
        $dx = $dir ~~ LEFT() ?? -1 !! 1;
        my @pos = self.rocks.map({$_[0]+$!x+$dx,$_[1]+$!y});
        for @pos -> [$x,$y] {
            if ( $x < 0 || $x >= $t.width ) { $dx = 0 }
            if ( $t.filled{$x}{$y} ) { $dx = 0 }
        }
        $dy = -1;
        @pos = self.rocks.map({$_[0]+$!x+$dx,$_[1]+$!y+$dy});
        for @pos -> [$x,$y] {
            if ( $y < 0 ) { $dy = 0 }
            if ( $t.filled{$x}{$y} ) { $dy = 0 }
        }
        if ( $dy != 0 ) {
            $!x += $dx;
            $!y += $dy;
            return True;
        } else {
            $!x += $dx;
            $t.end-rocks($!x,$!y,self.rocks);
            return False;
        }
    } 

    method draw($tube) {
        my $max = $.y + 4;
        my @poss = $tube.draw($.y+4);
        for self.rocks -> [$x, $y] {
            @poss[$max - ($.y+$y)][$.x+$x] = '@';
        }
        @poss.map(->@a {('|',|@a,'|').join('')}).join("\n") ~ "\n+-------+";
    }
    
    method gist {
        my @out = [ [" " for  ^4] for ^4];
        for self.rocks() -> [$x,$y] {
            @out[3-$y][$x] = '#';
        }               
        @out.map(*.join('')).join("\n");
    }
}

class Straight does Rock {
    method rocks { [[0,0],[1,0],[2,0],[3,0]] }
}

class Cross does Rock {
    method rocks { [[1,0],[0,1],[1,1],[2,1],[1,2]] }
}

class LPiece does Rock {
    method rocks { [[0,0],[1,0],[2,0],[2,1],[2,2]] }
}

class Down does Rock {
    method rocks { [[0,0],[0,1],[0,2],[0,3]] }
}

class Square does Rock {
    method rocks { [[0,0],[0,1],[1,0],[1,1]] }
}

class RockFall {
    has @!rocks = [Straight, Cross, LPiece, Down, Square];
    has $!r-index = 0;

    method next-rock {
        my $next = @!rocks[$!r-index];
        $!r-index++;
        $!r-index = 0 if $!r-index ~~ @!rocks.elems;
        return $next;
    }    
}

multi sub MAIN('TEST') {
    use Test;
    my @out = (1,4,6,7,9,10,13,15,17,17);
    for ^@out {
        my $t = rocks-fall('day-17-test.txt',$_+1);
        is $t.highest,@out[$_];
        $t.say;
    }
#    my $tube = rocks-fall('day-17-test.txt',10,:verbose);
#    say $tube.gist;
    done-testing;
}

sub rocks-fall($fh,$count,:$verbose=False,:$show=False) {
    my $tube = Tube.create($fh.IO.slurp.chomp);
    my $fall = RockFall.new;
    my $idx = 0;
    my $falling = False;
    my ( $rock, $jet );
    my @jets;
    while ( $idx < $count ) || ( $falling ) {
        if ( ! $falling ) {
            $rock = $fall.next-rock.new(:x(2),:y($tube.highest + 3));
            $idx++;
            note "{$idx} : {$tube.highest}" if $show;
        }
        $jet = $tube.jet;
        @jets.push($jet);
        $falling = $rock.move($jet,$tube);
    }
    return $tube;
}

multi sub MAIN(1,$fh,$count,:$show=False) {
    say rocks-fall($fh, $count,:$show).highest;
}

multi sub MAIN(2,$fh,$count) {
    my $jet-length = $fh.IO.slurp.chomp.comb.elems;
    my $cycle = 5 * $jet-length;
    my $tube = rocks-fall($fh,$cycle);
    my $height = $tube.highest + 1;
    note "Jets {$jet-length} Cycle {$cycle} height {$height}";
    my $skipped = ( ( $count div $cycle ) * $height );
    note "Skipping {$skipped} of {$count div $cycle}";
    note "Calculating {$count % $cycle}";
    $tube = rocks-fall($fh,($count % $cycle));
    note $tube.highest;
    say $tube.highest + $skipped;
    
}

sub LEFT { '<' }
sub RIGHT { '>' }
