# == Class: python::install
#
# Installs core python packages,
#
# === Examples
#
# include python::install
#
# === Authors
#
# Sergey Stankevich
# Ashley Penney
# Fotis Gimian
# Garrett Honeycutt <code@garretthoneycutt.com>
#
class python::install {

  package { 'python':
    ensure => $::python::ensure,
    name   => $::python::python_package,
  }

  package { 'python-dev':
    ensure => $::python::dev_ensure,
    name   => $::python::dev_package,
  }

  package { 'pip':
    ensure  => $::python::pip_ensure,
    name    => $::python::pip_package,
    require => Package['python'],
  }

  package { 'virtualenv':
    ensure  => $::python::venv_ensure,
    name    => $::python::virtualenv_package,
    require => Package['python'],
  }

  case $::python::pip_ensure {
    'absent': { $pip_link_ensure = 'absent' }
    default:  { $pip_link_ensure = 'link' }
  }

  file { '/usr/local/bin/pip':
    ensure => $pip_link_ensure,
    target => "${scl_root}/bin/pip",
  }

  case $::python::venv_ensure {
    'absent': { $venv_link_ensure = 'absent' }
    default:  { $venv_link_ensure = 'link' }
  }

  file { '/usr/local/bin/virtualenv':
    ensure => $venv_link_ensure,
    target => "${scl_root}/bin/virtualenv",
  }

  file { '/etc/profile.d/scl-python.sh':
    ensure  => link,
    target  => "${scl_path}/enable",
    require => Package['python'],
  }
}
