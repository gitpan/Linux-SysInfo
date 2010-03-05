#!perl -T

use strict;
use warnings;

use Config qw/%Config/;

BEGIN {
 my $has_threads = do {
  local $@;
  $Config{useithreads} and eval "use threads; 1";
 };
 # Load Test::More after threads
 require Test::More;
 Test::More->import;
 if ($has_threads) {
  plan(tests => 4 * 10);
 } else {
  plan(skip_all => 'This perl wasn\'t built to support threads');
 }
}

use Linux::SysInfo qw/sysinfo/;

sub try {
 my $tid = threads->tid();
 SKIP: {
  my $si = sysinfo;
  skip 'system error (sysinfo returned undef)' => 4 unless defined $si;
  is ref($si), 'HASH', "sysinfo returns a hash reference in thread $tid";

  for (1 .. 3) {
   if (defined $si->{uptime}) {
    like $si->{uptime}, qr/^\d+(?:\.\d+)?$/,
                                    "key $_ looks like a number in thread $tid";
   } else {
    fail "key $_ isn't defined in thread $tid";
   }
  }
 }
}

my @t = map { threads->create(\&try, $_) } 1 .. 10;
$_->join for @t;
