#!/usr/bin/env raku

class Valve {
    has $.name;
    has $.flow-rate;
    has @.edges;
    has $!network is built;
    
    method gist {
        "Valve {$.name} has flow rate={$.flow-rate}; tunnels lead to valves {@.edges.join(', ')}"
    }

    multi method route-to( $to, @route = () ) {
        my @poss;
        for @.edges.grep({! ($_ (elem) @route)}) -> $poss {
            @poss.push( $!network.get($poss).route-to($to,(|@route,$!name)) );
        }
        return (@poss.grep({$_[*-1] ~~ $to}).sort( { $^a.elems <=> $^b.elems } ))[0];
    }
    
    multi method route-to( $to where * ~~ $!name, @route = () ) {
        return (|@route,$!name);
    }

}

class Network {
    has %!valves;
    has %!distance;
    
    method parse( Str $str ) {
        $str ~~ m/'Valve ' $<name>=(<[A..Z]>+) ' has flow rate=' $<flow-rate>=(\d+) '; tunnel' ['s']? ' lead' ['s']? ' to valve' ['s']? ' ' $<edges>=((<[A..Z]>+)+ % ', ')/;
        my $name = ~$<name>;
        my $flow-rate = ~$<flow-rate>;
        my @edges = $<edges>.values>>.Str;
        %!valves{$name} = Valve.new( :$name, :$flow-rate, :@edges, network => self );
    }

    method get(Str $id) {
        %!valves{$id}
    }

    method openable {
        %!valves.values
        .grep(*.flow-rate > 0).map(*.name).sort;
    }

    method score( @valves, $start, $time is copy ) {
        my $current = $start;
        my $pressure = 0;
        my $score = 0;
        while $time > 0 {
            if ( ! @valves ) {
                $score += ($time * $pressure);
                $time = 0;
            } elsif ( $current ~~ @valves[0] ) {
                @valves.shift;
                $score += $pressure;
                $pressure += $.get($current).flow-rate;               
                $time--;
            } else {
                my $moves = $.distance($current,@valves[0]);
                $current = @valves[0];
                $moves = $time if $moves > $time;
                $time -= $moves;
                $score += $pressure * $moves;
            }
        }
        return $score;
    }

    method best-score($start, $time) {
        $.openable.permutations.race.map({$.score($_.Array,$start,$time)}).sort({$^b <=> $^a}).[0];
    }

    method distance($start,$end) {
        if ! %!distance.keys { self.calc-distances() }
        return %!distance{$start}{$end};
    }
    
    method calc-distances {
        my @check = ['AA',|$.openable];
        my @all;
        while (@check) {
            my $current = @check.shift;
            %!distance{$current}{$current} = 0;
            for @check -> $to {
                @all.push([$current,$to]);
            }
        }
        @all.race.map(->[$current,$to]{
                             my $dist = %!valves{$current}.route-to($to).elems -1;
                             note "$current => $to : $dist";
                             %!distance{$current}{$to} = $dist;
                             %!distance{$to}{$current} = $dist;
                         });
    }

    method possible-pressure($start,$end,$time) {
        return %!valves{$end}.flow-rate * ($time - $.distance($start,$end) - 1);
    }

}

multi sub MAIN('TEST') {
    use Test;
    my $network = Network.new();
    my $valve = $network.parse('Valve AA has flow rate=0; tunnels lead to valves DD, II, BB');
    is $valve.gist, 'Valve AA has flow rate=0; tunnels lead to valves DD, II, BB';
    is $network.get('AA'), $valve;    
    $valve = $network.parse('Valve HH has flow rate=22; tunnel lead to valve GG');
    is $valve.gist, 'Valve HH has flow rate=22; tunnels lead to valves GG';
    is $network.get('HH'), $valve;

    $network = Network.new();
    $network.parse($_) for "day-16-test.txt".IO.lines;
    my $aa = $network.get('AA');
    is-deeply $aa.route-to('AA'), ('AA',);
    is-deeply $aa.route-to('JJ'), ('AA','II','JJ');
    is-deeply $aa.route-to('EE'), ('AA','DD','EE');

    is-deeply $network.openable, ('BB', 'CC', 'DD', 'EE', 'HH', 'JJ' );
    is $network.score(['DD','BB','JJ','HH','EE','CC'],'AA',30), 1651;
    is $network.best-score('AA',30), 1651;

     ('BB', 'CC', 'DD', 'EE', 'HH', 'JJ' ).map( { [$_, $network.get($_).flow-rate / $network.distance('AA',$_)] } ).say;

    done-testing;
}

multi sub MAIN(1,$fh) {
    my $network = Network.new();
    note "Parsing";
    $network.parse($_) for $fh.IO.lines;
    note "Calculating distances";
    $network.calc-distances();
    note "Calculating best score";
    $network.best-score('AA',30).say;
}

multi sub MAIN(1.5,$fh) {
    my $network = Network.new();
    note "Parsing";
    $network.parse($_) for $fh.IO.lines;
    note "Calculating distances";
    $network.calc-distances();

    my @best = $network.openable.map( {[$_, $network.get($_).flow-rate / ($network.distance('AA',$_)+1)]}).sort( { $^b[1] <=> $^a[1] }).map(*[0]);

    note "Testing {@best}";
    
    $network.score( [|@best], 'AA',30 ).say;
}
