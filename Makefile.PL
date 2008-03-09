use strict;
use warnings;
use ExtUtils::MakeMaker;

my $BUILD_REQUIRES = {
 'ExtUtils::MakeMaker' => 0,
 'Test::More'          => 0,
};  
    
sub build_req {
 my $tometa = ' >> $(DISTVNAME)/META.yml;';
 my $build_req = 'echo "build_requires:" ' . $tometa;
 foreach my $mod ( sort { lc $a cmp lc $b } keys %$BUILD_REQUIRES ) {
  my $ver = $BUILD_REQUIRES->{$mod};
  $build_req .= sprintf 'echo "    %-30s %s" %s', "$mod:", $ver, $tometa;
 }  
 return $build_req;
}

WriteMakefile(
    NAME                => 'Linux::SysInfo',
    AUTHOR              => 'Vincent Pit <perl@profvince.com>',
    LICENSE             => 'perl',
    VERSION_FROM        => 'lib/Linux/SysInfo.pm',
    ABSTRACT_FROM       => 'lib/Linux/SysInfo.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Exporter'   => 0,
        'XSLoader'   => 0,
    },
    dist                => {
        PREOP => 'pod2text lib/Linux/SysInfo.pm > $(DISTVNAME)/README; '
                 . build_req,
        COMPRESS => 'gzip -9f', SUFFIX => 'gz',
    },
    clean               => { FILES => 'Linux-SysInfo-*' },
);
