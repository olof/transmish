# Copyright 2012, Olof Johansson <olof@ethup.se>
#
# Copying and distribution of this file, with or without 
# modification, are permitted in any medium without royalty 
# provided the copyright notice are preserved. This file is 
# offered as-is, without any warranty.

=head1 NAME

App::transmish::Out::Torrent - output torrent related information

=cut

package App::transmish::Out::Torrent;
our $VERSION = 0.1;

use warnings FATAL => 'all';
use strict;
use feature qw/say/;

use App::transmish::Utils qw/percentage rate size date bool/;
use Text::ASCIITable;

=head1 SUBROUTINES

=head2 summary

Print a short two line summary of the torrent with name, id,
percentage done, download rate, upload rate and how much has
been uploaded. Takes a Transmission::Torrent object as argument.

=cut

sub summary {
	my $torrent = shift;
	printf "%3d: %s\n", $torrent->id, $torrent->name;
	printf "      [%s] [down: %s] [up: %s] [uploaded: %s]\n", 
		percentage($torrent->percent_done),
		rate($torrent->rate_download),
		rate($torrent->rate_upload),
		size($torrent->uploaded_ever);
}

=head2 status

Print detailed information on torrent, given as argument (a
Transmission::Torrent object).

=cut

sub status {
	my $torrent = shift;
	my $done = $torrent->left_until_done == 0;

	# FIXME: this should ideally be replaced by a template engine

	my @information = (
		['ID', $torrent->id],
		['Hash', $torrent->hash_string],
		['Private', bool($torrent->is_private)],
		['---'],
		['Completed', percentage($torrent->percent_done)],
		['Size', size($torrent->size_when_done)],
		['Downloaded', size($torrent->downloaded_ever), bool(!$done)],
		['Uploaded', size($torrent->uploaded_ever)],
		['Ratio', sprintf('%.2f', $torrent->upload_ratio)],
		['---'],
		['Upload rate', rate($torrent->rate_upload)],
		['Download rate', rate($torrent->rate_download), bool(!$done)],
		['Tx to us', $torrent->peers_sending_to_us, bool(!$done)],
		['Rx from us', $torrent->peers_getting_from_us],

	# These guys just sit there saying -1... not helpful
	#	['Seeders', $torrent->seeders],
	#	['Leechers', $torrent->downloaders],

		['---'],
		['Added at', date($torrent->added_date)],
		['Completed at', date($torrent->done_date), bool($done)],
		['ETA', $torrent->eta, bool(!$done)],
		['Left', $torrent->left_until_done, bool(!$done)],
	);

	my $t = Text::ASCIITable->new({headingText => $torrent->name});
	$t->setCols('Key', 'Value');
	$t->alignCol('Value', 'left');
	for(@information) {
		my($key, $val, $show) = @$_;
		$show //= 'yes';

		if($key ne '---') {
			$t->addRow($key, $val) if $show eq 'yes';
		} else {
			$t->addRowLine();
		}
	}

	print $t;
}

=head2 files

Print information the files the torrent contains; file id,
filename, size, downloaded and if the file is selected to
be downloaded.

=cut

sub files {
	my $torrent = shift;

	say $torrent->name;
	say '-'x70;
	printf "%-3s | %6s | %-3s | %s (%s)\n", 'id', '%', 'on', 'name', 'size';
	say '-'x70;
	for my $file (sort {$a->name cmp $b->name} @{$torrent->files}) {
		_file_print $file->id, $file->name, $file->length,
		            $file->bytes_completed, $file->wanted;
	}
	say '-'x70;
}

sub _file_print {
	my($id, $file, $size, $done, $want) = @_;
	printf "%-3d | %s | [%s] | %s (%s)\n",
		$id, _percentage($done/$size),
	        $want ? 'X' : ' ',
		$file, _size($size);
}

=head1 COPYRIGHT

Copyright 2012, Olof Johansson <olof@ethup.se>

Copying and distribution of this file, with or without modification,
are permitted in any medium without royalty provided the copyright
notice are preserved. This file is offered as-is, without any warranty.

=cut

1;
