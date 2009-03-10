class SitemapController < ApplicationController
  def index
    @files = []
    @actions = []

    find_files("#{RAILS_ROOT}/app/controllers")

    @files.each do |f|
      begin
        @actions = @actions + eval(f).sitemapped_actions 
        # Memory?
        eval(f).sitemapped_actions = []
      rescue NoMethodError
        nil
      end
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