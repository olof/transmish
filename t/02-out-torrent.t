#!/usr/bin/perl
use warnings;
use strict;
use lib 't/lib';
use Transmission::Torrent;

use Test::More tests => 3;
use Test::Output;

BEGIN {
	use_ok('App::transmish::Out::Torrent', qw/summary/);
};

my $client;

$client = Transmission::Torrent->_create(
	id => 1,
	name => 'Torrent name',

	rate_upload => 0,
	rate_download => 0,
	uploaded_ever => 0,
	percent_done => 1,
);

stdout_is(sub { summary($client) }, 
	<<EOF
  1: Torrent name
      [100.0%] [down: 0.00B/s] [up: 0.00B/s] [uploaded: 0.00B]
EOF
	, 'inactive torrent should be as expected'
);

$client = Transmission::Torrent->_create(
	id => 20,
	name => 'Another torrent',

	rate_upload => 1024**2+1,
	rate_download => 1024**2+1,
	uploaded_ever => 1024**2+1,
	percent_done => 0.5,
);

stdout_is(sub { summary($client) }, 
	<<EOF
 20: Another torrent
      [50.0%] [down: 1.00MiB/s] [up: 1.00MiB/s] [uploaded: 1.00MiB]
EOF
	, 'inactive torrent should be as expected'
);



