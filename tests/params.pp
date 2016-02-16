# File::      <tt>params.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# You need the 'future' parser to be able to execute this manifest (that's
# required for the each loop below).
#
# Thus execute this manifest in your vagrant box as follows:
#
#      sudo puppet apply -t --parser future /vagrant/tests/params.pp
#
#

include 'conman::params'

$names = ["ensure", "coredump", "coredumpdir", "keepalive", "loopback", "port", "resetcmd", "tcpwrappers", "timestamp", "serialopts", "ipmiopts", "version", "conman_src_url", "extra_packages", "builddir", "builddir_mode", "builddir_owner", "builddir_group", "logdir", "logdir_mode", "logdir_owner", "logdir_group", "pidfile", "processname", "servicename", "hasstatus", "hasrestart", "configfile", "configfile_mode", "configfile_owner", "configfile_group"]

notice("conman::params::ensure = ${conman::params::ensure}")
notice("conman::params::coredump = ${conman::params::coredump}")
notice("conman::params::coredumpdir = ${conman::params::coredumpdir}")
notice("conman::params::keepalive = ${conman::params::keepalive}")
notice("conman::params::loopback = ${conman::params::loopback}")
notice("conman::params::port = ${conman::params::port}")
notice("conman::params::resetcmd = ${conman::params::resetcmd}")
notice("conman::params::tcpwrappers = ${conman::params::tcpwrappers}")
notice("conman::params::timestamp = ${conman::params::timestamp}")
notice("conman::params::serialopts = ${conman::params::serialopts}")
notice("conman::params::ipmiopts = ${conman::params::ipmiopts}")
notice("conman::params::version = ${conman::params::version}")
notice("conman::params::conman_src_url = ${conman::params::conman_src_url}")
notice("conman::params::extra_packages = ${conman::params::extra_packages}")
notice("conman::params::builddir = ${conman::params::builddir}")
notice("conman::params::builddir_mode = ${conman::params::builddir_mode}")
notice("conman::params::builddir_owner = ${conman::params::builddir_owner}")
notice("conman::params::builddir_group = ${conman::params::builddir_group}")
notice("conman::params::logdir = ${conman::params::logdir}")
notice("conman::params::logdir_mode = ${conman::params::logdir_mode}")
notice("conman::params::logdir_owner = ${conman::params::logdir_owner}")
notice("conman::params::logdir_group = ${conman::params::logdir_group}")
notice("conman::params::pidfile = ${conman::params::pidfile}")
notice("conman::params::processname = ${conman::params::processname}")
notice("conman::params::servicename = ${conman::params::servicename}")
notice("conman::params::hasstatus = ${conman::params::hasstatus}")
notice("conman::params::hasrestart = ${conman::params::hasrestart}")
notice("conman::params::configfile = ${conman::params::configfile}")
notice("conman::params::configfile_mode = ${conman::params::configfile_mode}")
notice("conman::params::configfile_owner = ${conman::params::configfile_owner}")
notice("conman::params::configfile_group = ${conman::params::configfile_group}")

#each($names) |$v| {
#    $var = "conman::params::${v}"
#    notice("${var} = ", inline_template('<%= scope.lookupvar(@var) %>'))
#}
