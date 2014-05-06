# Copyright 2012-2013, Olof Johansson <olof@ethup.se>
#
# Copying and distribution of this file, with or without
# modification, are permitted in any medium without royalty
# provided the copyright notice are preserved. This file is
# offered as-is, without any warranty.

=head1 NAME

App::transmish::Out - output related helper functions

=cut

package App::transmish::Out;
use 5.14.0;
use warnings;
use strict;

our $VERSION = 0.1;
my $DEBUG = 0;

require Exporter;
our @ISA = 'Exporter';
our @EXPORT = qw/
	info infof error errorf ymhfu ymhfuf dbg dbgf crap crapf dumper
/;

use Data::Dumper;
$Data::Dumper::Indent = 1;

=head1 SUBROUTINES

For each of these functions except for dumper, there exists a variant
with an f suffix; these use the printf format string syntax.

=head2 info, infof

The subroutine prints informational messages, without a prefix. This
subroutine should be used for any output you may need to use. This
makes it simple to mock away output generation in tests.

=cut

sub info {
	say "@_";
}

sub infof {
	info sprintf shift, @_;
}

=head2 error, errorf

Print an error message. The output is prefixed with "Error: " and a
newline is appended.

=cut

sub error {
	say "Error: @_";
}

sub errorf {
	# printf @_ does what i want it to do but
	# sprintf @_ just gives me the number of elements
	# in @_.
	error sprintf shift, @_;
}

=head2 ymhfu, ymhfuf

Print a warning message. The subroutine name is an acronym for "you
may have fucked up", credit for the awesome name goes to patogen.

=cut

sub ymhfu {
	say "Warning: @_";
}

sub ymhfuf {
	ymhfu sprintf shift, @_;
}

=head2 dbg, dbgf

Print a debug message if the debug level is above the debug message
level. The first argument is the debug level, a numeric value that
will be compared to the debug level set by App::transmish::Out::dbglvl.
The rest of the arguments are passed to say (prepended by "Debug: ").

=cut

sub dbg {
	my $level = shift;

	say "Debug: @_" unless $DEBUG < $level;
}

sub dbgf {
	my $lvl = shift;
	dbg $lvl, sprintf shift, @_;
}

=head2 crap, crapf

Like die or carp, but use our "error" routine. Exits with 1 after
printing the error message passed to it.

=cut

sub crap {
	error @_;
	exit 1;
}

sub crapf {
	crap sprintf shift, @_;
}

=head2 dumper

Call Data::Dumper on argument and print it if debuglevel is above 3.

=cut

sub dumper {
	my $obj = shift;
	dbg 3, Dumper($obj);
}

=head2 dbglvl

Set debug level, affecting the output by dbg. Defaults to 0.

=cut

sub dbglvl {
	my $level = shift;
	$DEBUG = $level if $level;
	return $DEBUG;
}

=head1 COPYRIGHT

Copyright 2012, Olof Johansson <olof@ethup.se>

Copying and distribution of this file, with or without modification,
are permitted in any medium without royalty provided the copyright
notice are preserved. This file is offered as-is, without any warranty.

=cut

1;
