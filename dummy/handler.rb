RESOURCE_ROUTES = {
  'GET /'       => :index,
  'POST /'      => :create,
  'GET /:id'    => :show,
  'PUT /:id'    => :update,
  'PATCH /:id'  => :update,
  'DELETE /:id' => :destroy
}.freeze


def handler(event:, context:)
  params =  JSON.parse(event, symbolize_names: true)
                .slice(:body, :pathParameters, :queryStringParameters, :headers)
                .merge(Hash[context: context])
  http_method = event[:requestContext][:http][:method]
  action = RESOURCE_ROUTES[http_method]

  BlogPostFunction.process(action, request: params)
end
