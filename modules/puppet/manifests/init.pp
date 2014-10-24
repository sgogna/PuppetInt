#author: Olgierd Wolodkiewicz
class puppet::agent_cronjobs {
	cron { 'puppet':
		ensure => present,
		command => '/apps/puppet/bin/puppet agent --no-daemonize --onetime --config /apps/puppet/etc/puppet/puppet.conf --logdest /apps/puppet-var/logs/agent.log >/dev/null 2>&1',
		minute => '*/10',
	}
}

class puppet($version) {
	#upgrade agent automatically except PuppetMasters
	if $hostname!="sswhli491" and $hostname!="sswhli492" {
		file { "/apps/puppet-installer.sh":
			source => "/apps/puppet_shared_files/puppet/installer-puppet-${version}.sh",
			show_diff => false,
		}

		exec { "/apps/puppet-installer.sh ssw-int":
			refreshonly => true,
			require     => File["/apps/puppet-installer.sh"],
			subscribe   => File["/apps/puppet-installer.sh"],
		}
	}
	#todo wipe/purge old versions
	include puppet::agent_cronjobs
}
