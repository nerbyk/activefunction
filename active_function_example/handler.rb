# frozen_string_literal: true

RESOURCE_ROUTES = {
  "GET /" => :index,
  "POST /" => :create,
  "GET /:id" => :show,
  "PUT /:id" => :update,
  "PATCH /:id" => :update,
  "DELETE /:id" => :destroy
}.freeze

def handler(event:, context:)
  params = event
    .slice(:body, :pathParameters, :queryStringParameters, :headers)
    .merge(context: context)
  http_method = event[:requestContext][:http][:method]
  action = RESOURCE_ROUTES[http_method]

  BlogPostFunction.process(action, params)
end
