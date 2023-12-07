#!/usr/bin/env raku

enum HandType <High OnePair TwoPair ThreeOfAKind FullHouse FourOfAKind FiveOfAKind>;

constant CARDS = "J23456789TQKA";
subset CardVal of Str where { .defined && CARDS.index($_) !~~ Nil }

class Card {
    has CardVal() $.value;
    method gist { $!value; }
    method Str { $!value; }
}

multi sub infix:<cmp>( Card \a, Card \b ) {
    CARDS.index(a.value) cmp CARDS.index(b.value);
}

class Hand {
    has Card @.cards;
    has HandType $.type;
    
    submethod BUILD( Str :$h ) {
        @!cards = $h.comb().map( { Card.new( :value($_) ) } );
        $!type = type-hand( @!cards );
    }
    
    sub type-hand( @cards ) {
        my $cardBag = @cards.map(*.Str).Bag;
        if ( $cardBag<J> ) {
            return FiveOfAKind if $cardBag<J> == 5;
            my @others = $cardBag.keys.grep( { $_ !~~ "J" } );
            my @non-jokers = @others.map( { ($_ xx $cardBag{$_}).Slip } );
            my @jokers = $cardBag.keys.grep( { $_ !~~ "J" } ).map( { ($_ xx $cardBag<J>).Slip } ).combinations($cardBag<J>);
            return @jokers.map( -> @j { classify-hand( ( |@j, |@non-jokers ).Bag ) } ).sort( { $^b cmp $^a } ).first;
        } else {      
            return classify-hand( $cardBag );
        }
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
    is Card.new(:value("A")).Str, "A";
    is (High, FiveOfAKind, TwoPair).sort, (High, TwoPair, FiveOfAKind);
    my Str(Card) @cards = ("A","2","3","2","A"); 
    is @cards.sort, ("2", "2", "3", "A", "A" );
    is Hand.new( :h("AAAAA") ).type, FiveOfAKind;
    is Hand.new( :h("AAAAJ") ).type, FiveOfAKind;
    is Hand.new( :h("AAAJJ") ).type, FiveOfAKind;
    is Hand.new( :h("AAJJJ") ).type, FiveOfAKind;
    is Hand.new( :h("AJJJJ") ).type, FiveOfAKind;
    is Hand.new( :h("JJJJJ") ).type, FiveOfAKind;
    is Hand.new( :h("AAAA2") ).type, FourOfAKind;
    is Hand.new( :h("AAAJ2") ).type, FourOfAKind;
    is Hand.new( :h("AAJJ2") ).type, FourOfAKind;
    is Hand.new( :h("AJJJ2") ).type, FourOfAKind;
    is Hand.new( :h("A2AA2") ).type, FullHouse;
    is Hand.new( :h("A2AJ2") ).type, FullHouse;
    is Hand.new( :h("ATAA2") ).type, ThreeOfAKind;
    is Hand.new( :h("ATAJ2") ).type, ThreeOfAKind;
    is Hand.new( :h("ATJJ2") ).type, ThreeOfAKind;
    is Hand.new( :h("ATTA2") ).type, TwoPair;
    is Hand.new( :h("3TAA2") ).type, OnePair;
    is Hand.new( :h("3TKA2") ).type, High;
    ok my Hand $pair = Hand.new( :h("A23A4") );
    is $pair.cards.sort, <2 3 4 A A>;
    is $pair.type, OnePair;

    is ("23456", "AAAAA", "62345", "JJJJJ", "22222").map({Hand.new($_)}).sort( { $^a cmp $^b } ).map(*.gist),
    ("23456","62345","JJJJJ", "22222", "AAAAA");
    my @test = "example".IO.lines.map(
        -> $l {
            my ($c, $v) = $l.split(" "); ( Hand.new($c) => $v );
        } );
    is @test.sort( { $^a.key cmp $^b.key } ).map(*.key.gist), <32T3K KK677 T55J5 QQQJA KTJJT>;
    my @values = @test.sort( { $^a.key cmp $^b.key } ).map(*.value);
    is ( [+] (@values Z* (1..*)) ), 5905;     
    
    done-testing;
}

multi sub MAIN('p2', $file) {
    my @hands = $file.IO.lines.map(
        -> $l {
            my ($c, $v) = $l.split(" "); ( Hand.new($c) => $v );
        } );
    #.say for @hands.sort({$^a.key cmp $^b.key}).map( -> $p { $p.key.gist, ":", $p.key.type, ":", $p.value } ); 
    
    say [+] ((@hands.sort({$^a.key cmp $^b.key}).map(*.value)) Z* (1..*) );
}
