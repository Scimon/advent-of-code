use v6.c;

my %progs;

for $*IN.lines -> $pipeline {
    my $match = $pipeline ~~ /^ (\d+) ' <-> ' ( (\d|','|' ' )+ )/;
    my @list = $match[1].Str.split( ', ' ).Array;
    @list.push($match[0].Str);
    for @list -> $val {
        %progs{$val} //= SetHash.new();
        %progs{$val}{$_} = True for @list;
    }
}

my $all = set( %progs.keys );
my $groups;

while ( $all.keys.elems > 0 ) {
    say $all;
    my $id = $all.keys[0];
    
    my $pipes = 0;
    my $set = set(%progs{$id}.keys);
    
    while ( $pipes != $set.keys.elems ) {
        $pipes = $set.keys.elems;
        $set = ( [(|)] $set.keys.map( { %progs{$_ } } ) );
    }
    $groups++;
    $all = $all (-) $set;
}

say $groups;
