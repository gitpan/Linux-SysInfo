use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Linux::SysInfo',
    AUTHOR              => 'Vincent Pit <perl@profvince.com>',
    LICENSE             => 'perl',
    VERSION_FROM        => 'lib/Linux/SysInfo.pm',
    ABSTRACT_FROM       => 'lib/Linux/SysInfo.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Exporter'   => 0,
        'Test::More' => 0,
        'XSLoader'   => 0,
    },
    dist                => {
        PREOP => 'pod2text lib/Linux/SysInfo.pm > $(DISTVNAME)/README',
        COMPRESS => 'gzip -9f', SUFFIX => 'gz',
    },
    clean               => { FILES => 'Linux-SysInfo-*' },
);
