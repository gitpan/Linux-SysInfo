#!perl -T

use Test::More;

use Linux::SysInfo qw/sysinfo LS_HAS_EXTENDED/;

unless (LS_HAS_EXTENDED) {
 plan skip_all => 'your kernel does not support extended sysinfo fields';
} else {
 plan tests => 4;

 my $si = sysinfo;
 ok(defined $si);

 ok(exists $si->{$_}) for qw/totalhigh freehigh mem_unit/;
}
