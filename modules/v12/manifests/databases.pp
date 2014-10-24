define v12::databases (
  $dest_path,
  $inst_num,
  $h_databases,
  $v12_app_type,
)
{

  file { "${dest_path}/appconf/configured-airlines-environment.properties":
    content => template("v12/${v12_app_type}/configured-airlines-environment.properties.erb"),
    require => File[ "${dest_path}"],
  }

}
