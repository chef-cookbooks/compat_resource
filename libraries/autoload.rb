unless Gem::Requirement.new(">= 12.0").satisfied_by?(Gem::Version.new(Chef::VERSION))
  raise "This resource is written with Chef 12.5 custom resources, and requires at least Chef 12.0 used with the compat_resource cookbook, it will not work with Chef 11.x clients, and those users must pin their cookbooks to older versions or upgrade."
end

# If users are on old verisons of ChefDK which activates an (old) gem via cheffish before this cookbook loads, then
# we just try to monkeypatch over the top of a monkeypatch.  Its possible that we have checks in this cookbook which
# will defeat that purpose and fail to monkeypatch on top of monkeypatches -- in which case those checks should be
# removed -- this cookbook needs to win when it gets into a fight with the old gem versions.
if Gem.loaded_specs["compat_resource"]
  Chef.log_deprecation "using compat_resource as a gem is deprecated;  please update cheffish and chef-provisioning gems (or use the latest Chef/ChefDK packages) or else manually pin your compat_resource cookbook version to the same version as the gem you are using to remove this warning"
end

require_relative '../files/lib/compat_resource/gemspec'
CompatResource::GEMSPEC.activate

require 'compat_resource'
