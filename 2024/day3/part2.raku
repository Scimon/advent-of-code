sub MAIN($input) {
    my $match = / ('mul') '(' (\d+) ',' (\d+) ')' | ('do')'()' | ("don't") '()' /;
    my $data = $input.IO.slurp;
    my $total = 0;
    my $process = True;
    for $data.match($match, :g) -> $m {
        given $m {
            when $m[0] ~~ 'do'    { $process = True }
            when $m[0] ~~ "don't" { $process = False }
            when $m[0] ~~ 'mul'   { $total+= $m[1] * $m[2] if $process }
        }
    }
    $total.say;
}
                 
