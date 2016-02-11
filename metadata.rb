name 'compat_resource'
maintainer 'John Keiser'
maintainer_email 'jkeiser@chef.io'
license 'Apache 2.0'
description 'Chef 12.5 Resources, For Chef 12.1-12.4'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

version_rb = IO.read(File.expand_path('../files/lib/compat_resource/version.rb', __FILE__))
fail 'Version file not in correct format' unless version_rb =~ /VERSION\s*=\s*'([^']+)'/
version Regexp.last_match(1)

chef_version '>= 12.0' if respond_to?(:chef_version)
source_url 'https://github.com/chef-cookbooks/compat_resource' if respond_to?(:source_url)
issues_url 'https://github.com/chef-cookbooks/compat_resource/issues' if respond_to?(:issues_url)
