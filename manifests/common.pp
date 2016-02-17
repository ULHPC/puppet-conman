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

    package { ['wget', 'bzip2']:
      ensure => 'present',
    }

    $archivename = "conman-${conman::params::version}"
    $archivefile = "${archivename}.tar.bz2"

    exec { 'Get ConMan sources':
        command => "wget ${conman::params::conman_src_url}/releases/download/${archivename}/${archivefile}",
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

    # TODO: put this in some module?
    if (! defined(Package['build-essential'])) {
        package { 'build-essential':
            ensure => 'present'
        }
    }
    package { $conman::params::extra_packages:
        ensure => 'present'
    }

    $configure_opts='--with-tcp-wrappers --with-freeipmi'
    exec { 'Compile ConMan sources':
        path    => "/sbin:/usr/bin:/usr/sbin:/bin:${conman::params::builddir}/${archivename}",
        cwd     => "${conman::params::builddir}/${archivename}",
        command => "./configure ${configure_opts} && make && make install",
        creates => '/usr/local/bin/conman',
        require => [ Package['build-essential'],
                    Exec['Untar ConMan sources']
                    ]
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
        require => Exec['Compile ConMan sources'],
    }

    file { '/etc/default/conman':
        ensure  => 'link',
        target  => '/usr/local/etc/default/conman',
        #creates => "/etc/default/conman",
        require => Exec['Compile ConMan sources'],
    }

    file {'/etc/logrotate.d/conman':
        ensure  => 'link',
        target  => '/usr/local/etc/logrotate.d/conman',
        #creates => "/etc/init.d/conman",
        require => Exec['Compile ConMan sources'],
    }

    concat { $conman::params::configfile:
        warn    => false,
        owner   => $conman::params::configfile_owner,
        group   => $conman::params::configfile_group,
        mode    => $conman::params::configfile_mode,
        require => Exec['Compile ConMan sources'],
        #notify  => Service['conman'],
    }
    file { "/usr/local/${conman::params::configfile}":
        ensure  => 'link',
        target  => $conman::params::configfile,
        require => [
                    Exec['Compile ConMan sources'],
                    Concat[$conman::params::configfile]
                    ]
    }

    # Let's go
    concat::fragment { "${conman::params::configfile}_header":
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
                        File["/usr/local/${conman::params::configfile}"],
                        Concat[$conman::params::configfile]
                        ]
    }

}
