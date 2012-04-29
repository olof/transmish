# Copyright 2012, Olof Johansson <olof@ethup.se>
#
# Copying and distribution of this file, with or without 
# modification, are permitted in any medium without royalty 
# provided the copyright notice are preserved. This file is 
# offered as-is, without any warranty.

=head1 NAME

App::transmish::Out - output related helper functions

=cut

package App::transmish::Out;
our $VERSION = 0.1;
my $DEBUG = 0;

use warnings;
use strict;
use feature qw/say/;

require Exporter;
our @ISA = 'Exporter';
our @EXPORT = qw/error dbg crap dumper/;

use Data::Dumper;

=head1 SUBROUTINES

=head2 error

Print an error message. The output is prefixed with "Error: " and a
newline is appended.

=cut

sub error(@) {
	say "Error: @_";
}

=head2 dbg

Print a debug message if the debug level is above the debug message
level. The first argument is the debug level, a numeric value that
will be compared to the debug level set by App::transmish::Out::dbglvl.
The rest of the arguments are passed to say (prepended by "Debug: ").

=cut

sub dbg($@) {
	my $level = shift;

	say "Debug: @_" unless $DEBUG < $level;
}

=head2 crap

Like die or crap, but use our "error" routine. Exits with 1 after
printing the error message passed to it.

=cut

sub crap(@) {
	error @_;
	exit 1;
}

=head2 dumper

Call Data::Dumper on argument and print it if debuglevel is above 3.

=cut

sub dumper($) {
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
