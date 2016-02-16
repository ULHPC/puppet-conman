# File::      <tt>common.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPLv3
#
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
    file { $conman::params::builddir:
        ensure => 'directory',
        owner  => $conman::params::builddir_owner,
        group  => $conman::params::builddir_group,
        mode   => $conman::params::builddir_mode,
    }
    $archivename = "conman-${conman::params::version}"
    $archivefile = "${archivename}.tar.bz2"

    exec { 'Get ConMan sources':
        command => "wget ${conman::params::conman_src_url}/${archivefile}",
        path    => '/sbin:/usr/bin:/usr/sbin:/bin',
        cwd     => $conman::params::builddir,
        creates => "${conman::params::builddir}/${archivefile}",
        user    => 'root',
        group   => 'root',
        require => [
                    Package['wget'],
                    File[$conman::params::builddir]
                    ]
    }

    exec { 'Untar ConMan sources':
        path    => '/sbin:/usr/bin:/usr/sbin:/bin',
        cwd     => $conman::params::builddir,
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
    package { $conman::params::extra_packages:
        ensure => 'present'
    }

    $prefixdir="${stow::params::stowdir}/conman-${conman::params::version}"
    $configure_opts='--with-tcp-wrappers --with-freeipmi'
    exec { 'Compile ConMan sources':
        path    => '/sbin:/usr/bin:/usr/sbin:/bin',
        cwd     => "${conman::params::builddir}/${archivename}",
        command => "./configure --prefix=${prefixdir} ${configure_opts} && make && make install",
        creates => "${stow::params::stowdir}/${archivename}/",
        require => [ Package['build-essential'],
                    Exec['Untar ConMan sources']
                    ]
    }
    # Now install it with stow
    stow::install { "conman-${conman::params::version}":
        require => Exec['Compile ConMan sources']
    }

    # Prepare le log directory
    file { $conman::params::logdir:
        ensure => 'directory',
        owner  => $conman::params::logdir_owner,
        group  => $conman::params::logdir_group,
        mode   => $conman::params::logdir_mode,
    }

    file { '/etc/init.d/conman':
        ensure  => 'link',
        target  => '/usr/local/etc/init.d/conman',
        #creates => "/etc/init.d/conman",
        require => Stow::Install["conman-${conman::params::version}"]
    }

    file { '/etc/default/conman':
        ensure  => 'link',
        target  => '/usr/local/etc/default/conman',
        #creates => "/etc/default/conman",
        require => Stow::Install["conman-${conman::params::version}"]
    }

    file {'/etc/logrotate.d/conman':
        ensure  => 'link',
        target  => '/usr/local/etc/logrotate.d/conman',
        #creates => "/etc/init.d/conman",
        require => Stow::Install["conman-${conman::params::version}"]
    }

    include concat::setup
    concat { $conman::params::configfile:
        warn    => false,
        owner   => $conman::params::configfile_owner,
        group   => $conman::params::configfile_group,
        mode    => $conman::params::configfile_mode,
        require => Stow::Install["conman-${conman::params::version}"]
        #notify  => Service['conman'],
    }
    file { "${stow::params::stowdir}/${archivename}/${conman::params::configfile}":
        ensure  => 'link',
        target  => $conman::params::configfile,
        require => [
                    Stow::Install["conman-${conman::params::version}"],
                    Concat[$conman::params::configfile]
                    ]
    }

    # Let's go
    concat::fragment { "${conman::params::configfile}_header":
        ensure  => $conman::ensure,
        target  => $conman::params::configfile,
        content => template('conman/conman.conf.erb'),
        order   => '01',
    }

    # Release the ConMan service
    service { 'conman':
        ensure     => running,
        name       => $conman::params::servicename,
        enable     => true,
        hasrestart => $conman::params::hasrestart,
        pattern    => $conman::params::processname,
        hasstatus  => $conman::params::hasstatus,
        require    => [
                        File['/etc/init.d/conman'],
                        File['/etc/default/conman'],
                        File["${stow::params::stowdir}/${archivename}/${conman::params::configfile}"],
                        Concat[$conman::params::configfile]
                        ]
    }

}
