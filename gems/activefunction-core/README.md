# ActiveFunction

rails/action_controller like gem which provides lightweight callbacks, strong parameters & rendering features. It's designed to be used with AWS Lambda functions, but can be also used with any Ruby application. 

Implemented with some of ruby 3.x features, but also supports ruby 2.6.x thanks to [RubyNext](https://github.com/ruby-next/ruby-next) transpiler. Type safety achieved by RBS and [Steep](https://github.com/soutaro/steep).


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
ActiveFunction supports simple callbacks `:before` and `:after` which runs around provided action in `#process`. 

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

Callbacks also can be user  with `only: Array[Symbol]` and `if: Symbol` options.

```ruby
class AppFunction < ActiveFunction::Base
  before_action :set_user, only: %i[show update destroy], if: :request_valid?
  
  # some actions ...
  
  private def request_valid? = true
end
```

Callbacks are inheritable so all callbacks calls will be inherited from base class
```ruby
class BaseFunction < ActiveFunction::Base
  before_action :set_current_user

  def set_current_user
    @current_user = User.first
  end 
end

class PostsFunction < BaseFunction
  def index
    render json: @current_user
  end
end
```
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
gem 'activefunction', git: "https://github.com/DanilMaximov/activefunction.git"
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
