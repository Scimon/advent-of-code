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

subset EvenInt of Int where *.Str.chars %% 2;

multi sub process (0) { 1 }
multi sub process (EvenInt $a) {
    my $d = $a.Str.chars / 2;
    |($a.Str.substr(0,$d).Int, $a.Str.substr($d,$d).Int);
}
multi sub process (Int $a) { $a * 2024; }
