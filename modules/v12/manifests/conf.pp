define v12::conf (
			$dest_path=$title,
			$inst_num,
			#$http_port=8080+$inst_num,
			#$https_port=8040+$inst_num,
			$v12_app_type,
			$h_v12_cluster,
		)
{
	$jmx_registry_port=$h_v12_cluster['jmx_registry_port']
	$jmx_server_port  =$h_v12_cluster['jmx_server_port']
	$http_port        =$h_v12_cluster['http_port']
	
	file { "${dest_path}/conf":
		source => "puppet:///modules/v12/v12_app_type/${v12_app_type}/conf",
		recurse => true,
		purge => true,
		force => true,
		require => File["${dest_path}"],
	}

	file { "${dest_path}/server.xml":
		content => template("v12/${v12_app_type}/server.xml.erb"),
		require => File[ "${dest_path}"],
	}

}

