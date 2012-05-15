# Copyright 2012, Olof Johansson <olof@ethup.se>
#
# Copying and distribution of this file, with or without 
# modification, are permitted in any medium without royalty 
# provided the copyright notice are preserved. This file is 
# offered as-is, without any warranty.

=head1 NAME

App::transmish::Out::Client - output client related information

=cut

package App::transmish::Out::Client;
our $VERSION = 0.1;

require Exporter;
our @ISA = 'Exporter';
our @EXPORT_OK = qw/summary/;

use warnings FATAL => 'all';
use strict;
use feature qw/say/;

use App::transmish::Out;
use App::transmish::Utils qw/rate/;

=head1 SUBROUTINES

Nothing is exported.

=head2 summary

summary takes a Transmission::Client object as argument and prints
a short summary line with current upload and download rate.

=cut

sub summary {
	my $client = shift;

	if(my $stats = $client->stats) {
		printf "\nTotal: [down: %s] [up: %s]\n",
			rate($stats->download_speed),
			rate($stats->upload_speed);
	} else {
		error $client->error;
	}
}

=head1 COPYRIGHT

Copyright 2012, Olof Johansson <olof@ethup.se>

Copying and distribution of this file, with or without modification,
are permitted in any medium without royalty provided the copyright
notice are preserved. This file is offered as-is, without any warranty.

=cut

1;
