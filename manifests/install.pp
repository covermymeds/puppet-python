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
    ensure   => $::python::ensure,
    name     => $::python::params::python_package,
    provider => $::python::params::package_provider,
  }

  package { 'virtualenv':
    ensure   => $::python::virtualenv,
    name     => $::python::params::virtualenv_package,
    provider => $::python::params::package_provider,
    require  => Package['python'],
  }

  package { 'pip':
    ensure   => $::python::pip,
    name     => $::python::params::pip_package,
    provider => $::python::params::package_provider,
    require  => Package['python'],
  }

  package { 'python-dev':
    ensure   => $::python::dev,
    name     => $::python::params::dev_package,
    provider => $::python::params::package_provider,
  }

  if $python::manage_gunicorn {
    package { 'gunicorn':
      ensure => $gunicorn_ensure,
    }
  }

  case $python::provider {
    pip: {
      # Install pip without pip, see https://pip.pypa.io/en/stable/installing/.
      exec { 'bootstrap pip':
        command => '/usr/bin/curl https://bootstrap.pypa.io/get-pip.py | python',
        unless  => '/usr/bin/which pip',
        require => Package['python'],
      }

      # Puppet is opinionated about the pip command name
      file { 'pip-python':
        ensure  => link,
        path    => '/usr/bin/pip-python',
        target  => '/usr/bin/pip',
        require => Exec['bootstrap pip'],
      }

      Exec['bootstrap pip'] -> File['pip-python'] -> Package <| provider == pip |>
    }
    scl: {
      # SCL is only valid in the RedHat family. If RHEL, package must be
      # enabled using the subscription manager outside of puppet. If CentOS,
      # the centos-release-SCL will install the repository.
      $scl_repo_package_ensure = $::operatingsystem ? {
        'CentOS' => 'present',
        default  => 'absent',
      }

      package { 'centos-release-SCL':
        ensure => $scl_repo_package_ensure,
        before => Package['scl-utils'],
      }
      package { 'scl-utils':
        ensure => 'latest',
        before => Package['python'],
      }
    }
    rhscl: {
      # rhscl is RedHat SCLs from softwarecollections.org
      $scl_package = "rhscl-${::python::version}-epel-${::operatingsystemmajrelease}-${::architecture}"
      package { $scl_package:
        source   => "https://www.softwarecollections.org/en/scls/rhscl/${::python::version}/epel-${::operatingsystemmajrelease}-${::architecture}/download/${scl_package}.noarch.rpm",
        provider => 'rpm',
        tag      => 'python-scl-repo',
      }

      package { "${python}-scldevel":
        ensure => $dev_ensure,
        tag    => 'python-scl-package',
      }

      if $pip_ensure != 'absent' {
        exec { 'python-scl-pip-install':
          command => "${python::exec_prefix}easy_install pip",
          path    => ['/usr/bin', '/bin'],
          creates => "/opt/rh/${python::version}/root/usr/bin/pip",
        }
      }

      Package <| name == 'python-scl-repo' |> ->
      Package <| tag == 'python-scl-package' |> ->
      Exec['python-scl-pip-install']
    }

    default: {
      if $::osfamily == 'RedHat' {
        if $pip_ensure != 'absent' {
          if $python::use_epel == true {
            include 'epel'
            Class['epel'] -> Package['pip']
          }
        }
        if ($venv_ensure != 'absent') and ($::operatingsystemrelease =~ /^6/) {
          if $python::use_epel == true {
            include 'epel'
            Class['epel'] -> Package['virtualenv']
          }
        }
      }

    }
  }
}
