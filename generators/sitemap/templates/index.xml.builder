xml.instruct! :xml, :version => "1.0"

xml.urlset(:xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9") do
  @actions.each do |action|
    xml.url do
      xml.loc url_for(action.merge({:only_path => false}))
    end
  end
end

