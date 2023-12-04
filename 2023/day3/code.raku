#!/usr/bin/env raku

class Part {
    has Int $.x;
    has Int $.y;
    has Str $.type;

    method is-gear( @part-nums ) {
        return False if $!type !~~ '*';
        return @part-nums.grep( *.is-part-num( [self,] ) ).elems == 2;
    }
    method gear-ratio( @part-nums ) {
        return 0 unless self.is-gear( @part-nums );
        [*] @part-nums.grep( *.is-part-num( [self,] ) ).map( *.value );
    }
    
    method gist { "($!x x $!y) => $!type" }
}

class PartNum {
    has Int $.x;
    has Int $.y;
    has Int $.value;

    method is-part-num( @parts ) {
        for @parts -> $part {
            if $part.y (elem) ($!y-1..$!y+1)
            && $part.x (elem) ($!x-1..($!x+$!value.chars)) {
                return True;
            }
        }
        return False;
    }
    method gist { "($!x x $!y) => $!value" }
}

multi sub MAIN('test') is hidden-from-USAGE {
    use Test;
    is-deeply parse-row(0, '467..114..'),
    (
        PartNum.new(x => 0, y => 0, value => 467 ),
        PartNum.new(x => 5, y => 0, value => 114 ),
    ), 'Parsed First Row OK';
    is-deeply parse-row(1, '...*......'),
    ( Part.new(x => 3, y => 1, type => '*' ), ), 'Parsed 2nd row OK';
    is-deeply parse-row(4, '617*......'),
    (
        PartNum.new(x => 0, y => 4, value => 617 ),
        Part.new(x => 3, y => 4, type => '*' ),
    ), 'Row 4 OK';
    my $part-num = PartNum.new(x => 0, y=> 0, value => 467);
    ok $part-num.is-part-num(
        ( Part.new(x => 3, y => 1, type => '*' ), )
    ), 'Part Match OK';
    my $parsed = parse-file('example');
    my @invalid = $parsed<part-nums>.grep( ! *.is-part-num($parsed<parts>) ).map( *.value ).Array;
    is @invalid, [114, 58], 'Got invalid parts';
    my @gears = $parsed<parts>.grep( *.is-gear($parsed<part-nums>) );
    is @gears.map( *.gear-ratio($parsed<part-nums>) ), [16345, 451490], 'Got gear ratios';
    done-testing;
}

multi sub MAIN('p1', $file) {
    my $parsed = parse-file($file);
    say [+] $parsed<part-nums>.grep( *.is-part-num($parsed<parts>)).map(*.value);
}

multi sub MAIN('p2', $file) {
    my $parsed = parse-file($file);
    say [+] $parsed<parts>.grep( *.is-gear($parsed<part-nums>)).map(*.gear-ratio($parsed<part-nums>));
}


sub parse-file($file) {
    my @parts;
    my @part-nums;
    my $row = 0;
    for $file.IO.lines -> $line {
        for parse-row( $row, $line ) -> $item {
            given ($item) {
                when (Part) { @parts.push($_) }
                when (PartNum) { @part-nums.push($_) }
            }
        }
        $row++;
    }
    
    return { parts => @parts, part-nums => @part-nums };
}

sub parse-row(Int $y, Str $row) {
    my $x = 0;
    my $value = 0;
    my @out;
    for $row.comb -> $c {
        if ( $c ~~ /\D/ ) {
            if ( $value ) {
                @out.push(
                    PartNum.new(
                                 x => ($x - $value.chars),
                                 :$y, :$value
                    )
                );
                $value = 0;
            }
            if ( $c !~~ '.' ) {
                @out.push(Part.new( :$x, :$y, type => $c ));
            }
        }
        if ( $c ~~ /\d/ ) {
            $value = ( $value * 10 ) + $c;
        }
        $x++;
    }
    if ( $value ) {
        @out.push(
            PartNum.new(
                x => ($x - $value.chars),
                :$y, :$value
            )
        );
        $value = 0;
    }

    return @out.List;
    
}
