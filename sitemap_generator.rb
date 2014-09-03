# Sitemap.xml Generator is a Jekyll plugin that generates a sitemap.xml file by 
# traversing all of the available posts and pages.
# 
# See readme file for documenation
# 
# Updated to use config file for settings by Daniel Groves
# Site: http://danielgroves.net
# 
# Author: Michael Levin
# Site: http://www.kinnetica.com
# Distributed Under A Creative Commons License
#   - http://creativecommons.org/licenses/by/3.0/

require 'rexml/document'

module Jekyll

  class Post
    attr_accessor :name

    def full_path_to_source
      File.join(@base, @name)
    end
    
    def path_to_source
      File.join(@name)
    end

    def location_on_server(my_url)
      "#{my_url}#{url}"
    end
    
    def last_modified
      latest_date = Time.new
      
      if (File.exists? self.full_path_to_source)
        latest_date = File.mtime self.full_path_to_source
      
        layouts = self.site.layouts
        layout = layouts[self.data["layout"]]
        while layout
          date = layout.last_modified

          latest_date = date if (date > latest_date)

          layout = layouts[layout.data["layout"]]
        end
      end

      latest_date
    end

    # Which of the two dates is later
    #
    # Returns latest of two dates
    def greater_date(date1, date2)
      if (date1 >= date2) 
        date1
      else 
        date2 
      end
    end
  end

  class Page
    attr_accessor :name

    def full_path_to_source
      unless @base.nil? || @dir.nil? || @name.nil?
      	return File.join(@base, @dir, @name)
      end
    end
    
    def path_to_source
      unless @dir.nil? || @name.nil?
      	return File.join(@dir, @name)
      end
    end

    def location_on_server(my_url)
      location = "#{my_url}#{url}"
      location.gsub(/index.html$/, "")
    end
    
    def last_modified
      latest_date = Time.new
      
      if (File.exists? self.full_path_to_source)
        latest_date = File.mtime self.full_path_to_source
      
        layouts = self.site.layouts
        layout = layouts[self.data["layout"]]
        while layout
          date = layout.last_modified

          latest_date = date if (date > latest_date)
 
          layout = layouts[layout.data["layout"]]
        end
      end

      latest_date
    end

    # Which of the two dates is later
    #
    # Returns latest of two dates
    def greater_date(date1, date2)
      if (date1 >= date2) 
        date1
      else 
        date2 
      end
    end
    
  end


  class Layout
    def full_path_to_source
      File.join(@base, @name)
    end
    
    def last_modified
      File.mtime self.full_path_to_source
    end

    # Which of the two dates is later
    #
    # Returns latest of two dates
    def greater_date(date1, date2)
      if (date1 >= date2) 
        date1
      else 
        date2 
      end
    end
    
  end

  # Recover from strange exception when starting server without --auto
  class SitemapFile < StaticFile
    def write(dest)
      true
    end
  end

  class SitemapGenerator < Generator
    priority :lowest

    # Config defaults
    SITEMAP_FILE_NAME = "/sitemap.xml"
    EXCLUDE = ["/atom.xml", "/feed.xml", "/feed/index.xml"]
    INCLUDE_POSTS = ["/index.html"] 
    CHANGE_FREQUENCY_NAME = "change_frequency"
    PRIORITY_NAME = "priority"
    
    # Valid values allowed by sitemap.xml spec for change frequencies
    VALID_CHANGE_FREQUENCY_VALUES = ["always", "hourly", "daily", "weekly",
      "monthly", "yearly", "never"] 

    # Goes through pages and posts and generates sitemap.xml file
    #
    # Returns nothing
    def generate(site)
      # Configuration
      sitemap_config = site.config['sitemap'] || {}
      @config = {}
      @config['filename'] = sitemap_config['filename'] || SITEMAP_FILE_NAME
      @config['change_frequency_name'] = sitemap_config['change_frequency_name'] || CHANGE_FREQUENCY_NAME
      @config['priority_name'] = sitemap_config['priority_name'] || PRIORITY_NAME
      @config['exclude'] = sitemap_config['exclude'] || EXCLUDE
      @config['include_posts'] = sitemap_config['include_posts'] || INCLUDE_POSTS

      sitemap = REXML::Document.new << REXML::XMLDecl.new("1.0", "UTF-8")

      urlset = REXML::Element.new "urlset"
      urlset.add_attribute("xmlns", 
        "http://www.sitemaps.org/schemas/sitemap/0.9")

      @last_modified_post_date = fill_posts(site, urlset)
      fill_pages(site, urlset)

      sitemap.add_element(urlset)

      # Create destination directory if it doesn't exist yet. Otherwise, we cannot write our file there.
      Dir::mkdir(site.dest) if !File.directory? site.dest

      # File I/O: create sitemap.xml file and write out pretty-printed XML
      filename = @config['filename']
      file = File.new(File.join(site.dest, filename), "w")
      formatter = REXML::Formatters::Pretty.new(4)
      formatter.compact = true
      formatter.write(sitemap, file)
      file.close

      # Keep the sitemap.xml file from being cleaned by Jekyll
      site.static_files << Jekyll::SitemapFile.new(site, site.dest, "/", filename)
    end

    # Create url elements for all the posts and find the date of the latest one
    #
    # Returns last_modified_date of latest post
    def fill_posts(site, urlset)
      last_modified_date = nil
      site.posts.each do |post|
        if !excluded?(post.name)
          url = fill_url(site, post)
          urlset.add_element(url)
        end

        date = post.last_modified
        last_modified_date = date if last_modified_date == nil or date > last_modified_date
      end

      last_modified_date
    end

    # Create url elements for all the normal pages and find the date of the
    # index to use with the pagination pages
    #
    # Returns last_modified_date of index page
    def fill_pages(site, urlset)
      site.pages.each do |page|
        if !excluded?(page.path_to_source)
          url = fill_url(site, page)
          urlset.add_element(url)
        end
      end
    end

    # Fill data of each URL element: location, last modified, 
    # change frequency (optional), and priority.
    #
    # Returns url REXML::Element
    def fill_url(site, page_or_post)
      url = REXML::Element.new "url"

      loc = fill_location(site, page_or_post)
      url.add_element(loc)

      lastmod = fill_last_modified(site, page_or_post)
      url.add_element(lastmod) if lastmod

      if (page_or_post.data[@config['change_frequency_name']])
        change_frequency = 
          page_or_post.data[@config['change_frequency_name']].downcase
          
        if (valid_change_frequency?(change_frequency))
          changefreq = REXML::Element.new "changefreq"
          changefreq.text = change_frequency
          url.add_element(changefreq)
        else
          puts "ERROR: Invalid Change Frequency In #{page_or_post.name}"
        end
      end

      if (page_or_post.data[@config['priority_name']])
        priority_value = page_or_post.data[@config['priority_name']]
        if valid_priority?(priority_value)
          priority = REXML::Element.new "priority"
          priority.text = page_or_post.data[@config['priority_name']]
          url.add_element(priority)
        else
          puts "ERROR: Invalid Priority In #{page_or_post.name}"
        end
      end

      url
    end

    # Get URL location of page or post 
    #
    # Returns the location of the page or post
    def fill_location(site, page_or_post)
      loc = REXML::Element.new "loc"
      url = site.config['url']
      loc.text = page_or_post.location_on_server(url)

      loc
    end

    # Fill lastmod XML element with the last modified date for the page or post.
    #
    # Returns lastmod REXML::Element or nil
    def fill_last_modified(site, page_or_post)
      path = page_or_post.full_path_to_source

      lastmod = REXML::Element.new "lastmod"
      latest_date = page_or_post.last_modified

      if @last_modified_post_date == nil
        # This is a post
        lastmod.text = latest_date.iso8601
      else
        # This is a page
        if posts_included?(page_or_post.path_to_source)
          # We want to take into account the last post date
          final_date = greater_date(latest_date, @last_modified_post_date)
          lastmod.text = final_date.iso8601
        else
          lastmod.text = latest_date.iso8601
        end
      end
      lastmod
    end

    # Which of the two dates is later
    #
    # Returns latest of two dates
    def greater_date(date1, date2)
      if (date1 >= date2) 
        date1
      else 
        date2 
      end
    end

    # Is the page or post listed as something we want to exclude?
    #
    # Returns boolean
    def excluded?(name)
      @config['exclude'].include? name
    end

    def posts_included?(name)
      @config['include_posts'].include? name
    end

    # Is the change frequency value provided valid according to the spec
    #
    # Returns boolean
    def valid_change_frequency?(change_frequency)
      VALID_CHANGE_FREQUENCY_VALUES.include? change_frequency
    end

    # Is the priority value provided valid according to the spec
    #
    # Returns boolean
    def valid_priority?(priority)
      begin
        priority_val = Float(priority)
        return true if priority_val >= 0.0 and priority_val <= 1.0
      rescue ArgumentError
      end

      false
    end
  end
end