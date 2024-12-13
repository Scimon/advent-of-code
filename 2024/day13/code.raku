use Math::Libgsl::LinearAlgebra;
use Math::Libgsl::Matrix;
use Math::Libgsl::Permutation;
use Math::Libgsl::Vector;

subset Part of Int() where * ~~ any(1|2);

multi sub MAIN ('brute', $file, Part :p($part)=1 ) {
    my @lines = $file.IO.lines;
    my $add = $part ~~ 1 ?? 0 !! 100000000000000;
    say [+] @lines.rotor( 3 => 1 ).map( -> @block { check-block( parse-block( $add, @block  ) ) } ).grep( * !~~ Inf );
}

multi sub MAIN( 'gsl', $file, Part :p($part)=1 ) {
    my @lines = $file.IO.lines;
    my $add = $part ~~ 1 ?? 0 !! 10000000000000;
    say [+] @lines.rotor( 3 => 1 ).race.map( -> @block { solve-block( parse-block( $add, @block  ) ) } ).grep( * !~~ Inf );
}

multi sub MAIN('test') {
    say solve-block( { A => { X => 94, Y => 34 }, B => { X => 22, Y => 67 }, P => { X => 8400, Y => 5400 } } );
    say solve-block( { A => { X => 26, Y => 66 }, B => { X => 67, Y => 21 }, P => { X => 12748, Y => 12176 } } );
}

sub check-block( %results ) {
    ((0..100) X, (0..100))
    .race.grep(
        -> @p {
            %results<A><X> * @p[0] + %results<B><X> * @p[1] == %results<P><X> &&
            %results<A><Y> * @p[0] + %results<B><Y> * @p[1] == %results<P><Y>
        } ).map( -> @p { @p[0] * 3 + @p[1] } ).min;
    
}

sub parse-block ($add, @block) {
    my (%results, $m);
    $m = ( @block[0] ~~ m/^ "Button A: X+" (\d+) ", Y+" (\d+) /);
    %results<A> = { X => $m[0].Int, Y => $m[1].Int };
    $m = ( @block[1] ~~ m/^ "Button B: X+" (\d+) ", Y+" (\d+) /);
    %results<B> = { X => $m[0].Int, Y => $m[1].Int };
    $m = ( @block[2] ~~ m/^ "Prize: X=" (\d+) ", Y=" (\d+) /);
    %results<P> = { X => $m[0].Int + $add, Y => $m[1].Int + $add };
    
    return %results;
}

sub solve-block( %results ) {
    my $*TOLERANCE = 1e-14;
    my $matrix-a = Math::Libgsl::Matrix.new(:size1(2), :size2(2));
    $matrix-a[0;0] = %results<A><X>;
    $matrix-a[1;0] = %results<A><Y>;
    $matrix-a[0;1] = %results<B><X>;
    $matrix-a[1;1] = %results<B><Y>;

    my $matrix-b = Math::Libgsl::Vector.new(:size(2));
    $matrix-b[0] = %results<P><X>;
    $matrix-b[1] = %results<P><Y>;
    
    my @out = LU-decomp($matrix-a);
    
    my @out2 = LU-solve($matrix-a, @out[1], $matrix-b);

    @out2 =  @out2.grep( -> $v { my $a = $v.get(0); my $b = $v.get(1); round($a,1) =~= $a && round($b,1) =~= $b } ).map( -> $v { round($v.get(0),1) * 3 + round($v.get(1),1) } ).min;

    return @out2[0];
}
