sub MAIN($input) {
    my $match = / 'mul(' (\d+) ',' (\d+) ')' /;
    my $data = $input.IO.slurp;
    my $total = 0;
    for $data.match($match, :g) -> $m {
        $total+= $m[0] * $m[1];
    }
    $total.say;
}
                 
