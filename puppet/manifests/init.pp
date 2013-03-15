node default {

    # Base packages
    package { ntp: ensure => installed }
    package { htop: ensure => installed }
    package { sysstat: ensure => installed }
    package { tmux: ensure => installed }
    #package { sqlite3: ensure => installed }
    #package { git-core: ensure => installed }
    #package { build-essential:  ensure => installed }
    #package { curl: ensure => installed }
    #package { libsqlite3-0: ensure => installed }
    #package { libsqlite3-dev: ensure => installed }
    #package { libzip-dev: ensure => installed }
    #package { libzip1: ensure => installed }
    #package { "libgtk2.0-dev": ensure => installed }
    #package { libwebkitgtk-dev: ensure => installed }
    #package { libssl-dev: ensure => installed }

    # Next two configs increase ulimit nofile
    file { "/etc/security/limits.conf":
        source  => "puppet:///modules/tilemill/limits.conf",
        replace => true,
    }

    # Setup tilemill user
    @user { tilemill:
        ensure => present,
        home => "/home/tilemill",
        shell => "/bin/bash",
    }
    realize(User[tilemill])
    file { "/home/tilemill":
        ensure => directory,
        owner => tilemill,
        group => tilemill,
    }
    file { "/home/tilemill/.tilemill":
        ensure => directory,
        owner => "tilemill",
        group => "tilemill",
    }
    file { "/home/tilemill/.tilemill/config.json":
	replace => false
        content => "puppet:///modules/tilemill/config.json"
    }

    # Nginx config
    file { "/etc/nginx/sites-available/tilemill":
        content => template("tilemill/tilemill-nginx.conf.erb"),
    }
    file { "/etc/nginx/sites-enabled/tilemill":
        ensure => "/etc/nginx/sites-available/tilemill",
        require => File["/etc/nginx/sites-available/tilemill"],
    }
    file { "/etc/nginx/sites-enabled/default":
        ensure => absent,
    }
    
    # Upstart config
    file { "/etc/init/tilemill.conf":
        source => "puppet:///modules/tilemill/tilemill-upstart.conf",
    }

}
