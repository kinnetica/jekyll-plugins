Jekyll Plugin: Sitemap.xml Generator
====================================

Sitemap Generator is a Jekyll plugin that generates a sitemap.xml file by scanning all of the available posts and pages

How To Use:
-----------
1. Copy File Into _plugins/ folder within your Jekyll project
2. Change MY_URL to reflect your domain name
3. Run Jekyll: jekyll --server to re-generate your site
4. A sitemap.xml should be included in _site/ folder

Customizations:
---------------
1. If there are any files you don't want included in the sitemap, add them to the EXCLUDED_FILES list. The name should match the name of the source file.
2. If you want to include the optional changefreq and priority attributes, simply include custom variables in the YAML Front Matter of those files. The names of these custom variables are defined below in the CHANGE_FREQUENCY_CUSTOM_VARIABLE_NAME and PRIORITY_CUSTOM_VARIABLE_NAME constants.

Notes:
------
1. The last modified date is determined by the latest from the following: system modified date of the page or post, system modified date of included layout, system modified date of included layout within that layout, ... 

Author: Michael Levin
Site: http://www.kinnetica.com
Distributed Under A Creative Commons License
  - http://creativecommons.org/licenses/by/3.0/