#!/usr/bin/env raku

multi sub MAIN('test') {
    use Test;
    is h-code('rn=1'), 30;
    is h-code('cm-'), 253;
    is sum-file('example'),1320;
    is h-code('rn'), 0;
    is h-code('cm'),0;
    is parse('rn=1'), ( rn => 1 );
    is parse('cm-'), ( cm => -1 );
    is update-boxes(code => 'rn=1', boxes => []), [[rn => 1]];
    is update-boxes(code => 'cm-',  boxes => [[rn => 1]]),[[rn => 1]];
    is score( [[rn => 1, cm => 2],[],[],[ot => 7, ab => 5, pc => 6]] ), 145;
    done-testing;
}

multi sub MAIN('p1',$file) { sum-file($file).say }

multi sub MAIN('p2', $file) {
    my @boxes;
    for $file.IO.slurp.chomp.split(/','/) -> $code {
        @boxes = update-boxes(:$code, :@boxes);
    }
    say score(@boxes);
}

sub h-code(Str $init) {
    (0, |$init.comb).reduce( -> $a, $b { ( ( $a + ($b.ord) ) * 17 ) % 256 } );
}

sub sum-file(Str $file) {
    [+] $file.IO.slurp.chomp.split(/','/).map({h-code($_)});
}

sub score( @boxes ) {
    my $sum;
    for (^256) -> $idx {
        next unless @boxes[$idx];
        my $c = 1;
        $sum += ( [+] @boxes[$idx].map(
                      -> $p {
                          ($idx+1) * ($c++) * $p.value
                      }) ); 
    }
    return $sum;
}

sub update-boxes(:$code, :@boxes) {
    my $command = parse($code);
    my $idx = h-code($command.key);
    @boxes[$idx] //= [];
    if ( $command.value ~~ -1 ) {
        @boxes[$idx] = @boxes[$idx].grep( -> $p { $p.key ne $command.key } ).Array;
    } else {
        if ( @boxes[$idx].first( { $_.key eq $command.key } ) ) {
            @boxes[$idx] = @boxes[$idx].map(
                -> $p {
                    $p.key eq $command.key ?? $command !! $p                    
                }).Array;
        } else {
            @boxes[$idx].push($command);
        }
    }
    return @boxes;
}

sub parse(Str $code) {
    given $code {
        when /^ (\w+) '=' (\d+) $/ {
            return $/[0].Str => $/[1].Int;
        }
        when /^ (\w+) '-' $/ {
            return $/[0].Str => -1;
        }
    }
    
}

