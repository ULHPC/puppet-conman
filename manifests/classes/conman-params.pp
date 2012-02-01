# File::      <tt>conman-params.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPL v3
#
# ------------------------------------------------------------------------------
# = Class: conman::params
#
# In this class are defined as variables values that are used in other
# conman classes.
# This class should be included, where necessary, and eventually be enhanced
# with support for more OS
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# The usage of a dedicated param classe is advised to better deal with
# parametrized classes, see
# http://docs.puppetlabs.com/guides/parameterized_classes.html
#
# [Remember: No empty lines between comments and class definition]
#
class conman::params {

    ######## DEFAULTS FOR VARIABLES USERS CAN SET ##########################
    # (Here are set the defaults, provide your custom variables externally)
    # (The default used is in the line with '')
    ###########################################

    # ensure the presence (or absence) of conman
    $ensure = $conman_ensure ? {
        ''      => 'present',
        default => "${conman_ensure}"
    }

    # Whether the daemon should generate a core dump file.  This file will be
    # created in the working directory (or '/' when running in the
    # background) unless `the coredumpdir parameter is also set.
    $coredump    = false

    # Directory where the daemon tries to write core dump files.  The default is
    # empty, meaning the current working directory (or '/' when running in the
    # background) will be used.
    $coredumpdir = ''

    # Specifies whether the daemon will use TCP keep-alives for detecting dead
    # connections.
    $keepalive   = true

    # Specifies whether the daemon will bind its socket to the loopback address,
    #   thereby only accepting local client connections directed to that address
    #   (127.0.0.1).
    $loopback    = false

    # Specifies the port on which the daemon will listen for client connections.
    $port        = ''

    # specifies a command string to be invoked by a subshell upon receipt of the
    #   client's "reset" escape.  Multiple commands within a string may be
    #   separated with semicolons.  This string undergoes conversion specifier
    #   expansion and will be invoked multiple times if the client is connected
    #   to multiple consoles.
    $resetcmd    = ''

    # Specifies whether the daemon will use Wietse Venema's TCP-Wrappers when
    #   accepting client connections.  Support for this feature is enabled at
    #   compile-time (via configure's "--with-tcp-wrappers" option).  Refer to
    #   the hosts_access(5) and hosts_options(5) man pages for more details.
    $tcpwrappers = false

    # Specifies the interval between timestamps written to all console log
    #   files.  The interval is an integer that may be followed by a single-char
    #   modifier; 'm' for minutes (the default), 'h' for hours, or 'd' for days.
    #   The default is 0 (ie, no timestamps).
    $timestamp   = 0

    # Specifies options for local serial devices; These options can be
    #    overridden on an per-console basis by specifying the CONSOLE SEROPTS
    #    keyword.
    # The default is "9600,8n1" for 9600 bps, 8 data bits, no parity, 1 stop bit
    $serialopts  = '9600,8n1'

    # Specifies global options for IPMI Serial-Over-LAN devices.  These options
    #    can be overridden on a per-console basis by specifying the CONSOLE
    #    IPMIOPTS keyword.  This directive is only available if configured using
    #    the "--with-freeipmi" option.
    #  The IPMIOPTS string is parsed into comma-delimited substrings where each
    #    substring is of the form "X:VALUE".  "X" is a single-character
    #    case-insensitive key specifying the option type, and "VALUE" is its
    #    corresponding value.  The IPMI default will be used if either "VALUE" is
    #    omitted from the substring ("X:") or the substring is omitted altogether.
    #    Note that since the IPMIOPTS string is delimited by commas, substring
    #    values cannot contain commas.
    #  The valid IPMIOPTS substrings include the following (in any order):
    #    - U:<username> - a string of at most 16 bytes for the username
    #      with which to authenticate to the BMCs serving the remote consoles.
    #    - P:<password> - a string of at most 20 bytes for the password
    #      with which to authenticate to the BMCs serving the remote consoles.
    #    - K:<K_g> - a string of at most 20 bytes for the K_g key with which
    #      to authenticate to the BMCs serving the remote consoles.
    #    - C:<cipher_suite> - an integer for the IPMI cipher suite ID.
    #      Refer to ipmiconsole(8) for a list of currently supported IDs.
    #    - L:<privilege_level> - the string "user", "op", or "admin".
    #    - W:<workaround_flag> - a string or integer for an IPMI workaround.
    #      Refer to ipmiconsole(8) for a list of currently supported flags.
    #      This substring may be repeated to specify multiple workaround flags.
    #  Both the <password> and <K_g> values can be specified in either ASCII or
    #    hexadecimal; in the latter case, the string should begin with "0x" and
    #    contain at most 40 hexadecimal digits.  A <K_g> key entered in hexadecimal
    #    may contain embedded null characters, but any characters following the
    #    first null character in the <password> key will be ignored.
    $ipmiopts    = ''


    #### MODULE INTERNAL VARIABLES  #########
    # (Modify to adapt to unsupported OSes)
    #######################################
    # ConMan version
    $version = '0.2.7'
    # Where to get the sources
    $conman_src_url = 'http://conman.googlecode.com/files/'

    $extra_packages = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/ => [  'expect', 'libfreeipmi-dev', 'libipmiconsole-dev'],
        default => [ 'expect', 'freeipmi' ]
    }
    
    # Where to build and compile the package
    $builddir = '/usr/local/src/'
    $builddir_mode = $::operatingsystem ? {
        default => '2755',
    }
    $builddir_owner = $::operatingsystem ? {
        default => 'root',
    }
    $builddir_group = $::operatingsystem ? {
        default => 'staff',
    }

    $logdir = $::operatingsystem ? {
        default => '/var/log/conman'
    }
    $logdir_mode = $::operatingsystem ? {
        default => '750',
    }
    $logdir_owner = $::operatingsystem ? {
        default => 'root',
    }
    $logdir_group = $::operatingsystem ? {
        default => 'adm',
    }

    $pidfile = $::operatingsystem ? {
        default => '/var/run/conman.pid'
    }


    $processname = $::operatingsystem ? {
        default => 'conman'
    }
    $servicename = $::operatingsystem ? {
        default => 'conman'
    }
    $hasstatus = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => false,
        /(?i-mx:centos|fedora|redhat)/ => true,
        default => true,
    }
    $hasrestart = $::operatingsystem ? {
        default => true,
    }

    # Main configuration file
    $configfile = $::operatingsystem ? {
        default => '/etc/conman.conf',
    }
    $configfile_mode = $::operatingsystem ? {
        default => '0600',
    }
    $configfile_owner = $::operatingsystem ? {
        default => 'root',
    }
    $configfile_group = $::operatingsystem ? {
        default => 'root',
    }

}

