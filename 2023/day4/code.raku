#!/usr/bin/env raku

class Card {
    has Int $.id;
    has Int @.winners;
    has Int @.numbers;

    method matches() {
        (@!winners ∩ @!numbers).keys.Array;
    }
    
    method score() {
        return 0 if self.matches.elems == 0;
        return 2 ** (self.matches.elems - 1);
    }

    method copies() {
        return [] if self.matches.elems == 0;
        return ($!id+1..$!id+self.matches.elems).Array;
    }
    
    multi submethod BUILD (Str :$def) {
        my $r = rx/^ 'Card' ' '* $<id>=(\d+) ': ' ' '?
                     @<winners>=([\d||' ']\d?) + % ' '
                     ' | ' ' '? 
                     @<numbers>=([\d||' ']\d?) + % ' ' $/;
        my $m = $def.match($r);
        $!id := $m<id>.Int;
        @!winners := Array[Int].new();
        @!winners.push($_) for $m<winners>.map(*.Int);
        @!numbers := Array[Int].new();
        @!numbers.push($_) for $m<numbers>.map(*.Int);
        
    }
}

multi sub MAIN('test') {
    use Test;
    my $card = Card.new(def => 'Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83');
    is $card.id, 4, 'Got expected ID';
    is $card.winners, [41, 92, 73, 84, 69];
    is $card.numbers, [59, 84, 76, 51, 58, 5, 54, 83];
    is $card.matches, [84];
    is $card.score, 1;

    is 'example'.IO.lines.map( -> $l {  Card.new( def => $l ).score } ), [8,2,2,1,0,0], 'Example Score OK';

    my $card2 = Card.new(def => 'Card   2:  1 12  3 |  4 10  5');
    is $card2.id, 2;
    is $card2.winners, [1,12,3];
    is $card2.numbers, [4,10,5];

    my $card3 = Card.new(def => 'Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53');
    is $card3.copies, [2,3,4,5];
    done-testing;
}

multi sub MAIN('p1', $file ) {
    say [+] $file.IO.lines.map( -> $l {  Card.new( def => $l ).score } );
}

multi sub MAIN('p2', $file ) {
    my %card-counts;
    
    for $file.IO.lines.map( -> $l {  Card.new( def => $l ) } ) -> $card {
        %card-counts{$card.id}++;
        for $card.copies -> $k {
            %card-counts{$k} += %card-counts{$card.id};
        }
    }

    say [+] %card-counts.values;
}
