package Transmission::Stats;

sub new {
	my $class = shift;
	bless { @_ }, $class;
}

sub active_torrent_count {
	my $self = shift;
	return $self->{active_torrent_count};
}

sub download_speed {
	my $self = shift;
	return $self->{download_speed};
}

sub paused_torrent_count {
	my $self = shift;
	return $self->{paused_torrent_count};
}

sub torrent_count {
	my $self = shift;
	return $self->{torrent_count};
}

sub upload_speed {
	my $self = shift;
	return $self->{upload_speed};
}

1;
