#!/usr/bin/perl
use warnings;
use strict;

use Test::More tests => 4;
BEGIN {
	use_ok 'App::transmish::Command';
};

cmd 'foo' => sub {
	my $arg = shift;

	return "nothing" unless defined $arg;
	return "flag" if $arg =~ /^-/;
	return "arg";
};

is(run('foo'), 'nothing', 'simple command');
is(run('foo', 'bar'), 'arg', 'simple command with arguments');

alias 'fnord' => 'foo --bar';
is(run('fnord'), 'flag', 'aliased command');
