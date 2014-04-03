package App::transmish::Out;

require Exporter;
our @ISA = 'Exporter';
our @EXPORT = (
	'dbglvl', 'dumper', map {$_, $_.'f'} qw(
		info error ymhfu crap dbg
));

sub info {}
sub infof {}
sub error {}
sub errorf {}
sub ymhfu {}
sub ymhfuf {}
sub crap {}
sub crapf {}
sub dbg {}
sub dbgf {}
sub dumper {}
sub dbglvl {}

1;
