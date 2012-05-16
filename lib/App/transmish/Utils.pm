# Copyright 2012, Olof Johansson <olof@ethup.se>
#
# Copying and distribution of this file, with or without 
# modification, are permitted in any medium without royalty 
# provided the copyright notice are preserved. This file is 
# offered as-is, without any warranty.

=head1 NAME

App::transmish::Utils - various helper functions

=cut

package App::transmish::Utils;
our $VERSION = 0.1;

use warnings;
use strict;
use feature qw/say/;
require Exporter;

use App::transmish::Out;
use POSIX qw/strftime/;
use LWP::UserAgent;

our @ISA = 'Exporter';
our @EXPORT_OK = qw/
	rate size date bool percentage is_http_uri read_file http_file
/;

=head1 SUBROUTINES

=head2 rate

Convert a numeric value, representing rate per seconds in bytes,
to a more human readable value + si prefix + unit of time (/s).

=cut

sub rate {
	return size(shift) . "/s";
}

=head2 size

Convert number of bytes to the greatest possible SI prefixed
number of bytes, and append this to the value and return it
(e.g. 1024 -> 1KiB).

=cut

sub size {
	my $n = shift;
	my $i = 0;
	my @si = qw/B KiB MiB GiB TiB PiB/;

	while($n > 1024 and $i < @si) {
		$n /= 1024;
		++$i;
	}

	$n = sprintf "%.2f", $n;
	return $n . $si[$i];
}

=head2 date

Convert epoch (seconds since 1970-01-01) to a date string as
specified by ISO 8601. (YYYY-MM-DD HH:MM:SS).

=cut

sub date {
	my $epoch = shift;
	return strftime '%Y-%m-%d %H:%M:%S', localtime $epoch;
}

=head2 bool

Convert a boolean value to the string "yes" or "no". This is
Perl, so the boolean value for yes is anything that evaluates
to true and vice versa.

=cut

sub bool {
	my $val = shift;
	return $val ? 'yes' : 'no';
}

=head2 percentage

Convert a fraction to a percentage.

=cut

sub percentage {
	my $p = shift;
	return sprintf "%.1f%%", $p*100;
}

=head2 read_file

Read the complete contents of the file, given as argument,
and return it to the caller. Prints error message and returns
undef if it fails to open the file.

=cut

sub read_file {
	my $file = shift;

	open my $fh, '<', $file;
	unless($fh) {
		error "Could not open $file for reading: $!";
		return;
	}
	read $fh, my $torrent, (stat $file)[7];
	close $fh;

	return $torrent;
}

=head1 COPYRIGHT

Copyright 2012, Olof Johansson <olof@ethup.se>

Copying and distribution of this file, with or without modification,
are permitted in any medium without royalty provided the copyright
notice are preserved. This file is offered as-is, without any warranty.

=cut

1;
