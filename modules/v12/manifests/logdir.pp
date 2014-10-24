define v12::logdir (
		$dest_path=$title,
		$inst_name,
		$v12_cluster,
	)
{


	file { "${dest_path}/logs/":
		ensure => directory,
		mode => 744,
		require => File["${dest_path}"],
	}

#	file { "${dest_path}/logs/int":
#		ensure => directory,
#		mode => 744,
#		require => File["${dest_path}/logs"],
#	}
#
#	file { "${dest_path}/logs/int/${v12_cluster}":
#		ensure => directory,
#		mode => 744,
#		require => File["${dest_path}/logs/int"],
#	}
#
#	file { "${dest_path}/logs/int/${v12_cluster}/${hostname}-${inst_name}":
#		ensure => directory,
#		mode => 744,
#		require => File["${dest_path}/logs/int/${v12_cluster}"],
#	}
#
#	file { "${dest_path}/logs":
#		ensure => link,
#		target => "/logs/int/${v12_cluster}/${hostname}-${inst_name}",
#		force => true,
#		require => File["${dest_path}/logs/int/${v12_cluster}/${hostname}-${inst_name}"],
#	}

	file { "${dest_path}/work_dir":
		ensure => directory,
		mode => 744,
		require => File["${dest_path}"],
	}
}

