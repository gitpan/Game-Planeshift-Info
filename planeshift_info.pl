#!/usr/bin/perl

use lib 'lib/';
use Game::Planeshift::Info ;
use Data::Dumper;

my $ps = Game::Planeshift::Info->new(
	players => ['Baston', 'Ehasara', 'Narita', 'Setill', 'Soshise', 'Mardun', 'Caules', 'Javeroal','Bodacher','Proglin','Eus','Sangwa','Anfa','Essiri','Isra','Vaice','Flameron']
) ;

# my $ps = Game::Planeshift::Info->new() ;

my $d = $ps->retrieve_info or die "unable to retrieve Planeshift informations\n";

print Dumper($d);

print "My coder is online !!!\n" if($ps->is_online('Baston')) ;
print "My coder is not online :'(\n" unless($ps->is_online('Baston')) ;

print $ps->data2xml($d) ;
