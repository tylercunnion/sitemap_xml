# SitemapXml

module SitemapXml
  protected
  def self.included(klass)
    klass.send :class_inheritable_array, :sitemapped_actions
    klass.send :extend, SitemapClassMethods
    klass.send :sitemapped_actions=, []
  end
  
  module SitemapClassMethods
  
    # Add this method to the end of your controller to enable it for
    # sitemapping. It <strong>must</strong> be below all the actions in your
    # controller or the system cannot detect them.
    #
    # ==== Parameters
    # * <tt>:only</tt> - Will only include the specified actions in the map.
    # * <tt>:except</tt> - Will map all actions except the specified ones.
    # * <tt>:include</tt> - Includes the given actions in the map. This method
    #   bypasses the normal checks on method existence -- use it when you have
    #   a view-only page with no corresponding method in the controller;
    #   this is the only way to make it appear in the list.
    # * <tt>:obj_required</tt> - Use this option when certain actions need an id.
    # * <tt>:model</tt> - Specify the model name when it does not match
    #   the controller's name.
    # * <tt>:obj_key</tt> - Use with <tt>:obj_required</tt>. If you need a
    #   column other than <tt>id</tt>, you can set it here.
    # * <tt>:conditions</tt> - By default, <tt>:obj_required</tt> will perform
    #   find(:all). You may pass in conditions in the same format as find() to
    #   return only a subset of the objects.
    #
    # ==== Examples
    #   enable_sitemap :only => ["index, show"], :obj_required => ["show"]
    #   enable_sitemap :except => ["destroy, edit"], :obj_required => ["show"], :model => "Person"
    #   enable_sitemap :obj_required => ["show"], :conditions => ["public = true"]
    def enable_sitemap(options={})
      options.to_options!
      options.assert_valid_keys(:only, :except, :include, :obj_required, :model, :obj_key, :conditions)
          
      base_actions = self.public_instance_methods(false)
      map_actions = base_actions
    
      map_actions = options[:only] & map_actions if options.has_key?(:only)
      map_actions = map_actions - options[:except] if options.has_key?(:except)
      map_actions = map_actions + options[:include] if options.has_key?(:include)
      
      if options.has_key?(:obj_required)
        static_actions = map_actions - options[:obj_required]
      else
        static_actions = map_actions
      end
      
      static_actions.each do |action|
        self.sitemapped_actions << {:controller => self.controller_path, :action => action}
      end
      
      if options.has_key?(:obj_required)
        unless options.has_key?(:model)
          model = Object.const_get(self.controller_name.capitalize.singularize)
        else
          model = Object.const_get(options[:model])
        end
        
        unless options.has_key?(:obj_key)
          column = "id"
        else
          column = options[:obj_key]
        end
        
        column = column.intern
        
        dynamic_actions = options[:obj_required] & map_actions
        objects = model.find(:all, :conditions => options[:conditions])
        dynamic_actions.each do |action|
          objects.each do |obj|
            self.sitemapped_actions << {:controller => self.controller_path, :action => action, column => obj.send(column)}
          end
        end
      end
    end
  end
end
  