#!/usr/bin/env raku

class Mirror {
    has Int $.x;
    has Int $.y;
    has Str $.type;

    method Str() { $.type }
    method gist() { "{$!x}x{$!y}:{$!type}" }
}

class Cave {
    has %.mirrors;
    has Int $.min-x = 0;
    has Int $.min-y = 0;
    has Int $.max-x;
    has Int $.max-y;
            
    method mirror-at(:$x,:$y) {
        %.mirrors{$x}{$y};
    }

    method add-mirror($mirror) {
        %.mirrors{$mirror.x} //= {};
        %.mirrors{$mirror.x}{$mirror.y} = $mirror;
    }

    method remove-mirror($mirror) {
        %.mirrors{$mirror.x}{$mirror.y}:delete;
    }
    
    submethod BUILD( :@lines ) {
        %!mirrors := {};
        my $y = 0;
        for @lines -> $line {
            $!max-x //= $line.codes-1;
            my $x = 0;
            for $line.comb -> $type {
                self.add-mirror( Mirror.new( :$x, :$y, :$type ) ) if $type ne '.';
                $x++;
            }
            $y++;
        }
        $!max-y = $y-1;
    }

    method gist() {
        my @out = [];
        for (0..self.max-y) -> $y {
            my @row = [];
            for (0..self.max-x) -> $x {
                @row.push(self.mirror-at(:$x,:$y) ?? self.mirror-at(:$x,:$y).Str !! '.');
            }
            @out.push(@row);
        }
        return @out.map(*.join('')).join("\n");
    }

    method route(%energy) {
        my @out = [];
        for (0..self.max-y) -> $y {
            my @row = [];
            for (0..self.max-x) -> $x {
                if ( self.mirror-at(:$x,:$y) ) {
                    @row.push(self.mirror-at(:$x,:$y).Str)
                } elsif ( %energy{"{$x}x{$y}"} ) { 
                    @row.push( %energy{"{$x}x{$y}"}.keys.elems > 1 ?? 
                                 %energy{"{$x}x{$y}"}.keys.elems !! 
                                 %energy{"{$x}x{$y}"}.keys[0] ) 
                }
                else { @row.push('.') }
            }
            @out.push(@row);
        }
        return @out.map(*.join('')).join("\n");
    }

    method energized(%energy) {
        my @out = [];
        for (0..self.max-y) -> $y {
            my @row = [];
            for (0..self.max-x) -> $x {
                if ( %energy{"{$x}x{$y}"} ) { 
                    @row.push('#') 
                } elsif ( self.mirror-at(:$x,:$y) ) {
                    @row.push(self.mirror-at(:$x,:$y).Str)
                } 
                else { @row.push('.') }
            }
            @out.push(@row);
        }
        return @out.map(*.join('')).join("\n");
    }
}

enum Dir <Up Down Left Right>;

class BeamPoint {
    has Int $.x;
    has Int $.y;
    has Dir $.dir;

    my %dir-arrows = ( Up => '^', Down => 'v',
                       Right => '>', Left => '<' );

    my %dir-moves =  ( Up => (0,-1), Down => (0,1),
                       Right => (1,0), Left => (-1,0) );

    
    method Str { %dir-arrows{$!dir} };
    method gist {"{$!x}x{$!y}"};

    method next($cave) {
        my %n = ( x => $!x + %dir-moves{$!dir}[0],
                  y => $!y + %dir-moves{$!dir}[1] );
        return [] unless $cave.min-x <= %n<x> <= $cave.max-x;
        return [] unless $cave.min-y <= %n<y> <= $cave.max-y;
        my $mirror = $cave.mirror-at(|%n);
        if ( ! $mirror ) {
            %n<dir> = $!dir;
            return [ BeamPoint.new(|%n) ];
        }
        return do given $mirror.type {
            when '/' {
                %n<dir> = do given $!dir {
                    when Up { Right }
                    when Down { Left }
                    when Left { Down }
                    when Right { Up }
                };
                [ BeamPoint.new(|%n) ];
            };
            when "\\" {
                %n<dir> = do given $!dir {
                    when Up { Left }
                    when Down { Right }
                    when Left { Up }
                    when Right { Down }
                };
                [ BeamPoint.new(|%n) ];
            };
            when '|' {
                given $!dir {
                    when Up | Down {
                        %n<dir> = $!dir;
                        [ BeamPoint.new(|%n) ];
                    }
                    when Left | Right {
                        [ BeamPoint.new(|%n, dir => Up), BeamPoint.new(|%n, dir => Down) ];
                    }
                }
            }   
            when '-' {
                given $!dir {
                    when Left | Right {
                        %n<dir> = $!dir;
                        [ BeamPoint.new(|%n) ];
                    }
                    when Up | Down {
                        [ BeamPoint.new(|%n, dir => Left), BeamPoint.new(|%n, dir => Right) ];
                    }
                }

            }        
        }
    }
}

