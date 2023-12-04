#!/usr/bin/env raku
#use Grammar::Tracer;
grammar Message {
    token TOP { <message-list> }
    token message-list { '[' <list-item>* % ',' ']' }
    token list-item { <message-list> | <number-item>  }
    token number-item { <[0..9]>+ }
}
class Message-actions {
    method TOP($/) { make $<message-list>.made }
    method message-list($/) {
        my @a = Array.new();
        @a.push($_.made) for @($<list-item>);
        make @a;
    }
    method list-item($/) { make $/.values[0].made }
    method number-item($/) { make $/.Int }
}

multi sub MAIN('TEST') {
    use Test;
    my @res = Message.parse('[1,2,[]]', actions => Message-actions).made;
    is-deeply @res, [1,2,[]];
    is ordered( [1,1,3,1,1], [1,1,5,1,1] ), True;
    is ordered( [[1,],[2,3,4]], [[1,],4] ), True;
    is ordered( [9,], [8,7,6] ), False;
    is ordered( [[4,4],4,4], [[4,4],4,4,4] ), True;
    is ordered( [7,7,7,7], [7,7,7] ), False;
    is ordered( [], [3] ), True;
    is ordered(
        Message.parse('[[[]]]', actions => Message-actions).made,
        Message.parse('[[]]', actions => Message-actions ).made ), False;
    is ordered( [1,[2,[3,[4,[5,6,7]]]],8,9], [1,[2,[3,[4,[5,6,0]]]],8,9] ), False;
    done-testing;
}

sub p($a) {Message.parse($a, actions => Message-actions).made}

multi sub MAIN(1,$f) {
    my @pairs = $f.IO.lines.rotor(2 => 1);
    my $idx = 0;
    my $total = 0;
    for @pairs -> ( $a, $b ) {
        $idx++;
        $total += $idx if ordered(p($a),p($b));
    }
    say $total;
}

sub p-cmp( $a, $b ) {
    $a.gist ~~ $b.gist ?? Same !! ordered($a,$b) ?? Less !! More; 
}

multi sub MAIN(2,$f) {
    my @list = ( |$f.IO.lines.rotor(2 => 1).flat, '[[2]]', '[[6]]' ).map({p($_)}).sort( &p-cmp );
    my $idx = 0;
    my @total;
    for @list -> $val {
        $idx++;
        if $val.gist ~~ p('[[2]]').gist|p('[[6]]').gist {
            @total.push($idx);
        }
    }
    say [*] @total;
}

subset EmptyList of Positional where *.elems == 0;
subset NonEmptyList of Positional where *.elems != 0;

multi sub ordered( NonEmptyList $, EmptyList $ ) { return False; }
multi sub ordered( EmptyList $, NonEmptyList $ ) { return True; }
multi sub ordered( EmptyList $, EmptyList $ ) { return; }
multi sub ordered( Int $a, Int $b where {$b > $a} ) { return True; }
multi sub ordered( Int $a, Int $b where {$b == $a} ) { return }
multi sub ordered( Int $a, Int $b where {$b < $a} ) { return False; }
multi sub ordered( Int $a, @b ) { ordered( [$a], @b ) }
multi sub ordered( @a, Int $b ) { ordered( @a, [$b] ) }
multi sub ordered( @a is copy, @b is copy ) {
    my $head-a = @a.head;
    my $head-b = @b.head;
    my $result = ordered( $head-a, $head-b );
    return $result if defined $result;
    return ordered( @a.tail(*-1).Array, @b.tail(*-1).Array );
}



