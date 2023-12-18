unit role Point;

has Int $.x;
has Int $.y;

method m-dist(Point $p) {
    abs($.x - $p.x) + abs($.y - $p.y);
}

method Str { '.' }
method gist { "{$!x}x{$!y}" }
