use lib "../../lib";
use Grid;
use Point;

class TopPoint does Point {
    has Int() $.val;
    has @!scorers = [];
    has Int $!score;
    has Int $!routes;
    
    method Str { $.val }
    method gist { "{$.x}x{$.y}:{$.val}" }

    method init( Grid $g ) {
        for $g.orth-adjacent( self ) -> $p {
            @!scorers.push( $p ) if $p.val == $!val + 1; 
        }
    }

    method score-list() {
        return (self,) if self.val == 9;
        return @!scorers.map( { |$_.score-list() } ).unique();
    }
    
    method score() {
        return $!score if defined $!score;
        $!score = $.score-list().elems();
    }

    method routes() {
        return $!routes if defined $!routes;
        $!routes = $!val == 9 ?? 1 !! [+] @!scorers.map( *.routes() );
    }
}

class TopGrid does Grid[TopPoint] {
}

sub MAIN($file, :v(:$verbose) ) {
    my $grid = TopGrid.new( lines => $file.IO.lines );
    $grid.say if $verbose;
    "-----".say if $verbose;
    for $grid.all-points -> $p { $p.init( $grid ); }
    if $verbose { for $grid.all-points.grep( *.val == 0 ) -> $p { say "{$p.gist} {$p.score()} {$p.routes}"; } }

    say "P1 : ", [+] $grid.all-points.grep( *.val == 0 ).map( *.score() );
    say "P2 : ", [+] $grid.all-points.grep( *.val == 0 ).map( *.routes() );

}
