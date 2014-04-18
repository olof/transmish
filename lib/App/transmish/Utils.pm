# Copyright 2012-2013, Olof Johansson <olof@ethup.se>
#
# Copying and distribution of this file, with or without
# modification, are permitted in any medium without royalty
# provided the copyright notice are preserved. This file is
# offered as-is, without any warranty.

=head1 NAME

App::transmish::Utils - various helper functions

=cut

package App::transmish::Utils;
use 5.14.0;
use warnings;
use strict;

our $VERSION = 0.1;

require Exporter;

use App::transmish::Out;
use POSIX qw/strftime/;
use LWP::UserAgent;

our @ISA = 'Exporter';
our @EXPORT_OK = qw/
	rate size sizef size_si date bool percentage is_http_uri
	read_file http_file strrange
/;

=head1 SUBROUTINES

=head2 rate

Convert a numeric value, representing rate per seconds in bytes,
to a more human readable value + si prefix + unit of time (/s).

Rates lesser or equal to 1024B/s are represented as a fraction
of a KiB/s for usability reasons (it's confusing when a rate
jumps from 1KiB/s to 1000B/s).

=cut

sub rate {
	return size(shift) . "/s";
}

=head2 size, sizef

Convert number of bytes to the greatest possible SI prefixed
number of bytes, and append this to the value and return it
(e.g. 1024 -> 1KiB).

Sizes lesser or equal to 1024B are represented as a fraction
of a KiB for usability reasons (this function is used to
present rates, and it can be confusing when a rate jumps
from 1KiB/s to 1000B/s).

size returns a string with two decimal points. sizef expects
a single format specifier, just like accepted by printf:

  size(1024**2)      # 1.00MiB
  size('d', 1024**2) # 1MiB
  percentagef('.5f', 1024**2) # 1.0000MiB

=cut

sub size {
	return sizef('.2f', shift);
}

sub sizef {
	my $fmt = shift;
	my $n = shift;

	my ($size, $unit) = size_si($n);

	if ($unit eq '' and $size > 0) {
		$unit = 'K';
		$size /= 1024;
	}

	$unit .= 'i' if $unit;
	$unit .= 'B';

	return sprintf "%$fmt%s", $size, $unit;
}

=head2 size_si

The size_si function returns, given a size in bytes, a tuple of
size and SI prefix:

 size_si(1) # returns (1, '')
 size_si(1024**2) # returns (1, M)

=cut

sub size_si {
	my $n = shift;

	my $sufix = '';
	my @si = qw(K M G T P);
	while($n > 1024 and @si) {
		$n /= 1024;
		$sufix = shift @si;
	}

	return ($n, $sufix);
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

=head2 strrange

Convert string representation of lists with to an array;
supporting a range syntax. Example:

 strrange("10")          # 10
 strrange("10", "11")    # 10, 11
 sttrange("10-13")       # 10, 11, 12, 13
 sttrange(9, "11-13")    #  9, 11, 12, 13

=cut

sub strrange {
	my @ret;
	for (@_) {
		if (my ($c, $d) = /^(-?[0-9]+)-(-?[0-9]+)$/) {
			push @ret, ($c .. $d) if $d > $c;
		} else {
			push @ret, $_;
		}
	}
	return @ret;
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
