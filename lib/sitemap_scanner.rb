class SitemapScanner

  attr_accessor :param
  attr_accessor :model
  attr_accessor :conditions
  attr_accessor :collection
  attr_accessor :objects
  attr_accessor :names
  attr_accessor :controller

  def initialize(args={})
    @names = []
    @param = args[:param]
    @model = args[:model]
    @conditions = args[:conditions]
    @collection = args[:collection]
    @objects = args[:objects]
    @controller = args[:controller]
  end

  def scan(action_definition)
  	case action_definition
  	  when Hash then gathered_actions = hash_scan(action_definition)
  	  when String then gathered_actions = string_scan(action_definition)
  	  when Symbol then gathered_actions = string_scan(action_definition.to_s)
  	end
  	return gathered_actions

  end

  def w3cdate(date)
    return date.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")
  end

  def string_scan(action_definition)
    gathered_actions = []
    @names << action_definition
    if @collection.nil?
      @objects.each do |obj|
        url = {:controller => @controller.controller_path, :action => action_definition, @param => obj.send(@param), :only_path => false}
        new_action = {:url => url}
        new_action.merge({:lastmod => w3cdate(obj.updated_at)}) if obj.respond_to?(:updated_at)
        gathered_actions << new_action
      end
    else
      @collection.each do |c|
        gathered_actions << {:url => {:controller => @controller.controller_path, :action => action_definition, @param => c, :only_path => false}}
      end
    end
    return gathered_actions
  end

  def hash_scan(action_definition)
    gathered_actions = []
    unless action_definition.size == 1
      action_definition.each do |key, value|
        gathered_actions += hash_scan({key => value})
      end
    else
      action_name = action_definition.to_a[0][0]
      options = action_definition.to_a[0][1]
    
      @names << action_name.to_s
    
      param = options[:param].nil? ? @param : options[:param]
      model = options[:model].nil? ? @model : options[:model]
      conditions = options[:conditions].nil? ? @conditions : options[:conditions]
      collection = options[:collection].nil? ? @collection : options[:collection]

      if collection.nil?
        unless options.size > 0 || objects.nil?
          objects = model.all(:conditions => conditions)
        end
        objects.each do |obj|
          url = {:controller => @controller.controller_path, :action => action_name, param => obj.send(param), :only_path => false}
          new_action = {:url => url}
          new_action.merge({:lastmod => w3cdate(obj.updated_at)}) if obj.respond_to?(:updated_at)
          gathered_actions << new_action
        end
      else
        collection.each do |c|
          gathered_actions << {:url => {:controller => @controller.controller_path, :action => action_name, param => c, :only_path => false}}
        end
      end
    end     
    return gathered_actions
  end
end
