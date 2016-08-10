raise "CompatResource defined on recent chef" if defined?(ChefCompat::Resource) && Gem::Requirement.new(">= 12.5").satisfied_by?(Gem::Version.new(Chef::VERSION)) 
