class SitemapController < ApplicationController
  def index
    
    @files = []
    @actions = []
    
    unless ENV['RAILS_ENV'] == "production"
      find_files("#{RAILS_ROOT}/app/controllers")

      @files.each do |f|
        eval(f)
      end
    end
    
    Sitemap.instance.map_args.each_pair do |the_controller, the_args|
      Sitemap.instance.set_sitemap(the_controller, the_args)
    end    
          
    Sitemap.instance.mapped_actions.each_value do |val|
      @actions += val
    end

  end
  
  private
  
  def find_files(dir, mod = "")
    controllers = Dir.new(dir).entries - [".", ".."]
    controllers.each do |c|
      if File.directory?("#{dir}/#{c}")
        #puts 'dir'
        find_files("#{dir}/#{c}", c.camelize + "::")
      else
        if c =~ /_controller/
          name =c.camelize.gsub(".rb","")
          unless mod.empty?
            name = mod + name
          end
          @files << name
        end
      end
    end
  end
end