package App::transmish::cmd::list;
use 5.014;
use warnings FATAL => 'all';

use App::transmish::Command;
use App::transmish::Client;
use App::transmish::list qw(torrent_list);
use App::transmish::Utils qw(strrange);
use App::transmish::Out;
use App::transmish::Out::Client;
use App::transmish::Out::Torrent;

sub _list {
	my $client = client or return;
	my $fun = shift;
	my $fields = shift;

	# FIXME: Use getopt... And don't implement it here of all places...
	my %flags = map { substr($_, 1) => 1 } grep(/^-/, @_);
	my @ids = grep { ! /^-/ } @_;

	for (@ids) {
		ymhfu "$_ isn't numeric; did you mean grep?" unless
			/^[0-9]+(?:-[0-9]+)?$/;
	}

	my @torrents = torrent_list(
		client => $client,
		filter => $fun,
		fields => [@$fields, qw(
			name percentDone rateDownload rateUpload uploadedEver
		)],
		ids => [@ids],
	);

	my $printfun = sub { App::transmish::Out::Torrent::summary(@_) };
	$printfun = sub {
		my $torrent = shift;
		printf "%3d: [%3d%%] %s\n",
			$torrent->id,
			int($torrent->percent_done*100),
			$torrent->name;
	} if $flags{1} or $flags{oneline};

	$printfun->($_) for @torrents;
	App::transmish::Out::Client::summary($client);
};

cmd list => sub {
	_list(sub { 1 }, [], @_);
};

cmd active => sub {
	_list(sub { $_[0]->peers_connected > 0 }, ['peersConnected'], @_);
};

cmd grep => sub {
	my @list_args;
	my $ptrn;

	while (@_) {
		local $_ = shift;
		push @list_args, $_ and next if /^-/;
		$ptrn = $_;
		last;
	}

	my $re;
	eval { $re = qr/$ptrn/i };
	if ($@) {
		my $err = $@;

		# This is a user error, no need to include line information
		# Can this be done in a prettier way?
		$err =~ s/ at $main::APP.*//s;

		error "Invalid regexp: $err";
		return;
	}

	_list(sub { $_[0]->name =~ /$re/ }, [], @list_args, @_);
};

=head1 NAME

App::transmish::cmd::list - list torrents commands

=head1 DESCRIPTION

Various commands for listing torrents:

=over

=item * list [ids]

=item * active

=item * grep <regexp>

=back

=head2 Torrent ID specification

The torrent ID is the transmission per session ID. It isn't
persistent and may be changed when restarting the transmission
daemon.

Commands like the list command supports listing multiple IDs,
either as an explicit list (list 1 2 3) or using a list syntax
(list 1-3).

