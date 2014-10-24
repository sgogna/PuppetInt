define jdk(	$dest_path=$title,
		$version, )
{
	$major_version  = regsubst ($version , '^(\d+)u(\d+)$' , '\1')
	$update_version = regsubst ($version , '^(\d+)u(\d+)$' , '\2')

	file { "${dest_path}":
		ensure => directory,
		mode => 750,
	}

	file { "${dest_path}.tar.gz":
		source => "/apps/puppet_shared_files/jdk-${major_version}u${update_version}-linux-x64.gz",
		require => File["${dest_path}"],
	}

	exec { "${dest_path}/.extracted.puppet":
		subscribe => File["${dest_path}.tar.gz"],
		path => "/bin",
		cwd => "${dest_path}",
		command => "rm -rf ${dest_path}/* && tar --strip-components 1 -xf ${dest_path}.tar.gz -C ${dest_path} && touch ${dest_path}/.extracted.puppet",
		require => File["${dest_path}.tar.gz"],
		refreshonly=>true,
	}

	file { "${dest_path}/jre/lib/security/cacerts":
		source => "puppet:///modules/jdk/cacerts-${version}",
		require => Exec["${dest_path}/.extracted.puppet"],
	}

	file { "${dest_path}/jre/lib/security/local_policy.jar":
		source => "puppet:///modules/jdk/UnlimitedJCEPolicyJDK${major_version}/local_policy.jar",
		require => Exec["${dest_path}/.extracted.puppet"],
	}

	file { "${dest_path}/jre/lib/security/US_export_policy.jar":
		source => "puppet:///modules/jdk/UnlimitedJCEPolicyJDK${major_version}/US_export_policy.jar",
		require => Exec["${dest_path}/.extracted.puppet"],
	}

	augeas { "${dest_path}: enabled MD2 in java.security":
		incl => "${dest_path}/jre/lib/security/java.security",
		lens => 'Properties.lns',
		changes => ['set jdk.certpath.disabledAlgorithms "RSA keySize < 1024"'],
		require => Exec["${dest_path}/.extracted.puppet"],
	}
}

