require 'spec_helper'

describe "SugarfreeConfig" do

  describe "config" do
    it "should create a Config with the given options" do
      opts = { :o1 => 2, :o2 => 2 }
      SugarfreeConfig::Config.expects(:new).once().with(opts)
      SugarfreeConfig.init(opts)
    end
  end

  describe "method_missing" do
    it "should create a Config and delegate" do
      config = mock()
      config.expects(:send).with(:test1)
      config.expects(:send).with(:test2)
      SugarfreeConfig::Config.expects(:new).once().returns(config)

      SugarfreeConfig.test1
      SugarfreeConfig.test2
    end
  end
end


describe "SugarfreeConfig delegation" do

  before do
    @config = {
      'development' => {
        'simple_config_key' => 1234,
        'nested_config_keys' => {
          'nested_key' => "the nested key"
        }
      }
    }

    YAML.stubs(:load_file).returns(@config)
  end

  describe "to_hash" do
    it "should return the environment config as a hash" do
      SugarfreeConfig.to_hash.must_equal(@config['development'])
    end

    it "should honor the scope" do
      SugarfreeConfig.nested_config_keys.to_hash.must_equal(@config['development']['nested_config_keys'])
    end
  end

  describe "asking for keys" do

    it "should return the configuration values" do
      SugarfreeConfig.simple_config_key.must_equal 1234
      SugarfreeConfig.nested_config_keys.nested_key.must_equal 'the nested key'
    end

    it "should fail when aksing for non existent key" do
      lambda { SugarfreeConfig.non_existent_key }.must_raise SugarfreeConfig::ConfigKeyException
    end
  end

end
