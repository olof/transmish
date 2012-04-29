# Copyright 2012, Olof Johansson <olof@ethup.se>
#
# Copying and distribution of this file, with or without 
# modification, are permitted in any medium without royalty 
# provided the copyright notice are preserved. This file is 
# offered as-is, without any warranty.

=head1 NAME

App::transmish::Command - command dispatcher

=head1 DESCRIPTION

App::transmish::Command keeps a record of registered commands,
and invokes them when asked to.

=cut

package App::transmish::Command;
our $VERSION = 0.1;

use warnings;
use strict;

require Exporter;
our @ISA = 'Exporter';
our @EXPORT = qw/cmd cmds alias run/;

use App::transmish::Out;

my %fun; # fun fun fun!

=head1 SUBROUTINES

=head2 cmd

Register a command. Takes the name of the command and a coderef to
the code that should be called when the command is called. The
called function gets the arguments passed to the command by the user
and is responsible for validating these.

 cmd example => sub {
     print "this is an example command\n";
 };

=cut

sub cmd {
	my $name = shift;
	my $fun = shift;

	$fun{$name} = $fun;
}

=head2 alias

Alias a command to a already existing one. Takes the name of the
alias and the name of the existing command:

 alias xmpl => 'example';

=cut

sub alias {
	my $alias = shift;
	my $cname = shift;

	$fun{$alias} = $fun{$cname};
}

=head2 cmds

Returns a list of the names of all registered commands or aliases.

=cut

sub cmds {
	return keys %fun;
}

=head2 run

Invoke a command; takes the name of the command to invoke as first
argument. Any remaining arguments are passed as arguments to the
subroutine being invoked.

=cut

sub run {
	my $cmd = shift;
	if(exists $fun{$cmd}) {
		$fun{$cmd}->(@_);
	} else {
		error "No such command '$cmd'";
	}
}

=head1 COPYRIGHT

Copyright 2012, Olof Johansson <olof@ethup.se>

Copying and distribution of this file, with or without modification,
are permitted in any medium without royalty provided the copyright
notice are preserved. This file is offered as-is, without any warranty.

=cut

1;