multi sub MAIN('test') {
    use Test;
    my $example = 'example'.IO.slurp;
    my $cave = Cave.new( lines => $example.lines );
    is $cave.gist, $example, 'Parse Input OK';
    ok my $bp = BeamPoint.new( :0x, :0y, dir => Right ), 'Able to make a beam point';
    is $bp.gist, '0x0', "Got expected gist"; 
    is $bp.Str, '>', "Got expected Str";    
    is-deeply $bp.next($cave), [
        BeamPoint.new( :1x, :0y, dir => Up ),
        BeamPoint.new( :1x, :0y, dir => Down ) ],
    'BeamPoints can move and split';
    is-deeply BeamPoint.new( :1x, :0y, dir => Up ).next($cave), [], 'Out of bounds';
    is-deeply BeamPoint.new( :1x, :0y, dir => Down ).next($cave), [ BeamPoint.new( :1x :1y, dir => Down )], 'Nothing';
    is-deeply BeamPoint.new( :2x, :7y, dir => Right ).next($cave), [ BeamPoint.new( :3x :7y, dir => Right )], 'Through';  
    is-deeply BeamPoint.new( :3x, :7y, dir => Right ).next($cave), [ BeamPoint.new( :4x :7y, dir => Up )], 'Bounce';  
    my %seen = find-route($cave, $bp);
    $cave.energized(%seen).say;
    is %seen.keys.elems, 46, 'Get exepected energization';

    my $small = Cave.new( lines => 'small'.IO.lines );
    $small.say;
    %seen = find-route($small, BeamPoint.new( x => -1, :0y, dir => Right ) );
    %seen.say;
    $small.route(%seen).say;
    is %seen.keys.elems, 4;

    done-testing;

}

sub find-route($cave, $bp) {
    my %seen;
    my @points = [$bp];
    while (@points) {
        my $next = @points.shift;
        if ( 
             $next.x >= $cave.min-x && $next.y >= $cave.min-y &&
             $next.x <= $cave.max-x && $next.y <= $cave.max-y
           ) {
            %seen{$next.gist} //=  {};
            next if %seen{$next.gist}{$next.Str};
            %seen{$next.gist}{$next.Str}++;
        }
        @points.push(|$next.next($cave));
    }
    return %seen;
}

my %*SUB-MAIN-OPTS = (:named-anywhere);

multi sub MAIN('p1', $file, :$debug = False) {
    my $cave = Cave.new( lines => $file.IO.lines );
    $cave.say if $debug;
    '---'.say if $debug;
    my $bp = BeamPoint.new( x => -1, :0y, dir => Right );

    my %seen = find-route($cave, $bp);
    $cave.route(%seen).say if $debug;
    '---'.say if $debug;
    $cave.energized(%seen).say if $debug;
    '---'.say if $debug;
    %seen.keys.elems.say;


}

multi sub MAIN('p2', $file) {
    my $cave = Cave.new( lines => $file.IO.lines );
    my @beams = [ 
        |(0..$cave.max-x).map( { BeamPoint.new( x => $_, y => -1, dir => Down ) }),
        |(0..$cave.max-x).map( { BeamPoint.new( x => $_, y => $cave.max-y+1, dir => Up ) }),
        |(0..$cave.max-y).map( { BeamPoint.new( x => -1, y => $_, dir => Right ) }),
        |(0..$cave.max-y).map( { BeamPoint.new( x => $cave.max-x+1, y => $_, dir => Down ) }),
    ];

    my %seen = @beams.race.map( -> $bp { find-route( $cave, $bp )} ).sort({ $^b.keys.elems <=> $^a.keys.elems }).first;
    %seen.keys.elems.say;
}
