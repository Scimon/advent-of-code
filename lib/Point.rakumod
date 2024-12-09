role Point {

    has Int $.x;
    has Int $.y;
    
    method m-dist(Point $p) {
        abs($.x - $p.x) + abs($.y - $p.y);
    }
    
    method Str { '.' }
    method gist { "{$!x}x{$!y}" }

    method sub (Point $p) { Point.new( x => $.x - $p.x, y => $.y - $p.y ) }
    method add (Point $p) { Point.new( x => $.x + $p.x, y => $.y + $p.y ) }

    method in-bounds (Point $p-min, Point $p-max) {
        return $p-min.x <= $.x <= $p-max.x && $p-min.y <= $.y <= $p-max.y;
    }
}
