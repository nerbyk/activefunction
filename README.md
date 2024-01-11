# ActiveFunction

Collection of gems designed to be used with FaaS (Function as a Service) computing instances. Inspired by aws-sdk v3 gem structure & rails/activesupport.

Implemented with most of ruby 3.2+ features, but also supports ruby >= 2.6 thanks to [RubyNext](https://github.com/ruby-next/ruby-next) transpiler. 

Type safety achieved by RBS and [Steep](https://github.com/soutaro/steep) (Disabled due to number of Ruby::UnsupportedSyntax errors)


# Gems 

- [activefunction](/) - Main gem, provides rails/action-controller like API
- [activefunction-core](/gems/activefunction-core/README.md) - Provides RubyNext integration and Plugins module
- activefunction-orm - WIP

## A Short Example

Here's a simple example of a function that uses ActiveFunction:

```ruby
require 'active_function'

class AppFunction < ActiveFunction::Base
  def index 
    render json: SomeTable.all
  end 
end
```

Use `#process` method to proceed the request:

```ruby 
AppFunction.process(:index) # processes index action of AppFunction instance
```
Also check extended [example](https://github.com/DanilMaximov/activefunction/tree/master/active_function_example)
## Callbacks 

ActiveFunction supports simple callbacks engined by [ActiveFunctionCore::Plugins::Hooks](https://github.com/DanilMaximov/activefunction/tree/master/gems/activefunction-core#hooks) plugin and provides `:before_action` and `:after_action` which runs around provided action in `#process`.  

```ruby
class AppFunction < ActiveFunction::Base
  before_action :set_user 
  after_action :log_response
  
  # some action ...

  private 

  def set_user 
    @user = User.first
  end 

  def log_response 
    Logger.info @response 
  end
end
```

### Callbacks options

Supports default [ActiveFunctionCore::Plugins::Hooks::Hook::Callback options](https://github.com/DanilMaximov/activefunction/tree/master/gems/activefunction-core#options) `:if => Symbol` & `:unless => Symbol` options.

Support custom defined in ActiveFunction::Function::Callbacks `only: Array[Symbol]` option.

```ruby
class AppFunction < ActiveFunction::Base
  before_action :set_user, only: %i[show update destroy], if: :request_valid?
  
  # some actions ...
  
  private def request_valid? = true
end
```
More details in [ActiveFunctionCore::Plugins::Hooks readme](https://github.com/DanilMaximov/activefunction/tree/master/gems/activefunction-core#hooks)

## Strong Parameters
ActiveFunction supports strong parameters which can be accessed by `#params` instance method. Strong parameters hash can be passed in `#process` as second argument.

```ruby
PostFunction.process(:index, data: { id: 1, name: "Pupa" })
```

Simple usage:
```ruby
class PostsFunction < ActiveFunction::Base
  def index 
    render json: permitted_params
  end 

  def permitted_params = params
    .require(:data)
    .permit(:id, :name)
    .to_h
end 
```
Strong params supports nested attributes
```ruby 
params.permit(:id, :name, :address => [:city, :street])
```

## Rendering
ActiveFunction supports rendering of JSON. Rendering is obligatory for any function naction and can be done by `#render` method.
```ruby
class PostsFunction < ActiveFunction::Base
  def index 
    render json: { id: 1, name: "Pupa" }
  end 
end
```
default status code is 200, but it can be changed by `:status` option
```ruby
class PostsFunction < ActiveFunction::Base
  def index 
    render json: { id: 1, name: "Pupa" }, status: 201
  end 
end
```
Headers can be passed by `:headers` option. Default headers are `{"Content-Type" => "application/json"}`.
```ruby
class PostsFunction < ActiveFunction::Base
  def index 
    render json: { id: 1, name: "Pupa" }, headers: { "X-Request-Id" => "123" }
  end 
end
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activefunction'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/rake test` to run the tests and `bin/rake steep` to run type checker. 

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/DanilMaximov/activefunction. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/DanilMaximov/activefunction/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActiveFunction::Functions project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/DanilMaximov/activefunction/blob/master/CODE_OF_CONDUCT.md).
