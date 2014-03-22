#!/usr/bin/perl
use warnings;
use strict;
use lib 't/lib';
use Transmission::Torrent;
use App::transmish::Utils qw(date);
use Test::More tests => 13;
use Test::Output qw(:tests stdout_from);
use JSON;

BEGIN {
	$ENV{TZ}='UTC';
	*CORE::GLOBAL::time = sub { 0 };
	use_ok('App::transmish::Out::Torrent', qw/summary status/);
};

my %TORRENT_DEFAULTS_ALL = (
	name => 'Example torrent',
	id => '42',
	hash_string => '1234567890abcdef1234567890abcdef12345678',
	download_dir => '/var/www/isos',
	is_private => 1,
	added_date => 0,
	done_date => -1,
);

sub ok_torrent_list_output {
	my $args = shift;
	my $ref = shift;
	my $msg = shift;
	my $torrent = Transmission::Torrent->_create(%$args);

	stdout_is(sub { summary($torrent) }, $ref, $msg);
}

sub ok_torrent_output_complete {
	my $torrent_data_in = shift;
	my $expected_in = shift;
	my $msg = shift;

	my %torrent_data = (
		%TORRENT_DEFAULTS_ALL,
		done_date => 3600,
		%{$torrent_data_in},
	);

	my $expected = [
		_torrent_head_section(%torrent_data),
		@{$expected_in->[0]},
		['### LINE ###'],
		@{$expected_in->[1]},
		['### LINE ###'],
		['Added at' => date($torrent_data{added_date})],
		['Completed at' => date($torrent_data{done_date})],
	];

	_validate_torrent_output(\%torrent_data, $expected, $msg);
}

sub ok_torrent_output_incomplete {
	my $torrent_data_in = shift;
	my $expected_in = shift;
	my $msg = shift;

	my %torrent_data = (
		%TORRENT_DEFAULTS_ALL,
		%{$torrent_data_in},
	);

	my $expected = [
		_torrent_head_section(%torrent_data),
		@{$expected_in->[0]},
		['### LINE ###'],
		@{$expected_in->[1]},
		['### LINE ###'],
		@{$expected_in->[2]},
	];

	_validate_torrent_output(\%torrent_data, $expected, $msg);
}

sub _validate_torrent_output {
	my $torrent_data = shift;
	my $expected = shift;
	my $msg = shift;

	my $torrent = Transmission::Torrent->_create( %$torrent_data );
	my $status = decode_json(stdout_from(sub { status($torrent) }));

	is_deeply($status, $expected, $msg);
}

sub _torrent_head_section {
	my %torrent_data = @_;

	return [$torrent_data{name}],
	       [Key => 'Value'],
	       [ID => $torrent_data{id}],
	       [Hash => $torrent_data{hash_string}],
	       [Private => $torrent_data{is_private} ? 'yes' : 'no'],
	       ['Download dir' => $torrent_data{download_dir}],
	       ['### LINE ###'];
}

ok_torrent_list_output(
	{
		id => 1,
		name => 'Torrent name',

		rate_upload => 0,
		rate_download => 0,
		uploaded_ever => 0,
		size_when_done => 100,
		downloaded_ever => 100,
	}, <<EOF
  1: Torrent name
      [100.0%] [down: 0.00B/s] [up: 0.00B/s] [uploaded: 0.00B]
EOF
	, 'inactive torrent should be as expected'
);

ok_torrent_list_output(
	{
		id => 20,
		name => 'Another torrent',

		rate_upload => 1024**2+1,
		rate_download => 1024**2+1,
		uploaded_ever => 1024**2+1,
		size_when_done => 100,
		downloaded_ever => 50,
	}, <<EOF
 20: Another torrent
      [50.0%] [down: 1.00MiB/s] [up: 1.00MiB/s] [uploaded: 1.00MiB]
EOF
	, 'inactive torrent should be as expected'
);

ok_torrent_output_complete(
	{
		size_when_done => 1024**3+1, # 1GiB
		downloaded_ever => 1024**3+1,
		uploaded_ever => 10 * 1024**2+1, # 10MiB

		rate_download => 0,
		rate_upload => 0,
		peers_getting_from_us => 0,
		peers_sending_to_us => 0,
	},
	[
		[
			[Completed => '100.0%'],
			[Size => '1.00GiB'],
			[Uploaded => '10.00MiB'],
			[Ratio => '0.01 (1 in 1 minute and 41 seconds)'],
		],
		[
			['Upload rate' => '0.00B/s'],
			[Peers => "Seeders:  0\n".
				  "Leechers: 0"],
		],
	],
	'completed torrent status'
);

