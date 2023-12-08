#!/usr/bin/env raku

class Node {
    has $.id;
    has $.left;
    has $.right;

    method gist { "$!id = ($!left, $!right)" };
    multi method new (Str $s) { Node.new(:$s); }
    submethod BUILD ( Str :$s ) {
        my $m = $s.match( /^ (...) ' = (' (...) ', ' (...) ')' $/ );
        $!id = $m[0].Str;
        $!left = $m[1].Str;
        $!right = $m[2].Str;
    }
}

multi sub MAIN('test') {
    use Test;
    my $node = Node.new('AAA = (BBB, CCC)');
    is $node.id, 'AAA';
    is $node.left, 'BBB';
    is $node.right, 'CCC';
    is prime-factors(10), (2,5);
    is prime-factors(300), (2,2,3,5,5);
    is lcm(12,30), 60;
    is lcm(24,300), 600;
    is lcm(6,7,21), 42;
    done-testing;
}

multi sub MAIN('p1', $file) {
    my @lines = $file.IO.lines;

    my @moves = @lines.shift.comb;
    my %nodes;
    @lines.shift;
    my $location = 'AAA';
    
    for (@lines) {
        my $node = Node.new($_);
        %nodes{$node.id} = $node;
    }
    
    my $moves-taken = 0;
    say "$moves-taken : $location";
    while ( $location ne 'ZZZ' ) {
        $moves-taken++;
        my $move = @moves.shift;
        @moves.push($move);
        given $move {
            when 'L' { $location = %nodes{$location}.left; }
            when 'R' { $location = %nodes{$location}.right; }
        }
        say "$moves-taken : $move : $location";
    }
    say $moves-taken;
}

multi sub MAIN('p2', $file) {
    my @lines = $file.IO.lines;

    my @moves = @lines.shift.comb;
    my %nodes;
    @lines.shift;
    my @locations;
    
    for (@lines) {
        my $node = Node.new($_);
        %nodes{$node.id} = $node;
        @locations.push($node.id) if $node.id ~~ / 'A' $/;
    }

    my $moves-taken = 0;
    say "$moves-taken : {@locations.join(',')}";
    while ( all(@locations) !~~ / 'Z' $/ ) {
        $moves-taken++;
        my $move = @moves.shift;
        @moves.push($move);
        @locations .= map( -> $location {
            my $l = do given $move {
                when 'L' { %nodes{$location}.left; }
                when 'R' { %nodes{$location}.right; }
            };
            $l;
        });
        say "$moves-taken : $move : {@locations.join(',')}";
    }
    say $moves-taken;
    
}

multi sub MAIN('p2-2', $file ) {
     my @lines = $file.IO.lines;

    my @moves = @lines.shift.comb;
    my %nodes;
    @lines.shift;
    my @locations;
    
    for (@lines) {
        my $node = Node.new($_);
        %nodes{$node.id} = $node;
        @locations.push($node.id) if $node.id ~~ / 'A' $/;
    }

    my @paths;
    for @locations -> $l {
        @paths.push( start follow-path( $l, %nodes, @moves ) );
    }
    @locations = await @paths;
    say lcm(@locations);
    
}

sub follow-path ( $start, %nodes is copy, @moves is copy ) {
    my $location = $start;
    my $moves-taken = 0;
    while ( $location !~~ / 'Z' $/ ) {
        $moves-taken++;
        my $move = @moves.shift;
        @moves.push($move);
        given $move {
            when 'L' { $location = %nodes{$location}.left; }
            when 'R' { $location = %nodes{$location}.right; }
        }
        say "$moves-taken : $move : $location";
    }
    return $moves-taken;
}

multi sub prime-factors( $p where $p.is-prime ) { $p }
multi sub prime-factors( $p ) {
    my $f = (2..*).grep(*.is-prime).first( { $p %% $^a } );
    ( $f, |prime-factors( $p div $f ) );
}

sub lcm( *@numbers ) {
    my %final;
    for @numbers.map( { Bag.new( prime-factors($_) ) } ) -> $factors {
        for $factors.keys -> $key {
            my $value = $factors{$key};
            %final{$key} //= $value;
            %final{$key} = $value if %final{$key} < $value;
        }
    }
    return [*] %final.pairs.map( -> $p { $p.key ** $p.value } );
}
