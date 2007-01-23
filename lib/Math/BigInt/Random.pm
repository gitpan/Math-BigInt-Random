package Math::BigInt::Random;

our $VERSION = 0.01;

use strict;
use warnings;
require Exporter;
our @ISA    = qw(Exporter);
our @EXPORT = qw(random_bigint);
use Carp qw(carp croak);
use Math::BigInt;

sub random_bigint {
    my (%args) = @_;
    my $max = $args{max} || 0;
    $max = Math::BigInt->new($max);
    my ($length_hex) = $args{length_hex};
    my $required_length = 0;
    croak "negative max for range" if $max < 0;
    if ( $max == 0 ) {
        $required_length = $args{length}
          or croak "Need a maximum or a length for the random number";
        my $digit  = '9';
        my $prefix = '';
        if ($length_hex) {
            $digit  = 'f';
            $prefix = '0x';
        }
        my $max_num_string = $prefix . ( $digit x $required_length );
        $max = Math::BigInt->new($max_num_string);
    }
    my $min = $args{min} || 0;
    $min = Math::BigInt->new($min);
    my $interval = $max - $min;
    croak "too narrow a range" if $interval <= 0;
    my $tries = 10000;
    for ( my $i = 0 ; $i < $tries ; ++$i ) {
        my $rand_num =
          ( $interval < 0xfffff )
          ? Math::BigInt->new( int rand($interval) )
          : bigint_rand($interval);
        $rand_num += $min;
        my $num_length_10 = length $rand_num;
        my $num_length_16 = int( length( $rand_num->as_hex() ) ) - 2;
        next
          if $required_length
          and $length_hex
          and $num_length_16 != $required_length;
        next
          if $required_length
          and !$length_hex
          and $num_length_10 != $required_length;
        return $rand_num;
    }
    carp "Could not make random number $required_length size in $tries tries";
    return;
}

sub bigint_rand {
    my $max = shift;
    $max = Math::BigInt->new($max) unless ref $max;
    my $as_hex       = $max->as_hex();
    my $len          = length($as_hex);           # include '0x' prefix
    my $bottom_quads = int( ( $len - 3 ) / 4 );
    my $top_quad_chunk = substr( $as_hex, 0, $len - 4 * $bottom_quads );

    # generate random the size of the quads
    my $num = '0x';

    # generate top part not greater than it
    $num .= sprintf( "%x", int( rand( hex $top_quad_chunk ) ) );
    for ( 1 .. $bottom_quads ) { $num .= sprintf( "%04x", int( rand 0xffff ) ) }

    #turn into bigint
    return Math::BigInt->new($num);
}

=head1 NAME

Math::BigInt::Random -- arbitrary sized random integers

=head1 DESCRIPTION

    Random number generator for arbitrarily large integers. 
    Uses the Math::BigInt module to handle the generated values.

    This module exports a single function called random_bigint, which returns 
    a single random Math::BigInt number of the specified range or size.  


=head1 SYNOPSIS

  use Math::BigInt;
  use Math::BigInt::Random qw/ random_bigint /;
 
  print "random by max : ",  random_bigint( max => '10000000000000000000000000'), "\n",
    "random by max and min : ", 
    random_bigint( min => '7000000000000000000000000', max => '10000000000000000000000000'), "\n",
    "random by length (base 10): ",   
    random_bigint( length => 20 ), "\n",
    "random by length (base 16) :",
    random_bigint( as_hex => 1, length => 20)->as_hex, "\n";
    

=head1 FUNCTION ARGUMENTS

This module exports a single function called random_bigint, which returns 
a single random Math::BigInt of arbitrary size.  


Parameters to the function are given in paired hash style:

  max => $max,   
    the maximum integer that can be returned.  Either the 'max' or the 'length' 
    parameter is mandatory. If both max and length are given, only the 'max' 
    parameter will be used.
  
  min => $min,   
    which specifies the minimum integer that can be returned.  Note that the 
    min should be >= 0.

  length => $required_length,
    which specifies the number of digits (with most significant digit not 0).  
    Note that if max is specified, length will be ignored.  However, if max is 
    not specified, length is a required argument.
  
  length_hex => 1,
    which specifies that, if length is used, the length is that of the base 16 
    number, not the base 10 number which is the default for the length.
    
=head1 AUTHOR

William Herrera (wherrera@skylightview.com)

=head1 COPYRIGHT

  Copyright (C) 2007 William Hererra.  All Rights Reserved.

  This module is free software; you can redistribute it and/or mutilate it
  under the same terms as Perl itself.

 
=cut

1;
