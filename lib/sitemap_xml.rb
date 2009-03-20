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
    # * <tt>:only</tt> - Map only the given actions
    # * <tt>:except</tt> - Map all actions except the given actions
    # * <tt>:include</tt> - Map the given additional actions. If you have
    #   static actions with only a view and no corresponding method in the
    #   controller, use this to tell the map about them.
    # * <tt>:dynamic</tt> - Tells the map that the given actions are dynamic;
    #   i.e., they take a parameter (usually <tt>id</tt>) to display an object.
    #   This can take a hash or several hashes of the form 
    #   <tt>:action_name => {options}</tt> to override the global default
    #   options.
    # * <tt>:model</tt> - Specify the model if it cannot be inferred from
    #   the controller name.
    # * <tt>:param</tt> - Specify the param to use if not <td>id</td>.
    # * <tt>:conditions</tt> - Specify <tt>find()</tt> conditions for objects
    #   attached to dynamic actions.
    # * <tt>:collection</tt> - As an alternative to grabbing objects from the
    #   database, you may specify a collection to use instead.
    #
    # ==== Examples
    #   enable_sitemap :except => :post_result
    #   enable_sitemap :dynamic => :show
    #   enable_sitemap :dynamic => {:show => { :param => :year, :collection => (2000..Date.today.year).collect }}
    #   enable_sitemap :resource, :include => :some_other_method
    def enable_sitemap(*args)
      Sitemap.instance.map_args[self] = args
    end

      
  end #module SitemapClassMethods
end #module SitemapXml
  