#!/usr/bin/perl
use warnings;
use strict;

use Test::More;
use App::transmish::Utils
	qw/
		rate size sizef size_si date bool percentage percentagef
		is_http_uri read_file http_file strrange
	/
;

my @tests = (
	['size(512)', '0.50KiB'],
	['size(1024)', '1.00KiB'],

	['size(1025)', '1.00KiB'],
	['size(1024**2+1)', '1.00MiB'],
	['size(1024**3+1)', '1.00GiB'],
	['size(1024**4+1)', '1.00TiB'],
	['size(1024**5+1)', '1.00PiB'],
	['size(1024**6+1)', '1024.00PiB'],

	['sizef("d", 1024**6+1)', '1024PiB'],
	['sizef(".3f", 1024**6+1)', '1024.000PiB'],

	['join(",", size_si(1024**3))', '1024,M'],
	['join(",", size_si(1024**3-1024**2/2))', '1023.5,M'],

	['rate(0)', '0.00B/s'],
	['rate(1)', '0.00KiB/s'],
	['rate(512)', '0.50KiB/s'],
	['rate(1024)', '1.00KiB/s'],
	['rate(1025)', '1.00KiB/s'],
	['rate(1024**2+1)', '1.00MiB/s'],

	['percentage(10/100)', '10.0%'],
	['percentagef("d", 10/100)', '10%'],

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

	['strrange()', []],
	['strrange(1)', [1]],
	['strrange("1")', [1]],
	['strrange(1, 2)', [1,2]],
	['strrange("1", "2")', [1,2]],
	['strrange("1-3")', [1,2,3]],
	['strrange("1-3", 4)', [1,2,3,4]],
	['strrange("1-3", "4")', [1,2,3,4]],
);

$ENV{TZ} = 'UTC';
plan tests => int @tests;

for (@tests) {
	my ($eval, $ref) = @$_;
	$ref = [$ref] unless ref $ref; # ref ref ref ref, whoops :-)
	is_deeply([eval($eval)], $ref, $eval);
}

