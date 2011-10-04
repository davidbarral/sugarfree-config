require 'spec_helper'

describe "ConfigKeyException" do
  it "keeps the path elements that caused the exception as a String array" do
    SugarfreeConfig::ConfigKeyException.new(:el1).key_path_elements.must_equal(["el1"])
    SugarfreeConfig::ConfigKeyException.new([:el1, :el2]).key_path_elements.must_equal(["el1", "el2"])
  end
end
