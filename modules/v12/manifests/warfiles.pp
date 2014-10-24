define v12::warfiles(
			$app_name,
			$war_file,
			$dest_path,
)
{
	file { "${dest_path}/webapps/${app_name}.war":
		source => "puppet:///puppet_shared_files/app_builds/${war_file}",
		ensure => file,
		show_diff => false,
		require => File["${dest_path}/webapps"],
		force => true,
#               notify => Exec["unzip SSW2010.server in ${dest_path}/webapps"],
	}

	exec { "${dest_path}/webapps/${app_name}/.extracted.puppet":
		subscribe => File["${dest_path}/webapps/${app_name}.war"],
		creates => "${dest_path}/webapps/${app_name}/.extracted.puppet",
		require => [
				File["${dest_path}/webapps/${app_name}.war"],
				Jdk["${dest_path}/jdk"],
			],
		path => "${dest_path}/jdk/bin:/bin",
		cwd => "${dest_path}/webapps",
		command => "rm -rf ${app_name} && mkdir ${app_name} && cd ${app_name} && jar xf ../${app_name}.war && touch .extracted.puppet",
	}

}
