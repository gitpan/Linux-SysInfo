#!perl -T

use Test::More tests => 12 * 5;

use Linux::SysInfo qw/sysinfo/;

for (1 .. 5) {
 my $si = sysinfo;
 ok(defined $si);

 ok(exists $si->{$_}) for qw/uptime load1 load5 load15 totalram freeram sharedram bufferram totalswap freeswap procs/;
}
