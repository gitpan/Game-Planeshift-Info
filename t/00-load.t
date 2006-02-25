#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Game::Planeshift::Info' );
}

diag( "Testing Game::Planeshift::Info $Game::Planeshift::Info::VERSION, Perl $], $^X" );
