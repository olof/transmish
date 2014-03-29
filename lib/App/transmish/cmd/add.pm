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

	return $client->add(%args);
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

options add => [qw(download-dir=s)];
cmd add => sub {
	my $client = client or return;
	my $opts = shift;
	my %add_args;

	if (not @_) {
		error "Not enough arguments. Need torrent path/URL";
		return;
	}

	for my $file (@_) {
		my @files = glob($file);

		# If the glob fails, we give it directly to transmission,
		# it could be a URI or a server local file.
		unless (@files) {
			if (_add_torrent_uri($client, $opts, $file)) {
				say "Added URI '$file'";
			} else {
				printf "Failed to add URI '%s': %s'\n",
					$file, $client->error;
			}
		}

		# Anything in @files is a client local file.
		for (@files) {
			if (_add_torrent_file($client, $opts, $_)) {
				say "Added '$_'";
			} else {
				printf "Failed to add file '%s': %s\n",
					$_, $client->error;
			}
		}
	}
};

options rm => [qw(delete)];
cmd rm => sub {
	my $client = client or return;
	my $opts = shift;
	my $index = shift or do {
		error "No id given";
		return;
	};

	$client->remove(
		ids => [$index],
		delete_local_data => $opts->{delete},
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
