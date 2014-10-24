hiera_include('classes')

#Exec { path => "/usr/bin:/usr/sbin/:/bin:/sbin" }

node default {

        file { "/apps/tools":
                ensure => directory,
                mode => 750,
        }
	file {'/apps/mw':
		ensure => directory,
		mode => 750,
	}

}

$v12_instances = hiera('v12_instances', 'none')


if $v12_instances != 'none' {
	file { '/apps/v12':
		ensure => directory,
		mode => 750,
	}
	create_resources('v12',$v12_instances)
}

$s2_instances = hiera('s2_instances', 'none')
if $s2_instances != 'none' {
	file { '/apps/s2':
		ensure => directory,
		mode => 750,
	}
	create_resources('s2',$s2_instances)
}

$jdk_mw = hiera('jdk_mw', 'none')
if $jdk_mw !='none' {
	create_resources('jdk',$jdk_mw)
}

$tomcat_mw = hiera('tomcat_mw', 'none')
if $tomcat_mw !='none' {
	create_resources('tomcat',$tomcat_mw)
}
