name              'appdynamics-agent-linux'
version           '0.4.0'
maintainer        'IBM'
description       'Installs and configures AppDynamics agents'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
  
depends 'windows', '>= 1.44.3'
depends 'python', '~> 1.4.6'
depends 'java', '~> 1.42.0'
depends 'apt', '~> 3.0.0'
depends 'powershell', '~> 3.0.0'
depends 'ark', '~> 1.1.0'

# Red Hat
supports 'amazon'
supports 'centos'
supports 'fedora'
supports 'oracle'
supports 'redhat'
supports 'scientific'

# Debian
supports 'debian'
supports 'linuxmint'
supports 'ubuntu'

# Mac
supports 'mac_os_x'
supports 'mac_os_x_server'

# Windows
supports 'mswin'
supports 'windows'
