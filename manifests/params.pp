# == Class: docker::params
#
# Default parameter values for the docker module
#
class docker::params {
  $version                      = undef
  $ensure                       = present
  $tcp_bind                     = undef
  $socket_bind                  = 'unix:///var/run/docker.sock'
  $log_level                    = undef
  $selinux_enabled              = undef
  $socket_group                 = undef
  $service_state                = running
  $service_enable               = true
  $root_dir                     = undef
  $tmp_dir                      = '/tmp/'
  $dns                          = undef
  $dns_search                   = undef
  $proxy                        = undef
  $no_proxy                     = undef
  $execdriver                   = undef
  $storage_driver               = undef
  $dm_basesize                  = undef
  $dm_fs                        = undef
  $dm_mkfsarg                   = undef
  $dm_mountopt                  = undef
  $dm_blocksize                 = undef
  $dm_loopdatasize              = undef
  $dm_loopmetadatasize          = undef
  $dm_datadev                   = undef
  $dm_metadatadev               = undef
  $manage_package               = true
  $manage_kernel                = true
  $package_name_default         = 'docker-engine'
  $service_name_default         = 'docker'
  $docker_command_default       = 'docker'
  $docker_group_default         = 'docker'
  case $::osfamily {
    'Debian' : {
      case $::operatingsystem {
        'Ubuntu' : {
          $package_release = "ubuntu-${::lsbdistcodename}"
          if (versioncmp($::operatingsystemrelease, '15.04') >= 0) {
            include docker::systemd_reload
          }
        }
        default: {
          $package_release = "debian-${::lsbdistcodename}"
          if (versioncmp($::operatingsystemmajrelease, '8') >= 0) {
            include docker::systemd_reload
          }
        }
      }

      $manage_epel = false
      $package_name = $package_name_default
      $service_name = $service_name_default
      $docker_command = $docker_command_default
      $docker_group = $docker_group_default
      $package_source_location = 'https://apt.dockerproject.org/repo'
      $package_key_source = 'https://apt.dockerproject.org/gpg'
      $package_key = '58118E89F3A912897C070ADBF76221572C52609D'
      $package_repos = 'main'
      $use_upstream_package_source = true
      $repo_opt = undef
      $nowarn_kernel = false

      if ($::operatingsystem == 'Debian' and versioncmp($::operatingsystemmajrelease, '8') >= 0) or ($::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemrelease, '15.04') >= 0) {
        $detach_service_in_init = false
      } else {
        $detach_service_in_init = true
      }

    }
    'RedHat' : {
      if (versioncmp($::operatingsystemrelease, '7.0') < 0) and $::operatingsystem != 'Amazon' {
        $package_name = 'docker-io'
        $use_upstream_package_source = false
        $manage_epel = true
      } elsif $::operatingsystem == 'Amazon' {
        $package_name = 'docker'
        $use_upstream_package_source = false
        $manage_epel = false
      } else {
        $package_name = $package_name_default
        $use_upstream_package_source = true
        $manage_epel = false
      }
      $package_key_source = 'https://yum.dockerproject.org/gpg'
      if $::operatingsystem == 'Fedora' {
        $package_source_location = "https://yum.dockerproject.org/repo/main/fedora/${::operatingsystemmajrelease}"
      } else {
        $package_source_location = "https://yum.dockerproject.org/repo/main/centos/${::operatingsystemmajrelease}"
      }
      $package_key = undef
      $package_repos = undef
      $package_release = undef
      $service_name = $service_name_default
      $docker_command = $docker_command_default
      if versioncmp($::operatingsystemrelease, '7.0') < 0 {
        $detach_service_in_init = true
        if $::operatingsystem == 'OracleLinux' {
          $docker_group = 'dockerroot'
        } else {
          $docker_group = $docker_group_default
        }
      } else {
        $detach_service_in_init = false
        if $use_upstream_package_source {
          $docker_group = $docker_group_default
        } else {
          $docker_group = 'dockerroot'
        }
        include docker::systemd_reload
      }

      # repo_opt to specify install_options for docker package
      if (versioncmp($::operatingsystemmajrelease, '7') == 0) {
        if $::operatingsystem == 'RedHat' {
          $repo_opt = '--enablerepo=rhel7-extras'
        } elsif $::operatingsystem == 'CentOS' {
          $repo_opt = '--enablerepo=extras'
        } elsif $::operatingsystem == 'OracleLinux' {
          $repo_opt = '--enablerepo=ol7_addons'
        } elsif $::operatingsystem == 'Scientific' {
          $repo_opt = '--enablerepo=sl-extras'
        } else {
          $repo_opt = undef
        }
      } elsif (versioncmp($::operatingsystemrelease, '7.0') < 0 and $::operatingsystem == 'OracleLinux') {
          # FIXME is 'public_ol6_addons' available on all OL6 installs?
          $repo_opt = '--enablerepo=public_ol6_addons,public_ol6_latest'
      } else {
        $repo_opt = undef
      }
      if $::kernelversion == '2.6.32' {
        $nowarn_kernel = true
      } else {
        $nowarn_kernel = false
      }
    }
    'Archlinux' : {
      include docker::systemd_reload
      $manage_epel = false
      $docker_group = $docker_group_default
      $package_key_source = undef
      $package_source_location = undef
      $package_key = undef
      $package_repos = undef
      $package_release = undef
      $use_upstream_package_source = false
      $package_name = 'docker'
      $service_name = $service_name_default
      $docker_command = $docker_command_default
      $detach_service_in_init = false
      $repo_opt = undef
      $nowarn_kernel = false
    }
    default: {
      $manage_epel = false
      $docker_group = $docker_group_default
      $package_key_source = undef
      $package_source_location = undef
      $package_key = undef
      $package_repos = undef
      $package_release = undef
      $use_upstream_package_source = true
      $package_name = $package_name_default
      $service_name = $service_name_default
      $docker_command = $docker_command_default
      $detach_service_in_init = true
      $repo_opt = undef
      $nowarn_kernel = false
    }
  }

  # Special extra packages are required on some OSes.
  # Specifically apparmor is needed for Ubuntu:
  # https://github.com/docker/docker/issues/4734
  $prerequired_packages = $::osfamily ? {
    'Debian' => $::operatingsystem ? {
      'Debian' => ['cgroupfs-mount'],
      'Ubuntu' => ['cgroup-lite', 'apparmor'],
      default  => [],
    },
    'RedHat' => ['device-mapper'],
    default  => [],
  }

}
