#!/usr/bin/perl
use warnings;
use strict;

use Test::More tests => 2;
BEGIN {
	use_ok 'App::transmish::Command';
};

cmd 'foo' => sub { "bar" };
is(run('foo'), 'bar');
