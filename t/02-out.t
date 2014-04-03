#!/usr/bin/perl
use warnings;
use strict;

use Test::More tests => 13;
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

sub test_out {
	my $sub = shift;
	my $prefix = shift;

	my $wrapper = sub {
		_scalar_stdout(eval("\\&$sub"), @_)
	};

	for (
		{
			i => ['foo'],
			o => 'foo'
		}, {
			i => ['foo', 'bar'],
			o => 'foo bar'
		}
	) {
		my $ref_str = $_->{o};
		$ref_str = "$prefix: $ref_str" if $prefix;
		is $wrapper->(@{$_->{i}}), "$ref_str\n";
	}

	$wrapper = sub {
		_scalar_stdout(eval("\\&${sub}f"), @_)
	};

	for (
		{
			i => ['%s', 'foo'],
			o => 'foo'
		}, {
			i => ['%s: %d', 'foo', 42],
			o => 'foo: 42'
		}
	) {
		my $ref_str = $_->{o};
		$ref_str = "$prefix: $ref_str" if $prefix;
		is $wrapper->(@{$_->{i}}), "$ref_str\n";
	}
}

test_out('info', '');
test_out('error', 'Error');
test_out('ymhfu', 'Warning');
