use v6.c;

my %registers;

for $*IN.lines -> $line {
    my $match = $line ~~ /^ (\d+) ': ' (\d+) /;
    %registers{$match[0].Str} = $match[1].Int;
}

my $last = %registers.keys.max;
my $delay = -1;

LOOP: while True {
    $delay++;
    
    for %registers.keys -> $idx {
        my $length = %registers{$idx};
        next LOOP if ($idx+$delay) %% (2*$length-2);        
    }
    last;
}
say $delay;
