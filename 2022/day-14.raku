#!/usr/bin/env raku

class Map {
    has $.min-x = 500;
    has $.max-x = 500;
    has $.min-y = 0;
    has $.max-y = 0;
    has %.walls = {};
    has %.sand = {};
    has $.floor = False;
    
    method check-extents( $x1, $y1, $x2, $y2 ) {
        $!min-x = $x1 if $x1 < $!min-x;
        $!max-x = $x2 if $x2 > $!max-x;
        $!min-y = $y1 if $y1 < $!min-y;
        $!max-y = $y2 if $y2 > $!max-y;
    }
    
    multi method add-wall( $x, $y, 0, $d ) {
        self.check-extents( $x, $y, $x, $y+$d);
        for 0..$d {
            %.walls{$x}{$y+$_} = True;
        }
    }

    multi method add-wall( $x, $y, $d, 0 ) {
        self.check-extents( $x, $y, $x+$d, $y);
        for 0..$d {
            %.walls{$x+$_}{$y} = True;
        }
    }

    method add-sand($x,$y) {
        if ( $.floor ) {
            if ($x == 500 && $y == 0 && $.sand{$x}{$y} ) { return False }
            if ( $y == $.max-y + 1 ) {
                self.check-extents($x,0,$x,0);
                $.sand{$x}{$y} = True;
                return True;
            }
        } else {
            if ( $y > $.max-y ) { return False }
        }
        if (! ($.walls{$x}{$y+1}|$.sand{$x}{$y+1}) ) {
            return self.add-sand($x,$y+1);
        }
        if (! ($.walls{$x-1}{$y+1}|$.sand{$x-1}{$y+1}) ) {
            return self.add-sand($x-1,$y+1);
        }
        if (! ($.walls{$x+1}{$y+1}|$.sand{$x+1}{$y+1}) ) {
            return self.self.add-sand($x+1,$y+1);
        }
        $.sand{$x}{$y} = True;
        return True;
    }
    
    method gist {
        my @out;
        for $.min-y..( $.floor ?? $.max-y+1 !! $.max-y) -> $y {
            my @row;
            for $.min-x..$.max-x -> $x {
                if ($x ~~ 500 && $y ~~ 0) {
                   @row.push('+')
                } elsif %.walls{$x}{$y} {
                   @row.push('#');
                } elsif %.sand{$x}{$y} {
                   @row.push('o');
                } else {
                   @row.push(' ');
                }
            }
            @out.push(@row.join(""));
        }
        if ( $.floor ) {
            my $width = $.max-x-$.min-x + 1;
            @out.push( '#' x $width );            
        }
        
        @out.join("\n") ~ "\n{$.min-x}x{$.min-y} => {$.max-x}x{$.max-y}";
    }
    
}

sub parse($f) {
    my @out;
    for $f.IO.lines -> $line {
        my ( $first, $next ) = (Nil,Nil);
        for $line.split(' -> ') -> $point {
            my $pair = $point.split(",").list;
            ( $first, $next ) = ( $next, $pair );
            if ( $first && $next ) {
                my %rule = (
                  'x'  => min(+$first[0],+$next[0]),
                  'y'  => min(+$first[1],+$next[1]),
                  'dx' => abs($first[0]-$next[0]),
                  'dy' => abs($first[1]-$next[1]),
            );
                @out.push(%rule);
            }
        }
    }
    return @out;
}

my %*SUB-MAIN-OPTS = :named-anywhere;

multi sub MAIN('draw',$f,:$floor=False) {
    my $map = Map.new(:$floor);
    for parse($f) -> $wall {
        $map.add-wall($wall<x>,$wall<y>,$wall<dx>,$wall<dy>);
    }
    say $map.gist;
}

multi sub MAIN('sand',$count,$f,:$floor=False) {
    my $map = Map.new(:$floor);
    for parse($f) -> $wall {
        $map.add-wall($wall<x>,$wall<y>,$wall<dx>,$wall<dy>);
    }
    for ^$count {
        $map.add-sand(500,0);
        say $map.gist;
    }
}

multi sub MAIN(1,$f,:$gist=False) {
    do-main($f,False,$gist);
}
multi sub MAIN(2,$f,:$gist=False) {
    do-main($f,True,$gist);
}

sub do-main($f,$floor,$gist) {
    my $map = Map.new(:$floor);
    for parse($f) -> $wall {
        $map.add-wall($wall<x>,$wall<y>,$wall<dx>,$wall<dy>);
    }
    my $count = 0;
    while $map.add-sand(500,0) {
        $count++;
    }
    say $map.gist if $gist;
    say $count;
}
