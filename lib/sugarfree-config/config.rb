require 'yaml'

module SugarfreeConfig

  #
  # Config base object. Caches the configuration in memory an acts as a factory
  # for the ConfigIterators needed to get config values
  #
  class Config

    #
    # Creates a new config object and load the config file into memory
    #
    def initialize(options)
      options = default_options.merge(options)

      @file   = options[:file]
      @reload = options[:reload]
      @env    = options[:env]
    end

    #
    # Returns all the config as a big hash
    #
    def to_hash
      values
    end

    #
    # Here is the magic. The first request to config returns a new
    # ConfigIterator that will handle the first +symbol+
    #
    def method_missing(symbol, *args)
      ConfigIterator.new(values, symbol).next
    end

    protected

      def values
        @config = fetch_config unless @config && !@reload
        @config
      end

      #
      # Fetch the config from the file
      #
      def fetch_config
        Rails.logger.debug "Loading #{@file}::#{@env}" if Object.const_defined?('Rails') && Rails.logger.present?
        YAML::load_file(@file)[@env.to_s]
      end

      #
      # Default configuration options for Rails and non Rails applications
      #
      def default_options
        if Object.const_defined?('Rails')
          {
            :file   => Rails.root.join('config', 'config.yml'),
            :reload => Rails.env.development?,
            :env    => Rails.env
          }
        else
          {
            :file   => File.expand_path("config.yml"),
            :reload => false,
            :env    => "development"
          }
        end
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
      @path_elements = [first_path_element.to_s]
    end

    #
    # Returns the current scope as a hash. Usefull to get a Big hash of config
    # that will be used later.
    #
    def to_hash
      @scoped_config
    end

    #
    # Here is the magic. When an unknown symbol is passed this symbol is set
    # as the last path element of this iteration, and the iterator is then
    # forced to make that movement
    #
    def method_missing(symbol, *args)
      @path_elements << symbol.to_s
      self.next
    end

    #
    # Iterate to the next element in the path
    #
    # Algorithm:
    # 1. Get the last element of the key path
    # 2. Try to find it in the scoped config
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
  end
end
