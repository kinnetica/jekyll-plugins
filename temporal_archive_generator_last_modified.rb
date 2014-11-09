module Jekyll

  # Create an override for temporal_archive_generator.rb to add the last_modified method from sitemap_generator.rb
  class MonthlyIndexPage < Page
    
    def last_modified
    
      latest_date = Time.at(0) # Unix Epoch
    
      self.data['posts'].each do |post|
      
      	latest_date = self.greater_date(latest_date, post.last_modified())
      
      end

      latest_date
      
    end
    
  end
  class YearlyIndexPage < Page
      
      def last_modified
          
          latest_date = Time.at(0) # Unix Epoch
          
          self.data['posts'].each do |post|
              
              latest_date = self.greater_date(latest_date, post.last_modified())
              
          end
          
          latest_date
          
      end
      
  end

end