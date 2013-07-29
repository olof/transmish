#!/usr/bin/perl
use warnings;
use strict;
use Test::More tests => 11;

use lib 't/lib';
use Transmission::Client;
use Transmission::Torrent;

# TODO: testing of the fields parameter

sub create_torrent {
	Transmission::Torrent->_create(
		name => 'Example torrent',
		hash_string => '1234567890abcdef1234567890abcdef12345678',
		is_private => 1,
		added_date => 0,
		done_date => -1,
		rate_upload => 0,
		rate_download => 0,
		uploaded_ever => 0,
		size_when_done => 1024**2,
		downloaded_ever => 0,
		peers_getting_from_us => 0,
		peers_sending_to_us => 0,
		@_,
	);
}

BEGIN {
	use_ok "App::transmish::list", 'torrent_list';
}

my $client = Transmission::Client->new(
	_torrents => [
		create_torrent(name => 'warez1'),
		create_torrent(name => 'warez2'),
		create_torrent(name => 'warez3'),
	],
);

my @torrents = torrent_list(client => $client);
is(int(@torrents), 3, "torrent_list, simple case, number of results");
is(
	$torrents[0]->name, 'warez1',
	'torrent_list, simple case, name of torrent'
);

@torrents = torrent_list(client => $client, ids => [2,3]);
is(int(@torrents), 2, "torrent_list, listed ids, number of results");
is(
	$torrents[0]->name, 'warez2',
	'torrent_list, listed ids, name of torrent'
);

@torrents = torrent_list(client => $client, ids => ['2-3']);
is(int(@torrents), 2, "torrent_list, listrange, number of results");
is(
	$torrents[1]->name, 'warez3',
	'torrent_list, listrange, name of torrent'
);

@torrents = torrent_list(client => $client, filter => sub {$_[0]->id % 2});
is(int(@torrents), 2, "torrent_list, filtered, number of results");
is(
	$torrents[0]->name, 'warez1',
	'torrent_list, filtered, name of torrent'
);

@torrents = torrent_list(
	client => $client,
	ids => [2,3],
	filter => sub {$_[0]->id % 2}
);
is(int(@torrents), 1, "torrent_list, listed ids+filtered, number of results");
is(
	$torrents[0]->name, 'warez3',
	'torrent_list, listed ids+filtered, name of torrent'
);
