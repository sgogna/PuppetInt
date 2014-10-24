define v12 (
		$inst_name=$title,
		$inst_num,
		$v12_cluster,
		$ensure,
)
{
	$dest_path       = "/apps/v12/${inst_name}"
	$h_v12_cluster   = hiera('v12_cluster','none',"v12/cluster/${v12_cluster}")
	$v12_app_build   = $h_v12_cluster['v12_app_build']
	$h_v12_app_build = hiera('v12_app_build','none',"v12/app_build/$v12_app_build")


    $v12_databases = $h_v12_cluster['v12_databases']
    $v12_static_resources = $h_v12_cluster['v12_static_resources']

    $h_databases = hiera('databases','none',"databases/${v12_databases}")

#    $h_db_patch_executor = hiera('db_patch_executor','none',"databases/${v12_databases}")
#
#
#    if $h_db_patch_executor != 'none' {
#      v12::db_patch { "db_patch for instance: ${inst_num}":
#          inst_num => $inst_num,
#          h_db_patch_executor => $h_db_patch_executor,
#          h_databases => $h_databases,
#      }
#    }


#    $h_static_resources_config = hiera('static_resources_config','none',"v12/static_resources/${v12_static_resources}")
#    
#    if $h_static_resources_config != 'none' {
#      v12::static_resources { "static_resources for instance: ${inst_num}":
#          inst_num => $inst_num,
#          h_static_resources_config => $h_static_resources_config,
#      }
#    }

	v12::mw { "$dest_path":
		tomcat_version => $h_v12_app_build['tomcat_version'],
		jdk_version    => $h_v12_app_build['jdk_version'],
	}

	v12::conf { "$dest_path":
		v12_app_type  => $h_v12_cluster['v12_app_type'],
		inst_num      => $inst_num,
		h_v12_cluster => $h_v12_cluster,
	}

    v12::databases { "Data base for ${dest_path}":
        dest_path       => $dest_path,
        inst_num        => $inst_num,
        h_databases     => $h_databases,
        v12_app_type    => $h_v12_cluster['v12_app_type'],
    }

	$warfiles=$h_v12_app_build['warfiles']
	$warfile1=$warfiles['war1']
	if $warfile1 {
		v12::warfiles { "$dest_path/webapps/war1":
			app_name  => $warfile1['app_name'],
			war_file  => $warfile1['war_file'],
		dest_path => $dest_path,
		}
	}
	$warfile2=$warfiles['war2']
	if $warfile2 {
		v12::warfiles { "$dest_path/webapps/war2":
			app_name  => $warfile2['app_name'],
			war_file  => $warfile2['war_file'],
			dest_path => $dest_path,
		}
	}
	#have to work on below method instead of above
#	create_resources('v12::warfiles',$warfiles, { dest_path => $dest_path })
	
	file { "${dest_path}/webapps":
		ensure  => directory ,
		require => File["${dest_path}"],
		mode    => 744,
	}

	file { "${dest_path}/webapps/ROOT":
		source  => "puppet:///modules/v12/ROOT",
		recurse => true,
		purge   => true,
		force   => true,
		require => File["${dest_path}/webapps"],
	}

	file { "${dest_path}/appconf":
		source  => "puppet:///modules/v12/v12_appconf/${v12_cluster}/appconf",
		recurse => true,
		purge   => true,
		force   => true,
		require => File["${dest_path}"],
	}

	$catalina_opts = $h_v12_app_build['catalina_opts']

	file { "${dest_path}/tomcat.sh":
		content => template("v12/tomcat.sh.erb"),
		require => File[ "${dest_path}"],
		mode    => "u+x",
		owner   => res2,
		group   => res,
	}

	v12::service { "$dest_path":
		ensure => 'running',
	}

	v12::logdir { "$dest_path":
		inst_name => $inst_name,
                v12_cluster => $v12_cluster,
	}

}

