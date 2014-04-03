#!/usr/bin/perl
use warnings;
use strict;
use lib 't/lib/silence';

package Transmission::Client;

sub wanted {

}

package Transmission::Torrent;

use Data::Dumper;
$Data::Dumper::Indent = 1;

sub files {
	shift->{files};
}

sub write_wanted { 1 }

package Transmission::Torrent::File;

sub name {
	shift->{name}
}

sub wanted {
	my $self = shift;
	$self->{wanted} = shift;
}

package main;

# Current test data.
our $CURRENT;

use Test::More;
use List::MoreUtils qw(pairwise);
BEGIN {
	$INC{'Transmission/Client.pm'} = '/dev/null';
	$INC{'Transmission/Torrent.pm'} = '/dev/null';
	$INC{'Transmission/Torrent/File.pm'} = '/dev/null';

	use_ok 'App::transmish::cmd::torrent';
};

for my $test (
	{
		testname => 'all on => files on => all on',
		pattern => '.*',
		match => 1,
		initial => {
			files => ['file1', 'file2', 'FILE2/bar'],
			wanted => [1, 1, 1]
		},
		expected => {
			files => ['file1', 'file2', 'FILE2/bar'],
			wanted => [1, 1, 1]
		},
	},
	{
		testname => 'all off => files on => all on',
		pattern => '.*',
		match => 1,
		initial => {
			files => ['file1', 'file2', 'FILE2/bar'],
			wanted => [0, 0, 0]
		},
		expected => {
			files => ['file1', 'file2', 'FILE2/bar'],
			wanted => [1, 1, 1]
		},
	},
	{
		testname => 'all off => files on FILE2 => FILE2 on',
		pattern => 'FILE2',
		match => 1,
		initial => {
			files => ['file1', 'file2', 'FILE2/bar'],
			wanted => [0, 0, 0]
		},
		expected => {
			files => ['file1', 'file2', 'FILE2/bar'],
			wanted => [0, 0, 1]
		},
	},
	{
		testname => 'all on => files off ^file[12]$ => file{1,2} off',
		pattern => '^file[12]$',
		match => 0,
		initial => {
			files => ['file1', 'file2', 'FILE2/bar'],
			wanted => [1, 1, 1]
		},
		expected => {
			files => ['file1', 'file2', 'FILE2/bar'],
			wanted => [0, 0, 1]
		},
	},
	{
		testname => 'all off => files only file1 => only file1 on',
		pattern => 'file1',
		miss => 0,
		match => 1,
		initial => {
			files => ['file1', 'file2', 'FILE2/bar'],
			wanted => [0, 0, 0]
		},
		expected => {
			files => ['file1', 'file2', 'FILE2/bar'],
			wanted => [1, 0, 0]
		},
	},
	{
		testname => 'all on => files only file1 => only file1 on',
		pattern => 'file1',
		miss => 0,
		match => 1,
		initial => {
			files => ['file1', 'file2', 'FILE2/bar'],
			wanted => [1, 0, 0]
		},
		expected => {
			files => ['file1', 'file2', 'FILE2/bar'],
			wanted => [1, 0, 0]
		},
	},
	{
		testname => 'some on => files only file1 => only file1 on',
		pattern => 'file1',
		miss => 0,
		match => 1,
		initial => {
			files => ['file1', 'file2', 'FILE2/bar'],
			wanted => [0, 1, 1]
		},
		expected => {
			files => ['file1', 'file2', 'FILE2/bar'],
			wanted => [1, 0, 0]
		},
	},
) {
	files_test($test);
}

done_testing();

sub load_testdata {
	my $test = shift;
	my $init = $test->{initial};
	our ($a, $b);

	$test->{client} = bless {}, "Transmission::Client";
	$test->{torrent} = bless {
		files => [pairwise {
			bless { name => $a, wanted => $b },
				"Transmission::Torrent::File"
		} @{$init->{files}}, @{$init->{wanted}}]
	}, "Transmission::Torrent";
}

sub analyze_testdata {
	my $test = shift;

	my $idx = 0;
	for (@{$test->{torrent}->files}) {
		is $_->{wanted}, $test->{expected}->{wanted}->[$idx],
			sprintf "%s: %s", $test->{testname}, $_->name;
		++$idx;
	}
}

sub files_test {
	my $test = shift;
	load_testdata($test);

	App::transmish::cmd::torrent::_select_wanted(
		$test->{client}, $test->{torrent},
		pattern => $test->{pattern},
		match => $test->{match},
		miss => $test->{miss},
	);

	analyze_testdata($test);
}
