class SitemapGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.template "controller.rb", "app/controllers/sitemap.rb"
      m.directory "app/views/sitemap"
      m.file "index.xml.builder", "app/views/sitemap/index.xml.builder"
    end
  end
  
  def after_generate
    puts "You're almost ready to get sitemapping!"
    puts "To complete installation, add the following line to config/routes.rb:"
    puts "map.sitemap 'sitemap.xml', :controller => \"sitemap\", :action => \"index\", :format => \"xml\""
  end
  
  
end