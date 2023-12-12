#!/usr/bin/env perl

multi sub MAIN('test') {
    use Test;
    is-deeply make-cache(1), { '' => (''), '?' => ('.','#') };
    is-deeply make-cache(2), { '' => (''), '?' => ('.','#'), '??' => ('..','.#','#.','##') };
    my %cache = make-cache(10);
    is damage-count('#.#.###'), (1,1,3), 'Damage count matches';
    is damage-count('..#'), (1), 'Damage count matches';
    is-deeply options('#',%cache), ('#',), 'No placeholders';
    is-deeply options('.',%cache), ('.',), 'No placeholders';
    is-deeply options('?',%cache), ('.','#'), 'Simple options';
    is-deeply options('??',%cache), ('..','.#','#.','##'), 'More options';
    is-deeply options('#?.',%cache), ('#..','##.'), 'Options with others';
    is-deeply options('.?.?.',%cache), ('.....','...#.','.#...','.#.#.');
    is options('???.###',%cache).grep( { damage-count($_) ~~ (1,1,3) } ).elems, 1;
    is options('.??..??...?##.',%cache).grep( -> $v { damage-count($v) ~~ (1,1,3) } ).elems, 4;
    is options('.??..??...?.',%cache).grep( -> $v { damage-count($v) ~~ (1,1,1) } ).elems, 4;
    is options('???#??????', %cache).grep( -> $v { damage-count($v) ~~ (1,1,1) } ).elems, 16;
    #is f('???#??????????#??????', %cache, (1,1,1,1,1,1)), 587;

    is f('##.??.??##?',%cache,(2,2,4)), 2, 'f1 1';
    is f2('##.??.??##?',%cache,(2,2,4)), 4, 'f2 1';

    is f('???????##?????#?#?', %cache, (9,6)), 5, 'f1 2';
    #is f2('???????##?????#?#?', %cache, (9,6)), 42, 'f2 2';
    
#    is-deeply possible-damages('?'), ((1,),), '?';
#    is-deeply possible-damages('??'), ((2,),(1,)), '??';
#    is-deeply possible-damages('???'), ((3,),(2,),(1,),(1,1)), '???';
#    is-deeply possible-damages('????'), ((4,),(3,),(2,),(1,),(2,1),(1,2),(1,1)), '????';
#    is-deeply possible-damages('?????'), ((5,),(4,),(3,),(2,),(1,),(3,1),(1,3),(2,2),(2,1),(1,2),(1,1),(1,1,1)), '?????';

    is matches('###', (3,)), 1, 'Simple damamge';
    is matches('##', (3,)), 0, 'Nope';
    is matches('###....', (3,)), 1, 'Damage and stuff';
    is matches('?', (1,)), 1, 'Options starts';
    
    done-testing;   
}

multi sub matches('', ()) { 1; }
multi sub matches('', @r where @r.elems > 0) { 0; }
multi sub matches(Str $record where $record ~~ m/^ '#' /, @damages ) {
    warn '# ',$record,":",@damages.join(",");
    my $d = @damages[0];
    if ( $d <= $record.codes && $record.match( /^ '#' ** {$d} ('.'||'?'||$)/ ) ) {
        my $rest = $record.substr($d);
        matches($rest,@damages[1..*].list);
    } else {
        return 0;
    }
}
multi sub matches(Str $record where $record ~~ m/^ '.'+ /, @damages) {
    warn '. ',$record,":",@damages.join(",");
    my $rest = $record.substr(1);
    matches($rest,@damages);
}
multi sub matches(Str $record where $record ~~ m/^ '?'+ /, @damages) {
    
    warn '? ',$record,':',@damages.join(',');
    return 0;
}

sub possible-damages(Str $s) {
    my $l = $s.codes;
    (1..$l).map( -> $v { |(($l-$v)+1 xx $v) } )
        .combinations(1..$l).grep(->@l { ([+] |@l, (@l.elems-1)) <= $l })
        .map(->@l { |@l.permutations } )
        .unique(:with(&[eqv]));
}


#multi sub possible-damages('') { ( (), ) }
#multi sub possible-damages('?') { ((), (1,),) }
#multi sub possible-damages('??') { ((), (1,),(2,),) }
#multi sub possible-damages(Str $s) {
#    my $l = $s.codes;
#    my @prev = possible-damages('?' x $l-2).map( -> @v { (1,|@v) } );;
#    
#    
#    ( |(2..$l).map( -> $v { ($v,) } ), |@prev );
#}

#multi sub possible-damages('???') { ((0,),(1,),(2,),(3,),(1,1),) }
#multi sub possible-damages('????') { ((0,),(1,),(2,),(3,),(4,),(1,1),(1,2),(2,1),) }

multi sub MAIN('p1', $file) {
    print "Making Cache...";
    my %cache = make-cache(10);
    say "Done";
    say [+] $file.IO.lines.race.map(
        -> $l {
            say $l;
            my ( $record, $score ) = $l.split(" ");
            my @target = $score.split(",");
            f($record,%cache,@target);
        });
}

multi sub MAIN('p2', $file) {
    say "Making Cache...";
    my %cache = make-cache(10);
    say "Done";
    say [+] $file.IO.lines.race.map(
        -> $l {
            my ( $record, $score ) = $l.split(" ");
            my @target = $score.split(",");
            $record = "{$record}?{$record}?{$record}?{$record}?{$record}";
            @target = (|@target,|@target,|@target,|@target,|@target);
            my $f = f($record,%cache,@target);
            say "$l : $f";
            $f;
        });
}

sub f($record,%cache,@target) {
    options($record,%cache).race.grep({ damage-count($_) ~~ @target }).elems;
}

sub f2($record,%cache,@target) {
    options("{$record}?{$record}",%cache).race.grep({ damage-count($_) ~~ (|@target,|@target) }).elems;
}

sub make-cache(Int $max) {
    my %cache = ( '' => ('') );
    my $key = '';
    for (^$max) {
        %cache{"?$key"} = (%cache{$key}.List X~ ['.', '#']).List;
        $key = "?$key";
        say $key,":",%cache{$key}.elems;
    }
    return %cache;
}

sub options(Str $record, %cache) {
    my $max = %cache.keys.map(*.codes).max;
    return $record
    .comb(/ "?"{1..$max} || <[#.]>+ /)
    .map( -> $v { %cache{$v} ?? %cache{$v} !! [$v]; })
    .reduce( -> @a, @b { (@a X~ @b).list; })
    .flat.list;
}

sub damage-count(Str $record) { $record.comb(/'#'+/).map(*.chars).List; }
