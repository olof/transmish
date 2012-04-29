# Copyright 2012, Olof Johansson <olof@ethup.se>
#
# Copying and distribution of this file, with or without 
# modification, are permitted in any medium without royalty 
# provided the copyright notice are preserved. This file is 
# offered as-is, without any warranty.

=head1 NAME

App::transmish::Config - handle configuration

=cut

package App::transmish::Config;
our $VERSION = 0.1;

use warnings;
use strict;
require Exporter;
our @ISA = 'Exporter';
our @EXPORT = 'config';

use Config::Tiny;
use App::transmish::Out;

my $config;

=head1 SUBROUTINES

=head2 load

Load configuration file, given as argument. Only errors (dies)
when the file specified exists and isn't readable for some reason.

=cut

sub load {
	my $conffile = shift;

	unless(defined $conffile) {
		dbg 1, "No config file specified, using defaults.";
		return;
	}

	if(-e $conffile) {
		dbg 1, "Loading config from '$conffile'";
		$config = Config::Tiny->read($conffile) or
			crap "Could not load configs from $conffile";	
		dumper $config->{_};
	} else {
		dbg 1, "No config found, using defaults.";
	}
}

=head2 config

Get the hashref of configs.

=cut

sub config {
	return $config->{_};
}

=head2 COPYRIGHT

Copyright 2012, Olof Johansson <olof@ethup.se>

Copying and distribution of this file, with or without modification,
are permitted in any medium without royalty provided the copyright
notice are preserved. This file is offered as-is, without any warranty.

=cut

1;
