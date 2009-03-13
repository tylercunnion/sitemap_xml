# SitemapXml

module SitemapXml
  protected
  def self.included(klass)
    klass.send :extend, SitemapClassMethods
  end
  
  module SitemapClassMethods
  
    # Add this method to the end of your controller to enable it for
    # sitemapping. It must be below all the actions in your
    # controller or the system cannot detect them.
    #
    # If your controller is RESTful, then mapping is easy. For an automatic map
    # of the <tt>index</tt> and <tt>show</tt> actions, call <tt>enable_sitemap</tt> with <tt>:resource</tt>
    # as your first argument. You may still use the parameters below to modify
    # your mapping arrangement.
    #
    #
    # ==== Parameters

    def enable_sitemap(*args)
      sitemapped_actions = []
      options = args.extract_options!

      possible_actions = self.public_instance_methods(false)


      if args.first == :resource
       valid_keys = [:except, :include, :dynamic, :model, :param, :conditions, :collection]
       map_actions = ["index", "show"]
      else
       valid_keys = [:only, :except, :include, :dynamic, :model, :param, :conditions, :collection]
       map_actions = possible_actions
      end

      options.assert_valid_keys(valid_keys)

      if options.has_key?(:only)
       map_actions = options[:only].to_a & possible_actions
      else
       map_actions -= options[:except].to_a if options.has_key?(:except)
       map_actions += options[:include].to_a if options.has_key?(:include)
      end
      
      if options.has_key?(:dynamic)
        logger.debug "Dynamic!"
        unless options.has_key?(:model)
          default_model = Object.const_get(self.controller_name.capitalize.singularize)
        else
          default_model = Object.const_get(options[:model])
        end
        logger.debug "Default Model: " + default_model.name

        default_conditions = options[:conditions]
        
        logger.debug "Default Conditions: " + default_conditions.inspect

        if options.has_key?(:param)
          default_param = options[:param]
        else
          default_param = :id
        end
        
        logger.debug "Default Param: " + default_param.inspect

        default_collection = options[:collection]
        
        logger.debug "Default Collection: " + default_collection.inspect

        dynamics = []
        
        logger.debug "Options-Dynamic: " + options[:dynamic].inspect
        logger.debug "Class of above: " + options[:dynamic].class.inspect
        case options[:dynamic]
          when Array:
            dynamics += options[:dynamic]
          when Hash, String, Symbol:
            dynamics << options[:dynamic]
        end
        
        logger.debug "Dynamics: " + dynamics.inspect

        default_objects = default_model.find(:all, :conditions => default_conditions)

        scanner = SitemapScanner.new(:controller => self, :model => default_model, :conditions => default_conditions, :param => default_param, :collection => default_collection, :objects => default_objects)
        
                
        dynamics.each do |d|
          sitemapped_actions += scanner.scan(d)
        end

        static_actions = map_actions - scanner.names
      else
        static_actions = map_actions
      end

      static_actions.each do |action|
        url = {:controller => self.controller_path, :action => action, :only_path => false}
        sitemapped_actions << {:url => url}
      end
      logger.debug "Final: " + sitemapped_actions.inspect
      unless sitemapped_actions.empty?
        Sitemap.instance.mapped_actions[self.name.intern] = sitemapped_actions
      end
    end #enable_sitemap


      
  end #module SitemapClassMethods
end #module SitemapXml
  