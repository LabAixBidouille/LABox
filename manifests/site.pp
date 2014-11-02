

class base {
	# Ship our sources.list with all the pockets (especially multiverse)
	# enabled so that we can install virtualbox dkms packages.
	file { 'apt sources.list':
	path => "/etc/apt/sources.list.d/00default-${operatingsystemrelease}.list",
	ensure => present,
	mode => 0644,
	owner => root,
	group => root,
	source => "/vagrant/files/apt/sources-${operatingsystemrelease}.list",
	before => Exec['apt_update'],
	}
	
	class { 'apt':
		always_apt_update    => true,
		
	}
	
	exec { 'apt-get dist-upgrade':
		require => Exec['apt_update'],
		command => '/usr/bin/apt-get dist-upgrade --yes',
		timeout => 3600,
	}
}

class grub {
  file { 'grub configuration':
    path    => '/etc/default/grub',
    ensure  => present,
    mode    => 0644,
    owner   => root,
    group   => root,
    source  => '/vagrant/files/grub/grub',
  }
  exec { 'update-grub':
    require => File['grub configuration'],
    command => '/usr/sbin/update-grub',
  }
}

class virtualbox_x11 {
  package {
      "virtualbox-guest-dkms": ensure => installed, require => Exec['apt_update'];
      "virtualbox-guest-x11": ensure => installed, require => Exec['apt_update'];
  }
}

class unity_desktop {
  package { "ubuntu-desktop":
    ensure => present,
    install_options => ['--no-install-recommends'],
  }
  file { 'lightdm.conf':
    require => Package['ubuntu-desktop'],
    path    => '/etc/lightdm/lightdm.conf',
    ensure  => present,
    mode    => 0644,
    owner   => root,
    group   => root,
    content => "[SeatDefaults]\ngreeter-session=unity-greeter\nuser-session=ubuntu\nautologin-user=vagrant\n"
  }
  service { 'lightdm':
    require => File['lightdm.conf'],
    ensure  => running,
  }
  
  class { 'timezone':
    timezone => 'Europe/Paris',
  }
  
  class { 'keyboard':
    layout  => 'fr',
  }
  
  dconf::set { "/com/canonical/unity/launcher/favorites": 
  		value => "['nautilus-home.desktop', 'ubuntu-software-center.desktop', 'gnome-control-center.desktop', 'gnome-terminal.desktop', 'firefox.desktop', 'arduino.desktop', 'codelite.desktop']",
	    user => "vagrant",
	    group => "vagrant",
		require => [Package['arduino', 'ubuntu-desktop'], Exec['install codelite']],
		notify  => Service["lightdm"],
  }
  
  dconf::set { "/org/gnome/desktop/input-sources/sources":
          value => "[('xkb', 'fr'), ('xkb', 'fr+mac')]",
		  user => "vagrant",
		  group => "vagrant",
		  notify  => Service["lightdm"],
  }
}

class arduino {
	user { 'vagrant':
		name                 => 'vagrant',
		ensure               => 'present',
		allowdupe            => false,
		comment              => 'Embedded Developer',
		expiry               => 'absent',
		groups               => 'dialout',
		managehome           => true,
	}

	package { 'arduino-core':
		ensure => 'present',
		require => User['vagrant'],
	}

	package { 'arduino':
		ensure => 'present',
		notify  => Service["lightdm"],
		require => Package['arduino-core'],
	}
}

class openocd {
	vcsrepo { "/usr/src/openocd":
	  ensure   => present,
	  provider => git,
	  source   => "https://github.com/ntfreak/openocd.git",
	  before   => Exec['compile openocd'],
	  require  => Package['git'],
	}
	
	package { 'libhidapi-dev':
		ensure => 'present',
	}
	
	package { 'libusb-1.0-0-dev':
		ensure => 'present',
	}
	
	package { 'libusb-dev':
		ensure => 'present',
	}
	
	package { 'libtool':
		ensure => 'present',
	}
	
	package { 'autotools-dev':
		ensure => 'present',
	}
	
	package { 'automake':
		ensure => 'present',
	}
	
	User<| title == 'vagrant' |> { 
		groups +> 'plugdev',
		notify  => Service["lightdm"],
	}
	
    file { 'openocd.rules':
      path    => '/etc/udev/rules.d/99-openocd.rules',
      ensure  => present,
      mode    => 0644,
      owner   => root,
      group   => root,
      source  => "/usr/local/share/openocd/contrib/99-openocd.rules",
	  require   => [Exec['install openocd']],
    }

