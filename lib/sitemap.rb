class Sitemap
  include Singleton
  
  attr_accessor :mapped_actions

  def initialize()
    @mapped_actions = {}
  end
  
end