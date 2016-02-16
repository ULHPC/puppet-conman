# File::      <tt>conman-console.pp</tt>
# Author::    Sebastien Varrette (<Sebastien.Varrette@uni.lu>)
# Copyright:: Copyright (c) 2011 Sebastien Varrette (www[http://varrette.gforge.uni.lu])
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Defines: conman::console
#
# Defines a console being managed by the daemon.
#
# == Pre-requisites
#
# * The class 'conman' should have been instanciated
#
# == Parameters:
#
# [*ensure*]
#   default to 'present', can be 'absent'.
#   Default: 'present'
#
# [*content*]
#  Specify the contents of the console entry as a string. Newlines, tabs,
#  and spaces can be specified using the escaped syntax (e.g., \n for a newline)
#
# [*source*]
#  Copy a file as the content of the console entry.
#  Uses checksum to determine when a file should be copied.
#  Valid values are either fully qualified paths to files, or URIs. Currently
#  supported URI types are puppet and file.
#  In neither the 'source' or 'content' parameter is specified, then the
#  following parameters can be used to set the console entry.
#
# [*consolename*]
#  Defines a console being managed by the daemon. You may also use the name of
#  the definition for this directive
#
# [*connector*]
#  Specifies the type of connector to use to connect to the console of the
#  node.
#   - An external process-based connection is defined by the "<path> <args>"
#     format (where <path> is the pathname to an executable file/script, and
#     any additional <args> are space-delimited).
#     Ex:      connector => '/path/to/script <args>'
#   - An IPMI Serial-Over-LAN connection is defined by the "ipmi:<host>" format
#     (where "ipmi:" is the literal string and <host> is a hostname or IPv4
#     address). Consequently, you'll have to use in this general:
#           connector => 'ipmi:'
#
# [*bmcname_suffix*]
#   Define the suffix to apply to the name of the console (i.e. the host) to
#   access the baseboard Managment Card (BMC).
#  Default to '-bmc' such that the BMC card is assumed to be '${name}-bmc'. If
#   the 'min_index' and 'max_index' parameter are used, then the BMC cards are
#   assumed to be named '${name}${idx}-bmc' (or more precisely
#   '${name}-${idx}${bmcname_suffix}')
#
# [*min_index*] [*max_index*]
#  Permits to define a sequence of console entries for successive hosts named
#  ${name}${min_index}..${name}${max_index}. Useful for cluster nodes
#  definition.
#  Ex:   conman::console { 'myclusternode-':
#              min_index => 1,
#              min_index => 2,
#              connector => 'ipmi:'
#        }
#        will produce the console entries
#           console name="myclusternode-1" dev="ipmi:myclusternode-1-bmc"
#           console name="myclusternode-2" dev="ipmi:myclusternode-2-bmc"
#           console name="myclusternode-3" dev="ipmi:myclusternode-3-bmc"
#           console name="myclusternode-4" dev="ipmi:myclusternode-4-bmc"
#
# [*logfile*]
#   File where console output is logged.
#   This parameter undergoes conversion specifier expansion each time the file is
#   opened.  If an absolute pathname is not given, the file's location is
#   relative to either conman::params::logdir.
#   Default: empty string, which disables logging, overriding the GLOBAL LOG name.
#
# [*serialopts*]
#   See conman::param::serialopts
#
# [*ipmiopts*]
#    See conman::param::ipmiopts

# == Sample usage:
#
#     class { 'conman':
#         ensure => 'present'
#     }
#
# You can then add a console specification as follows:
#
#      conman::console {
#
#      }
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
define conman::console (
    $ensure         = 'present',
    $content        = '',
    $source         = '',
    $consolename    = '',
    $connector      = '',
    $bmcname_suffix = '-bmc',
    $login          = '',
    $password       = '',
    $logfile        = '',
    $min_index      = 0,
    $max_index      = 0,
    $serialopts     = $conman::params::serialopts,
    $ipmiopts       = $conman::params::ipmiopts
)
{

    include conman::params

    # $name is provided by define invocation and is should be set to the
    # vendor, unless the vendor attribute is set
    $basename = $name

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("conman::console 'ensure' parameter must be set to either 'absent' or 'present'")
    }

    if ($conman::ensure != $ensure) {
        if ($conman::ensure != 'present') {
            fail("Cannot configure a conman console '${basename}' as conman::ensure is NOT set to present (but ${conman::ensure})")
        }
    }

    $device_prefix = $connector ? {
        'ipmi:' => $connector,
        default => "/usr/local/lib/conman/exec/${connector} "
    }
    $connector_login_args = $login ? {
        ''      => '',
        default => $password ? {
            ''      => " ${login}",
            default => " ${login} ${password}"
        }
    }
    # if content is passed, use that, else if source is passed use that
    $real_content = $content ? {
        '' => $source ? {
            ''      => template('conman/conman_console_entry.erb'),
            default => ''
        },
        default => $content
    }
    $real_source = $source ? {
        '' => '',
        default => $content ? {
            ''      => $source,
            default => ''
        }
    }

    concat::fragment { "${conman::params::configfile}_${basename}":
        ensure  => $ensure,
        target  => $conman::params::configfile,
        content => $real_content,
        source  => $real_source,
        order   => '50',
    }


}
