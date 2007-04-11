#!perl -T

use Test::More tests => 4;

use Linux::SysInfo qw/sysinfo LS_HAS_EXTENDED/;

SKIP:
{
 skip 'Your kernel does not support extended sysinfo fields', 4 unless LS_HAS_EXTENDED;

 my $si = sysinfo;
 ok(defined $si);

 ok(exists $si->{$_}) for qw/totalhigh freehigh mem_unit/;
}
