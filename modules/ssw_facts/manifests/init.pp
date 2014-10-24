# author: Olgierd Wolodkiewicz

# custom_facts class is used to set custom facts on target node
# facts value are read from hiera tree. It takes 2-3 puppet client runs for them to be visible one the dashboard.
#
# === Parameters
# 
# [*custom_facts::env_type*] 

class ssw_facts () {
	# must be: int, cert, prod
	$env_type = hiera('ssw_facts::env_type')
	# must be: 1, 2, 3
	$env_tier = hiera('ssw_facts::tier')
	# must be: tcc, cdc
	#$env_datacenter = hiera('ssw_facts::datacenter')

	file { '/apps/puppet/facts/facts.d/ssw_facts.yaml':
		ensure => present,
		mode => 755,
		content => template('ssw_facts/custom.yaml.erb'),
		require => [File['/apps/puppet/facts/facts.d']],
	}
	file{	[	'/apps/puppet/facts/facts.d',
			'/apps/puppet/facts',
			'/home/res2/.facter',
		]:
		ensure => directory,
		mode => 755
	}

}
