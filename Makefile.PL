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
		'Text::ASCIITable' => 0,
		'Time::Duration' => 0,
		'Transmission::Client' => 0.0603,
		'Test::Output' => 0,
	},
);

