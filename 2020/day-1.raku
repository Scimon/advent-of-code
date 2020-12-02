#!/usr/bin/env raku

"input".IO.lines.race.combinations(2).grep( -> ($a, $b) { $a + $b == 2020 } ).map( -> ( $a, $b ) { $a * $b } ).say;
