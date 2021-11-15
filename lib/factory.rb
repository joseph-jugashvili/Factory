# * Here you must define your `Factory` class.
# * Each instance of Factory could be stored into variable. The name of this variable is the name of created Class
# * Arguments of creatable Factory instance are fields/attributes of created class
# * The ability to add some methods to this class must be provided while creating a Factory
# * We must have an ability to get/set the value of attribute like [0], ['attribute_name'], [:attribute_name]
#
# * Instance of creatable Factory class should correctly respond to main methods of Struct
# - each
# - each_pair
# - dig
# - size/length
# - members
# - select
# - to_a
# - values_at
# - ==, eql?

class Factory
  class << self
    def new(class_name, *arguments, &block)
      const_set(class_name, create_class(*arguments, &block)) if class_name.is_a? String
      create_class(*arguments.unshift(class_name), &block)
    end
  def create_class(*arguments, &block)
    Class.new do
      attr_accessor *arguments

      define_method :initialize do |*vars|
        raise ArgumentError, "Expected #{arguments.count}" if arguments.count != vars.count

        arguments.each_index { |index| instance_variable_set("@#{arguments[index]}", vars[index]) }
      end

      define_method :each do |&container|
        values.each(&container)
      end

      define_method :each_pair do |&container|
        to_h.each(&container)
      end

      define_method :dig do |*args|
        args.inject(self) { |key, value| key[value] if key }
      end

      define_method :length do
        arguments.size
      end
      
      define_method :arguments do
        arguments
      end

      alias_method :members, :arguments

      define_method :select do |&container|
        values.select(&container)
      end

      define_method :to_a do
        instance_variables.map { |arg| instance_variable_get(arg) }
      end

      define_method :values_at do |*index|
        values.select { |value| index.include?(values.index(value)) }
      end

      define_method :eql? do |statement|
        instance_of?(statement.class) && values == statement.values
      end

      define_method :[] do |argument|
        argument.is_a?(Integer) ? values[argument] : instance_variable_get("@#{argument}")
      end

      define_method :[]= do |argument, value|
        variable_to_set = argument.is_a?(Integer) ? instance_variables[argument] : "@#{argument}"
        instance_variable_set variable_to_set, value
      end

      alias_method :values, :to_a
      alias_method :==, :eql?
      alias_method :size, :length

      class_eval(&block) if block_given?
      define_method :to_h do
        arguments.zip(values).to_h
      end
    end
  end
end
end
