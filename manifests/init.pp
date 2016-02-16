# File::      <tt>init.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Class: conman
#
# Configure and manage ConMan: The Console Manager
#
# == Parameters:
#
# $ensure:: *Default*: 'present'. Ensure the presence (or absence) of conman
# $coredump:: *Default*: false. Specifies whether the daemon should generate a
#             core dump file.
# $coredumpdir:: Specifies the directory where the daemon tries to write core dump files.
# $keepalive:: *Default*: true. Specifies whether the daemon will use TCP
#             keep-alives for detecting dead connections
# $loopback:: *Default*: false. Specifies whether the daemon will bind its
#             socket to the loopback address, thereby only accepting local
#             client connections directed to that address (127.0.0.1)
# $port:: specifies the port on which the daemon will listen for client connections.
# $resetcmd:: specifies a command string to be invoked by a subshell upon
#             receipt of the client's "reset" escape
# $tcpwrappers:: *Default*: false. specifies whether the daemon will use Wietse
#             Venema's TCP-Wrappers when accepting client connections.
# $timestamp:: *Default*:0 (ie, no timestamps). specifies the interval between
#             timestamps written to all console log files.  The interval is an
#             integer that may be followed by a single-char modifier; 'm' for
#             minutes (the default), 'h' for hours, or 'd' for days.
# $serialopts:: *Default*: '9600,8n1' (for 9600 bps, 8 data bits, no parity, 1
#             stop bit). Specifies default options for local serial devices;
#
#
# == Actions:
#
# Install and configure conman
#
# == Requires:
#
# n/a
#
# == Sample Usage:
#
#     import conman
#
# You can then specialize the various aspects of the configuration,
# for instance:
#
#         class { 'conman':
#             ensure => 'present'
#         }
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
#
# [Remember: No empty lines between comments and class definition]
#
class conman(
    $ensure      = $conman::params::ensure,
    $coredump    = $conman::params::coredump,
    $coredumpdir = $conman::params::coredumpdir,
    $keepalive   = $conman::params::keepalive,
    $loopback    = $conman::params::loopback,
    $port        = $conman::params::port,
    $resetcmd    = $conman::params::resetcmd,
    $tcpwrappers = $conman::params::tcpwrappers,
    $timestamp   = $conman::params::timestamp,
    $serialopts  = $conman::params::serialopts,
    $ipmiopts    = $conman::params::ipmiopts
)
inherits conman::params
{
    info ("Configuring conman (with ensure = ${ensure})")

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("conman 'ensure' parameter must be set to either 'absent' or 'present'")
    }

    case $::operatingsystem {
        debian, ubuntu:         { include conman::debian }
        default: {
            fail("Module ${module_name} is not supported on ${::operatingsystem}")
        }
    }
}
