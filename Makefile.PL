use ExtUtils::MakeMaker;

WriteMakefile(
	'NAME' 		=> 'Isilon',
	'AUTHOR'	=> 'Steven Kreuzer <skreuzer@exit2shell.com>',
	'ABSTRACT'	=> 'Interface into Isilon Storage Products',
	'VERSION_FROM'	=> 'lib/Isilon.pm',
	'PREREQ_PM'	=> { Net::SNMP => 5.2.0 }
);
