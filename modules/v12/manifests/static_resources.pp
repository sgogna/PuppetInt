define v12::static_resources (
  $inst_num,
  $h_static_resources_config,
) {
    
  $base = "/apps/v12/inst${inst_num}"
  $dest_path = "${base}/static_content"
  $static_resources_dir = $h_static_resources_config['static_resources_dir']

  file { "$dest_path":
    ensure  => directory,
    require => File["$base"],
  }

  
  file { "$dest_path/prepare_static_resources.sh":
    content => template('v12/static_resources/prepare_static_resources.sh.erb'),
    mode    => "u=ru+x",
    require => File["$dest_path"],
  }


  exec { "Start generating static content for instance : ${inst_num}" :
    cwd => "$dest_path",
    path => "${dest_path}:${base}/jdk/bin:/bin",
    #subscribe => File["${dest_path}/webapps/${app_name}.war"],
    #creates => "${dest_path}/webapps/${app_name}/.extracted.puppet",
    require => [
      File["$dest_path/prepare_static_resources.sh"],
  #    File["${static_resources_dir}"],
      Jdk["${base}/jdk"],
    ],
    command => "prepare_static_resources.sh",
  }

}
