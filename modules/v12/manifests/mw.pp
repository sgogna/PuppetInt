define v12::mw (
			$dest_path=$title,
			$tomcat_version,
			$jdk_version,
		)
{
	file { "${dest_path}":
		ensure => directory,
		require => File['/apps/v12'],
		mode => 750,
	}

	tomcat { "${dest_path}/tomcat":
		version => "${tomcat_version}",
		require => File ["${dest_path}"],
	}

	jdk { "${dest_path}/jdk":
		version => "${jdk_version}",
		require => File ["${dest_path}"],
	}
}

