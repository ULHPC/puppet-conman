-*- mode: markdown; mode: visual-line;  -*-

# Conman Puppet Module 

[![Puppet Forge](http://img.shields.io/puppetforge/v/ULHPC/conman.svg)](https://forge.puppetlabs.com/ULHPC/conman)
[![License](http://img.shields.io/:license-GPL3.0-blue.svg)](LICENSE)
![Supported Platforms](http://img.shields.io/badge/platform-debian-lightgrey.svg)
[![Documentation Status](https://readthedocs.org/projects/ulhpc-puppet-conman/badge/?version=latest)](https://readthedocs.org/projects/ulhpc-puppet-conman/?badge=latest)

Configure and manage ConMan: The Console Manager

      Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team <hpc-sysadmins@uni.lu>
      

| [Project Page](https://github.com/ULHPC/puppet-conman) | [Sources](https://github.com/ULHPC/puppet-conman) | [Documentation](https://ulhpc-puppet-conman.readthedocs.org/en/latest/) | [Issues](https://github.com/ULHPC/puppet-conman/issues) |

## Synopsis

Configure and manage ConMan: The Console Manager.

This module implements the following elements: 

* __Puppet classes__:
    - `conman` 
    - `conman::common` 
    - `conman::debian` 
    - `conman::params` 

* __Puppet definitions__: 
    - `conman::console` 

All these components are configured through a set of variables you will find in
[`manifests/params.pp`](manifests/params.pp). 

_Note_: the various operations that can be conducted from this repository are piloted from a [`Rakefile`](https://github.com/ruby/rake) and assumes you have a running [Ruby](https://www.ruby-lang.org/en/) installation.
See `docs/contributing.md` for more details on the steps you shall follow to have this `Rakefile` working properly. 

## Dependencies

See [`metadata.json`](metadata.json). In particular, this module depends on 

* [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)
* [puppetlabs/concat](https://forge.puppetlabs.com/puppetlabs/concat)

## Overview and Usage

### Class `conman`

This is the main class defined in this module.
It accepts the following parameters: 

* `$ensure`: *Default*: 'present'. Ensure the presence (or absence) of conman
* `$coredump`: *Default*: false. Specifies whether the daemon should generate a
             core dump file.
* `$coredumpdir`: Specifies the directory where the daemon tries to write core dump files.
* `$keepalive`: *Default*: true. Specifies whether the daemon will use TCP
             keep-alives for detecting dead connections
* `$loopback`: *Default*: false. Specifies whether the daemon will bind its
             socket to the loopback address, thereby only accepting local
             client connections directed to that address (127.0.0.1)
* `$port`: specifies the port on which the daemon will listen for client connections.
* `$resetcmd`: specifies a command string to be invoked by a subshell upon
             receipt of the client's "reset" escape
* `$tcpwrappers`: *Default*: false. specifies whether the daemon will use Wietse
             Venema's TCP-Wrappers when accepting client connections.
* `$timestamp`: *Default*:0 (ie, no timestamps). specifies the interval between
             timestamps written to all console log files.  The interval is an
             integer that may be followed by a single-char modifier; 'm' for
             minutes (the default), 'h' for hours, or 'd' for days.
* `$serialopts`: *Default*: '9600,8n1' (for 9600 bps, 8 data bits, no parity, 1
             stop bit). Specifies default options for local serial devices;

Use it as follows:

     include 'conman'

You can then specialize the various aspects of the configuration, for instance:

     class { 'conman':
         ensure => 'present'
     }


See also [`tests/init.pp`](tests/init.pp)


### Definition `conman::console`

Defines a console being managed by the daemon.

Pre-requisites:

 * The class 'conman' should have been instanciated

This definition accepts the following parameters:

* `$ensure`:
   default to 'present', can be 'absent'.
   Default: 'present'

* `$content`:
  Specify the contents of the console entry as a string. Newlines, tabs,
  and spaces can be specified using the escaped syntax (e.g., \n for a newline)

* `$source`:
  Copy a file as the content of the console entry.
  Uses checksum to determine when a file should be copied.
  Valid values are either fully qualified paths to files, or URIs. Currently
  supported URI types are puppet and file.
  In neither the 'source' or 'content' parameter is specified, then the
  following parameters can be used to set the console entry.

* `$consolename`:
  Defines a console being managed by the daemon. You may also use the name of
  the definition for this directive

* `$connector`:
  Specifies the type of connector to use to connect to the console of the
  node.
   - An external process-based connection is defined by the "<path> <args>"
     format (where <path> is the pathname to an executable file/script, and
     any additional <args> are space-delimited).
     Ex:      connector => '/path/to/script <args>'
   - An IPMI Serial-Over-LAN connection is defined by the "ipmi:<host>" format
     (where "ipmi:" is the literal string and <host> is a hostname or IPv4
     address). Consequently, you'll have to use in this general:
           connector => 'ipmi:'

* `$bmcname_suffix`:
   Define the suffix to apply to the name of the console (i.e. the host) to
   access the baseboard Managment Card (BMC).
  Default to '-bmc' such that the BMC card is assumed to be '${name}-bmc'. If
   the 'min_index' and 'max_index' parameter are used, then the BMC cards are
   assumed to be named '${name}${idx}-bmc' (or more precisely
   '${name}-${idx}${bmcname_suffix}')

* `$min_index`, `$max_index`:
  Permits to define a sequence of console entries for successive hosts named
  `${name}${min_index}..${name}${max_index}`. Useful for cluster nodes
  definition.
  Example:   
  
  		conman::console { 'myclusternode-':
              min_index => 1,
              min_index => 2,
              connector => 'ipmi:'
        }
        
  will produce the console entries
        
       console name="myclusternode-1" dev="ipmi:myclusternode-1-bmc"
       console name="myclusternode-2" dev="ipmi:myclusternode-2-bmc"
       console name="myclusternode-3" dev="ipmi:myclusternode-3-bmc"
       console name="myclusternode-4" dev="ipmi:myclusternode-4-bmc"

* `$logfile`:
   File where console output is logged.
   This parameter undergoes conversion specifier expansion each time the file is
   opened.  If an absolute pathname is not given, the file's location is
   relative to either `conman::params::logdir`.
   Default: empty string, which disables logging, overriding the GLOBAL LOG name.

* `$serialopts`: 
   Specifies options for local serial devices; These options can be
        overridden on an per-console basis by specifying the CONSOLE SEROPTS
        keyword.
     The default is "9600,8n1" for 9600 bps, 8 data bits, no parity, 1 stop bit

* `$ipmiopts`: Specifies global options for IPMI Serial-Over-LAN devices.  These options can be overridden on a per-console basis by specifying the CONSOLE IPMIOPTS keyword.  This directive is only available if configured using
        the "--with-freeipmi" option.
      The IPMIOPTS string is parsed into comma-delimited substrings where each
        substring is of the form "X:VALUE".  "X" is a single-character
        case-insensitive key specifying the option type, and "VALUE" is its
        corresponding value.  The IPMI default will be used if either "VALUE" is
        omitted from the substring ("X:") or the substring is omitted altogether.
        Note that since the IPMIOPTS string is delimited by commas, substring
        values cannot contain commas.
      The valid IPMIOPTS substrings include the following (in any order):
      
     - `U:<username>` - a string of at most 16 bytes for the username
        with which to authenticate to the BMCs serving the remote consoles.
     - `P:<password>` - a string of at most 20 bytes for the password
          with which to authenticate to the BMCs serving the remote consoles.
     - `K:<K_g>` - a string of at most 20 bytes for the K_g key with which
          to authenticate to the BMCs serving the remote consoles.
     - `C:<cipher_suite>` - an integer for the IPMI cipher suite ID.
       Refer to ipmiconsole(8) for a list of currently supported IDs.
     - `L:<privilege_level>` - the string "user", "op", or "admin".
     - `W:<workaround_flag>` - a string or integer for an IPMI workaround.
          Refer to ipmiconsole(8) for a list of currently supported flags.
          This substring may be repeated to specify multiple workaround flags.
          
  Both the `<password>` and `<K_g>` values can be specified in either ASCII or
  hexadecimal; in the latter case, the string should begin with "0x" and
  contain at most 40 hexadecimal digits.  A `<K_g>` key entered in hexadecimal
  may contain embedded null characters, but any characters following the
  first null character in the <password> key will be ignored.

Example:

    conman::console { 'toto': }


## Librarian-Puppet / R10K Setup

You can of course configure the conman module in your `Puppetfile` to make it available with [Librarian puppet](http://librarian-puppet.com/) or
[r10k](https://github.com/adrienthebo/r10k) by adding the following entry:

     # Modules from the Puppet Forge
     mod "ULHPC/conman"

or, if you prefer to work on the git version: 

     mod "ULHPC/conman", 
         :git => 'https://github.com/ULHPC/puppet-conman',
         :ref => 'production' 

## Issues / Feature request

You can submit bug / issues / feature request using the [ULHPC/conman Puppet Module Tracker](https://github.com/ULHPC/puppet-conman/issues). 

## Developments / Contributing to the code 

If you want to contribute to the code, you shall be aware of the way this module is organized. 
These elements are detailed on [`docs/contributing.md`](contributing/index.md).

You are more than welcome to contribute to its development by [sending a pull request](https://help.github.com/articles/using-pull-requests). 

## Puppet modules tests within a Vagrant box

The best way to test this module in a non-intrusive way is to rely on [Vagrant](http://www.vagrantup.com/).
The `Vagrantfile` at the root of the repository pilot the provisioning various vagrant boxes available on [Vagrant cloud](https://atlas.hashicorp.com/boxes/search?utf8=%E2%9C%93&sort=&provider=virtualbox&q=svarrette) you can use to test this module.

See [`docs/vagrant.md`](vagrant.md) for more details. 

## Online Documentation

[Read the Docs](https://readthedocs.org/) aka RTFD hosts documentation for the open source community and the [ULHPC/conman](https://github.com/ULHPC/puppet-conman) puppet module has its documentation (see the `docs/` directly) hosted on [readthedocs](http://ulhpc-puppet-conman.rtfd.org).

See [`docs/rtfd.md`](rtfd.md) for more details.

## Licence

This project and the sources proposed within this repository are released under the terms of the [GPL-3.0](LICENCE) licence.


[![Licence](https://www.gnu.org/graphics/gplv3-88x31.png)](LICENSE)
