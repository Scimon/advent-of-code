#!/usr/bin/env raku

class Dir {
    has @.contents;
    has $.parent;
    has $.name;

    method size() { [+] @.contents.map(*.size()) }
}

class File {
    has $.name;
    has $.size;
}

multi sub MAIN( 'total', $f, $max_size = 100000 ) {
    my @dirs = get_dirs( $f );
    say [+] @dirs.map(*.size()).grep(* <= $max_size );
}

multi sub MAIN( 'smallest', $f, $total = 70000000, $required = 30000000 ) {
    my @dirs = get_dirs( $f );
    my $used = @dirs.first({$_.name ~~ '/'}).size();
    note $used;
    my $free = $total - $used;
    note $free;
    @dirs.sort({$^a.size() <=> $^b.size}).first({$free + $_.size >= $required}).size().say;
}

sub get_dirs( $f ) {
    my @dirs;
    my $current;
    for $f.IO.lines -> $line {
        given $line {
            when '$ cd /' {
                $current = Dir.new( name => '/' );
                @dirs.push( $current );
            }
            when '$ cd ..' {
                $current = $current.parent;
            }
            when /'$ cd '(.+)/ {
                my $new = Dir.new(
                    name => $current.name ~ $0 ~ '/',
                    parent => $current,
                );
                $current.contents.push($new);
                @dirs.push( $new );
                $current = $new;
            }
            when 'ls' {...}
            when /(\d+)' '(.+)/ {
                $current.contents.push( File.new( name => $1.Str, size => $0.Int ) );
            }                
        }
    }

    return @dirs;
}