    exec {
         'compile openocd':
             command   => "/bin/sh -c 'cd /usr/src/openocd && ./bootstrap && ./configure --enable-stlink --enable-jlink --enable-ftdi  --enable-cmsis-dap &&make'",
             user      => 'root',
			 subscribe => Vcsrepo["/usr/src/openocd"],
			 require   => [Package['build-essential','libhidapi-dev', 'libusb-1.0-0-dev', 'libusb-dev', 'libtool', 'autotools-dev', 'automake']],
			 refreshonly => true,
	     ;
         'install openocd':
             command   => "/bin/sh -c 'cd /usr/src/openocd && make install'",
			 creates   => "/usr/local/bin/openocd",
             user      => 'root',
			 require   => [Exec['compile openocd']],
			 refreshonly => true
	     ;
         'install openocd rules reload':
             command   => "/bin/sh -c 'udevadm control --reload-rules'",
             user      => 'root',
			 refreshonly => true,
			 require   => [Exec['install openocd']],
			 subscribe => [Exec['install openocd'], File['openocd.rules']],
			 notify    => Service["lightdm"],
	     ;
	}
}

class codelite{
	package { "libgtk2.0-dev":
		ensure => "installed"
	}
	
	package { "pkg-config":
		ensure => "installed"
	}
	
	package { "cmake":
		ensure => "installed"
	}
	
	package { "libssh-dev":
		ensure => "installed"
	}
	
	package { "libwxgtk3.0-0":
		ensure => "installed"
	}
	
	package { "libwxgtk3.0-dev":
		ensure => "installed"
	}
	
	vcsrepo { "/usr/src/codelite":
	  ensure   => present,
	  provider => git,
	  source   => "https://github.com/eranif/codelite.git",
	  before   => Exec['compile codelite'],
	  require  => Package['git'],
	}
	
    exec { 
		 'compile codelite':
             command   => "/bin/sh -c 'cd /usr/src/codelite && rm -rf  build-release&&mkdir build-release && cd build-release && cmake -G \"Unix Makefiles\" -DCMAKE_BUILD_TYPE=Release .. && make -j4'",
             user      => 'root',
			 require   => [Package['libgtk2.0-dev', 'pkg-config', 'build-essential', 'cmake', 'libssh-dev', 'libwxgtk3.0-dev', 'libwxgtk3.0-0'], Vcsrepo[ "/usr/src/codelite"]],
			 creates   => "/usr/src/codelite/build-release",
			 timeout   => 3600,
			 refreshonly => true,
			 subscribe => Vcsrepo["/usr/src/openocd"],
	     ;
         'install codelite':
             command   => "/bin/sh -c 'cd /usr/src/codelite/build-release && make install'",
             user      => 'root',
			 require   => [Exec['compile codelite']],
			 refreshonly => true,
			 subscribe => Vcsrepo["/usr/src/openocd"],
	     ;
	}
}

class devtools {
	package { 'build-essential':
		ensure => 'present',
	}
	
	package {'gdb':
		ensure => 'present',
	}
	
	package { 'git':
		ensure => 'present',
	}
	
	package { 'vim':
		ensure => 'present',
	}
	package { 'moserial':
		ensure => 'present',
	}
}

class gcc-arm-none-eabi {	
	package { 'gcc-arm-none-eabi':
		ensure => 'present',
		require => Package['build-essential'],
	}
    $apt_conf_d = $apt::params::apt_conf_d
   	file { "${apt_conf_d}/20ForceOverwrite":
   		ensure => 'present',
   	 	content => 'Dpkg::Options {"--force-confdef"; "--force-confold"; "--force-overwrite";}',
   	 	owner => root,
   	 	group => root,
   	 	mode => '0644',
		before => Package['gdb-arm-none-eabi'],
   	}
	package { 'gdb-arm-none-eabi':
		ensure          => 'present',
		require         => Package['gcc-arm-none-eabi','gdb'],
		provider => 'apt',
	}
    exec {'rm gbd workaround':
        command   => "/bin/sh -c 'rm -f ${apt_conf_d}/20ForceOverwrite'",
        user      => 'root',
		onlyif    => "/usr/bin/test -e ${apt_conf_d}/20ForceOverwrite",
		require   => [Package['gdb-arm-none-eabi']],
	}	
}

class java {
	apt::ppa { 'ppa:webupd8team/java': 
		before => Package["oracle-java8-installer"]
	}
	
	exec { "auto_accept_license":
		command => "echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections",
		path => "/bin:/usr/bin",
		before => Package["oracle-java8-installer"],
		onlyif => 'debconf-get-selections | grep "shared/accepted-oracle-license-v1-1"| grep "select true"',
	}
	
