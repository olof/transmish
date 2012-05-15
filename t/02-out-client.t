#!/usr/bin/perl
use warnings;
use strict;
use lib 't/lib';
use Transmission::Client;

use Test::More tests => 5;
use Test::Output;

BEGIN {
	use_ok('App::transmish::Out::Client', qw/summary/)
};

my $client;

$client = Transmission::Client->new(
	_stats_args => {
		download_speed => 0,
		upload_speed => 0,
	},
);

stdout_is(sub { summary($client) },
	<<EOF

Total: [down: 0.00B/s] [up: 0.00B/s]
EOF
	, 'Inactivity output'
);

$client = Transmission::Client->new(
	_stats_args => {
		download_speed => 5*1024**2+1,
		upload_speed => 0,
	},
);

stdout_is(sub { summary($client) },
	<<EOF

Total: [down: 5.00MiB/s] [up: 0.00B/s]
EOF
	, 'Download activity output'
);

$client = Transmission::Client->new(
	_stats_args => {
		download_speed => 0,
		upload_speed => 42*1024**2+1,
	},
);

stdout_is(sub { summary($client) },
	<<EOF

Total: [down: 0.00B/s] [up: 42.00MiB/s]
EOF
	, 'Download activity output'
);

$client = Transmission::Client->new(
	_stats_args => {
		download_speed => 22*1024+1,
		upload_speed => 42*1024**2+1,
	},
);

stdout_is(sub { summary($client) },
	<<EOF

Total: [down: 22.00KiB/s] [up: 42.00MiB/s]
EOF
	, 'Up- and download activity output'
);

