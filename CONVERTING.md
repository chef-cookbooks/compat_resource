# Converting cookbooks from the old resource model to the new

## Boilerplate

1. Depend on compat_resource

  - Descend resources from ChefCompat::Resource
  - Set resource_name in the class instead of the constructor

2. Convert Attributes to Properties

  - Rename attribute -> property
  - Move set_or_return -> property
  - Take kind_of/equal_to/regexes and make them types
  - Use true/false/nil instead of TrueClass/FalseClass/NilClass
  - Remove default: nil (it's the default)

3. Convert Top-Level Providers to Actions

  - Create any resources that don't already exist (for example in multi-provider cases) and descend from the base resource
  - Remove allowed_actions / @actions
  - @action -> default_action
  - Move `provides` and `action :x` to the resource
  - Remove use_inline_resources and def whyrun_safe?
  - Move other methods to `action_class.class_eval do`

Now you have everything in a resource, are using properties, and have gotten rid of a bunch of boilerplate. Of course, this is just getting it _moved_.

## Advanced Concepts

1. Resource Inheritance
2. Resources That Are Different On Each OS?
3. Coercion: Handling User Input
4. Lazy Defaults
5. Using Load Current Resource
6. Using Converge If Changed
7. Defaults Are For Creation
8. Shared types: using a type multiple places
