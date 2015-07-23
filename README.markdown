# iniconfig

Load INI-style configuration files with ease.

## Installation

    git clone http://github.com/silvamerica/iniconfig.git
    cd iniconfig
    gem build iniconfig.gemspec
    gem install iniconfig-X.X.X.gem
    
## Quickstart

    require 'rubygems'
    require 'iniconfig'
  
    CONFIG = IniConfig.load('path_to_config_file.ini')
  
    puts CONFIG.http.path
    => "/tmp/"
  
## Overrides

  You can define override values in your INI file like this:
  
    path = /tmp/
    path<ubuntu> = /ext/tmp/
    path<live> = /var/home/tmp/
  
  and enable or disable overrides with an optional array.  The last value of all active overrides or default values is chosen.
    CONFIG = IniConfig.load('path_to_config_file.ini', ["ubuntu", :live])

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself so I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 Nicholas Silva. See LICENSE for details.
