package Text::ASCIITable;
use warnings;
use strict;
use YAML;
use Data::Dumper;
use JSON;
# .---------------------------------------------------------.
# |                     Example torrent                     |
# +--------------+------------------------------------------+
# | Key          | Value                                    |
# +--------------+------------------------------------------+
# | ID           | 42                                       |
# | Hash         | 1234567890abcdef1234567890abcdef12345678 |
# | Private      | yes                                      |
# +--------------+------------------------------------------+
# | Completed    | 100.0%                                   |
# | Size         | 1.00GiB                                  |
# | Uploaded     | 10.00MiB                                 |
# | Ratio        | 0.01 (1 in 1 minute and 41 seconds)      |
# +--------------+------------------------------------------+
# | Upload rate  | 0.00B/s                                  |
# | Peers        | Seeders:  0                              |
# |              | Leechers: 0                              |
# +--------------+------------------------------------------+
# | Added at     | 1970-01-01 00:00:00                      |
# | Completed at | 1970-01-01 01:00:00                      |
# '--------------+------------------------------------------'

use overload q("") => \&_render;

sub _render {
	my $self = shift;

	my $heading = [$self->{headingText}];
	my $cols = $self->{cols};
	my @rows = @{$self->{rows}};

	#print STDERR Dumper $self->{cols};
	#print STDERR Dumper \@rows;

	my $json = JSON->new->pretty;
	return $json->encode([
	#return Dumper([
		$heading,
		$cols,
		@rows,
	]);
}

sub new {
	my $class = shift;
	my $args = shift;
	$args->{rows} = [];
	$args->{cols} = [];
	bless $args, $class;
}

sub setCols {
	my $self = shift;
	$self->{cols} = [@_];
}

sub alignCol { }

sub addRow {
	my $self = shift;
	push @{$self->{rows}}, [@_];
}

sub addRowLine {
	shift->addRow('### LINE ###');
}

1;
