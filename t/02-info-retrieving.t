#!perl -T

use Test::More tests => 3;

use_ok( 'Game::Planeshift::Info' );
my $ps = Game::Planeshift::Info->new();
ok(ref($ps) eq 'Game::Planeshift::Info');
my $data = $ps->retrieve_info ;

ok(ref($data) eq 'HASH');