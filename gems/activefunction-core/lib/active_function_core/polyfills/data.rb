# frozen_string_literal: true

require "set"
require "forwardable"

begin
  Object.send(:remove_const, :Data)
rescue
  nil
end

class Data < Object
  extend Forwardable

  class MissingKeywordError < ArgumentError
    MESSAGE_TEMPLATE        = "missing keyword: %s"
    MESSAGE_TEMPLATE_PLURAL = "missing keywords: %s"

    def initialize(missing_keywords)
      message = if missing_keywords.size == 1
        MESSAGE_TEMPLATE % missing_keywords[0]
      else
        MESSAGE_TEMPLATE_PLURAL % missing_keywords.join(", ")
      end

      raise ArgumentError, message
    end
  end

  class UnknownKeywordError < ArgumentError
    MESSAGE_TEMPLATE        = "unknown keyword: %s"
    MESSAGE_TEMPLATE_PLURAL = "unknown keywords: %s"

    def initialize(*unknown_keywords)
      message = if unknown_keywords.size == 1
        MESSAGE_TEMPLATE % unknown_keywords[0]
      else
        MESSAGE_TEMPLATE_PLURAL % unknown_keywords.join(", ")
      end

      super(message)

      raise ArgumentError, message
    end
  end

  class WrongArgumentsNumberError < ArgumentError
    MESSAGE_TEMPLATE = "wrong number of arguments (given %s, expected %s)"

    def initialize(given, expected)
      message = MESSAGE_TEMPLATE % [given, expected]

      raise ArgumentError, message
    end
  end

  class << self
    alias_method :[], :new
  end

  def self.define(*args, &block)
    members = args.map do |v|
      raise TypeError, "#{v} is not a symbol" unless v.respond_to?(:to_sym)

      v.to_sym
    end

    ::Class.new(self).tap do |klass|
      klass.instance_variable_set(:@members, Set.new(members))
      members.each { |member| klass.attr_accessor(member) }
      klass.class_eval(&block) if block
    end
  end

  def self.members
    instance_variable_get(:@members).to_a
  end

  def self._members
    instance_variable_get(:@members)
  end

  def self.name
    name = super

    name == "Data" ? nil : name
  end

  def initialize(*args, **kwargs)
    if args.any?
      raise ArgumentError, format(WRONG_NUMBER_OF_ARGUMENTS, [args.size, expected]) if args.size != members.size

      self.class.members.each_with_index do |name, i|
        instance_variable_set("@#{name}", args[i])
      end
    elsif kwargs.any?
      kwargs.each { |name, value| instance_variable_set("@#{name}", value) } if _members | kwargs.keys == _members

      missing_members = stringify(members - kwargs.keys)

      raise MissingKeywordError, missing_members if missing_members.any?

      unknown_kwargs = stringify(kwargs.keys - members)

      raise UnknownKeywordError, unknown_kwargs if unknown_kwargs.any?
    elsif members.any?
      raise MissingKeywordError, stringify(members)
    end
  end

  def members
    self.class.members
  end

  def _members
    self.class._members
  end

  def to_h
    self.class.members.each_with_object({}) do |member, hash|
      hash[member] = instance_variable_get("@#{member}")
    end
  end

  def to_s
    attributes = to_h.map { |k, v| "#{k}=#{v}" }.join(", ")

    "<#data #{self.class.name} #{attributes}>"
  end

  private

  def stringify(arr)
    arr.map { |v| ":#{v}" }
  end

  alias_method :inspect, :to_s
end
