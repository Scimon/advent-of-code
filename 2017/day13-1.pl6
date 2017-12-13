use v6.c;

my %registers;

enum Dir ( Down => 1, Up => -1 );

for $*IN.lines -> $line {
    my $match = $line ~~ /^ (\d+) ': ' (\d+) /;
    %registers{$match[0].Str} = { 'length' => $match[1].Int, 'scanner-idx' => 0, 'dir' => Down };
}

my $last = %registers.keys.max;
my $severity = 0;

for 0..$last -> $idx {
    say $idx,":",$severity,":",%registers;
    if %registers{$idx.Str}:exists && %registers{$idx.Str}<scanner-idx> == 0 {
        $severity += $idx * %registers{$idx.Str}<length>;
    }
    for %registers.keys -> $key {
        %registers{$key}<scanner-idx> += %registers{$key}<dir>;
        if ( %registers{$key}<scanner-idx> == %registers{$key}<length>-1 || %registers{$key}<scanner-idx> == 0 ) {
            %registers{$key}<dir> = %registers{$key}<dir> == Up ?? Down !! Up;
        }
    }
    say $idx,":",$severity,":",%registers;
}
say $severity;
        
