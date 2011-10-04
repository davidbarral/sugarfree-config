
require 'sugarfree-config/exceptions'
require 'sugarfree-config/config'

# Sugarfree config allows easy access to the config values.
#
# See README.rdoc for usage info
#
module SugarfreeConfig

  class << self
    attr_reader :config

    def init(options = {})
      @config = Config.new(options)
    end

    def method_missing(*args)
      init unless SugarfreeConfig.config
      SugarfreeConfig.config.send(*args)
    end
  end
end

