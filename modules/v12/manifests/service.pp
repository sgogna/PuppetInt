define v12::service (
			$dest_path=$title,
			$ensure
)
{
	if $ensure == 'running' or $ensure == 'stopped' {
		service { "$dest_path":
			provider  => 'base',
			require   => File["${dest_path}/conf"],
			ensure    => $ensure,
			hasstatus => true,
			start     => "${dest_path}/tomcat.sh start",
			stop      => "${dest_path}/tomcat.sh stop",
			status    => "${dest_path}/tomcat.sh check",
		}
	}
}

