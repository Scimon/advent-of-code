#!/usr/bin/env

class Monkey {
    has $.id;
    has @.items;
    has $.op-type;
    has $.op-value;
    has $.test-div;
    has $.true-target;
    has $.false-target;
    has $.worry-div = 3;
    has Int $.inspection-count = 0;
    has Int $.mod = 0;
    
    method gist {
        return qq:to/EOF/;
Monkey {$.id}:
  Items: {@.items.join(", ")}
  Operation: new = old {$.op-type} {$.op-value}
  Test: divisible by {$.test-div}
    If true: throw to monkey {$.true-target}
    If false: throw to monkey {$.false-target}
EOF
    }

    method more-worried() { $!worry-div = 1 };
    method set-mod($mod) { $!mod = $mod }
    
    multi method apply-op( '+', $v, $i ) { $v+$i }
    multi method apply-op( '*', $v, $i ) { $v*$i }
    multi method apply-op( '+', 'old', $i ) { $i+$i }
    multi method apply-op( '*', 'old', $i ) { $i*$i }
    
    method do-round( @monkeys ) {
        while @.items {
            $!inspection-count++;
            my $item = @.items.shift();
            $item = $item mod $!mod if $!mod;
            $item = self.apply-op( $.op-type, $.op-value, $item );
            $item div= $.worry-div;
            @monkeys[$item %% $.test-div ?? $.true-target !! $.false-target].catch-item($item);
        }
    }

    method catch-item( $item ) { @.items.push($item) }
    
    multi method parse( Str $monkey ) { self.parse( $monkey.lines ) }

    multi method parse( @lines ) {
        my ( $id, @items, $op-type, $op-value, $test-div, $true-target, $false-target );
        if ( @lines[0] ~~ /"Monkey "$<id>=(\d+)/ ) {
            $id = $<id>.Int;
        }
        if ( @lines[1] ~~ /<[Ii]>"tems: "$<items>=(\d+)* % ', '/ ) {
            @items = $<items>.map(*.Int)
        }
        if ( @lines[2] ~~ /"Operation: new = old " $<op>=(<[*+]>) " " $<val>=(.+)/ ) {
            $op-type = $<op>.Str;
            $op-value = $<val>.Str;
        }
        if ( @lines[3] ~~ /"Test: divisible by " $<div>=(\d+)/ ) {
            $test-div = $<div>.Int;
        }
        if ( @lines[4] ~~ /"If true: throw to monkey " $<mon>=(\d+)/ ) {
            $true-target = $<mon>.Int;
        }
        if ( @lines[5] ~~ /"If false: throw to monkey " $<mon>=(\d+)/ ) {
            $false-target = $<mon>.Int;
        }
        
        return Monkey.new( :$id, :@items, :$op-type, :$op-value, :$test-div, :$true-target, :$false-target );
    }
}

sub monkey-party( @monkeys ) {
    for @monkeys -> $monkey { $monkey.do-round( @monkeys ) }
}

sub monkey-business( @monkeys ) {
    [*] @monkeys.map( *.inspection-count ).sort.reverse[^2];
}

multi sub MAIN(1,$f) {
    my @monkeys =  $f.IO.lines.rotor(6=>1).map(-> @m {Monkey.parse(@m) });
    monkey-party( @monkeys ) for ^20;
    monkey-business( @monkeys ).say;

}

multi sub MAIN(2,$f) {
    my @monkeys =  $f.IO.lines.rotor(6=>1).map(-> @m {Monkey.parse(@m) });
    my $max-div = [*] @monkeys.map(*.test-div);
    .more-worried for @monkeys;
    .set-mod($max-div) for @monkeys;    
    monkey-party( @monkeys ) for ^10000;
    monkey-business( @monkeys ).say;
}

