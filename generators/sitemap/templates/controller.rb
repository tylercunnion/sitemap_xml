class SitemapController < ApplicationController
  def index
    @files = []
    @actions = []

    find_files("#{RAILS_ROOT}/app/controllers")

    @files.each do |f|
      ct = eval(f).new
      ct.get_sitemap if ct.respond_to?(:get_sitemap)
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