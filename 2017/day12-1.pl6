use v6.c;

my %progs;

for $*IN.lines -> $pipeline {
    my $match = $pipeline ~~ /^ (\d+) ' <-> ' ( (\d|','|' ' )+ )/;
    my @list = $match[1].Str.split( ', ' ).map(*.Int).Array;
    @list.push($match[0].Int);
    for @list -> $val {
        %progs{$val} //= SetHash.new();
        %progs{$val}{$_} = True for @list;
    }
}

my $all = set( %progs.keys );
my $main = 0;

my $pipes = 0;
my @zero-set = %progs{0}.keys;

while ( $pipes != @zero-set.elems ) {
    $pipes = @zero-set.elems;
    @zero-set = ( [(|)] @zero-set.map( { %progs{$_ } } ) ).keys;
    say @zero-set;
}

say $pipes;
