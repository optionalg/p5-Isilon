#!perl -T

use Test::More tests => 1;

BEGIN { use_ok( 'Isilon' ); }

diag( "Testing Isilon $Isilon::VERSION, Perl $], $^X" );
