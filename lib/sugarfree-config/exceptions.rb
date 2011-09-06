module SugarfreeConfig
  #
  # Exception raised by the module on unexpected behaviors
  #
  class ConfigException < Exception
  end

  #
  # Exception raised by the Config Iterator when a key is not found
  #
  class ConfigKeyException < ConfigException

    #
    # Config key path (as a key collection) that failed
    #
    attr_accessor :key_path_elements

    #
    # Create a new exception with the not found key paths (+key_path_elements+
    # Array)
    #
    def initialize(key_path_elements)
      self.key_path_elements = [*key_path_elements].map(&:to_s)
      super("Cannot find key #{self.key_path_elements.join('.')}")
    end
  end
end