ok_torrent_output_complete(
	{
		size_when_done => 1024**3+1, # 1GiB
		total_size => 2*(1024**3)+1, # 2GiB
		downloaded_ever => 1024**3+1,
		uploaded_ever => 10 * 1024**2+1, # 10MiB

		rate_download => 0,
		rate_upload => 0,
		peers_getting_from_us => 0,
		peers_sending_to_us => 0,
	},
	[
		[
			[Completed => '100.0% (total: 50.0%)'],
			[Size => '1.00GiB (total: 2.00GiB)'],
			[Uploaded => '10.00MiB'],
			[Ratio => '0.01 (1 in 1 minute and 41 seconds)'],
		],
		[
			['Upload rate' => '0.00B/s'],
			[Peers => "Seeders:  0\n".
				  "Leechers: 0"],
		],
	],
	'completed torrent status'
);

ok_torrent_output_incomplete(
	{
		size_when_done => 1024**3+1, # 1GiB
		downloaded_ever => (1024**3+1)/2, # 512MiB
		uploaded_ever => 10 * 1024**2+1, # 10MiB

		rate_download => 0,
		rate_upload => 0,
		peers_getting_from_us => 0,
		peers_sending_to_us => 0,
	},
	[
		[
			[Completed => '50.0%'],
			[Size => '1.00GiB'],
			[Downloaded => '512.00MiB'],
			[Uploaded => '10.00MiB'],
			[Ratio => '0.02 (1 in 50 seconds)'],
		],
		[
			['Upload rate' => '0.00B/s'],
			['Download rate' => '0.00B/s'],
			[Peers => "Seeders:  0\n".
				  "Leechers: 0"],
		],
		[
			['Added at' => '1970-01-01 00:00:00'],
			[ETA => 'Unknown'],
			[Left => '512.00MiB'],
		],
	],
	'half completed torrent status (zero rate download)'
);

ok_torrent_output_incomplete(
	{
		size_when_done => 1024**3+1, # 1GiB
		total_size => 2*(1024**3)+1, # 2GiB
		downloaded_ever => (1024**3+1)/2,
		uploaded_ever => 10 * 1024**2+1, # 10MiB

		rate_download => 0,
		rate_upload => 0,
		peers_getting_from_us => 0,
		peers_sending_to_us => 0,
	},
	[
		[
			[Completed => '50.0% (total: 25.0%)'],
			[Size => '1.00GiB (total: 2.00GiB)'],
			[Downloaded => '512.00MiB'],
			[Uploaded => '10.00MiB'],
			[Ratio => '0.02 (1 in 50 seconds)'],
		],
		[
			['Upload rate' => '0.00B/s'],
			['Download rate' => '0.00B/s'],
			[Peers => "Seeders:  0\n".
				  "Leechers: 0"],
		],
		[
			['Added at' => '1970-01-01 00:00:00'],
			[ETA => 'Unknown'],
			[Left => '512.00MiB'],
		],
	],
	'half completed torrent status (not all files wanted)'
);

ok_torrent_output_incomplete(
	{
		size_when_done => 1024**3+1, # 1GiB
		downloaded_ever => (1024**3+1)/2,
		uploaded_ever => 10 * 1024**2+1, # 10MiB

		rate_download => 512*1024,
		rate_upload => 0,
		peers_getting_from_us => 0,
		peers_sending_to_us => 1,
	},
	[
		[
			[Completed => '50.0%'],
			[Size => '1.00GiB'],
			[Downloaded => '512.00MiB'],
			[Uploaded => '10.00MiB'],
			[Ratio => '0.02 (1 in 50 seconds)'],
		],
		[
			['Upload rate' => '0.00B/s'],
			['Download rate' => '512.00KiB/s'],
			[Peers => "Seeders:  1\n".
				  "Leechers: 0"],
		],
		[
			['Added at' => '1970-01-01 00:00:00'],
			[ETA => '1970-01-01 00:17:04 (in 17 minutes and 4 seconds)'],
			[Left => '512.00MiB'],
		],
	],
	'half completed torrent status (non-zero rate download)'
);

