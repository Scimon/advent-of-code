#!/usr/bin/env raku

enum HandType <High OnePair TwoPair ThreeOfAKind FullHouse FourOfAKind FiveOfAKind>;

subset Card of Str where /^ [2..9||T||J||Q||K||A] $/;
constant CARDS = "23456789TJQKA"; 

multi sub infix:<cmp>( Card \a, Card \b ) {
    CARDS.index(a) cmp CARDS.index(b);
}

class Hand {
    has Str(Card) @.cards;
    has HandType $.type;
    
    submethod BUILD( Str :$h ) {
        @!cards = $h.comb();
        my $cardBag = @!cards.Bag;
            $!type = classify-hand( @!cards.Bag );
    }
    
    sub classify-hand( $cardBag ) {
        return do given ( $cardBag ) {
            when ( $_.values.max == 5 ) { FiveOfAKind; }
            when ( $_.values.max == 4 ) { FourOfAKind; }
            when ( $_.values.sort ~~ (2,3) ) { FullHouse; }
            when ( $_.values.sort ~~ (1,1,3) ) { ThreeOfAKind; }
            when ( $_.values.sort ~~ (1,2,2) ) { TwoPair; }
            when ( $_.values.sort ~~ (1,1,1,2) ) { OnePair; }
            default { High }
        }
    }
    
    multi method new(Str $s) { Hand.new(:h($s) ) }

    method gist { @!cards.join("") }
}

multi sub infix:<cmp>( Hand \a, Hand \b ) {
    return a.type cmp b.type unless a.type cmp b.type eq Same;
    (a.cards Zcmp b.cards).first(* != Same) // Same;
        
}

multi sub MAIN('test') {
    use Test;
    is (High, FiveOfAKind, TwoPair).sort, (High, TwoPair, FiveOfAKind);
    my Str(Card) @cards = ("A","2","3","2","A"); 
    is @cards.sort, ("2", "2", "3", "A", "A" );
    is Hand.new( :h("AAAAA") ).type, FiveOfAKind;
    is Hand.new( :h("AAAA2") ).type, FourOfAKind;
    is Hand.new( :h("A2AA2") ).type, FullHouse;
    is Hand.new( :h("ATAA2") ).type, ThreeOfAKind;
    is Hand.new( :h("ATTA2") ).type, TwoPair;
    is Hand.new( :h("3TAA2") ).type, OnePair;
    is Hand.new( :h("3TKA2") ).type, High;
    ok my Hand $pair = Hand.new( :h("A23A4") );
    is $pair.cards.sort, <2 3 4 A A>;
    is $pair.type, OnePair;

    is (Hand.new(:h("23456")), Hand.new(:h("AAAAA")), Hand.new(:h("62345")))
    .sort( { $^a cmp $^b } ).map(*.gist),
    ("23456","62345","AAAAA");
    my @test = "example".IO.lines.map(
        -> $l {
            my ($c, $v) = $l.split(" "); ( Hand.new($c) => $v );
        } );
    is @test.sort( { $^a.key cmp $^b.key } ).map(*.key.gist), <32T3K KTJJT KK677 T55J5 QQQJA>;
    my @values = @test.sort( { $^a.key cmp $^b.key } ).map(*.value);
    is ( [+] (@values Z* (1..*)) ), 6440;  
    
    done-testing;
}

multi sub MAIN('p1', $file) {
    my @hands = $file.IO.lines.map(
        -> $l {
            my ($c, $v) = $l.split(" "); ( Hand.new($c) => $v );
        } );
    say [+] ((@hands.sort({$^a.key cmp $^b.key}).map(*.value)) Z* (1..*) );
}
