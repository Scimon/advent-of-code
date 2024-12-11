multi sub MAIN($file, $blinks is copy) {
    my @items = $file.IO.slurp.chomp.split(" ").map(*.Int);
    while ( $blinks > 0 ) {
        @items = @items.map( -> $a { process( $a ) } );
        $blinks--;
        say "$blinks : {@items.elems} : {@items.max}";
    }

}

multi sub MAIN('ext', $file, $blinks is copy) {
    my $c-file = "/tmp/day-11-$blinks";
    if ( ! $c-file.IO.e ) {
        $c-file.IO.spurt( $file.IO.slurp.chomp.split(" ").join("\n") );
    }

    my $count = 0;
    while ( $blinks > 0 ) {
        my $i-file = "/tmp/day-11-$blinks";
        my $o-file = "/tmp/day-11-{$blinks-1}";
        my $o-file-handle = open $o-file, :w;
        $count = 0;
        for $i-file.IO.lines -> $a {
            for process($a.Int) -> $v {
                $o-file-handle.say($v);
                $count++;
            }
        }
        $o-file-handle.close;
        $i-file.IO.unlink;
        $blinks--;
        say "$blinks : $count";
    }

    say $count;
    
    "/tmp/day-11-0".unlink;
}

multi sub MAIN( 'supply', $file, $blink ) {
    my $in = Supplier.new();
    my @supplies = [$in.Supply];
    for (^$blink) -> $i {
        @supplies.push( supply { whenever @supplies[$i] -> $v { say "$i : $v"; emit $_ for process($v) } } );
    }
    my $out = @supplies[$blink].elems.tail.tap(&say);
    $in.emit($_) for $file.IO.slurp.chomp.split(" ").map(*.Int);
    $in.done();
}

multi sub MAIN('copied', $file, $blinks ) {
    my @stones = $file.IO.slurp.chomp.split(" ").map(*.Int);

    my %counts;
    %counts{$_}++ for @stones;

    for ^$blinks -> $i {
        my %new_counts;
        for keys %counts -> $stone {
            %new_counts{$_} += %counts{$stone} for process( $stone.Int );
        }
        %counts = %new_counts;
        say "$i : {%counts.values.sum}";
    }
}     

subset EvenInt of Int where *.Str.chars %% 2;

multi sub process (0) { 1 }
multi sub process (EvenInt $a) {
    my $d = $a.Str.chars / 2;
    |($a.Str.substr(0,$d).Int, $a.Str.substr($d,$d).Int);
}
multi sub process (Int $a) { $a * 2024; }
