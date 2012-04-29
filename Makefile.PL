#!/usr/bin/perl
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME => 'transmish',
	VERSION_FROM => 'transmish',
	ABSTRACT => 'transmission command line client',
	EXE_FILES => ['transmish'],

	PREREQ_PM => {
		'Config::Tiny' => 0,
		'LWP::UserAgent' => 0,
		'Regexp::Common' => 0,
		'Regexp::Common::URI' => 0,
		'Text::ASCIITable' => 0,
		'Transmission::Client' => 0,
	},
);

