#!/usr/bin/env raku

enum Direction <North South East West>;

class Rock {
    has Int $.x;
    has Int $.y;
    has Bool $.moves = False;

    method weight () { +$!moves }
    method Str() { $!moves ?? 'O' !! '#' }
    method gist() { $!x ~ 'x' ~ $!y ~ ':' ~ self.Str }

}

class Mirror {
    has %.rocks;
    has Int $.min-x = 0;
    has Int $.min-y = 0;
    has Int $.max-x;
    has Int $.max-y;
            
    method rock-at(:$x,:$y) {
        %.rocks{$x}{$y};
    }

    method add-rock($rock) {
        %.rocks{$rock.x} //= {};
        %.rocks{$rock.x}{$rock.y} = $rock;
    }

    method remove-rock($rock) {
        %.rocks{$rock.x}{$rock.y}:delete;
    }
    
    method move-list(Direction $dir) {
        my @rocks = %.rocks.values.map( |*.values );
        given $dir {
            when North { return @rocks.sort({ $^a.y <=> $^b.y }) }
            when South { return @rocks.sort({ $^b.y <=> $^a.y }) }
            when East { return @rocks.sort({ $^b.x <=> $^a.x }) }
            when West { return @rocks.sort({ $^a.x <=> $^b.x }) }
        }
        return @.rocks;
    }

    method load(Direction $dir) {
        [+] self.move-list($dir).map(
            -> $r {
                do given $dir {
                    when North { $r.weight * ($!max-y - $r.y + 1 )}
                    default { 0 }
                }
            });
    }
    
    method move(Direction $dir) {
        my %moves = ( North => { x => 0,  y => -1 },
                      South => { x => 0,  y => 1  },
                      East  => { x => 1,  y => 0  },
                      West  => { x => -1, y => 0  });
        ROCK: for self.move-list($dir) -> $rock is rw {
            next unless $rock.moves;
            my %pos = ( x => $rock.x, y => $rock.y );
            my $first = True;
            MOVE: loop {
                my %new-pos = ( x => %pos<x> + %moves{$dir}<x>,
                                y => %pos<y> + %moves{$dir}<y>, );
                last MOVE if self.rock-at( |%new-pos );
                last MOVE unless $!min-x <= %new-pos<x> <= $!max-x;
                last MOVE unless $!min-y <= %new-pos<y> <= $!max-y;
                %pos = %new-pos;                
            }
            self.remove-rock($rock);       
            %pos<moves> = True;
            self.add-rock(Rock.new( |%pos ));
        }
        self;
    }

    method cycle() {
        for (North, West, South, East) -> $dir { self.move($dir); }
        self;
    }
    
    submethod BUILD( :@lines ) {
        %!rocks := {};
        my $y = 0;
        for @lines -> $line {
            $!max-x //= $line.codes-1;
            my $x = 0;
            for $line.comb -> $p {
                self.add-rock( Rock.new( :$x, :$y, :moves ) ) if $p eq 'O';
                self.add-rock( Rock.new( :$x, :$y ) ) if $p eq '#';
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
                @row.push(self.rock-at(:$x,:$y) ?? self.rock-at(:$x,:$y).Str !! '.');
            }
            @out.push(@row);
        }
        return @out.map(*.join('')).join("\n");
    }
}

sub cycle-length(@a) {
    my $max = @a.elems div 2;
    my @test = @a.reverse;
    for (3..$max) -> $length {
        if (@test[^$length] ~~ @test[$length..^($length*2)] ) { return $length }
    }
    return 0;
}

sub find-cycle($mirror) {
    my @loads = [$mirror.load(North)];

    my $length;
    loop {
        my $next = $mirror.cycle.load(North);
        $length = cycle-length(@loads);
        if $length {
            last if (@loads[*-$length] == $next);
        }
        @loads.push( $next );
        @loads.elems.say;
    }

    return { length => $length, load => @loads[0..^(*-$length)] };
}

sub calc-value(@loads,$cycle-length, $idx) {
    return @loads[$idx] if $idx < @loads.elems;
    my $shift-idx = (@loads.elems - $cycle-length);
    my $cycle-idx = ($idx - $shift-idx) % $cycle-length;
    @loads[$shift-idx + $cycle-idx];
}

multi sub MAIN('test') {
    use Test;
    is Mirror.new(lines => 'complete'.IO.lines ).load(North), 136;
    my $example = Mirror.new(lines => 'example'.IO.lines);
    is $example.load(North), 10 + (3*9) + (4*7) + (2*6) + (2*5) + (3*4) + 3 + 2, 'Example starting load correct';
    $example.move(North);
    is $example.load(North), 136;

    is cycle-length([1,2,3,1,2,3]), 3;
    is cycle-length([5,6,1,2,1,4,1,2,1,4]), 4;
    is cycle-length([1,2,3]),0;
    
    $example = Mirror.new(lines => 'example'.IO.lines);
    #    (^100).map( { $example.cycle; $example.load(North) } ).say;
    $example.say;
    my %result = find-cycle($example);
    my $loads = %result<load>;
    my $cycle-length = %result<length>;
    is $cycle-length, 7, 'Got length';
    is $loads, [104,87,69,69,69,65,64,65,63,68], 'Got loads';
    is calc-value($loads,$cycle-length, 0), 104, 'l0';
    is calc-value($loads,$cycle-length, 1), 87, 'l1';
    is calc-value($loads,$cycle-length, 9), 68, 'l9';
    is calc-value($loads,$cycle-length, 10), 69, 'l10';
    is calc-value($loads,$cycle-length, 11), 69, 'l11';
    is calc-value($loads,$cycle-length, 12), 65, 'l12';
    is calc-value($loads,$cycle-length, 13), 64, 'l13';
    is calc-value($loads,$cycle-length, 14), 65, 'l14';
    is calc-value($loads,$cycle-length, 15), 63, 'l15';
    is calc-value($loads,$cycle-length, 16), 68, 'l16';
    is calc-value($loads,$cycle-length, 17), 69, 'l17';
    is calc-value($loads,$cycle-length, 1000000000), 64, 'da big one';
    
    done-testing;
}

multi sub MAIN('p1', $file) {
    my $mirror = Mirror.new(lines => $file.IO.lines);
    $mirror.move(North);
    $mirror.load(North).say;
}

multi sub MAIN('p2', $file) {
    my $mirror = Mirror.new(lines => $file.IO.lines);
    my %result = find-cycle($mirror);
    say %result<length>;
    say %result<load>.elems;
    say calc-value(%result<load>,%result<length>, 1000000000);
    
}
