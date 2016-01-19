# == Class: python::params
#
# The python Module default configuration settings.
#
class python::params {
  $ensure          = 'present'
  $version         = 'system'
  $dev             = 'absent'
  $pip             = 'present'
  $virtualenv      = 'absent'
  $gunicorn        = 'absent'
  $manage_gunicorn = true
  $use_epel               = true

  $python = $::python::version ? {
    'system' => 'python',
    'pypy'   => 'pypy',
    default  => 'system',
  }

  case $::osfamily {
    'RedHat': {
      $dev_package    = "${python}-devel"
      $valid_versions = ['3','27','33'],
    }
    'Debian': {
      $dev_package    = "${python}-dev"
      $valid_versions = ['3', '3.3', '2.7']
    }
    'Suse': {
      $dev_package    = "${python}-devel"
      $valid_versions = []
    }
    default: {
      fail("Module is not compatible with ${::operatingsystem}")
    }
  }

  case $python::provider {
    'pip': {
      $exec_prefix = ''
      $package_provider = 'pip'
      $pip_package = "${python}-python-pip"
      $virtualenv_package = "${python}-python-virtualenv"
    }
    'scl': {
      $exec_prefix = "scl enable ${python_version} -- "
      $package_provider = undef
      $pip_package = "${python}-python-pip"
      $virtualenv_package = "${python}-python-virtualenv"
    }
    'rhscl': {
      $exec_prefix = "scl enable ${python_version} -- "
      $package_provider = undef
      $python_package = 'python-scl-package'
      $pip_package = "${python}-python-pip"
      $virtualenv_package = "${python}-python-virtualenv"
    }
    default: {
      $package_provider = undef
      case $::osfamily {
        'RedHat': {
          $virtualenv_package = "${python}-virtualenv"
        }
        default: {
          $virtualenv_package = $::lsbdistcodename ? {
            'jessie' => 'virtualenv',
            default  => 'python-virtualenv',
          }
        }
      }

      if $::python::version =~ /^3/ {
        $pip_package = 'python3-pip'
      } else {
        $pip_package = 'python-pip'
      }
    }
  }
}
