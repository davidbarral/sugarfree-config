#
# Sugarfree config allows easy access to the config values.
# 
# See README.textile for usage info 
#
module SugarfreeConfig
    
  def self.init(force_reload = false)
    @@config = Config.new(force_reload)
  end

  def self.method_missing(*args)
    init unless @@config
    @@config.send(*args)
  end

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
    
  #
  # Config base object. Caches the configuration in memory an acts as a factory
  # for the ConfigIterators needed to get config values
  #
  class Config
    
    #
    # Conifg file is expected at "#{RAILS_ROOT}/config/config.yml"
    #    
    DEFAULT_CONFIG_FILE = File.join(RAILS_ROOT, 'config', 'config.yml')
            
    def values
      @values = fetch_config unless @values && !@force_reload     
      @values
    end
        
    #
    # Creates a new config object and load the config file into memory
    #
    def initialize(force_reload = false) 
      @force_reload = force_reload  
    end

    #
    # Returns all the config as a big hash
    #
    def to_hash
      @values
    end
    
    #
    # Here is the magic. The first request to config returns a new 
    # ConfigIterator that will handle the first +symbol+
    #
    def method_missing(symbol, *args)
      ConfigIterator.new(values, symbol).next
    end
     
    protected
    
      #
      # Fetch the config from the file
      #
      def fetch_config
       if Object.const_defined?('RAILS_DEFAULT_LOGGER') && RAILS_DEFAULT_LOGGER.debug?          
          RAILS_DEFAULT_LOGGER.debug "Loading #{DEFAULT_CONFIG_FILE}::#{RAILS_ENV}"
        end
        HashWithIndifferentAccess.new(YAML::load(File.new(DEFAULT_CONFIG_FILE))[RAILS_ENV])                       
      end    
  end

  #
  # Config Iterator. Given a configuration hash it can navigate trough the
  # values using method calls that will be translated into hash keys and 
  # indexed
  #
  class ConfigIterator
    
    #
    # Create a new iterator with a given +configuration+ and the first 
    # element of the path to be iterated (+first_path_element+)
    #
    def initialize(configuration, first_path_element)
      @scoped_config = configuration
      @path_elements = [first_path_element]
    end
    
    #
    # Returns the current scope as a hash. Usefull to get a Big hash of config
    # that will be used later.
    #
    def to_hash      
      @scoped_config
    end
    
    #
    # Iterate to the next element in the path
    # 
    # Algorithm: 
    # 1. Get the last element of the key path
    # 2. Try to find it in the scoped config.
    # 3. If not present raise an error
    # 4. If present and is a hash we are not in a config leaf, so the scoped
    #    config is reset to this new value and self is returned
    # 5. If present and is a value then return the value
    #
    def next      
      if (value = @scoped_config[@path_elements.last]).nil?
        raise ConfigKeyException.new(@path_elements)
      elsif value.is_a?(Hash)
        @scoped_config = value
        self
      else
        value
      end
    end
    
    #
    # Here is the magic. When an unknown symbol is passed this symbol is set
    # as the last path element of this iteration, and the iterator is then 
    # forced to make that movement
    #
    def method_missing(symbol, *args)
      @path_elements << symbol
      self.next
    end        
  end
  
end
  
