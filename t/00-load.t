#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Linux::SysInfo' );
}

diag( "Testing Linux::SysInfo $Linux::SysInfo::VERSION, Perl $], $^X" );
