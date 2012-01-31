name       'conman'
version    '0.0.2'
source     'git-admin.uni.lu:puppet-repo.git'
author     'Sebastien Varrette (Sebastien.Varrette@uni.lu)'
license    'GPL v3'
summary    'Configure and manage ConMan: The Console Manager'
description 'Configure and manage ConMan: The Console Manager'
project_page 'UNKNOWN'

## List of the classes defined in this module
classes    'conman::params, conman, conman::common, conman::debian'

## Add dependencies, if any:
# dependency 'username/name', '>= 1.2.0'
dependency 'stow'
dependency 'concat'
defines    '["conman::console"]'
