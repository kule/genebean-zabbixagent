# Manages configuration of the Zabbix agent and associated repos (if enabled)
class zabbixagent::config (
  $hostname       = $::zabbixagent::params::hostname,
  $servers        = $::zabbixagent::params::servers,
  $servers_active = $::zabbixagent::params::servers,
) inherits ::zabbixagent::params {
  case $::kernel {
    'Linux'   : {
      $config_dir  = '/etc/zabbix'
      
      file { "${config_dir}/zabbix_agentd.d":
        ensure => 'directory',
      }
    
      ini_setting { 'include setting':
        ensure  => present,
        path    => "${config_dir}/zabbix_agentd.conf",
        section => '',
        setting => 'Include',
        value   => "${config_dir}\\zabbix_agentd.d",
        notify  => Service['zabbix-agent'],
      }
    }

    'Windows' : {
      $config_dir  = 'C:/Program Files/Zabbix Agent'
      
      file { 'C:/ProgramData/Zabbix':
        ensure => 'directory',
      }
    
      file { 'C:/ProgramData/Zabbix/zabbix_agentd.d':
        ensure  => 'directory',
        require => File['C:/ProgramData/Zabbix'],
      }
    
      ini_setting { 'include setting':
        ensure  => present,
        path    => "${config_dir}/zabbix_agentd.conf",
        section => '',
        setting => 'Include',
        value   => "C:\\ProgramData\\Zabbix\\zabbix_agentd.d\\*.conf",
        notify  => Service['zabbix-agent'],
      }
    }

    default   : {
      fail($::zabbixagent::params::fail_message)
    }
  }

  ini_setting { 'servers setting':
    ensure  => present,
    path    => "${config_dir}/zabbix_agentd.conf",
    section => '',
    setting => 'Server',
    value   => join(flatten([$servers]), ','),
    notify  => Service['zabbix-agent'],
  }

  ini_setting { 'servers active setting':
    ensure  => present,
    path    => "${config_dir}/zabbix_agentd.conf",
    section => '',
    setting => 'ServerActive',
    value   => join(flatten([$servers_active]), ','),
    notify  => Service['zabbix-agent'],
  }

  ini_setting { 'hostname setting':
    ensure  => present,
    path    => "${config_dir}/zabbix_agentd.conf",
    section => '',
    setting => 'Hostname',
    value   => $hostname,
    notify  => Service['zabbix-agent'],
  }
}
