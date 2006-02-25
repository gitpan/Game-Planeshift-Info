use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Game::Planeshift::Info',
    license             => 'perl',
    dist_author         => 'Arnaud DUPUIS <dupuisarn@cpan.org>',
    dist_version_from   => 'lib/Game/Planeshift/Info.pm',
    build_requires => {
        'Test::More' => 0,
	'LWP::Simple' => 1.41,
    },
    add_to_cleanup      => [ 'Game-Planeshift-Info-*' ],
);

$builder->create_build_script();
