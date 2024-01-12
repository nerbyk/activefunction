# ActiveFunction

Playground gem for Ruby 3.2+ features and more.

Collection of gems designed to be used with FaaS (Function as a Service) computing instances. Inspired by aws-sdk v3 gem structure & rails/activesupport.

## Features

- **Ruby Version Compatibility:** Implemented with most of ruby 3.2+ features, BUT supports Ruby versions >= 2.6 through the use of the [RubyNext](https://github.com/ruby-next/ruby-next) transpiler. (CI'ed)
- **Type Safety:** Achieves type safety through the use of RBS and [Steep](https://github.com/soutaro/steep). (CI'ed)
  - Note: disabled due to the presence of Ruby::UnsupportedSyntax errors.
- **Plugins System:** Provides a simple Plugin system (inspired by [Polishing Ruby Programming by Jeremy Evans](https://github.com/PacktPublishing/Polished-Ruby-Programming)) to load gem plugins as well as self-defined plugins.
- **Gem Collection** Provides a collection of gems designed to be used within ActiveFunction or standalone.

# Gems

- [activefunction](/) - Main gem, provides rails/action-controller like API with callbacks, strong parameters and rendering under plugins.
- [activefunction-core](/gems/activefunction-core/README.md) - Provides RubyNext integration and External Standalone Plugins
- activefunction-orm - WIP (ORM around AWS PartiQL)

## Quick Start

Here's a simple example of a function that uses ActiveFunction:

```ruby
require "active_function"

class AppFunction < ActiveFunction::Base
  def index
    response_with_error if @request[:data].nil?

    return if performed?

    @response.status  = 200
    @response.headers = {"Content-Type" => "application/json"}
    @response.body    = @request[:data]
  end

  private def response_with_error
    @response.status = 400
    @response.commit!
  end
end

AppFunction.process(:index, {data: {id: 1}}) # => { :statusCode=>200, :headers=> {"Content-Type"=>"application/json"}, :body=>{id: 1}"}
```

## Plugins

ActiveFunction supports plugins which can be loaded by `ActiveFunction.config` method. Currently, there are 3 plugins available:
  - [:callbacks](#callbacks) - provides `:before_action` and `:after_action` callbacks with `:if`, `:unless` & `:only` options.
  - [:strong_parameters](#strong-parameters) - provides strong parameters support via `#params` instance method.
  - [:rendering](#rendering) - provides rendering support via `#render` instance method.

## Configuration

To configure ActiveFunction with plugins, use the `ActiveFunction.config` method.

```ruby
# config/initializers/active_function.rb
require "active_function"

ActiveFunction.config do
  plugin :callbacks
  plugin :strong_parameters
  plugin :rendering
end
```

```ruby
# app/functions/app_function.rb
class AppFunction < ActiveFunction::Base
  before_action :parse_user_data

  def index
    render json: @user_data
  end

  private def parse_user_data = @user_data = params.require(:data).permit(:id, :name).to_h
end
```

Use `#process` method to proceed the request:

```ruby
# handler.rb
AppFunction.process(:index, {data: { id: 1, name: 2}}) # => { :statusCode=>200, :headers=> {"Content-Type"=>"application/json"}, :body=>"{\"id\":1,\"name\":2}"}
```


## Callbacks

Simple callbacks engined by [ActiveFunctionCore::Plugins::Hooks](https://github.com/DanilMaximov/activefunction/tree/master/gems/activefunction-core#hooks) external plugin and provides `:before_action` and `:after_action` which runs around provided action in `#process`.

```ruby
require "active_function"

ActiveFunction.config do
  plugin :callbacks
end

class AppFunction < ActiveFunction::Base
  before_action :set_user
  after_action :log_response

  def index
    # some actions ...
  end

  private

  def set_user     = @_user ||= User.find(@request[:id])
  def log_response = Logger.info(@response)
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

ActiveFunction supports strong parameters which can be accessed by `#params` instance method.

The `#params` method represents a Ruby 3.2 Data class that allows the manipulation of request parameters. It supports the following methods:

- `[]`: Access parameters by key.
- `permit`: Specify the allowed parameters.
- `require`: Ensure the presence of a specific parameter.
- `to_h`: Convert the parameters to a hash.

Usage Example:

```ruby
require "active_function"

ActiveFunction.config do
  plugin :strong_parameters
end

class PostsFunction < ActiveFunction::Base
  def index
    @response.body = permitted_params
  end

  def permitted_params = params
    .require(:data)
    .permit(:id, :name)
    .to_h
end

PostFunction.process(:index, data: {id: 1, name: "Pupa"})
```

Strong params supports nested attributes
```ruby
params.permit(:id, :name, :address => [:city, :street])
```

## Rendering

ActiveFunction supports rendering of JSON. The #render method is used for rendering responses. It accepts the following options:

- `head`: Set response headers. Defaults to `{ "Content-Type" => "application/json" }`.
- `json`: Set the response body with a JSON-like object. Defaults to `{}`.
- `status`: Set the HTTP status code. Defaults to `200`.

Additionally, the method automatically commits the response and JSONifies the body.

Usage Example:
```ruby
require "active_function"

ActiveFunction.config do
  plugin :rendering
end

class PostsFunction < ActiveFunction::Base
  def index
    render json: {id: 1, name: "Pupa"}, status: 200, head: {"Some-Header" => "Some-Value"}
  end
end

PostFunction.process(:index) # => { :statusCode=>200, :headers=> {"Content-Type"=>"application/json", "Some-Header" => "Some-Value"}, :body=>"{\"id\":1,\"name\":\"Pupa\"}"}
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem "activefunction"
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
