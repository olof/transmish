package App::transmish::cmd::torrent;
use 5.014;
use warnings FATAL => 'all';

use App::transmish::Command;
use App::transmish::Client;
use App::transmish::Out;
use App::transmish::Out::Torrent;

# _select_wanted takes $client, $torrent, %args. %args can
# contain the keys miss, match and pattern. The pattern key
# is required and is a regular expression that will be
# applied to the filenames contained in the torrent. If a
# file is match, the 'match' key decides if it should be
# marked for download (a true value), unmarked a false value
# or if no action should be taken (undef, the default). The
# same goes for 'miss'.
sub _select_wanted {
	my $client = shift;
	my $torrent = shift;
	my %args = (
		@_,
	);

	my $pattern = qr/$args{pattern}/;
	my $change = 0;
	for my $file (sort { $a->name cmp $b->name } @{$torrent->files}) {
		my $wanted = $args{miss};
		$wanted = $args{match} if $file->name =~ /$pattern/;
		next unless defined $wanted;

		infof "%s %s for download",
			$wanted ? 'Marking' : 'Unmarking', $file->name;
		$file->wanted($wanted);
		$change = 1;
	}

	return 1 unless $change;
	$torrent->write_wanted or error $client->error;
	return 1;
}

sub _valid_setting {
	my $key = shift;

	# FIXME; Very ugly. Transmission::Torrent should
	#        probably export the available attributes
	#        and their types...

	return 'wo' if grep {$_ eq $key} qw(
		location
		peer_limit
	);

	return 'rw' if grep {$_ eq $key} qw(
		bandwidth_priority
		download_limit
		download_limited
		honors_session_limits
		seed_ratio_limit
		seed_ratio_mode
		upload_limit
		upload_limited
		is_private
	);

	return 'ro' if grep {$_ eq $key} qw(
		id
		activity_date
		added_date
		comment
		corrupt_ever
		creator
		date_created
		desired_available
		done_date
		downloaded_ever
		downloaders
		error
		error_string
		eta
		hash_str
		have_unchecked
		have_valid
		leechers
		left_until_done
		manual_announce_time
		max_connected_peers
	); # .. etc
	return;
}

cmd torrent => sub {
	my $client = client or return 1;
	my $index = shift;

	if (not defined $index) {
		error 'No id given';
		return 1;
	};

	my ($torrent) = $client->read_torrents(
		ids => [$index],
		fields => [qw(
			id
			name
			sizeWhenDone
			leftUntilDone
			uploadRatio
			hashString
			isPrivate
			downloadedEver
			uploadedEver
			rateUpload
			rateDownload
			addedDate
			doneDate
			eta
			peersSendingToUs
			peersGettingFromUs
			totalSize
			percentDone
			downloadDir
		)],
	);
	unless($torrent) {
		error "No torrent with id $index";
		return 1;
	}

	unless(@_) {
		App::transmish::Out::Torrent::status($torrent);
		return 1;
	}

	my $cmd = shift;
	run_subcmd 'torrent', $cmd, $client, $torrent, @_;
};

subcmd torrent => files => sub {
	my $client = shift;
	my $torrent = shift;
	my $cmd = @_ ? shift : 'show';

	run_subcmd 'torrent/files', $cmd, $client, $torrent, @_;
};

subcmd 'torrent/files' => show => sub {
	my $client = shift;
	my $torrent = shift;
	App::transmish::Out::Torrent::files($torrent, @_);
	return 1;
};

subcmd 'torrent/files' => on => sub {
	my $client = shift;
	my $torrent = shift;
	my $pattern = shift;

	_select_wanted($client, $torrent,
		pattern => $pattern ? qr/$pattern/ : qr/.*/,
		match => 1
	);
	return 1;
};

subcmd 'torrent/files' => off => sub {
	my $client = shift;
	my $torrent = shift;
	my $pattern = shift;

	_select_wanted($client, $torrent,
		pattern => $pattern ? qr/$pattern/ : qr/.*/,
		match => 0
	);
	return 1;
};

subcmd 'torrent/files' => only => sub {
	my $client = shift;
	my $torrent = shift;
	my $pattern = shift;

	_select_wanted($client, $torrent,
		pattern => $pattern ? qr/$pattern/ : qr/.*/,
		match => 1,
		miss => 0
	);
	return 1;
};

subcmd torrent => set => sub {
	my $client = shift;
	my $torrent = shift;
	my ($key, $val) = @_;

	if ($key) {
		my $type = valid_setting($key);
		if (not $type) {
			error "Unknown setting '$key'";
			return;
		}

		if (not defined $val and $type eq 'wo') {
			error "$key is write only";
			return;
		}

		if (defined $val and $type eq 'rw' or $type eq 'wo') {
			$torrent->$key($val) or error $torrent->error;
		} elsif (defined $val) {
			error "$key is read only";
		}

		if ($type ne 'wo') {
			say $torrent->$key();
		}

		return 1;
	}

	error "You currently have to select an attribute to show/change:";
	error "  transmish <id> set download_dir";
	error "  transmish <id> set upload_limit 10";
};

subcmd torrent => start => sub {
	my $client = shift;
	my $torrent = shift;

	$torrent->start;
};

subcmd torrent => stop => sub {
	my $client = shift;
	my $torrent = shift;

	$torrent->stop;
};

subcmd torrent => move => sub {
	my $client = shift;
	my $torrent = shift;
	my $path = shift;

	$torrent->move($path) && return 1;
	error "Could not move torrent: ", $torrent->error_string;
};

subcmd torrent => rm => sub {
	my $client = shift;
	my $torrent = shift;
	my $delete = shift;

	# FIXME: Ugly, needs some getopt!
	if ($delete and $delete eq '-d') {
		run 'rm', '-d', $torrent->id;
	} else {
		run 'rm', $torrent->id;
	}
};

=head1 NAME

App::transmish::cmd::torrent - show and manipulate a single torrent

=head1 DESCRIPTION

The torrent command is used to show current status of a torrent and
to manipulate various things, including starting/stopping, selecting
files to download and moving the torrent on the transmission host.
