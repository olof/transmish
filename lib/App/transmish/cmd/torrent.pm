package App::transmish::cmd::torrent;
use 5.014;
use warnings FATAL => 'all';

use App::transmish::Command;
use App::transmish::Client;
use App::transmish::Out;
use App::transmish::Out::Torrent;

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
	my $client = client or return;
	my $index = shift;

	if (not defined $index) {
		error 'No id given';
		return;
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
		return;
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
	App::transmish::Out::Torrent::files($torrent);
	return 1;
};

subcmd 'torrent/files' => on => sub {
	my $client = shift;
	my $torrent = shift;
	my $pattern = shift;

	select_wanted($client, $torrent, 1, $pattern ? qr/$pattern/ : qr/.*/);
	return 1;
};

subcmd 'torrent/files' => off => sub {
	my $client = shift;
	my $torrent = shift;
	my $pattern = shift;

	select_wanted($client, $torrent, 0, $pattern ? qr/$pattern/ : qr/.*/);
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

