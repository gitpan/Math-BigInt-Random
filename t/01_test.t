use strict;
use warnings;
require 5.008;

use Test::More tests => 9;
use Math::BigInt;
use Math::BigInt::Random;
 
ok( random_bigint( max => '10000000000000000000000000') =~ /^\d+$/, "Big base 10 number");
my $min = new Math::BigInt('70000000');
my $max = new Math::BigInt('100000000');
my $n = random_bigint( min => $min, max => $max);
ok( $n <= $max, "Ranged random integer small enough");
ok( $n >= $min, "Ranged random integer big enough");
$n = random_bigint( min => 250, max => 300 );
ok( $n <= 300, "Ranged small random integer small enough");
ok( $n >= 250, "Ranged small random integer big enough");
$n = random_bigint( length => 20 );
ok( length $n == 20, "Base 10 set length of $n");
ok( $n =~ /^[1234567890]+$/, "Base 10 look");
my $hex_digits = 44;
$n = random_bigint( length_hex => 1, length => $hex_digits);
my $hex_len = length $n->as_hex();
ok( $hex_len == $hex_digits + 2, "Base 16 set length");
ok( $n =~ /^[abcdefABCDEF1234567890x]+$/, "Base 16 look");

