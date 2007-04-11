use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Linux::SysInfo',
    AUTHOR              => 'Vincent Pit <perl@profvince.com>',
    VERSION_FROM        => 'lib/Linux/SysInfo.pm',
    ABSTRACT_FROM       => 'lib/Linux/SysInfo.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Linux-SysInfo-*' },
);
