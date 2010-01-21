class Sitemap
  include Singleton
  
  attr_accessor :mapped_actions
  attr_accessor :map_args
  
  def initialize
    @mapped_actions = {} if @mapped_actions.nil?
    @map_args = {} if @map_args.nil?
  end
  
  def set_sitemap(controller, args)
    
    args = args.clone
    
    sitemapped_actions = []
    options = args.extract_options!
    
    possible_actions = [*(controller.action_methods - ApplicationController.action_methods)].collect{|a| a.to_sym}


    if args.first == :resource
     valid_keys = [:except, :include, :dynamic, :model, :param, :conditions, :collection]
     map_actions = [:index, :show]
    else
     valid_keys = [:only, :except, :include, :dynamic, :model, :param, :conditions, :collection]
     map_actions = possible_actions
    end

    options.assert_valid_keys(valid_keys)

    if options.has_key?(:only)
     map_actions = [*options[:only]].collect {|a| a.to_sym} & possible_actions
    else
     map_actions -= [*options[:except]].collect {|a| a.to_sym} if options.has_key?(:except)
     map_actions += [*options[:include]].collect {|a| a.to_sym} if options.has_key?(:include)
    end

    if options.has_key?(:dynamic)
      ##logger.debug "Dynamic!"
      unless options.has_key?(:model)
        default_model = Object.const_get(controller.controller_name.capitalize.singularize)
      else
        default_model = Object.const_get(options[:model])
      end
      #logger.debug "Default Model: " + default_model.name

      default_conditions = options[:conditions]

      #logger.debug "Default Conditions: " + default_conditions.inspect

      if options.has_key?(:param)
        default_param = options[:param]
      else
        default_param = :id
      end

      #logger.debug "Default Param: " + default_param.inspect

      default_collection = options[:collection]

      #logger.debug "Default Collection: " + default_collection.inspect

      dynamics = []

      #logger.debug "Options-Dynamic: " + options[:dynamic].inspect
      #logger.debug "Class of above: " + options[:dynamic].class.inspect
      case options[:dynamic]
        when Array then
          dynamics += options[:dynamic]
        when Hash, String, Symbol then
          dynamics << options[:dynamic]
      end

      #logger.debug "Dynamics: " + dynamics.inspect

      default_objects = default_model.find(:all, :conditions => default_conditions)

      scanner = SitemapScanner.new(:controller => controller, :model => default_model, :conditions => default_conditions, :param => default_param, :collection => default_collection, :objects => default_objects)


      dynamics.each do |d|
        sitemapped_actions += scanner.scan(d)
      end

      static_actions = map_actions - scanner.names
    else
      static_actions = map_actions
    end

    static_actions.each do |action|
      url = {:controller => controller.controller_path, :action => action, :only_path => false}
      sitemapped_actions << {:url => url}
    end
    #logger.debug "Final: " + sitemapped_actions.inspect
    unless sitemapped_actions.empty?
      Sitemap.instance.mapped_actions[controller.name.intern] = sitemapped_actions
    end
  end
end