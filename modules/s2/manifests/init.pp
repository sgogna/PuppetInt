#author: Olgierd Wolodkiewicz

define s2 (
		$inst_name=$title,	#name of instance used to create directory
		$inst_num,		#to calculate ports
		$s2_cluster,		#cluster name with common settings to use like s2_app_build, environment
		$ensure,		#status of service
)
{
	$dest_path	= "/apps/s2/${inst_name}"					# string value with destination path to deploy whole package
	$h_s2_cluster	= hiera('s2_cluster','none',"s2/cluster/${s2_cluster}")		# hash with config from hiera/s2/cluster/NAME.yaml to read cluster configuration
	$s2_app_build	= $h_s2_cluster['s2_app_build']					# string with s2_app_build in hiera/s2/appbuild/NAME.yaml
	$s2_logdir_base = $h_s2_cluster['logdir_base']
	$h_s2_app_build = hiera('s2_app_build','none',"s2/app_build/$s2_app_build")	# hash with app_build definition

        file { "${dest_path}":
                ensure => directory,
                require => File['/apps/s2'],
                mode => 750,
        } ->
	jdk { "$dest_path/jdk":
		version => $h_s2_app_build['jdk_version'],
	}

	$s2_package  = $h_s2_app_build['s2_package']	# name of tar.gz file to uncompress
	$s2_app_name = $h_s2_app_build['s2_app_name']	# name of directory to create to uncompress package

	file { "${dest_path}/${s2_app_name}.tar.gz":
		source => "/apps/puppet_shared_files/app_builds/${s2_package}",
		require => File["${dest_path}"],		
	} ->
	file { "${dest_path}/${s2_app_name}":
		ensure => directory,
	} 
	exec { "$dest_path/${s2_app_name}":
		#creates => "${dest_path}/${s2_app_name}/.extracted.puppet",
		subscribe =>	[
					File["${dest_path}/${s2_app_name}"],
					File["${dest_path}/${s2_app_name}.tar.gz"],
				],
		require => File["${dest_path}/${s2_app_name}"],
		cwd => "${dest_path}",
		path => "/bin",
		command => "rm -rf ${s2_app_name}/* && tar --strip-components 1 -xf ${s2_app_name}.tar.gz -C ${dest_path}/${s2_app_name} && touch ${s2_app_name}/.extracted.puppet",
		refreshonly => true,
		notify => Service["${dest_path}"],
	}

	file { "${s2_logdir_base}/${s2_cluster}/${hostname}-${inst_name}":
		ensure => directory,
		mode => 744,
	}

	file { "${dest_path}/${s2_app_name}/logs":
		ensure => link,
		target => "${s2_logdir_base}/${s2_cluster}/${hostname}-${inst_name}",
		force => true,
		require =>	[
					File["${s2_logdir_base}/${s2_cluster}/${hostname}-${inst_name}"],
					Exec["${dest_path}/${s2_app_name}"],
				]
	}

	$service_http_port=		8180+$inst_num			#http port of service (application port)
	$service_jmx_registry_port=	9000+$inst_num			#JMX/RMI port to connect via jconsole
	$service_jmx_port=		9100+$inst_num			#2nd JMX/RMI port, to add to firewall
	$service_shutdown_port=		8000+$inst_num			#catalina shutdown port
	$service_jmx_http_port=		8010+$inst_num			#JMX over http port to connect via wget/curl
	$service_environment=		$h_s2_cluster['environment']	#environment set of params: int, cert, prod.... depends on what is included in S2 container
        file { "${dest_path}/tomcat.sh":
                content => template("s2/tomcat.sh.erb"),
                require => File[ "${dest_path}"],
		mode    => 744,
	}


	service { "$dest_path":
		provider  => base,
		start     => "${dest_path}/tomcat.sh start",
		stop      => "${dest_path}/tomcat.sh stop",
		#status    => "${dest_path}/tomcat.sh status",
		hasstatus => false,
		hasrestart=> false,
		ensure    => $ensure,
		pattern   => "$dest_path/jdk/bin/java",
		require   =>	[
					File["${dest_path}/${s2_app_name}/logs"],
					Jdk["${dest_path}/jdk"],
					File["${dest_path}/tomcat.sh"],
				],
		subscribe =>	[
					Exec["${dest_path}/${s2_app_name}"],
					Jdk["${dest_path}/jdk"],
				],
	}
}