	package { "oracle-java8-installer":
		ensure => "installed"
	}
	
	package { "oracle-java8-set-default": 
		ensure => "installed", 
		require => Package["oracle-java8-installer"]
	}
}

class screensaver_settings {
  exec {
      'disable screensaver when idle':
          command   => "/bin/sh -c 'DISPLAY=:0 dconf write /org/gnome/desktop/screensaver/idle-activation-enabled false'",
          unless    => "/bin/sh -c 'test $(DISPLAY=:0 dconf read /org/gnome/desktop/screensaver/idle-activation-enabled) = false'",
          require   => [Package['dconf-tools', 'ubuntu-desktop'], Service['lightdm']],
          user      => 'vagrant',
          tries     => 3,
          try_sleep => 5,
       ;
      'disable screensaver lock':
          command   => "/bin/sh -c 'DISPLAY=:0 dconf write /org/gnome/desktop/screensaver/lock-enabled false'",
          unless    => "/bin/sh -c 'test $(DISPLAY=:0 dconf read /org/gnome/desktop/screensaver/lock-enabled) = false'",
          require   => [Package['dconf-tools', 'ubuntu-desktop'], Service['lightdm']],
          user      => 'vagrant',
          tries     => 3,
          try_sleep => 5,
       ;
      'disable screensaver lock after suspend':
          command   => "/bin/sh -c 'DISPLAY=:0 dconf write /org/gnome/desktop/screensaver/ubuntu-lock-on-suspend false'",
          unless    => "/bin/sh -c 'test $(DISPLAY=:0 dconf read /org/gnome/desktop/screensaver/ubuntu-lock-on-suspend) = false'",
          require   => [Package['dconf-tools', 'ubuntu-desktop'], Service['lightdm']],
          user      => 'vagrant',
          tries     => 3,
          try_sleep => 5,
       ;
       'set idle delay to zero':
          command   => "/bin/sh -c 'DISPLAY=:0 dconf write /org/gnome/session/idle-delay 0'",
          unless    => "/bin/sh -c 'test $(DISPLAY=:0 dconf read /org/gnome/session/idle-delay) = 0'",
          require   => [Package['dconf-tools', 'ubuntu-desktop'], Service['lightdm']],
          user      => 'vagrant',
          tries     => 3,
          try_sleep => 5,
       ;
       'set idle delay to zero (2)':
          command   => "/bin/sh -c 'DISPLAY=:0 dconf write /org/gnome/desktop/session/idle-delay 0'",
          unless    => "/bin/sh -c 'test $(DISPLAY=:0 dconf read /org/gnome/desktop/session/idle-delay) = 0'",
          require   => [Package['dconf-tools', 'ubuntu-desktop'], Service['lightdm']],
          user      => 'vagrant',
          tries     => 3,
          try_sleep => 5,
       ;
       'disable monitor sleep on AC':
          command   => "/bin/sh -c 'DISPLAY=:0 dconf write /org/gnome/settings-daemon/plugins/power/sleep-display-ac 0'",
          unless    => "/bin/sh -c 'test $(DISPLAY=:0 dconf read /org/gnome/settings-daemon/plugins/power/sleep-display-ac) = 0'",
          require   => [Package['dconf-tools', 'ubuntu-desktop'], Service['lightdm']],
          user      => 'vagrant',
          tries     => 3,
          try_sleep => 5,
       ;
       'disable monitor sleep on battery':
          command   => "/bin/sh -c 'DISPLAY=:0 dconf write /org/gnome/settings-daemon/plugins/power/sleep-display-battery 0'",
          unless    => "/bin/sh -c 'test $(DISPLAY=:0 dconf read /org/gnome/settings-daemon/plugins/power/sleep-display-battery) = 0'",
          require   => [Package['dconf-tools', 'ubuntu-desktop'], Service['lightdm']],
          user      => 'vagrant',
          tries     => 3,
          try_sleep => 5,
       ;
       'disable remind-reload query':
          command   => "/bin/sh -c 'DISPLAY=:0 dconf write /apps/update-manager/remind-reload false'",
          unless    => "/bin/sh -c 'test $(DISPLAY=:0 dconf read /apps/update-manager/remind-reload) = false'",
          require   => [Package['dconf-tools', 'ubuntu-desktop'], Service['lightdm']],
          user      => 'vagrant',
          tries     => 3,
          try_sleep => 5,
       ;
  }
}

include base
include grub
include devtools
include java
include gcc-arm-none-eabi
include openocd
include virtualbox_x11
include unity_desktop
include arduino
include codelite
include screensaver_settings
