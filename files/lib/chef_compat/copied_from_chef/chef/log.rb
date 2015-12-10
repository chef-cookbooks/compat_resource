require 'chef_compat/copied_from_chef'
class Chef
module ::ChefCompat
module CopiedFromChef
class Chef < (defined?(::Chef) ? ::Chef : Object)
  class Log < (defined?(::Chef::Log) ? ::Chef::Log : Object)
    extend Mixlib::Log
    init(MonoLogger.new(STDOUT))
    class Formatter < (defined?(::Chef::Log::Formatter) ? ::Chef::Log::Formatter : Object)
    end
  end
end
end
end
end
