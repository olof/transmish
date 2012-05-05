#!/usr/bin/perl
use warnings;
use strict;

use Test::More;
use App::transmish::Utils 
	qw/
		rate size date duration bool percentage
		is_http_uri read_file http_file
	/
;

my @tests = (
	['size(1024)', '1024.00B'],
	['size(1025)', '1.00KiB'],
	['size(1024**2+1)', '1.00MiB'],
	['size(1024**3+1)', '1.00GiB'],
	['size(1024**4+1)', '1.00TiB'],
	['size(1024**5+1)', '1.00PiB'],
	['size(1024**6+1)', '1024.00PiB'],

	['rate(1024)', '1024.00B/s'],
	['rate(1025)', '1.00KiB/s'],
	['rate(1024**2+1)', '1.00MiB/s'],

	['date(0)', '1970-01-01 00:00:00'],
	['date(1234567890)', '2009-02-13 23:31:30'],

	['bool("0")', 'no'],
	['bool(0)', 'no'],
	['bool(undef)', 'no'],
	['bool("")', 'no'],
	['bool()', 'no'],
	['bool("1")', 'yes'],
	['bool(1)', 'yes'],
	['bool("yes")', 'yes'],
	['bool("no")', 'yes'],

	['duration(0)', '0 seconds'],
	['duration(1)', '1 second'],
	['duration(2)', '2 seconds'],
	['duration(60)', '1 minute 0 seconds'],
	['duration(61)', '1 minute 1 second'],
	['duration(62)', '1 minute 2 seconds'],
	['duration(120)', '2 minutes 0 seconds'],
	['duration(121)', '2 minutes 1 second'],
	['duration(122)', '2 minutes 2 seconds'],
	['duration(3660)', '1 hour 1 minute'],
	['duration(3661)', '1 hour 1 minute'],
	['duration(7200)', '2 hours 0 minutes'],
	['duration(90000)', '1 day 1 hour'],
	['duration(90600)', '1 day 1 hour'],
	['duration(172800)', '2 days 0 hours'],
	['duration(172802)', '2 days 0 hours'],
	['duration(176400)', '2 days 1 hour'],
	['duration(180000)', '2 days 2 hours'],
);

$ENV{TZ} = 'UTC';
plan tests => int @tests;

for(@tests) {
	my ($eval, $ref) = @$_;
	is(eval($eval), $ref, $eval);
}

