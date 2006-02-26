package Game::Planeshift::Info;

use warnings;
use strict;

use LWP::Simple;

=head1 NAME

Game::Planeshift::Info - A module to retrieve players' data on the main Planeshift server.

=head1 VERSION

Version 0.2b

=cut

our $VERSION = '0.2b';

=head1 SYNOPSIS

Planeshift is a free MMORPG available at : http://www.planeshift.it.

This module allow you to easily get and parse data from the info page of a Planeshift server (so this module depend on LWP::Simple).

the default web page used to retrieve informations is on the Laanx server : http://laanx.fragnetics.com/index.php?page=char_stats.

    use Game::Planeshift::Info;

    my $ps = Game::Planeshift::Info->new(
    	encoding => 'utf-8',
    	players => ['Baston', 'Ehasara', 'Narita', 'Setill', 'Soshise', 'Mardun', 'Caules', 'Javeroal']
    );
    my $data = $ps->retrieve_info ;

=head1 CONSTRUCTOR

=head2 new([args])

The constructor take the followings arguments which are all optionnal :

B<encoding> : A string. The encoding you currently use (default: iso-8859-1)

B<players> : An arrayref. The list of players you want to see the status.

B<info_page> : A string. The URL of the page to parse to retrieve informations on the Planeshift server (default: http://laanx.fragnetics.com/index.php?page=char_stats)

=cut

sub new
{
	my ($ref,%args) = @_;
	my $self = {%args} ;
	$self->{info_page} = "http://laanx.fragnetics.com/index.php?page=char_stats" unless(defined($self->{info_page}));
	$self->{encoding} = "iso-8859-1" unless(defined($self->{encoding}));
	bless($self,$ref);
	return $self;
}

=head1 FUNCTIONS

=head2 retrieve_info

Get informations from the info page of the Planeshift server, parse the result and return a hashref with parsed data.

Here is an example :

	use Data::Dumper
	use Game::Planeshift::Info ;
	
	my my $ps = Game::Planeshift::Info->new(players => ['Baston', 'Ehasara', 'Narita', 'Setill', 'Soshise', 'Mardun', 'Caules', 'Javeroal']) ;
	print Dumper( $ps->retrieve_info );

On screen you will have :

	$VAR1 = {
		'online_players' => {
					'Caules' => 0,
					'Narita' => 0,
					'Javeroal' => 1,
					'Setill' => 0,
					'Baston' => 0,
					'Soshise' => 0,
					'Mardun' => 0,
					'Ehasara' => 0
				},
		'most_active_players' => {
					'Javeroal' => '1963.53',
					'Ganinos' => '1388.28',
					'Proteous' => '1851.65',
					'Ogu' => '1486.75',
					'Verrliit' => '1552.45'
					},
		'server_status' => {
				'Time' => 'Sun Feb 26 15:31:57 SGT 2006',
				'Total_Online' => 45,
				'Accounts' => '197993',
				'Report_Time_' => 'Sun Feb 26 15:31:56 SGT 2006',
				'Cal3d_Date' => '2005-05-15 00:00:00',
				'PS_Date' => '2006-01-14 00:00:00',
				'CS_Date' => '2006-01-04 00:00:00',
				'CEL_Date' => '2006-01-04 00:00:00',
				'Characters' => '75687',
				'Net_Version' => '0x47 '
				},
		'best_advisors' => {
				'Waoredo' => '3',
				'Virtutes' => '4',
				'Janner' => '18',
				'Minuis' => '18',
				'Gigelf' => '8'
				},
		'cleverer_players' => {
					'Maximillian' => '127.00',
					'Chromo' => '127.00',
					'Thinkundus' => '139.00',
					'Marco' => '140.00',
					'Lemethian' => '124.00'
					},
		'best_player_average' => {
					'Anfa' => {
							'hours_per_day' => '8.9571',
							'day_active' => '63'
						},
					'Javeroal' => {
							'hours_per_day' => '11.2202',
							'day_active' => '175'
							},
					'Setill' => {
							'hours_per_day' => '8.5811',
							'day_active' => '130'
							},
					'Tutoned' => {
							'hours_per_day' => '8.5708',
							'day_active' => '28'
							},
					'Satayne' => {
							'hours_per_day' => '9.7551',
							'day_active' => '128'
							}
					},
		'stronger_players' => {
					'Ozbi' => '150.00',
					'Kordin' => '150.00',
					'Eolius' => '151.00',
					'Rilno' => '150.00',
					'Slimx' => '150.00'
					},
		'dueling_champs' => {
					'Tarel' => '516.23',
					'Xshii' => '324.00',
					'Xeohna' => '300.00',
					'Brittany' => '263.33',
					'Kyixi' => '1008.00'
				}
		};


NOTE: In the 'online_players' section you will find a hashref where keys are players' name and value a boolean (0 or 1). So obviously 0 is when player is not online and 1 when he is.

NOTE2: The only information keep in mind by the object after a call to this method is the list off online players.

=cut

sub retrieve_info 
{
	my $self = shift;
	my $content = get($self->{info_page});
	return undef unless defined $content;
	return $self->_parse_content($content) ;
}

sub _parse_content
{

	sub _priv_parse_server_data
	{
		my $str = shift ;
		if($str=~/\s*<TD>\s*([^<]+)<\/TD>.+<A HREF='[^']+'>([^:<&]+):<\/A><\/TD><TD>\s*([^<]*)<\/TD>\s*/im)
		{
			return ($1,$2,$3);
		}
		elsif($str=~ /^\s*<TD>\s*([^<]+)/im)
		{
			return $1;
		}
		elsif($str=~/([^<]+)<\/FONT><\/TD>/)
		{
			return $1;
		}
	}
	my ($self,$content) = @_;
	my $data = {};
	my @raw_data=split(/\n/,$content);
	if(defined($self->{players}))
	{
		foreach (@{$self->{players}})
		{
			$data->{online_players}->{$_} = 0;
		}
	}
	for (my $k=0;$k<=$#raw_data;$k++)
	{
		next if($raw_data[$k]=~/^\s*$/) ;
		if($raw_data[$k]=~/\s*<H2>Stats<\/H2>/)
		{
			my $tmp;
			while(1)
			{
				$raw_data[$k]=~ s/&nbsp;/ /g;
				if($raw_data[$k]=~/\s*<\/TABLE>/i)
				{
					last ;
				}
				if($raw_data[$k]=~/\s*<TD class="testo">([^:<&]+):*\s*<\/TD>/)
				{
					$tmp = $1;
					$tmp=~ s/\s+/_/g;
					$k++;
					if($raw_data[$k]=~ /<TD><FONT SIZE=2>/)
					{
						while(1)
						{
							$k++;
							next if($raw_data[$k]=~ /^\s*$/);
							last;
						}
					}
					my ($key,$value);
					($data->{server_status}->{$tmp},$key,$value) = _priv_parse_server_data($raw_data[$k]);
					if(defined($key))
					{
						$key=~ s/\s+/_/g;
						$data->{server_status}->{$key} = $value;
					}
				}
				elsif($raw_data[$k]=~/\s*<TD class="testo"><A HREF="chars.png">([^:<&]+):*\s*<\/A><\/TD>/)
				{
					$tmp = $1;
					$tmp=~ s/\s+/_/g;
					$k++;
					my ($key,$value);
					($data->{server_status}->{$tmp},$key,$value) = _priv_parse_server_data($raw_data[$k]);
					if(defined($key))
					{
						$key=~ s/\s+/_/g;
						$data->{server_status}->{$key} = $value;
					}
				}
				$k++;
			}
			if(defined($data->{server_status}->{Total_Online}) && $data->{server_status}->{Total_Online} > 0)
			{
				$self->{server_online} = 1 ;
			}
			else
			{
				$self->{server_online} = 0 ;
			}
		}
		elsif($raw_data[$k]=~/<p class="yellowtitlebig">Players Online<\/p>/i)
		{
			my $html;
			my $start_found;
			while(1)
			{
				if(!defined($start_found) && $raw_data[$k]!~/\s*<p>/i)
				{
					$k++;
					next;
				}
				else
				{
					$start_found++;
				}
				if($raw_data[$k]=~/\s*<BR><BR>/i) #/\s*<table border=0 cellspacing="0" cellpadding="1">/i
				{
					last ;
				}
				$html .= $raw_data[$k];
				$k++;
			}
# 			print "(active) \$k is now at $k/$#raw_data\n";
# 			print "===> DEBUG (online) <===\n\n$html\n\n===> END DEBUG <===\n\n";
			foreach my $name (split(/,/,$html))
			{
				$name =~ s/\s*//g;
				$name =~ s/<p>//ig;
				if(defined($self->{players}) && exists($data->{online_players}->{$name}))
				{
					$data->{online_players}->{$name} = 1 ;
				}
				elsif(!defined($self->{players}))
				{
					$data->{online_players}->{$name} = 1 ;
				}
			}
			$self->{online_players} = $data->{online_players};
		}
		elsif($raw_data[$k]=~/<p class="yellowtitlebig">Most Active Players<\/p>/i)
		{
			my $html;
			my $start_found;
			while(1)
			{
				if(!defined($start_found) && $raw_data[$k]!~/\s*<TABLE CELLPADDING=5>/i)
				{
					$k++;
					next;
				}
				else
				{
					$start_found++;
				}
				if($raw_data[$k]=~/\s*<BR><BR>/i)
				{
					last ;
				}
				$html .= $raw_data[$k];
				$k++;
			}
# 			print "(active) \$k is now at $k/$#raw_data\n";
# 			print "===> DEBUG <===\n\n$html\n\n===> END DEBUG <===\n\n";
			foreach (split(/<\/TR>/,$html))
			{
				s/^\s*//g;
				/<TR>(.+)$/;
				if($1)
				{
					my $l = $1 ;
					my ($name,$hours) = $l =~/<TD>([^<]+)<\/TD>/g ;
					$data->{most_active_players}->{$name} = $hours;
				}
			}
		}
		elsif($raw_data[$k]=~/<p class="yellowtitlebig">Best Player Averages<\/p>/i)
		{
			my $html;
			my $start_found;
			while(1)
			{
				if(!defined($start_found) && $raw_data[$k]!~/\s*<TABLE CELLPADDING=5>/i)
				{
					$k++;
					next;
				}
				else
				{
					$start_found++;
				}
				if($raw_data[$k]=~/\s*<BR><BR>/i)
				{
					last ;
				}
				$html .= $raw_data[$k];
				$k++;
			}
# 			print "(avg) \$k is now at $k/$#raw_data\n";
# 			print "===> DEBUG <===\n\n$html\n\n===> END DEBUG <===\n\n";
			foreach (split(/<\/TR>/,$html))
			{
				s/^\s*//g;
				/<TR>(.+)$/;
				if($1)
				{
					my $l = $1 ;
					my ($name,$day_active,$hours_per_day) = $l =~/<TD>([^<]+)<\/TD>/g ;
					$data->{best_player_average}->{$name} = {day_active => $day_active,hours_per_day => $hours_per_day};
				}
			}
		}
		elsif($raw_data[$k]=~/<P class="yellowtitlehelp">Best Advisors<\/P>/i)
		{
# 			print "Entering in Best Advisors\n";
			my $html;
			my $start_found;
			while(1)
			{
				if(!defined($start_found) && $raw_data[$k]!~/\s*<TABLE CELLPADDING=5>/i)
				{
					$k++;
					next;
				}
				else
				{
					$start_found++;
				}
				if($raw_data[$k]=~/\s*<BR><BR>/i)
				{
					last ;
				}
				$html .= $raw_data[$k];
				$k++;
			}
# 			print "(adv) \$k is now at $k/$#raw_data\n";
			foreach (split(/<\/TR>/,$html))
			{
				s/^\s*//g;
				/<TR>(.+)$/;
				if($1)
				{
					my $l = $1 ;
					my ($name,$advisor_points) = $l =~/<TD>([^<]+)<\/TD>/g ;
					$data->{best_advisors}->{$name} = $advisor_points;
				}
			}
		}
		elsif($raw_data[$k]=~/<P class="yellowtitleaxe">Dueling Champs<\/P>/i)
		{
# 			print "Entering in Dueling Champs\n";
			my $html;
			my $start_found;
			while(1)
			{
				if(!defined($start_found) && $raw_data[$k]!~/\s*<TABLE CELLPADDING=5>/i)
				{
					$k++;
					next;
				}
				else
				{
					$start_found++;
				}
				if($raw_data[$k]=~/\s*<BR><BR>/i)
				{
					last ;
				}
				$html .= $raw_data[$k];
				$k++;
			}
# 			print "(duel) \$k is now at $k/$#raw_data\n";
			foreach (split(/<\/TR>/,$html))
			{
				s/^\s*//g;
				/<TR>(.+)$/;
				if($1)
				{
					my $l = $1 ;
					my ($name,$duel_points) = $l =~/<TD>([^<]+)<\/TD>/g ;
					$data->{dueling_champs}->{$name} = $duel_points;
				}
			}
		}
		elsif($raw_data[$k]=~/<P class="yellowtitlebig">Strength of the Gods<\/P>/i)
		{
			my $html;
			my $start_found;
			while(1)
			{
				if(!defined($start_found) && $raw_data[$k]!~/\s*<TABLE CELLPADDING=5>/i)
				{
					$k++;
					next;
				}
				else
				{
					$start_found++;
				}
				if($raw_data[$k]=~/\s*<BR><BR>/i)
				{
					last ;
				}
				$html .= $raw_data[$k];
				$k++;
			}
# 			print "(str) \$k is now at $k/$#raw_data\n";
			foreach (split(/<\/TR>/,$html))
			{
				s/^\s*//g;
				/<TR>(.+)$/;
				if($1)
				{
					my $l = $1 ;
					my ($name,$str) = $l =~/<TD>([^<]+)<\/TD>/g ;
					$data->{stronger_players}->{$name} = $str;
				}
			}
		}
		elsif($raw_data[$k]=~/<P class="yellowtitlebig">Thinkers of the World<\/P>/i)
		{
			my $html;
			my $start_found;
			while(1)
			{
				if(!defined($start_found) && $raw_data[$k]!~/\s*<TABLE CELLPADDING=5>/i)
				{
					$k++;
					next;
				}
				else
				{
					$start_found++;
				}
				if(!defined($raw_data[$k]))
				{
					last ;
				}
				$html .= $raw_data[$k];
				$k++;
			}
# # 			print "===> DEBUG <===\n\n$html\n\n===> END DEBUG <===\n\n";
# 			print "(int) \$k is now at $k/$#raw_data\n";
			foreach (split(/<\/TR>/,$html))
			{
				s/^\s*//g;
				/<TR>(.+)$/;
				if($1)
				{
					my $l = $1 ;
					my ($name,$int) = $l =~/<TD>([^<]+)<\/TD>/g ;
					$data->{cleverer_players}->{$name} = $int;
				}
			}
		}
	}
	@raw_data = ();
	return $data;
}

=head2 is_online

Return true is the player is online.

	print "My coder is online !!!\n" if($ps->is_online('Baston')) ;

This method can be called statically :

	print "My coder is online !!!\n" if(Game::Planeshift::Info::is_online($data,'Baston));

=cut

sub is_online
{
	return $_[0]->{online_players}->{$_[1]};
}

=head2 server_is_up

	Return a boolean (0 or 1). True if the server is up.

=cut

sub server_is_up
{
	my $self = shift;
	return $self->{server_online} ;
}

=head2 data2xml

Translate a data (returned by the retrieve_info() method) to XML :

	print $ps->data2xml( $ps->retrieve_info ) ;

The XML generated by this method on the data previously retrieve is :

	<?xml version="1.0" encoding="iso-8859-1" standalone="yes"?>
	<planeshift-info>
		<server-status>
			<time>Sun Feb 26 15:31:57 SGT 2006</time>
			<total-online>45</total-online>
			<accounts>197993</accounts>
			<report-time->Sun Feb 26 15:31:56 SGT 2006</report-time->
			<cal3d-date>2005-05-15 00:00:00</cal3d-date>
			<ps-date>2006-01-14 00:00:00</ps-date>
			<cs-date>2006-01-04 00:00:00</cs-date>
			<cel-date>2006-01-04 00:00:00</cel-date>
			<characters>75687</characters>
			<net-version>0x47 </net-version>
		</server-status>
		<online-players>
			<player name="Javeroal" />
		</online-players>
		<most-active-players>
			<player name="Javeroal" hours="1963.53"/>
			<player name="Ganinos" hours="1388.28"/>
			<player name="Proteous" hours="1851.65"/>
			<player name="Ogu" hours="1486.75"/>
			<player name="Verrliit" hours="1552.45"/>
		</most-active-players>
		<best-advisors>
			<player name="Waoredo" points="3"/>
			<player name="Virtutes" points="4"/>
			<player name="Janner" points="18"/>
			<player name="Minuis" points="18"/>
			<player name="Gigelf" points="8"/>
		</best-advisors>
		<cleverer-players>
			<player name="Maximillian" intelligence="127.00"/>
			<player name="Chromo" intelligence="127.00"/>
			<player name="Thinkundus" intelligence="139.00"/>
			<player name="Marco" intelligence="140.00"/>
			<player name="Lemethian" intelligence="124.00"/>
		</cleverer-players>
		<best-player-average>
			<player name="Anfa" hours-per-day="8.9571" day-active="63"/>
			<player name="Javeroal" hours-per-day="11.2202" day-active="175"/>
			<player name="Setill" hours-per-day="8.5811" day-active="130"/>
			<player name="Tutoned" hours-per-day="8.5708" day-active="28"/>
			<player name="Satayne" hours-per-day="9.7551" day-active="128"/>
		</best-player-average>
		<stronger-players>
			<player name="Ozbi" strength="150.00"/>
			<player name="Kordin" strength="150.00"/>
			<player name="Eolius" strength="151.00"/>
			<player name="Rilno" strength="150.00"/>
			<player name="Slimx" strength="150.00"/>
		</stronger-players>
		<dueling-champs>
			<player name="Tarel" points="516.23"/>
			<player name="Xshii" points="324.00"/>
			<player name="Xeohna" points="300.00"/>
			<player name="Brittany" points="263.33"/>
			<player name="Kyixi" points="1008.00"/>
		</dueling-champs>
	</planeshift-info>


=cut

sub data2xml
{
	my ($self,$data) = @_;
	my $xml = "<?xml version=\"1.0\" encoding=\"$self->{encoding}\" standalone=\"yes\"?>\n<planeshift-info>\n";
	
	$xml .= "\t<server-status>\n";
	foreach (keys(%{$data->{server_status}}))
	{
		my $key = lc($_) ;
		$key =~ s/_/-/g;
		$xml .= "\t\t<$key>$data->{server_status}->{$_}</$key>\n";
	}
	$xml .= "\t</server-status>\n";
	
	$xml .= "\t<online-players>\n";
	foreach (keys(%{$data->{online_players}}))
	{
		$xml .= "\t\t<player name=\"$_\" />\n" if(defined($data->{online_players}->{$_}) && $data->{online_players}->{$_});
	}
	$xml .= "\t</online-players>\n";
	
	$xml .= "\t<most-active-players>\n";
	foreach (keys(%{$data->{most_active_players}}))
	{
		$xml .= "\t\t<player name=\"$_\" hours=\"$data->{most_active_players}->{$_}\"/>\n" ;
	}
	$xml .= "\t</most-active-players>\n";
	
	$xml .= "\t<best-advisors>\n";
	foreach (keys(%{$data->{best_advisors}}))
	{
		$xml .= "\t\t<player name=\"$_\" points=\"$data->{best_advisors}->{$_}\"/>\n" ;
	}
	$xml .= "\t</best-advisors>\n";
	
	$xml .= "\t<cleverer-players>\n";
	foreach (keys(%{$data->{cleverer_players}}))
	{
		$xml .= "\t\t<player name=\"$_\" intelligence=\"$data->{cleverer_players}->{$_}\"/>\n" ;
	}
	$xml .= "\t</cleverer-players>\n";
	
	$xml .= "\t<best-player-average>\n";
	foreach (keys(%{$data->{best_player_average}}))
	{
		$xml .= "\t\t<player name=\"$_\" hours-per-day=\"$data->{best_player_average}->{$_}->{hours_per_day}\" day-active=\"$data->{best_player_average}->{$_}->{day_active}\"/>\n" ;
	}
	$xml .= "\t</best-player-average>\n";
	
	$xml .= "\t<stronger-players>\n";
	foreach (keys(%{$data->{stronger_players}}))
	{
		$xml .= "\t\t<player name=\"$_\" strength=\"$data->{stronger_players}->{$_}\"/>\n" ;
	}
	$xml .= "\t</stronger-players>\n";
	
	$xml .= "\t<dueling-champs>\n";
	foreach (keys(%{$data->{dueling_champs}}))
	{
		$xml .= "\t\t<player name=\"$_\" points=\"$data->{dueling_champs}->{$_}\"/>\n" ;
	}
	$xml .= "\t</dueling-champs>\n";
	
	$xml .= "</planeshift-info>\n";
	
	return $xml;
}

=head1 AUTHOR

Arnaud DUPUIS, C<< <dupuisarn at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-planeshift-info at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Planeshift-Info>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Game::Planeshift::Info

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Planeshift-Info>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Planeshift-Info>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Planeshift-Info>

=item * Search CPAN

L<http://search.cpan.org/dist/Planeshift-Info>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2006 Arnaud DUPUIS, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Game::Planeshift::Info
