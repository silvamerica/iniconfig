require 'rubygems'
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'iniconfig'

class Test::Unit::TestCase
  class << self
    def should_fail_to_load_if(failure, file)
      should "fail to load if #{failure}" do 
        assert_raise Exception do
          config = IniConfig.load(File.join("test", "samples", file))
        end
      end
    end
  end
end
