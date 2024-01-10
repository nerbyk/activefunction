# ActiveFunction Core

Inspired by the structure of the AWS SDK gem, `activefunction-core` seamlessly integrates with the `activefunction` library family, offering a unified interface. It's also designed to operate as a standalone solution.

## Features

- **Ruby-Next Integration:** Enables ruby-next auto-transpiling mode. This allows to use latest Ruby syntax while maintaining compatibility with older versions.
- **Plugins:** Extends functionality via plugin capabilities, including a callbacks DSL for `before_action` and `after_action` implementation within classes.


## Plugins

### Hooks

Provides ActiveSupport::Callbacks like DSL for hooks through `::define_hooks_for` to define `before_[method_name]` & `after_[method_name]` callbacks and redefined #method_name to execute callbacks around it. 

### Usage

```ruby
class YourClass
  include ActiveFunction::Core::Plugins::Hooks

  define_hooks_for :your_method

  before_your_method :do_something_before
  after_your_method :do_something_after

  def your_method
    # Method implementation here...
  end

  private

  def do_something_before
    # Callback logic to execute before your_method
  end

  def do_something_after
    # Callback logic to execute after your_method
  end
end
``` 

### Hook Method Alias

If you need to alias the method name, you can do so by passing the `:name` option.

```ruby
define_hooks_for :your_method, name: :your_method_alias
before_your_method_alias :do_something_before
```

### Options

Supports options for `before_[method_name]` & `after_[method_name]` callbacks. Each option is a Proc that return a Bool. By default, `:if` & `:unless` options are vailable, accepting method name.

```ruby

class YourClass
  include ActiveFunction::Core::Plugins::Hooks

  define_hooks_for :your_method

  before_your_method :do_something_before, if: :condition_met?
  after_your_method :do_something_after, unless: :condition_met?

  def your_method
    # Method implementation here...
  end

  private

  def condition_met?
    # Condition logic here...
  end

  def do_something_before
    # Callback logic to execute before your_method
  end

  def do_something_after
    # Callback logic to execute after your_method
  end
end
```

Using `::set_callback_options` method, you can define your own options. This method accepts a single attribute Hash where the key is the option name and the value is a Proc that returns a Bool. Specify `context:` keyword argument for proc to access current class instance.

```ruby
class YourClass
  include ActiveFunction::Core::Plugins::Hooks

  set_callback_options only: ->(only_methods, context:) { only_methods.include?(context.action) }

  define_hooks_for :your_method

  before_your_method :do_something_before, only: %[foo bar]

  def action = "foo"
end
```

### Callbacks Inheritance

Callbacks are inheritable so all callbacks calls will be inherited from base class.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/rake test:all` to run the tests and `bin/rake steep` to run type checker. 

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/DanilMaximov/activefunction. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/DanilMaximov/activefunction/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActiveFunction::Functions project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/DanilMaximov/activefunction/blob/master/CODE_OF_CONDUCT.md).
