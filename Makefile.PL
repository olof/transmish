#!/usr/bin/perl
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME => 'transmish',
	VERSION_FROM => 'transmish',
	ABSTRACT => 'transmission command line client',
	EXE_FILES => ['transmish'],
	MIN_PERL_VERSION => '5.14.0',

	PREREQ_PM => {
		'Config::Tiny' => 0,
		'IO::Interactive' => 0,
		'LWP::UserAgent' => 0,
		'Text::ASCIITable' => 0,
		'Time::Duration' => 0,
		'Transmission::Client' => 0.0701,
		'Test::Output' => 0,
	},
);

