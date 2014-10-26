package Linux::SysInfo;

use warnings;
use strict;

=head1 NAME

Linux::SysInfo - Perl interface to the sysinfo(2) Linux system call.

=head1 VERSION

Version 0.05

=cut

our $VERSION = '0.05';

=head1 SYNOPSIS

    use Linux::SysInfo qw/sysinfo/;

    my $si = sysinfo;
    print "$_: $si->{$_}\n" for keys %$si;

=head1 DESCRIPTION

This module is a wrapper around the sysinfo(2) Linux system call. It gives information about the current uptime, load average, memory usage and processes running. Other systems have also this system call (e.g. Solaris), but in most cases the returned information is different.

=head1 EXPORT

The only function of this module, C<sysinfo>, and the constant C<LS_HAS_EXTENDED> are only exported on request.

=cut

use base qw/Exporter/;

our @EXPORT_OK = qw/sysinfo LS_HAS_EXTENDED/;

our %EXPORT_TAGS = ( 'all' => [ @EXPORT_OK ] );

require XSLoader;

XSLoader::load('Linux::SysInfo', $VERSION);

=head1 FUNCTIONS

=head2 C<sysinfo>

This function takes no argument. It returns undef on failure or a hash reference whose keys are the members name of the struct sysinfo on success :

=over 4

=item C<uptime>

Seconds elapsed since the system booted.

=item C<load1>, C<load5>, C<load15>

1, 5 and 15 minutes load average.

=item C<totalram>

Total usable main memory size.

=item C<freeram>

Available memory size.

=item C<sharedram>

Amount of shared memory.

=item C<bufferram>

Memory used by buffers.

=item C<totalswap>

Total swap space size.

=item C<freeswap>

Swap space stil available.

=item C<procs>

Number of current processes.

=back

Prior to Linux 2.3.23 on i386 and 2.3.48 on all other architectures, the memory sizes were given in bytes. Since then, the following members are also available and all the memory sizes are given as multiples of mem_unit bytes :

=over 4

=item C<totalhigh>

Total high memory size.

=item C<freehigh>

Available high memory size.

=item C<mem_unit>

Memory unit size in bytes.

=back

=head1 CONSTANTS

=head2 LS_HAS_EXTENDED

This constant is set to 1 if your kernel supports the three extended fields C<totalhigh>, C<freehigh> and C<mem_unit> ; and to 0 otherwise.

=head1 BINARY COMPATIBILITY

If you upgrade your kernel to a greater version than 2.3.23 on i386 or 2.3.48 on any other platform, you will need to rebuild the module to access the extended fields.

Moreover, since the perl hash function has changed after the 5.6 version, you will also need to recompile the module if you upgrade your perl from a version earlier than 5.6.

=head1 SEE ALSO

The C<sysinfo(2)> man page.

L<Sys::Info> : Gather information about your system.

L<Sys::CpuLoad> : Try several different methods to retrieve the load average.

L<BSD::getloadavg> : Wrapper to the C<getloadavg(3)> BSD system call.

=head1 AUTHOR

Vincent Pit, C<< <perl at profvince.com> >>

You can contact me by mail or on #perl @ FreeNode (Prof_Vince).

=head1 BUGS

Please report any bugs or feature requests to
C<bug-linux-sysinfo at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Linux-SysInfo>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Linux::SysInfo

=head1 COPYRIGHT & LICENSE

Copyright 2007 Vincent Pit, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Linux::SysInfo
