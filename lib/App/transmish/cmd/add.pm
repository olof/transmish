package App::transmish::cmd::list;
use 5.014;
use warnings FATAL => 'all';

use Getopt::Long qw(GetOptionsFromArray);

use App::transmish::Command;
use App::transmish::Client;
use App::transmish::Out;
use App::transmish::Utils qw(read_file);

sub _add_torrent_common {
	my $client = shift;
	my $opts = shift;
	my %args = @_;

	$args{download_dir} = $opts->{'download-dir'} if
		exists $opts->{'download-dir'};

	my $resp = $client->add(%args);

	if (not $resp) {
		error "Could not add torrent:", $client->error;
		return;
	}

	$resp = $resp->{'torrent-added'};
	infof "Added '%s' (id: %d)", @{$resp}{qw(name id)};

	return $resp;
}

sub _add_torrent_file {
	my $client = shift;
	my $opts = shift;
	my $file = shift;

	my %add_args;
	$add_args{metainfo} = read_file($file);
	$add_args{filename} = $file unless $add_args{metainfo};
	return _add_torrent_common($client, $opts, %add_args);
}

sub _add_torrent_uri {
	my $client = shift;
	my $opts = shift;
	my $uri = shift;
	return _add_torrent_common($client, $opts, filename => $uri);
}

sub _add_torrent {
	my $client = shift;
	my $opts = shift;
	my $file = shift;

	dbg 1, "Adding $file";

	return _add_torrent_file($client, $opts, $file) if -e $file;
	return _add_torrent_uri($client, $opts, $file);
}

cmd add => sub {
	my $client = client or return;
	my %add_args;

	GetOptionsFromArray(\@_, my $opts = {}, qw(
		download-dir=s
	)) or return;

	if (not @_) {
		error "Not enough arguments. Need torrent path/URL";
		return;
	}

	for my $file (@_) {
		my @files = glob($file);

		# Under some circumstances, namely the file/url
		# contains shell wildcard characters, like * or more
		# commonly ?, the glob fails to expand at all. In that
		# case, we want to use the string verbatimelly.
		@files = $file if not @files;

		_add_torrent($client, $opts, $_) for @files;
	}
};

cmd rm => sub {
	my $client = client or return;
	my $index = shift or do {
		error "No id given";
		return;
	};

	my $delete = 0;

	# FIXME: do getopt on commands
	# FIXME: you sure, dawg? [yN]
	if($index eq '-d') {
		$index = shift;
		$delete = 1;
	}

	$client->remove(
		ids => [$index],
		delete_local_data => $delete,
	) or error $client->error;
};

=head1 NAME

App::transmish::cmd::add - add/remove torrents

=head1 DESCRIPTION

Add (add <path|url>) and remove torrents (rm <torrent id>).

If the argument to add is a local file, that file is uploaded to
the transmission host and added. Otherwise, the path is sent as is
to transmission. This means that http URLs, magnet links and
torrent files on the transmission host are all supported. For local
files, glob expressions are also supported (add /tmp/*.torrent).
