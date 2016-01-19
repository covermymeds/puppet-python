# puppet-python [![Build Status](https://travis-ci.org/stankevich/puppet-python.svg?branch=master)](https://travis-ci.org/stankevich/puppet-python)

Puppet module for installing and managing python, pip, and virtualenvs. This is a fork of https://github.com/stankevich/puppet-python which is designed to only support Red Hat Software Collections. 

# Using SCL packages from RedHat or CentOS

To use this module with Linux distributions in the Red Hat family and python distributions
from softwarecollections.org, set python::provider to 'rhscl' and python::version to the name 
of the collection you want to use (e.g., 'python27', 'python33', or 'rh-python34').

# Compatibility

The goal is to be compatible with the base functionality of stankevich module, without the complexity of supporting the variety of operating systems and install methods.

The following have been removed:

* gunicorn support (considered outside scope)
* dotfiles support (open a PR or issue to re-add)
* pyvenv support (open a PR or issue to re-add)

===

## Puppet

Only future parser or Puppet 4 compatible

* Puppet v3 w/ future parser
* Puppet v4

## Ruby versions

* 1.9.3
* 2.0.0
* 2.1.0

## OS Distributions ##

This module has been tested to work on the following systems.

* EL 6
* EL 7

===

## Installation

``` shell
puppet module install covermymeds-python
```

## Usage

### python

Installs and manages python, python-pip, python-dev, python-virtualenv and Gunicorn.

**ensure** - Desired installation state for the Python package. Options are absent, present and latest. Default: present

**version** - Python version to install. Default: system

**pip** - Desired installation state for the python-pip package. Options are absent, present and latest. Default: present

**dev** - Desired installation state for the python-dev package. Options are absent, present and latest. Default: absent

**virtualenv** - Desired installation state for the virtualenv package. Options are absent, present and latest. Default: absent
```puppet
  class { 'python' :
    version    => 'system',
    pip        => 'present',
    dev        => 'absent',
    virtualenv => 'absent',
  }
```

### python::pip

Installs and manages packages from pip.

**pkgname** - the name of the package to install. Required.

**ensure** - present/latest/absent. You can also specify the version. Default: present

**virtualenv** - virtualenv to run pip in. Default: system (no virtualenv)

**url** - URL to install from. Default: none

**owner** - The owner of the virtualenv to ensure that packages are installed with the correct permissions (must be specified). Default: root

**proxy** - Proxy server to use for outbound connections. Default: none

**environment** - Additional environment variables required to install the packages. Default: none

**egg** - The egg name to use. Default: `$name` of the class, e.g. cx_Oracle

**install_args** - String of additional flags to pass to pip during installaton. Default: none

**uninstall_args** - String of additional flags to pass to pip during uninstall. Default: none

**timeout** - Timeout for the pip install command. Defaults to 1800.
```puppet
  python::pip { 'cx_Oracle' :
    pkgname       => 'cx_Oracle',
    ensure        => '5.1.2',
    virtualenv    => '/var/www/project1',
    owner         => 'appuser',
    proxy         => 'http://proxy.domain.com:3128',
    environment   => 'ORACLE_HOME=/usr/lib/oracle/11.2/client64',
    install_args  => '-e',
    timeout       => 1800,
   }
```

### python::requirements

Installs and manages Python packages from requirements file.

**virtualenv** - virtualenv to run pip in. Default: system-wide

**proxy** - Proxy server to use for outbound connections. Default: none

**owner** - The owner of the virtualenv to ensure that packages are installed with the correct permissions (must be specified). Default: root

**src** - The `--src` parameter to `pip`, used to specify where to install `--editable` resources; by default no `--src` parameter is passed to `pip`.

**group** - The group that was used to create the virtualenv.  This is used to create the requirements file with correct permissions if it's not present already.

**manage_requirements** - Create the requirements file if it doesn't exist. Default: true

```puppet
  python::requirements { '/var/www/project1/requirements.txt' :
    virtualenv => '/var/www/project1',
    proxy      => 'http://proxy.domain.com:3128',
    owner      => 'appuser',
    group      => 'apps',
  }
```

### python::virtualenv

Creates Python virtualenv.

**ensure** - present/absent. Default: present

**version** - Unused. Kept for compatibility purposes

**requirements** - Path to pip requirements.txt file. Default: none

**proxy** - Proxy server to use for outbound connections. Default: none

**systempkgs** - Copy system site-packages into virtualenv. Default: don't

**distribute** - Include distribute in the virtualenv. Default: true

**venv_dir** - The location of the virtualenv if resource path not specified. Must be absolute path. Default: resource name

**owner** - Specify the owner of this virtualenv

**group** - Specify the group for this virtualenv

**index** - Base URL of Python package index. Default: none

**cwd** - The directory from which to run the "pip install" command. Default: undef

**timeout** - The maximum time in seconds the "pip install" command should take. Default: 1800

```puppet
  python::virtualenv { '/var/www/project1' :
    ensure       => present,
    requirements => '/var/www/project1/requirements.txt',
    proxy        => 'http://proxy.domain.com:3128',
    systempkgs   => true,
    distribute   => false,
    venv_dir     => '/home/appuser/virtualenvs',
    owner        => 'appuser',
    group        => 'apps',
    cwd          => '/var/www/project1',
    timeout      => 0,
  }
```

### hiera configuration

This module supports configuration through hiera. The following example
creates two python3 virtualenvs. The configuration also pip installs a
package into each environment.

```yaml
python::python_pips:
  "nose":
    virtualenv: "/opt/env1"
  "coverage":
    virtualenv: "/opt/env2"
```

## Thanks

Special thanks to the upstream contributors:
 * [Sergey Stankevich](https://github.com/stankevich)
 * [Shiva Poudel](https://github.com/shivapoudel)
 * [Peter Souter](https://github.com/petems)
 * [Garrett Honeycutt](http://learnpuppet.com)
