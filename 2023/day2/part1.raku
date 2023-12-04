#!/usr/bin/env raku
use Grammar::Tracer;


multi sub MAIN('test') {
    use Test;
    is parse-row( 'Game 1: 1 blue' ), { 'id' => 1, pulls => [{blue => 1},] };
    is parse-row( 'Game 1: 1 blue, 1 green; 11 red' ), {
        'id' => 1, pulls => [{blue => 1, green => 1},{red => 11},] };
    ok check-row( parse-row('Game 1: 10 blue'), { 'blue' => 20, 'red' => 1, 'green' => 1} );
    ok !check-row( parse-row('Game 1: 10 blue; 10 red'), { 'blue' => 20, 'red' => 1, 'green' => 1} );
    is count-row( parse-row('Game 1: 10 blue') ), { blue => 10, red => 0, green => 0 };
    is count-row( parse-row('Game 1: 10 blue; 5 blue, 1 red, 1 green') ), { blue => 10, red =>1, green => 1 };

    done-testing;
}

sub part1( :$file, :$red, :$green, :$blue ) {
    my %colours = ( 'red' => $red, 'green' => $green, 'blue' => $blue );
    return [+] $file.IO.lines
      .map( -> $l { parse-row($l) } )
      .grep( -> $r { check-row($r, %colours) } )
      .map( -> $r { $r<id> } ); 
}

sub part2( :$file ) {
    return [+] $file.IO.lines
    .map( -> $l { [*] count-row( parse-row($l) ).values } )
}

multi sub MAIN('p1', :$file, :$red, :$green, :$blue) {
    say part1( :$file, :$red, :$green, :$blue );
}

multi sub MAIN('p2', :$file ) {
    say part2( :$file );
}

sub count-row( %row ) {
    my %colours = ( blue => 0, red => 0, green => 0 );
    for %row<pulls>.List -> %pull {
        for %pull.keys -> $key {
            %colours{$key} = %pull{$key} if %pull{$key} > %colours{$key};
        }
    }
    return %colours;
}

sub check-row( %row, %colours ) {
    for %row<pulls>.List -> %pull {
        for %pull.keys -> $key {
            return False if %colours{$key} < %pull{$key};
        }
    }
    return True;
}

sub parse-row( Str $row ) {
    my $match = $row.match(/^ 'Game '
                           $<id>=[\d+] ': '
                           $<pulls>=([            
                              $<pull>=([
                               $<count>=[\d+] ' '
                               $<colour>=['red' || 'green' || 'blue']
                               ]) + % ', '            
                            ]) + % '; ' /);
    
    return { 'id' => $match.<id>.Int,
             'pulls' => [ $match.<pulls>.map(
                 -> $m {
                     $m.<pull>.map(
                         -> $p {
                             $p<colour>.Str => $p<count>.Int
                     }).Hash
                 }) ]
           }

}
