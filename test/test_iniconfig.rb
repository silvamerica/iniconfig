require 'helper'

class TestIniconfig < Test::Unit::TestCase
  context "an ini file" do
    should_fail_to_load_if "a line exists before a section is defined", "fail_no_section.ini"
    should_fail_to_load_if "a section name starts with a number", "fail_section_starts_with_number.ini"
    should_fail_to_load_if "a key starts with a number", "fail_key_starts_with_number.ini"
    should_fail_to_load_if "a line has no key", "fail_no_key.ini"
    should_fail_to_load_if "a line isn't a section, key, or comment", "fail_bad_line.ini"
    should_fail_to_load_if "a section name is missing a bracket", "fail_missing_bracket.ini"
    should_fail_to_load_if "an override key is missing an angle bracket", "fail_missing_angle_bracket.ini"  
  end
  
  context "a valid ini file" do
    setup do
      @config = IniConfig.load('test/samples/valid.ini')
    end
    
    should "return integers as Integer classes" do 
      assert @config.common.basic_size_limit.is_a? Integer
    end
    
    should "return boolean classes for yes, no, true, false values" do
      assert @config.ftp.enabled.is_a? FalseClass
      assert @config.ftp.restricted.is_a? TrueClass
      assert @config.ftp.giant.is_a? FalseClass
      assert @config.ftp.valid.is_a? TrueClass
    end
    
    should "return escaped strings if a value is quoted" do
      assert_equal @config.ftp.name, "hello there, ftp uploading"
      assert_equal @config.http.inline, "this is an ;inline comment inside a string"
    end
    
    should "return an array for comma-separated values" do
      assert @config.http.params.is_a? Array
    end
    
    should "return a symbol for a value preceded by a colon" do
      assert @config.http.authentication.is_a? Symbol
    end
    
    should "ignore comments at the end of a line" do
      assert_equal @config.common.paid_users_size_limit, 2147483648
    end
    
  end
  
  context "an ini file loaded with overrides" do
    setup do
      @config = IniConfig.load('test/samples/valid.ini', ["ubuntu", :live])
    end
    
    should "use override values" do
      assert_equal @config.ftp.path, "/etc/var/uploads"
      assert_equal @config.http.path, "/box/var/tmp/"
    end
  end
  
  context "a config object" do
    setup do
      @config = IniConfig.load('test/samples/valid.ini')
    end
    
    should "respond to method calls" do
      assert_not_nil @config.common.basic_size_limit
    end
    
    should "respond to hash calls" do
      assert_not_nil @config.common[:basic_size_limit]
    end
    
    should "return a hash object for a section" do
      assert @config.common.is_a? Hash
    end
    
    should "return a hash for an undefined section" do
      assert @config.undefined.is_a? Hash
    end
    
    should "return nil for undefined values inside a section" do
      assert_nil @config.common.undefined
    end
    
    should "return nil for any value in an undefined section" do
      assert_nil @config.undefined.undefined
    end
  end
end
