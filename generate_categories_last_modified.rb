module Jekyll

  # Create an override for generate_categories.rb to add the last_modified method from sitemap_generator.rb
  class CategoryPage < Page
    
    def last_modified
    
      latest_date = Time.at(0) # Unix Epoch
    
      self.site.categories[self.data['category']].each do |post|
     
      	latest_date = self.greater_date(latest_date, post.last_modified)
      
      end

      latest_date
      
    end
    
  end

end