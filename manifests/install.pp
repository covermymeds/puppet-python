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
}