multi sub MAIN('TEST') {
    use Test;
    my @monkeys = "day-11-test.txt".IO.lines.rotor(6=>1).map(-> @m {Monkey.parse(@m) });
    my $expected = q:to/END/;
Monkey 0:
  Items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3
END
    is @monkeys[0].gist, $expected;
    is @monkeys[0].gist, Monkey.parse($expected).gist;
    monkey-party( @monkeys );
    is-deeply @monkeys[0].items, [20, 23, 27, 26];
    is-deeply @monkeys[1].items, [2080, 25, 167, 207, 401, 1046];
    is-deeply @monkeys[2].items, [];
    is-deeply @monkeys[3].items, [];
    monkey-party( @monkeys );
    is-deeply @monkeys[0].items, [695, 10, 71, 135, 350];
    is-deeply @monkeys[1].items, [43, 49, 58, 55, 362];
    is-deeply @monkeys[2].items, [];
    is-deeply @monkeys[3].items, [];
    monkey-party( @monkeys );
    is-deeply @monkeys[0].items, [16, 18, 21, 20, 122];
    is-deeply @monkeys[1].items, [1468, 22, 150, 286, 739];
    is-deeply @monkeys[2].items, [];
    is-deeply @monkeys[3].items, [];
    monkey-party( @monkeys );
    is-deeply @monkeys[0].items, [491, 9, 52, 97, 248, 34];
    is-deeply @monkeys[1].items, [39, 45, 43, 258];
    is-deeply @monkeys[2].items, [];
    is-deeply @monkeys[3].items, [];
    monkey-party( @monkeys );
    is-deeply @monkeys[0].items, [15, 17, 16, 88, 1037];
    is-deeply @monkeys[1].items, [20, 110, 205, 524, 72];
    is-deeply @monkeys[2].items, [];
    is-deeply @monkeys[3].items, [];
    monkey-party( @monkeys );
    is-deeply @monkeys[0].items, [8, 70, 176, 26, 34];
    is-deeply @monkeys[1].items, [481, 32, 36, 186, 2190];
    is-deeply @monkeys[2].items, [];
    is-deeply @monkeys[3].items, [];
    monkey-party( @monkeys );
    is-deeply @monkeys[0].items, [162, 12, 14, 64, 732, 17];
    is-deeply @monkeys[1].items, [148, 372, 55, 72];
    is-deeply @monkeys[2].items, [];
    is-deeply @monkeys[3].items, [];
    monkey-party( @monkeys );
    is-deeply @monkeys[0].items, [51, 126, 20, 26, 136];
    is-deeply @monkeys[1].items, [343, 26, 30, 1546, 36];
    is-deeply @monkeys[2].items, [];
    is-deeply @monkeys[3].items, [];
    monkey-party( @monkeys );
    is-deeply @monkeys[0].items, [116, 10, 12, 517, 14];
    is-deeply @monkeys[1].items, [108, 267, 43, 55, 288];
    is-deeply @monkeys[2].items, [];
    is-deeply @monkeys[3].items, [];
    monkey-party( @monkeys );
    is-deeply @monkeys[0].items, [91, 16, 20, 98];
    is-deeply @monkeys[1].items, [481, 245, 22, 26, 1092, 30];
    is-deeply @monkeys[2].items, [];
    is-deeply @monkeys[3].items, [];
    monkey-party( @monkeys ) for ^5;
    is-deeply @monkeys[0].items, [83, 44, 8, 184, 9, 20, 26, 102];
    is-deeply @monkeys[1].items, [110, 36];
    is-deeply @monkeys[2].items, [];
    is-deeply @monkeys[3].items, [];
    monkey-party( @monkeys ) for ^5;
    is-deeply @monkeys[0].items, [10, 12, 14, 26, 34];
    is-deeply @monkeys[1].items, [245, 93, 53, 199, 115];
    is-deeply @monkeys[2].items, [];
    is-deeply @monkeys[3].items, [];
    is @monkeys[0].inspection-count, 101;
    is @monkeys[1].inspection-count, 95;
    is @monkeys[2].inspection-count, 7;
    is @monkeys[3].inspection-count, 105;
    is monkey-business( @monkeys ), 10605;

    @monkeys = "day-11-test.txt".IO.lines.rotor(6=>1).map(-> @m {Monkey.parse(@m) });
    my $max-div = [*] @monkeys.map(*.test-div);
    .more-worried for @monkeys;
    .set-mod($max-div) for @monkeys;    
    monkey-party( @monkeys );
    is @monkeys[0].inspection-count, 2;
    is @monkeys[1].inspection-count, 4;
    is @monkeys[2].inspection-count, 3;
    is @monkeys[3].inspection-count, 6;
    monkey-party( @monkeys ) for ^19;
    is @monkeys[0].inspection-count, 99;
    is @monkeys[1].inspection-count, 97;
    is @monkeys[2].inspection-count, 8;
    is @monkeys[3].inspection-count, 103;
    monkey-party( @monkeys ) for ^980;
    is @monkeys[0].inspection-count, 5204;
    is @monkeys[1].inspection-count, 4792;
    is @monkeys[2].inspection-count, 199;
    is @monkeys[3].inspection-count, 5192;
    monkey-party( @monkeys ) for ^1000;
    is @monkeys[0].inspection-count, 10419;
    is @monkeys[1].inspection-count, 9577;
    is @monkeys[2].inspection-count, 392;
    is @monkeys[3].inspection-count, 10391;
    monkey-party( @monkeys ) for ^8000;
    is @monkeys[0].inspection-count, 52166;
    is @monkeys[1].inspection-count, 47830;
    is @monkeys[2].inspection-count, 1938;
    is @monkeys[3].inspection-count, 52013;
    is monkey-business(@monkeys), 2713310158;
    done-testing;
}
