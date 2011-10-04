require 'spec_helper'

describe "Config" do

  before do
    @config = {
     'an_env' => {
        'l1' => {
          'l2' => 'a'
        }
      }
    }
  end

  describe "initialize with no params for non rails apps" do
    it "should return default values" do
      Object.stubs(:const_defined?).with('Rails').returns(false)
      h = mock()
      h.expects(:'[]').with('development').once().returns({})
      YAML.expects(:load_file).with(File.expand_path("config.yml")).once().returns(h)

      c = SugarfreeConfig::Config.new({})
      c.to_hash
      c.to_hash
    end
  end

  describe "initialize with no params for rails apps" do

    #
    # Yehaaaa! I know it's awful
    #
    it "should return default values" do
      Object.stubs(:const_defined?).with('Rails').returns(true)

      rails_root = mock()
      rails_root.expects(:join).once().with('config', 'config.yml').returns("/rails_root/config/config.yml")

      rails_logger = mock()
      rails_logger.expects(:debug).once().with("Loading /rails_root/config/config.yml::production")

      String.any_instance.stubs(:development?).returns(false)

      Rails = mock()
      Rails.stubs(:root).returns(rails_root)
      Rails.stubs(:env).returns("production")
      Rails.stubs(:logger).returns(rails_logger)

      h = mock()
      h.expects(:'[]').with('production').once().returns({})
      YAML.expects(:load_file).with("/rails_root/config/config.yml").once.returns(h)

      c = SugarfreeConfig::Config.new({})
      c.to_hash
      c.to_hash
    end
  end

  describe "reloading" do
    it "should reload the configuration if set to" do
      Object.stubs(:const_defined?).with('Rails').returns(false)
      YAML.expects(:load_file).twice().returns(@config)

      c = SugarfreeConfig::Config.new(:reload => true, :env => 'an_env')
      c.to_hash
      c.to_hash
    end

    it "should not reload the configuration" do
      Object.stubs(:const_defined?).with('Rails').returns(false)
      YAML.expects(:load_file).once.returns(@config)

      SugarfreeConfig::Config.new(:reload => false, :env => 'an_env').to_hash
    end
  end

  describe "to_hash" do
    it "should return the base config for a given env" do
      Object.stubs(:const_defined?).with('Rails').returns(false)
      YAML.stubs(:load_file).returns(@config)

      c = SugarfreeConfig::Config.new(:env => 'an_env')
      c.to_hash.must_equal @config['an_env']
    end
  end

  describe "method_missing" do
    it "should return an scoped iterator config" do
      Object.stubs(:const_defined?).with('Rails').returns(false)
      YAML.stubs(:load_file).returns(@config)

      c = SugarfreeConfig::Config.new(:env => 'an_env')
      ci = c.l1
      ci.must_be_instance_of SugarfreeConfig::ConfigIterator
      ci.to_hash.must_equal @config['an_env']['l1']
    end
  end
end


describe "ConfigIterator" do

  before do
    @config = {
      'l1' => {
        'l2a' => {
          'l3' => 'a'
        },
        'l2b' => 'b'
      }
    }
  end

  def iterator(config,key)
    SugarfreeConfig::ConfigIterator.new(config, key)
  end


  describe "to_hash" do
    it "should return the scoped config" do
       ci = iterator(@config, :l1)

       ci.to_hash.must_equal @config
       ci.next.to_hash.must_equal @config['l1']
    end
  end

  describe "method_missing" do
    it "should move the iterator" do
      ci = iterator(@config, :l1)
      ci.to_hash.wont_equal ci.next.to_hash
    end

  end

  describe "next" do

    it "should raise an exception when key is not available" do
      ci = iterator(@config, :unknown_key)
      lambda { ci.next }.must_raise SugarfreeConfig::ConfigKeyException
    end

    it "should return a value if iterated node is a leaf" do
      iterator(@config['l1'], :l2b).next.must_equal 'b'
    end

    it "should return self and change iterator state if iterated node is not leaf" do
      ci = iterator(@config, :l1)
      cii = ci.next
      cii.must_be_same_as ci
    end

  end
end

