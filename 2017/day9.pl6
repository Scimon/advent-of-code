use v6.c;

sub MAIN() {
    my $garbage = False;
    my $skip = False;
    my $count = 0;
    my $score = 0;
    my $garb = 0;
    
    for $*IN.slurp.comb -> $char {
        if $skip {
            $skip = False;
            next;
        }
        given $char {
            when '!' { $skip = True };
            when '<' {
                $garb++ if $garbage;
                $garbage = True;
            };
            when '>' { $garbage = False; };
            when '{' {
                $garb++ if $garbage;
                next if $garbage;
                $count++;
            }
            when '}' {
                $garb++ if $garbage;
                next if $garbage;
                $score += $count;
                $count--;
            }
            default {
                $garb++ if $garbage;
            }
        }
    }
    say $score;
    say $garb;
}
