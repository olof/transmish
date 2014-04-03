#!/usr/bin/perl
use warnings;
use strict;

use Test::More tests => 10;
BEGIN {
	use_ok 'App::transmish::Out';
};

use Data::Dumper;

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
sub _errorf { _scalar_stdout(\&errorf, @_) }
sub _ymhfu { _scalar_stdout(\&ymhfu, @_) }
sub _ymhfuf { _scalar_stdout(\&ymhfuf, @_) }
sub _info { _scalar_stdout(\&info, @_) }
sub _infof { _scalar_stdout(\&infof, @_) }

is _error("foo"), "Error: foo\n";
is _errorf("%s: %d", "adams", "42"), "Error: adams: 42\n";
is _error("foo", "bar"), "Error: foo bar\n";
is _ymhfu("foo"), "Warning: foo\n";
is _ymhfu("foo", "bar"), "Warning: foo bar\n";
is _ymhfuf("%s", "barbaz"), "Warning: barbaz\n";
is _info("foo"), "foo\n";
is _info("foo", "bar"), "foo bar\n";
is _infof("%s", "barbaz"), "barbaz\n";
