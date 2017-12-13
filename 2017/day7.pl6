use v6.c;

sub MAIN ( $input ) {
    my @lines = $input.IO.lines;

    my @children;
    my @nodes;
    my %tree;
    
    for @lines -> $line {
        my $match = $line ~~ / ^ (\S+) ' (' (\d+) ')' (' -> ' (.+))? /;
        my $name = $match[0].Str;
        my $weight = $match[1].Int;
        my @child = ();
        @child = $match[2][0].split( ", " ) if $match[2];
        @nodes.push( $name );
        @children.push( |@child );
        %tree{$name} = { 'wgt' => $weight, 'cld' => @child };
    }
    my $base = (@nodes (-) @children).keys[0];
    say $base;
    say %tree;
    %tree.keys.grep( { ! balanced( $_, %tree ) } ).map( { say $_,"=>",( %tree{$_}<cld>.map( { $_ ~ ":" ~ %tree{$_}<wgt> ~ ":" ~ full-weight( $_, %tree ) } ).join(",") ) } );
}

sub full-weight ( $key, %tree ) {
    if ( %tree{$key}<cld> ) {
         %tree{$key}<wgt> + ( [+] %tree{$key}<cld>.map( { full-weight( $_, %tree ) } ) );
    } else {
        %tree{$key}<wgt>;
    }
}

sub balanced ( $key, %tree ) {
    if ( %tree{$key}<cld> ) {
        [==] %tree{$key}<cld>.map( { full-weight( $_, %tree ) } );
    } else {
        True;
    }
}
