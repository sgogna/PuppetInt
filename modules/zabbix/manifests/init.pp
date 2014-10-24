#author: Olgierd Wolodkiewicz
class zabbix::agent ($version="2.2.5") {
	file { "/apps/tools/zabbix_agent/zabbix_agentd":
		source  => "puppet:///puppet_shared_files/zabbix/zabbix_agentd-${version}-rhel${operatingsystemmajrelease}",
		mode    => "u=rwx,g=r,o=",
		require =>  File['/apps/tools/zabbix_agent'],
		notify  => Service["zabbix_agent"],
	}

	file { "/apps/tools/zabbix_agent/zabbix_agentd.conf":
		content => template("zabbix/zabbix_agentd.conf.erb"),
		mode    => "ug=r,o=",
		require => File["/apps/tools/zabbix_agent/zabbix_agentd"],
		notify  => Service["zabbix_agent"],
	}

	file { "/apps/tools/zabbix_agent":
		ensure => directory,
		mode   => "u=rwx,g=rx,o=",
	}

	service { 'zabbix_agent':
		ensure    => running,
		provider  => base,
		hasstatus => true,
		start     => "pkill zabbix_agentd;/apps/tools/zabbix_agent/zabbix_agentd -c /apps/tools/zabbix_agent/zabbix_agentd.conf",
		stop      => "pkill zabbix_agentd",
		status    => 'pgrep -f "/apps/tools/zabbix_agent/zabbix_agentd -c /apps/tools/zabbix_agent/zabbix_agentd.conf"|grep `cat /tmp/zabbix_agentd.pid`',
	}
}
