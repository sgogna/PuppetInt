define tomcat($version , $dest_path = $title ) {

	file { "${dest_path}":
		ensure => directory,
		mode => 750,
	}

	file { "${dest_path}.tar.gz":
		source => "puppet:///puppet_shared_files/apache-tomcat-${version}.tar.gz",
		require => File["${dest_path}"],
	}

	exec { "${dest_path}.tar.gz extracted":
		creates => "$dest_path/.extracted.puppet",
		subscribe => File["${dest_path}.tar.gz"],
		path => "/bin",
		cwd => "${dest_path}",
		command => "rm -rf ${dest_path}/* &&  tar --strip-components 1 -xf ${dest_path}.tar.gz -C ${dest_path} && touch ${dest_path}/.extracted.puppet",
		require => File["${dest_path}.tar.gz"],
	}


	file { "${dest_path}/lib/catalina-jmx-remote.jar":
		source => "puppet:///modules/tomcat/catalina-jmx-remote.jar-${version}",
		require => Exec["${dest_path}.tar.gz extracted"],
	}

	file { "${dest_path}/bin/catalina.sh.patch":
		source => "puppet:///modules/tomcat/catalina.sh.patch",
		require => Exec["${dest_path}.tar.gz extracted"],
	}

	exec { "${dest_path}/bin/catalina.sh.patch":
		creates => "$dest_path/bin/catalina.sh.orig",
		subscribe => Exec["${dest_path}.tar.gz extracted"],
		path => "/usr/bin:/bin",
		cwd => "${dest_path}/bin",
		require => File["${dest_path}/bin/catalina.sh.patch"],
		command => "patch -Nb catalina.sh -i catalina.sh.patch",
	}

	file { "${dest_path}/server":
		source => "puppet:///modules/tomcat/eb2_classes/server",
		recurse => true,
		force => true,
		require => Exec["${dest_path}.tar.gz extracted"],
	}

	file { "${dest_path}/bin/rotatelogs":
		source => "puppet:///modules/tomcat/rotatelogs",
		require => Exec["${dest_path}.tar.gz extracted"],
	}

}

