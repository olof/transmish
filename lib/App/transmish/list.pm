package App::transmish::list;
use 5.14.0;
use warnings FATAL => 'all';
use strict;
use App::transmish::Utils qw(strrange);
require Exporter;

our $VERSION = 0.1;
our @ISA = 'Exporter';
our @EXPORT_OK = qw( torrent_list );

sub torrent_list {
	my %args = @_;
	my $client = $args{client};
	my $filter = $args{filter};
	my $fields = $args{fields} // [];
	my @ids = map {
		strrange($_)
	} (exists $args{ids} ? @{$args{ids}} : ());

	my @torrents = $client->read_torrents(
		@ids ? (ids => [ @ids ]) : (),
		@$fields ? (fields => $args{fields}) : (),
	);

	@torrents = grep { $filter->($_) } @torrents if $filter;

	return @torrents;
}

=head1 NAME

App::transmish::list;

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 FUNCTIONS

=head2 torrent_list

 my @torrents = torrent_list(
   client => $client,
   filter => sub { 1 },
   ids => [1,2,3],
   fields => [qw(peersConnected)],
 )

The list function takes a Transmission::Client object and returns a
list of torrents managed by the Transmission service.

=head3 Parameters

=over

=item ids

Takes an array reference with numeric ids for the torrents you are
interested in. This will limit what torrents are returned from the
Transmission RPC.

The ids parameter may contain range notion, with 1-3 meaning 1, 2, 3.

=item fields

Takes an array reference with torrent field names, as specified in the
Transmission RPC specification (and in L<Transmission::Torrent>).

=item filter

Takes a subroutine reference. This subroutine will be called once for
each torrent returned from Transmission and pass the corresponding
L<Transmission::Torrent> object as argument. If the subroutine returns
true, the torrent will be part of the list of torrents that gets
returned from torrent_list.

=cut

1;
