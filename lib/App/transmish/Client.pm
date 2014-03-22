# Copyright 2012, Olof Johansson <olof@ethup.se>
#
# Copying and distribution of this file, with or without
# modification, are permitted in any medium without royalty
# provided the copyright notice are preserved. This file is
# offered as-is, without any warranty.

=head1 NAME

App::transmish::Client - convenience wrapper around Transmission::Client

=cut

package App::transmish::Client;

use 5.14.0;
use warnings;
use strict;

our $VERSION = 0.1;

require Exporter;
our @ISA = 'Exporter';
our @EXPORT = 'client';
use App::transmish::Config;
use Transmission::Client;

=head1 SUBROUTINES

=head2 client

Get a Transmission::Client object with constructor parameters fetched
from App::transmish::Config. Takes no arguments.

=cut

sub client {
	my $url = config->{url} // 'http://localhost:9091/transmission/rpc';
	my $username = config->{username};
	my $password = config->{password};
	my $timeout = config->{timeout} // 10;

	return Transmission::Client->new(
		url => $url,
		username => $username,
		password => $password,
		timeout => $timeout,
	);
}

1;


=head1 COPYRIGHT

Copyright 2012, Olof Johansson <olof@ethup.se>

Copying and distribution of this file, with or without modification,
are permitted in any medium without royalty provided the copyright
notice are preserved. This file is offered as-is, without any warranty.
