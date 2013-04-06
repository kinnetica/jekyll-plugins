Jekyll Plugin: Sitemap.xml Generator
====================================

Sitemap.xml Generator is a Jekyll plugin that generates a sitemap.xml file by traversing all of the available posts and pages.

How To Use:
-----------
1. Copy file into your _plugins folder within your Jekyll project.
2. Change MY_URL to reflect your domain name.
3. Change SITEMAP_FILE_NAME if you want your sitemap to be called something other than sitemap.xml.
4. Change the PAGES_INCLUDE_POSTS list to include any pages that are looping through your posts (e.g. "/index.html", "/archive/index.html", etc.). This will ensure that right after you make a new post, the last modified date will be updated to reflect the new post.
5. Run Jekyll: `jekyll` to re-generate your site.
6. A sitemap.xml should be included in your _site folder.

Customizations:
---------------
1. If there are any files you don't want included in the sitemap, add them to the EXCLUDED_FILES list. The path should match the path of the source file.
2. If you want to include the optional changefreq and priority attributes, simply include custom variables in the YAML Front Matter of those files. The names of these custom variables are defined in the source file in the CHANGE_FREQUENCY_CUSTOM_VARIABLE_NAME and PRIORITY_CUSTOM_VARIABLE_NAME constants.

Notes:
------
1. The last modified date is determined by the latest date of the following: system modified date of the page or post, system modified date of included layout, system modified date of included layout within that layout, ...

Author: Michael Levin ([http://www.kinnetica.com](http://www.kinnetica.com))

Distributed Under A [Creative Commons](http://creativecommons.org/licenses/by/3.0/) License