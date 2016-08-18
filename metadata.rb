name 'compat_resource'
maintainer 'John Keiser'
maintainer_email 'jkeiser@chef.io'
license 'Apache 2.0'
description 'Brings the modern custom resource syntax to earlier Chef 12 releases prior to 12.5'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

version_rb = IO.read(File.expand_path("../files/lib/compat_resource/version.rb", __FILE__))
raise "Version file not in correct format" unless version_rb =~ /VERSION\s*=\s*'([^']+)'/
version $1

chef_version '>= 12.0' if respond_to?(:chef_version)
source_url 'https://github.com/chef-cookbooks/compat_resource'
issues_url 'https://github.com/chef-cookbooks/compat_resource/issues'
