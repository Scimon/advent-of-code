#!/usr/bin/env raku

class Galaxy {
    has Int $.x;
    has Int $.y;

    method m-dist(Galaxy $g) {
        abs($.x - $g.x) + abs($.y - $g.y);
    }
}

class Universe {
    has Galaxy @.galaxies;
    
    method max-x () {
        @.galaxies.map(*.x).max;
    }
    method max-y () {
        @.galaxies.map(*.y).max;
    }
    method galaxy-at(:$x,:$y) {
        @.galaxies.first( { $_.x == $x && $_.y == $y } );
    }
    method empty-row(:$y) {
        so none(@.galaxies.map(*.y)) == $y;
    }
    method empty-col(:$x) {
        so none(@.galaxies.map(*.x)) == $x;
    }
    method expand-row(:$y,:$expansion) {
        @.galaxies = @.galaxies.map( { $_.y > $y ?? Galaxy.new(x => $_.x, y => $_.y + $expansion) !! $_ } )
    }
    method expand-col(:$x,:$expansion) {
        @.galaxies = @.galaxies.map( { $_.x > $x ?? Galaxy.new(x => $_.x + $expansion, y => $_.y) !! $_ } )
    }
    
    submethod BUILD( :@lines ) {
        @!galaxies = Array[Galaxy].new();
        my $y = 0;
        for @lines -> $line {
            my $x = 0;
            for $line.comb -> $p {
                @!galaxies.push( Galaxy.new( :$x, :$y ) ) if $p eq '#';
                $x++;
            }
            $y++;
        }
    }

    method gist() {
        my @out = [];        
        for (0..self.max-y) -> $y {
            my @row = [];
            for (0..self.max-x) -> $x {
                @row.push(self.galaxy-at(:$x,:$y) ?? '#' !! '.');
            }
            @out.push(@row);
        }
        return @out.map(*.join('')).join("\n");
    }

    method expand(:$expansion) {
        my $my = self.max-y;
        my $mx = self.max-x;
        for ($my...0) -> $y {
            self.expand-row(:$y,:$expansion) if self.empty-row(:$y);
        }
        for ($mx...0) -> $x {
            self.expand-col(:$x,:$expansion) if self.empty-col(:$x);
        }
        return self;
    }

    method distances() {
        my $id = 0;
        my %dists;
        for (@!galaxies) -> $g1 {
            $id++;
            %dists{$id} = {};
            my $id2 = $id;
            for (@!galaxies[$id..*]) -> $g2 {
                $id2++;
                %dists{$id}{$id2} = $g1.m-dist($g2);
            }
        }
        return %dists;
    }
}


multi sub MAIN('test') {
    use Test;
    my $universe = Universe.new(lines => ('..','.#') );
    dd $universe;
    is $universe.gist, "..\n.#", 'Universe is as expected';
    $universe.expand(expansion => 1);
    is $universe.gist, "...\n...\n..#", 'Universe Expanded OK';
    my $example-universe = Universe.new( lines => 'example'.IO.lines );
    $example-universe.expand(expansion => 1);
    my $distances = $example-universe.distances();
    is $distances{5}{9}, 9;
    is $distances{1}{7}, 15;
    is $distances{3}{6}, 17;
    is $distances{8}{9}, 5;
    done-testing;
}

multi sub MAIN('p1',$file) {
    my $universe = Universe.new( lines => $file.IO.lines ).expand(expansion => 1);
    say [+] $universe.distances.values.map({ |$_.values });
    
}

multi sub MAIN('p2',$file) {
    my $universe = Universe.new( lines => $file.IO.lines ).expand(expansion => 999999);
    say [+] $universe.distances.values.map({ |$_.values });
    
}



