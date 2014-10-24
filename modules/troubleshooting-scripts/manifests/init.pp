#author: Olgierd Wolodkiewicz
class troubleshooting-scripts($version) {
	# create home for troubleshooting-scripts
	file { '/apps/tools/troubleshooting-scripts':
		ensure => directory,
	} ~>
	# download new tgz
	file { '/apps/tools/troubleshooting-scripts.tgz':
		source => "/apps/puppet_shared_files/troubleshooting-scripts/troubleshooting-scripts-${version}.tgz",
	} ~>
	# simple wipe on demand of home for the troubleshooting-scripts
	exec { 'rm -rf /apps/tools/troubleshooting-scripts/*':
		cwd => '/apps/tools/troubleshooting-scripts',
		refreshonly => true,
		path => '/usr/bin:/bin',
	}

	#extract on 'subscribe' conditions and make sure requirements are in place: tgz, home_dir, wipe of home_dir (refresh)
	exec { 'tar xfz /apps/tools/troubleshooting-scripts.tgz':
		cwd => '/apps/tools',
		path => '/usr/bin:/bin',
		subscribe =>	[
					File['/apps/tools/troubleshooting-scripts'],
					Exec['rm -rf /apps/tools/troubleshooting-scripts/*'],
				],
		require =>	[
					File['/apps/tools/troubleshooting-scripts'],
					Exec['rm -rf /apps/tools/troubleshooting-scripts/*'],
				],
		unless => "fgrep ${version} troubleshooting-scripts/collect-troubleshooting-data.sh",
	}

}
