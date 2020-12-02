#!/usr/bin/env raku

"input".IO.lines.race.combinations(3).grep( -> @l { ( [+] @l ) == 2020 } ).map( -> @l { [*] @l } ).say;