ok_torrent_output_incomplete(
	{
		size_when_done => 1024**3+1, # 1GiB
		downloaded_ever => (1024**3+1)/2,
		uploaded_ever => 10 * 1024**2+1, # 10MiB

		rate_download => 1000,
		rate_upload => 0,
		peers_getting_from_us => 0,
		peers_sending_to_us => 1,
	},
	[
		[
			[Completed => '50.0%'],
			[Size => '1.00GiB'],
			[Downloaded => '512.00MiB'],
			[Uploaded => '10.00MiB'],
			[Ratio => '0.02 (1 in 50 seconds)'],
		],
		[
			['Upload rate' => '0.00B/s'],
			['Download rate' => '0.98KiB/s'],
			[Peers => "Seeders:  1\n".
				  "Leechers: 0"],
		],
		[
			['Added at' => '1970-01-01 00:00:00'],
			[ETA => '1970-01-07 05:07:50 (in 6 days and 5 hours)'],
			[Left => '512.00MiB'],
		],
	],
	'half completed torrent status (rate between 0 and 1024B/s)'
);

ok_torrent_output_incomplete(
	{
		size_when_done => 1024**3+1, # 1GiB
		downloaded_ever => (1024**3+1)/2, # 512M
		uploaded_ever =>   (1024**3+1)/2, # 512M

		rate_download => 1000,
		rate_upload => 0,
		peers_getting_from_us => 0,
		peers_sending_to_us => 1,
	},
	[
		[
			[Completed => '50.0%'],
			[Size => '1.00GiB'],
			[Downloaded => '512.00MiB'],
			[Uploaded => '512.00MiB'],
			[Ratio => '1.00'],
		],
		[
			['Upload rate' => '0.00B/s'],
			['Download rate' => '0.98KiB/s'],
			[Peers => "Seeders:  1\n".
				  "Leechers: 0"],
		],
		[
			['Added at' => '1970-01-01 00:00:00'],
			[ETA => '1970-01-07 05:07:50 (in 6 days and 5 hours)'],
			[Left => '512.00MiB'],
		],
	],
	'half completed torrent status, 1.0 ratio'
);

ok_torrent_output_incomplete(
	{
		size_when_done => 1024**3+1, # 1GiB
		downloaded_ever => 0,
		uploaded_ever => 0,

		rate_download => 0,
		rate_upload => 0,
		peers_getting_from_us => 0,
		peers_sending_to_us => 1,
	},
	[
		[
			[Completed => '0.0%'],
			[Size => '1.00GiB'],
			[Downloaded => '0.00B'],
			[Uploaded => '0.00B'],
			[Ratio => '0.00'],
		],
		[
			['Upload rate' => '0.00B/s'],
			['Download rate' => '0.00B/s'],
			[Peers => "Seeders:  1\n".
				  "Leechers: 0"],
		],
		[
			['Added at' => '1970-01-01 00:00:00'],
			[ETA => 'Unknown'],
			[Left => '1.00GiB'],
		],
	],
	'torrent not started'
);

ok_torrent_output_incomplete(
	{
		name => 'debian-7.0.0-amd64-DVD-1.iso',

		hash_string => '96534331d2d75acf14f8162770495bd5b05a17a9',
		is_private => 0,

		size_when_done => 0,
		downloaded_ever => 0,
		uploaded_ever => 0,

		rate_download => 0,
		rate_upload => 0,
		peers_getting_from_us => 0,
		peers_sending_to_us => 0,
	},
	[
		[
			[Completed => 'unknown'],
			[Size => '0.00B'],
			[Downloaded => '0.00B'],
			[Uploaded => '0.00B'],
			[Ratio => 'Inf'],
		],
		[
			['Upload rate' => '0.00B/s'],
			['Download rate' => '0.00B/s'],
			[Peers => "Seeders:  0\n".
				  "Leechers: 0"],
		],
		[
			['Added at' => '1970-01-01 00:00:00'],
			[ETA => 'Unknown'],
			[Left => 'Unknown'],
		],
	],
	'torrent not started, metadata not available'
);

ok_torrent_output_complete(
	{
		size_when_done => 2*1024**3+1, # 2GiB
		total_size => 2*1024**3+1, # 2GiB
		downloaded_ever => 1024**3+1, # 1GiB
		uploaded_ever => 10 * 1024**2+1, # 10MiB
		percent_done => 1,

		rate_download => 0,
		rate_upload => 0,
		peers_getting_from_us => 0,
		peers_sending_to_us => 0,
	},
	[
		[
			[Completed => '100.0%'],
			[Size => '2.00GiB (downloaded: 1.00GiB)'],
			[Uploaded => '10.00MiB'],
			[Ratio => '0.01 (1 in 1 minute and 41 seconds)'],
		],
		[
			['Upload rate' => '0.00B/s'],
			[Peers => "Seeders:  0\n".
				  "Leechers: 0"],
		],
	],
	'completed torrent status (some data supplied out of bands)'
);
