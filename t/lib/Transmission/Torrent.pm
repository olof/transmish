package Transmission::Torrent;

# Test API

my @torrents;

# _add_torrent_name takes a hash of the following format:
#   (
#    name => 'Torrent.Name',
#    files => [ list of Transmission::Torrent::File objects ],
#   )
sub _add_torrent_name {
	my %arg = @_;
	push @torrents, \%arg;
}

sub _create {
	my $class = shift;
	bless { @_ }, $class;
}

# current time is overrideable
sub _time {
	my $self = shift;
	return $self->{_time} // time;
}

# API

sub id {
	my $self = shift;
	return $self->{id};
}

sub bandwidth_priority {
	my $self = shift;
	my $prio = shift;
	$self->{bandwidth_priority} = $prio if defined $prio;
	return $self->{bandwidht_priority};
}

sub download_limit {
	my $self = shift;
	my $lim = shift;
	$self->{download_limit} = $lim if defined $lim;
	return $self->{download_limit};
}

sub download_limited {
	my $self = shift;
	my $expr = shift;
	$self->{download_limited} = 1 if $expr;
	return $self->{download_limited};
}

sub honors_session_limits {
	my $self = shift;
	my $expr = shift;
	$self->{honors_session_limits} = 1 if $expr;
	return $self->{honors_session_limits};
}

sub location {
	my $self = shift;
	return $self->{location};
}

sub peer_limit {
	my $self = shift;
	return $self->{peer_limit};
}

sub seed_ratio_limit {
	my $self = shift;
	my $lim = shift;
	$self->{seed_ratio_limit} = $lim if defined $lim;
	return $self->{seed_ratio_limit};
}

sub seed_ratio_mode {
	my $self = shift;
	return $self->{seed_ratio_mode};
}

sub uploaded_ever {
	my $self = shift;
	return $self->{uploaded_ever};
}

sub upload_limit {
	my $self = shift;
	my $lim = shift;
	$self->{upload_limit} = $lim if defined $lim;
	return $self->{upload_limit};
}

sub upload_limited {
	my $self = shift;
	my $expr = shift;
	$self->{upload_limited} = 1 if $expr;
	return $self->{upload_limited};
}

sub activity_date {
	my $self = shift;
	return $self->{activity_date};
}

sub added_date {
	my $self = shift;
	return $self->{added_date};
}

sub comment {
	my $self = shift;
	return $self->{comment};
}

sub corrupt_ever {
	my $self = shift;
	return $self->{corrupt_ever};
}

sub creator {
	my $self = shift;
	return $self->{creator};
}

sub date_created {
	my $self = shift;
	return $self->{date_created};
}

sub desired_available {
	my $self = shift;
	return $self->{desired_available};
}

sub done_date {
	my $self = shift;
	return $self->{done_date};
}

sub download_dir {
	my $self = shift;
	return $self->{download_dir};
}

sub downloaded_ever {
	my $self = shift;
	return $self->{downloaded_ever};
}

sub downloaders {
	my $self = shift;
	return $self->{downloaders};
}

sub error {
	my $self = shift;
	return $self->{error};
}

sub error_string {
	my $self = shift;
	return $self->{error_string};
}

sub eta {
	my $self = shift;
	return -1 if $self->left_until_done == 0;

	my $left = $self->left_until_done;
	my $rate = $self->rate_download;
	my $now = $self->_time;

	return $now + $left/$rate;
}

sub hash_string {
	my $self = shift;
	return $self->{hash_string};
}

sub have_unchecked {
	my $self = shift;
	return $self->{have_unchecked};
}

sub have_valid {
	my $self = shift;
	return $self->{have_valid};
}

sub is_private {
	my $self = shift;
	return $self->{is_private};
}

sub leechers {
	my $self = shift;
	return $self->{leechers};
}

sub left_until_done {
	my $self = shift;
	return $self->size_when_done - $self->downloaded_ever;
}

sub manual_announce_time {
	my $self = shift;
	return $self->{manual_announce_time};
}

sub max_connected_peers {
	my $self = shift;
	return $self->{max_connected_peers};
}

sub name {
	my $self = shift;
	return $self->{name};
}

sub peer {
	my $self = shift;
	return $self->{peer};
}

sub peers_connected {
	my $self = shift;
	return $self->{peers_connected};
}

sub peers_getting_from_us {
	my $self = shift;
	return $self->{peers_getting_from_us};
}

sub peers_known {
	my $self = shift;
	return $self->{peers_known};
}

sub peers_sending_to_us {
	my $self = shift;
	return $self->{peers_sending_to_us};
}

sub percent_done {
	my $self = shift;
	return $self->downloaded_ever / $self->size_when_done;
}

sub pieces {
	my $self = shift;
	return $self->{pieces};
}

sub piece_count {
	my $self = shift;
	return $self->{piece_count};
}

sub piece_size {
	my $self = shift;
	return $self->{piece_size};
}

sub rate_download {
	my $self = shift;
	return $self->{rate_download};
}

sub rate_upload {
	my $self = shift;
	return $self->{rate_upload};
}

sub recheck_progress {
	my $self = shift;
	return $self->{recheck_progress};
}

sub seeders {
	my $self = shift;
	return $self->{seeders};
}

sub size_when_done {
	my $self = shift;
	return $self->{size_when_done};
}

sub start_date {
	my $self = shift;
	return $self->{start_date};
}

sub status {
	my $self = shift;
	return $self->{status};
}

sub swarm_speed {
	my $self = shift;
	return $self->{swarm_speed};
}

sub times_completed {
	my $self = shift;
	return $self->{times_completed};
}

sub total_size {
	my $self = shift;
	return $self->{total_size};
}

sub torrent_file {
	my $self = shift;
	return $self->{torrent_file};
}

sub upload_ever {
	my $self = shift;
	return $self->{upload_ever};
}

sub upload_ratio {
	my $self = shift;
	return $self->uploaded_ever / $self->downloaded_ever;
}

sub webseeds_sending_to_us {
	my $self = shift;
	return $self->{webseeds_sending_to_us};
}

sub files {
	my $self = shift;
	return $self->{files};
}

1;
