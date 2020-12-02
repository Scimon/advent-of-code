#!/usr/bin/env raku

"input".IO.lines.race.combinations(2).grep( -> @l { ( [+] @l ) == 2020 } ).map( -> @l { [*] @l } ).say;
