# File::      <tt>conman.pp</tt>
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
            fail("Module $module_name is not supported on $operatingsystem")
        }
    }
}

# ------------------------------------------------------------------------------
# = Class: conman::common
#
# Base class to be inherited by the other conman classes
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]
class conman::common {

    # Load the variables used in this module. Check the conman-params.pp file
    require conman::params

    # Get the sources and compile them
    file { "${conman::params::builddir}":
        ensure => 'directory',
        owner  => "${conman::params::builddir_owner}",
        group  => "${conman::params::builddir_group}",
        mode   => "${conman::params::builddir_mode}",
    }
    $archivename = "conman-${conman::params::version}"
    $archivefile = "${archivename}.tar.bz2"

    exec { 'Get ConMan sources':
        command => "wget ${conman::params::conman_src_url}/${archivefile}",
        path    => '/sbin:/usr/bin:/usr/sbin:/bin',
        cwd     => "${conman::params::builddir}",
        creates => "${conman::params::builddir}/${archivefile}",
        user    => 'root',
        group   => 'root',
        require => [
                    Package['wget'],
                    File["${conman::params::builddir}"]
                    ]
    }

    exec { "Untar ConMan sources":
        path    => '/sbin:/usr/bin:/usr/sbin:/bin',
        cwd     => "${conman::params::builddir}",
        command => "tar xvjf ${archivefile}",
        creates => "${conman::params::builddir}/${archivename}",
        require => [
                    Package['bzip2'],
                    Exec['Get ConMan sources']
                    ]
    }

    include stow
    # TODO: put this in some module?
    if (! defined(Package['build-essential'])) {
        package { 'build-essential':
            ensure => 'present'
        }
    }
    if (! defined(Package['expect'])) {
        package { 'expect':
            ensure => 'present'
        }
    }

    $prefixdir="${stow::params::stowdir}/conman-${conman::params::version}"
    $configure_opts="--with-tcp-wrappers --with-freeipmi"
    exec { "Compile ConMan sources":
        path    => '/sbin:/usr/bin:/usr/sbin:/bin',
        cwd     => "${conman::params::builddir}/${archivename}",
        command => "./configure --prefix=${prefixdir} ${configure_opts} && make && make install",
        creates => "${stow::params::stowdir}/${archivename}",
        require => Package['build-essential']
    }
    # Now install it with stow
    stow::install { "conman-${conman::params::version}":
    }

    # Prepare le log directory
    file { "${conman::params::logdir}":
        ensure => 'directory',
        owner  => "${conman::params::logdir_owner}",
        group  => "${conman::params::logdir_group}",
        mode   => "${conman::params::logdir_mode}",
    }

    file { "/etc/init.d/conman":
        ensure  => 'link',
        target  => "/usr/local/etc/init.d/conman",
        #creates => "/etc/init.d/conman",
        require => Stow::Install["conman-${conman::params::version}"]
    }

    file { "/etc/default/conman":
        ensure  => 'link',
        target  => "/usr/local/etc/default/conman",
        #creates => "/etc/default/conman",
        require => Stow::Install["conman-${conman::params::version}"]
    }

    file {"/etc/logrotate.d/conman":
        ensure  => 'link',
        target  => "/usr/local/etc/logrotate.d/conman",
        #creates => "/etc/init.d/conman",
        require => Stow::Install["conman-${conman::params::version}"]
    }

    include concat::setup
    concat { "${conman::params::configfile}":
        warn    => false,
        owner   => "${conman::params::configfile_owner}",
        group   => "${conman::params::configfile_group}",
        mode    => "${conman::params::configfile_mode}",
        require => Stow::Install["conman-${conman::params::version}"]
        #notify  => Service['conman'],
    }
    file { "${stow::params::stowdir}/${archivename}/${conman::params::configfile}":
        ensure  => 'link',
        target  => "${conman::params::configfile}",
        require => [
                    Stow::Install["conman-${conman::params::version}"],
                    Concat["${conman::params::configfile}"]
                    ]       
    }
    
    # Let's go
    concat::fragment { "${conman::params::configfile}_header":
        target  => "${conman::params::configfile}",
        ensure  => "${conman::ensure}",
        content => template("conman/conman.conf.erb"),
        order   => '01',
    }

    # Release the ConMan service
    service { 'conman':
        name       => "${conman::params::servicename}",
        enable     => true,
        ensure     => running,
        hasrestart => "${conman::params::hasrestart}",
        pattern    => "${conman::params::processname}",
        hasstatus  => "${conman::params::hasstatus}",
        require    => [
                       File["/etc/init.d/conman"],
                       File["/etc/default/conman"],
                       File["${stow::params::stowdir}/${archivename}/${conman::params::configfile}"],
                       Concat["${conman::params::configfile}"]
                       ]
    }

}



# ------------------------------------------------------------------------------
# = Class: conman::debian
#
# Specialization class for Debian systems
class conman::debian inherits conman::common { }




