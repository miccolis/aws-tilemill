# Base packages
package { ntp: ensure => installed }
package { nginx: ensure => installed }

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
    content => template("tilemill/tilemill-config.json"),
    owner => "tilemill",
    group => "tilemill",
    replace => false,
}

# Nginx config
file { "/etc/nginx/sites-available/tilemill":
    content => template("tilemill/tilemill-nginx.conf.erb"),
    require => [ Package["nginx"], Service["tilemill"] ],
}
file { "/etc/nginx/sites-enabled/tilemill":
    ensure => "/etc/nginx/sites-available/tilemill",
    require => File["/etc/nginx/sites-available/tilemill"],
    notify => Service["nginx"],
}
file { "/etc/nginx/sites-enabled/default":
    ensure => absent,
}
service { "nginx":
    provider => "init",
    ensure => "running",
    hasrestart => true,
}

# TileMill config
file { "/etc/init/tilemill.conf":
    content => template("tilemill/tilemill-upstart.conf.erb")
}

service { "tilemill":
    provider => "upstart",
    ensure => "running",
    enable => true,
    require => File["/home/tilemill/.tilemill/config.json"],
}
