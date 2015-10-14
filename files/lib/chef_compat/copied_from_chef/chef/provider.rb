require 'chef_compat/copied_from_chef'
class Chef
module ::ChefCompat
module CopiedFromChef
class Chef < (defined?(::Chef) ? ::Chef : Object)
  class Provider < (defined?(::Chef::Provider) ? ::Chef::Provider : Object)
    def initialize(new_resource, run_context)
super if defined?(::Chef::Provider)
      @new_resource = new_resource
      @action = action
      @current_resource = nil
      @run_context = run_context
      @converge_actions = nil

      @recipe_name = nil
      @cookbook_name = nil
      self.class.include_resource_dsl_module(new_resource)
    end
    def converge_if_changed(*properties, &converge_block)
      if !converge_block
        raise ArgumentError, "converge_if_changed must be passed a block!"
      end

      properties = new_resource.class.state_properties.map { |p| p.name } if properties.empty?
      properties = properties.map { |p| p.to_sym }
      if current_resource
        # Collect the list of modified properties
        specified_properties = properties.select { |property| new_resource.property_is_set?(property) }
        modified = specified_properties.select { |p| new_resource.send(p) != current_resource.send(p) }
        if modified.empty?
          if @sensitive == true
            Chef::Log.debug("Skipping update of #{new_resource.to_s}: has not changed any of the specified properties (suppressed sensitive properties).")
          else
            Chef::Log.debug("Skipping update of #{new_resource.to_s}: has not changed any of the specified properties #{specified_properties.map { |p| "#{p}=#{new_resource.send(p).inspect}" }.join(", ")}.")
          end
          return false
        end

        # Print the pretty green text and run the block
        property_size = modified.map { |p| p.size }.max
        if @sensitive == true
          modified = modified.map { |p| "  set #{p.to_s.ljust(property_size)} to (suppressed sensitive properties)"}
        else
          modified = modified.map { |p| "  set #{p.to_s.ljust(property_size)} to #{new_resource.send(p).inspect} (was #{current_resource.send(p).inspect})" }
        end
        converge_by([ "update #{current_resource.identity}" ] + modified, &converge_block)

      else
        # The resource doesn't exist. Mark that we are *creating* this, and
        # write down any properties we are setting.
        property_size = properties.map { |p| p.size }.max
        created = []
        properties.each do |property|
          default = ' (default value)' unless new_resource.property_is_set?(property)
          if @sensitive == true
            created << "  set #{property.to_s.ljust(property_size)} to (suppressed sensitive properties)" + default ||= ''
          else
            created << "  set #{property.to_s.ljust(property_size)} to #{new_resource.send(property).inspect}" + default ||= ''
          end
        end

        converge_by([ "create #{new_resource.identity}" ] + created, &converge_block)
      end
      true
    end
    def self.include_resource_dsl(include_resource_dsl)
      @include_resource_dsl = include_resource_dsl
    end
    def self.include_resource_dsl_module(resource)
      if @include_resource_dsl && !defined?(@included_resource_dsl_module)
        provider_class = self
        @included_resource_dsl_module = Module.new do
          extend Forwardable
          define_singleton_method(:to_s) { "forwarder module for #{provider_class}" }
          define_singleton_method(:inspect) { to_s }
          # Add a delegator for each explicit property that will get the *current* value
          # of the property by default instead of the *actual* value.
          resource.class.properties.each do |name, property|
            class_eval(<<-EOM, __FILE__, __LINE__)
              def #{name}(*args, &block)
                # If no arguments were passed, we process "get" by defaulting
                # the value to current_resource, not new_resource. This helps
                # avoid issues where resources accidentally overwrite perfectly
                # valid stuff with default values.
                if args.empty? && !block
                  if !new_resource.property_is_set?(__method__) && current_resource
                    return current_resource.public_send(__method__)
                  end
                end
                new_resource.public_send(__method__, *args, &block)
              end
            EOM
          end
          dsl_methods =
             resource.class.public_instance_methods +
             resource.class.protected_instance_methods -
             provider_class.instance_methods -
             resource.class.properties.keys
          def_delegators(:new_resource, *dsl_methods)
        end
        include @included_resource_dsl_module
      end
    end
    def self.use_inline_resources
      extend InlineResources::ClassMethods
      include InlineResources
    end
    protected
  end
end
end
end
end
