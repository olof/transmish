package Transmission::Client;
use Transmission::Stats;

# Test API and/or internal

sub _next_id {
	my $self = shift;
	return ++$self->{max_id};
}

# API

sub new {
	my $class = shift;
	my %args = @_;

	my %stats_args;
	my @torrents;
	my $max_id = 0;

	@torrents = @{$args{_torrents}} if exists $args{_torrents};
	%stats_args = %{$args{_stats_args}} if exists $args{_stats_args};
	delete $args{_stats_args};

	$_->_id(++$max_id) for @torrents;

	bless {
		url => 'http://localhost:9091/transmission/rpc',
		%args,
		torrents => \@torrents,
		stats => Transmission::Stats->new(%stats_args),
		max_id => $max_id,
	}, $class;
}

sub stats {
	my $self = shift;
	return $self->{stats};
}

sub url {
	my $self = shift;
	return $self->{url};
}

sub error {
	my $self = shift;
	return $self->{error};
}

sub username {
	my $self = shift;
	return $self->{username};
}

sub password {
	my $self = shift;
	return $self->{password};
}

sub timeout {
	my $self = shift;
	return $self->{timeout};
}

sub session {
	my $self = shift;
	return Transmission::Stats->new;
}

sub torrents {
	my $self = shift;
	return $self->{torrents};
}

sub version {
	my $self = shift;
	return $self->{version};
}

sub session_id {
	my $self = shift;
	my $id = shift;
	$self->{session_id} = $id if defined $id;
	return $self->{session_id};
}

sub add {
	my $self = shift;
	my $args = {@_};

	my $download_dir = $args->{download_dir};
	my $filename = $args->{filename};
	my $metainfo = $args->{metainfo};
	my $paused = $args->{paused};
	my $peer_limit = $args->{peer_limit};

	die("filename or metainfo is required when adding torrents")
		unless $filename or $metainfo;

	push @{$self->{torrents}}, Transmission::Torrent->_create(
		id => $self->_next_id,
		download_dir => $download_dir,
		filename => $filename,
		metainfo => $metainfo,
		paused => $paused,
		peer_limit => $peer_limit,
	);
}

sub remove {
	my $self = shift;

}

sub move {
	my $self = shift;

}

sub start {
	my $self = shift;

}

sub stop {
	my $self = shift;

}

sub verify {
	my $self = shift;

}

sub read_torrents {
	my $self = shift;
	my $args = { @_ };
	my @torrents = @{$self->{torrents}};
	my @ret;

	if ($args->{ids}) {
		for my $torrent (@{$self->{torrents}}) {
			push @ret, $torrent if grep {
				$_ == $torrent->id
			} @{$args->{ids}};
		}
	} else {
		@ret = @{$self->{torrents}}
	}

	return @ret;
}

sub rpc {
	my $self = shift;

}

sub read_all {
	my $self = shift;

}

# All arguments must be Transmission::Torrent objects
sub _test_add {
	my $self = shift;
	push @{$self->{torrents}}, @_;
}

1;
