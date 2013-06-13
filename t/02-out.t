#!/usr/bin/perl
use warnings;
use strict;

use Test::More tests => 5;
BEGIN {
	use_ok 'App::transmish::Out';
};

BEGIN {
	*CORE::GLOBAL::say = sub { return "@_" };
}

# We want to override functions writing to the default filehandle
# (STDOUT), but as print can't be overriden, we resort to making
# it write to our scalar instead.
sub _scalar_stdout {
	my $fun = shift;
	my $stdout;
	open my $fake_fh, '>', \$stdout;
	my $old = select($fake_fh);
	$fun->(@_);
	select($old);
	close $fake_fh;
	return $stdout;
}

sub _error { _scalar_stdout(\&error, @_) }
sub _ymhfu { _scalar_stdout(\&ymhfu, @_) }

is _error("foo"), "Error: foo\n";
is _error("foo", "bar"), "Error: foo bar\n";
is _ymhfu("foo"), "Warning: foo\n";
is _ymhfu("foo", "bar"), "Warning: foo bar\n";
