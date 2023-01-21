# ActiveFunction

rails/action_controller like gem which provides lightweight callbacks, strong parameters & rendering features. It's designed to be used with AWS Lambda functions, but can be used with any Ruby application.

## How

Here's a simple example of a function that uses ActiveFunction:

```ruby
# ./src/functions/posts_function.rb

require 'active_function'

class PostsFunction < ActiveFunction::Base
  before_action :set_blog_post, only: %i[update], if: :authorized?

  def update
    if @blog_post.update(blog_post_attributes)
      render json: @blog_post
    else
      render json: @blog_post.errors, status: 422
    end 
  end
  
  private 

  def authorized = true
  def blog_post_attributes = params.require(:blog_post).permit(:title, :body).to_h
  
  def set_blog_post
    @blog_post = BlogPost.find(params[:id])
  end
end

```

Use `#process` method to call the proceed request:

```ruby
request = {
  "id": 1,
  "blog_post": {
    "title": "New title",
    "body": "New body"
  }
}

PostsFunction.process(:update, request)
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activefunction'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install activefunction


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/activefunction. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/activefunction/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActiveFunction::Functions project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/activefunction/blob/master/CODE_OF_CONDUCT.md).
