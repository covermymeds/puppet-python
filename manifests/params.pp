# == Class: python::params
#
# The python Module default configuration settings.
#
class python::params {
  $ensure      = 'present'
  $version     = '27'
  $pip         = 'present'
  $dev         = 'absent'
  $virtualenv  = 'absent'
}
