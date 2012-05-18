#!/usr/bin/perl
use warnings;
use strict;
use lib 't/lib';
use Transmission::Torrent;

use Test::More tests => 5;
use Test::Output;

$ENV{TZ}='UTC';

BEGIN {
	use_ok('App::transmish::Out::Torrent', qw/summary status/);
};

my $torrent;

$torrent = Transmission::Torrent->_create(
	id => 1,
	name => 'Torrent name',

	rate_upload => 0,
	rate_download => 0,
	uploaded_ever => 0,
	size_when_done => 100,
	downloaded_ever => 100,
);

stdout_is(sub { summary($torrent) },
	<<EOF
  1: Torrent name
      [100.0%] [down: 0.00B/s] [up: 0.00B/s] [uploaded: 0.00B]
EOF
	, 'inactive torrent should be as expected'
);

$torrent = Transmission::Torrent->_create(
	id => 20,
	name => 'Another torrent',

	rate_upload => 1024**2+1,
	rate_download => 1024**2+1,
	uploaded_ever => 1024**2+1,
	size_when_done => 100,
	downloaded_ever => 50,
);

stdout_is(sub { summary($torrent) },
	<<EOF
 20: Another torrent
      [50.0%] [down: 1.00MiB/s] [up: 1.00MiB/s] [uploaded: 1.00MiB]
EOF
	, 'inactive torrent should be as expected'
);

$torrent = Transmission::Torrent->_create(
	name => 'Example torrent',

	id => 42,
	hash_string => '1234567890abcdef1234567890abcdef12345678',
	is_private => 'top secret',

	size_when_done => 1024**3+1, # 1GiB
	downloaded_ever => 1024**3+1,
	uploaded_ever => 10 * 1024**2+1, # 10MiB

	rate_download => 0,
	rate_upload => 0,
	peers_getting_from_us => 0,

	added_date => 0,
	done_date => 3600,
);

stdout_is(sub { status($torrent) },
	<<EOF
.---------------------------------------------------------.
|                     Example torrent                     |
+--------------+------------------------------------------+
| Key          | Value                                    |
+--------------+------------------------------------------+
| ID           | 42                                       |
| Hash         | 1234567890abcdef1234567890abcdef12345678 |
| Private      | yes                                      |
+--------------+------------------------------------------+
| Completed    | 100.0%                                   |
| Size         | 1.00GiB                                  |
| Uploaded     | 10.00MiB                                 |
| Ratio        | 0.01                                     |
+--------------+------------------------------------------+
| Upload rate  | 0.00B/s                                  |
| Rx from us   | 0                                        |
+--------------+------------------------------------------+
| Added at     | 1970-01-01 00:00:00                      |
| Completed at | 1970-01-01 01:00:00                      |
'--------------+------------------------------------------'
EOF
	, 'completed torrent status'
);

$torrent = Transmission::Torrent->_create(
	name => 'Example torrent',

	id => 42,
	hash_string => '1234567890abcdef1234567890abcdef12345678',
	is_private => 'top secret',

	size_when_done => 1024**3+1, # 1GiB
	downloaded_ever => (1024**3+1)/2,
	uploaded_ever => 10 * 1024**2+1, # 10MiB

	rate_download => 0,
	rate_upload => 0,
	peers_getting_from_us => 0,
	peers_sending_to_us => 0,

	added_date => 0,
	done_date => 3600,
);

stdout_is(sub { status($torrent) },
	<<EOF
.----------------------------------------------------------.
|                      Example torrent                     |
+---------------+------------------------------------------+
| Key           | Value                                    |
+---------------+------------------------------------------+
| ID            | 42                                       |
| Hash          | 1234567890abcdef1234567890abcdef12345678 |
| Private       | yes                                      |
+---------------+------------------------------------------+
| Completed     | 50.0%                                    |
| Size          | 1.00GiB                                  |
| Downloaded    | 512.00MiB                                |
| Uploaded      | 10.00MiB                                 |
| Ratio         | 0.02                                     |
+---------------+------------------------------------------+
| Upload rate   | 0.00B/s                                  |
| Download rate | 0.00B/s                                  |
| Tx to us      | 0                                        |
| Rx from us    | 0                                        |
+---------------+------------------------------------------+
| Added at      | 1970-01-01 00:00:00                      |
| ETA           | Unknown                                  |
| Left          | 512.00MiB                                |
'---------------+------------------------------------------'
EOF
	, 'half completed torrent status (zero rate download)'
);

