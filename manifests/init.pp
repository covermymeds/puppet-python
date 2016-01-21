# == Class: python
#
# Installs and manages python, python-dev, python-virtualenv and Gunicorn.
#
# === Parameters
#
# [*ensure*]
#  Desired installation state for the Python package. Valid options are absent,
#  present and latest. Default: present
#
# [*version*]
#  Python version to install. Beware that valid values for this differ a) by
#  the provider you choose and b) by the osfamily/operatingsystem you are using.
#  Default: system default
#  Allowed values:
#   - provider == pip: everything pip allows as a version after the 'python=='
#   - else: 'system', 'pypy', 3/3.3/...
#      - Be aware that 'system' usually means python 2.X.
#      - 'pypy' actually lets us use pypy as python.
#      - 3/3.3/... means you are going to install the python3/python3.3/...
#        package, if available on your osfamily.
#
# [*pip*]
#  Desired installation state for python-pip. Boolean values are deprecated.
#  Default: present
#  Allowed values: 'absent', 'present', 'latest'
#
# [*dev*]
#  Desired installation state for python-dev. Boolean values are deprecated.
#  Default: absent
#  Allowed values: 'absent', 'present', 'latest'
#
# [*virtualenv*]
#  Desired installation state for python-virtualenv. Boolean values are
#  deprecated. Default: absent
#  Allowed values: 'absent', 'present', 'latest
#
# [*gunicorn*]
#  Desired installation state for Gunicorn. Boolean values are deprecated.
#  Default: absent
#  Allowed values: 'absent', 'present', 'latest'
#
# [*manage_gunicorn*]
#  Allow Installation / Removal of Gunicorn. Default: true
#
# [*provider*]
#  What provider to use for installation of the packages, except gunicorn and
#  Python itself. Default: system default provider
#  Allowed values: 'pip'
#
# [*use_epel*]
#  Boolean to determine if the epel class is used. Default: true
#
# === Examples
#
# class { 'python':
#   version    => 'system',
#   pip        => 'present',
#   dev        => 'present',
#   virtualenv => 'present',
#   gunicorn   => 'present',
# }
#
# === Authors
#
# Sergey Stankevich
# Garrett Honeycutt <code@garretthoneycutt.com>
#
class python (
  Enum['present', 'absent'] $ensure              = $python::params::ensure,
  String                    $version             = $python::params::version,
  Enum['present', 'absent'] $pip                 = $python::params::pip,
  Enum['present', 'absent'] $dev                 = $python::params::dev,
  Enum['present', 'absent'] $virtualenv          = $python::params::virtualenv,
  Hash                      $python_pips         = { },
  Hash                      $python_virtualenvs  = { },
  Hash                      $python_pyvenvs      = { },
  Hash                      $python_requirements = { },
) inherits python::params {

  $python_package     = "python${version}"
  $pip_package        = "${python_package}-python-pip"
  $dev_package        = "${python_package}-python-devel"
  $virtualenv_package = "${python_package}-python-virtualenv"

  $exec_prefix = "scl enable ${python_package} -- "
  $scl_path    = "/opt/rh/${python_package}"
  $scl_root    = "${scl_path}/root"

  # Anchor pattern to contain dependencies
  anchor { 'python::begin': } ->
  class { 'python::install': } ->
  class { 'python::config': } ->
  anchor { 'python::end': }

  # Allow hiera configuration of python resources
  create_resources('python::pip', $python_pips)
  create_resources('python::pyvenv', $python_pyvenvs)
  create_resources('python::virtualenv', $python_virtualenvs)
  create_resources('python::requirements', $python_requirements)

}
