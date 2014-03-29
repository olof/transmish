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
use 5.14.0;
use warnings;
use strict;

our $VERSION = 0.1;

require Exporter;
our @ISA = 'Exporter';
our @EXPORT = qw/cmd subcmd options cmds alias run run_subcmd/;

use App::transmish::Out;
use App::transmish::Config;

use Text::ParseWords;

my %fun; # fun fun fun!
my %subfun; # not as fun
my %alias; # has nothing to with fun :(

my %options;

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

=head2 subcmd

Register a sub command, i.e a command that will only work in the
context of another command. Takes the top level command as first
argument, followed by the sub command and then the definition (as
a coderef).

 subcmd torrent => files => sub {
     my $client = shift;
     my $torrent = shift;
     my @args = @_;
 };

=cut

sub subcmd {
	my $parent = shift;
	my $name = shift;
	my $fun = shift;

	$subfun{$parent}->{$name} = $fun;
}

=head2 options

 options 'cmd' => [qw(foo=s bar)] => {
   foo => \&foo_flag_sub,
   bar => 1,
 };

Associate options to command. The first (required) argument is a
Getopt::Long compatible option spec as an array ref, while the
second (optional) argument is a hash ref of default values (refer
to the manual of Getopt::Long for how it's used).

To specify options for subcommands, separate the parent command(s)
with /, e.g:

  options 'torrent/show' => [qw(verbose)];

If you register options for a command, that command will receive
an additional argument after the $client argument with the
options hashref.

=cut

sub options {
	my $cmd = shift;
	my $optspec = shift;
	my $defaults = shift // {};

	$options{$cmd} = {
		obj => $defaults,
		spec => $optspec,
	};
}

=head2 alias

Alias a command to an existing one, possibly with preset flags. The
alias concept is very similar in behavior to that of bash et al.
Takes the name of the alias and the value of the alias:

 alias xmpl => 'example --foo';

You can later call from the command line like:

 xmpl        # resulting in example --foo

or

 xmpl --bar  # resulting in example --foo --bar

=cut

sub alias {
	my $alias = shift;
	my $cmd = shift;

	$alias{$alias} = $cmd;
}

=head2 alias_lookup

Look up definition for alias. If the alias contains arguments,
they will be split, and you will get a list of arguments that
you can prepend to the user supplied arguments.

=cut

sub alias_lookup {
	my $alias = shift;
	dbg 3, "Looking for alias $alias";
	return unless exists $alias{$alias};
	my $cmd = $alias{$alias};
	dbg 2, "$alias is alias for $cmd";
	return parse_line(qr/\s+/, 0, $cmd);
}

=head2 load_user_aliases

Load configured alias from the config object.

=cut

sub load_user_aliases {
	my $config = config('aliases');

	dbg 1, "Loading user aliases";

	dumper $config;

	for my $alias (keys %$config) {
		my $cmd = $config->{$alias};
		dbg 2, "Loading user alias $alias => $cmd";
		alias($alias => $cmd);
	}
}

=head2 cmds

Returns a list of the names of all registered commands or aliases.

=cut

sub cmds {
	return keys %fun, keys %alias;
}

=head2 run

Invoke a command; takes the name of the command to invoke as first
argument. Any remaining arguments are passed as arguments to the
subroutine being invoked.

=cut

sub run {
	my $cmd = shift;
	my @args = @_;

	dbg 1, "Executing $cmd ", join(' ', @args);

	my @alias = alias_lookup($cmd);
	if (@alias) {
		$cmd = shift @alias;
		unshift @args, @alias;
		dbg 1, "Resolving alias to $cmd ", join(' ', @args);
	}

	if(not exists $fun{$cmd}) {
		error "No such command '$cmd'";
		return;
	}

	if (exists $options{$cmd}) {
		my $opts = $options{$cmd}->{defaults};
		GetOptionsFromArray(
			\@args, $opts, $options{$cmd}->{optspec}
		) or return;
		unshift @args, $opts;
	}

	$fun{$cmd}->(@args);
}

=head2 run_subcmd

Invoke a subcommand; takes the name of the toplevel command followed
by the name of the subcommand. The remaining arguments are given as
argument to the subcommand itself.

=cut

sub run_subcmd {
	my $parent = shift;
	my $cmd = shift;
	if(not exists $subfun{$parent}) {
		error "No such parent command, $parent";
		return 1;
	}

	my %tbl = %{$subfun{$parent}};
	if(not exists $tbl{$cmd}) {
		error "No such command, $cmd";
		return 1;
	}

	$subfun{$parent}->{$cmd}->(@_);
}

=head1 COPYRIGHT

Copyright 2012, Olof Johansson <olof@ethup.se>

Copying and distribution of this file, with or without modification,
are permitted in any medium without royalty provided the copyright
notice are preserved. This file is offered as-is, without any warranty.

=cut

1;
