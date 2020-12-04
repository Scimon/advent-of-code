#!/usr/bin/env raku

grammar Passport {
    token TOP { <passport>+ % <sep> \n? } 
    token field-name { "byr"|"iyr"|"eyr"|"hgt"|"hcl"|"ecl"|"pid"|"cid" }
    token field-data { \S+ }
    token field { <field-name> ":" <field-data> }
    token field-row { <field>+ % ' ' }
    token passport { <field-row>+ % \n }
    token sep { \n \n }
}

class PassportActions {
    has @.passports;

    method TOP($/) {
        @.passports = $<passport>>>.made;
    }
    method passport($/) {
        my @row = [ $<field-row>>>.made.map( *.Slip ) ];
        my $valid = (@row.elems == 8) || (@row.elems == 7 && none(@row.map(*.key)) ~~ 'cid');  
        make { fields => [ $<field-row>>>.made.map( *.Slip ) ], valid => $valid };
    }
    method field-row($/) {
        make [ $<field>>>.made ];
    }
    method field($/) {
        make $<field-name>.made => $<field-data>.made
    }
    method field-name($/) {
        make $/.Str;
    }
    method field-data($/) {
        make $/.Str;
    }
}

multi sub MAIN ( "test" ) {
    use Test;
    ok Passport.parse( "ecl:gry", :rule<field> );
    ok Passport.parse( "ecl:gry pid:860033327 eyr:2020 hcl:#fffffd", :rule<field-row> );
    ok Passport.parse( "ecl:gry pid:860033327 eyr:2020 hcl:#fffffd\nbyr:1937 iyr:2017 cid:147 hgt:183cm", :rule<passport> );
    ok Passport.parse( "example".IO.slurp );
    ok Passport.parse( "input".IO.slurp );
    done-testing;
}

multi sub MAIN ( Str $file where * ~~ "input"|"example" ) {
    my $actions = PassportActions.new;
    Passport.parse( $file.IO.slurp, :$actions );
    say $actions.passports.grep( -> $p { $p<valid> } ).elems;                               
}
