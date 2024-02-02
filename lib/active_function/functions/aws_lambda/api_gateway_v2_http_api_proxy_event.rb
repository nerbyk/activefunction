module ActiveFunction::Functions::AwsLambda
  class ApiGatewayV2HttpApiProxyEvent
   include ActiveFunctionCore::Plugins::Types

    define_schema do
      type Event => {
        version: String,
        routeKey: String,
        rawPath: String,
        rawQueryString: String,
        cookies: Array[String],
        headers: Hash[Symbol, String],
        requestContext: RequestContext,
        isBase64Encoded: Boolean,
        "?body": String,
        "?pathParameters": Hash[Symbol, String],
        "?queryStringParameters": Hash[Symbol, String],
        "?stageVariables": Hash[Symbol, String]
      }

      type RequestContext => {
        accountId: String,
        apiId: String,
        "?authorizer": Authorizer,
        "?authentication": Authentication,
        domainName: String,
        "?domainPrefix": String,
        http: Http,
        requestId: String,
        routeKey: String,
        stage: String,
        time: String,
        timeEpoch: Integer
      }

      type Authentication => {
        clientCert: ClientCert
      }

      type ClientCert => {
        clientCertPem: String,
        subjectDN: String,
        issuerDN: String,
        serialNumber: String,
        validity: Validity
      }

      type Validity => {
        notBefore: String,
        notAfter: String
      }

      type Authorizer => {
        jwt: JwtAuthorizer
      }

      type JwtAuthorizer => {
        claims: Hash[Symbol, String],
        scopes: Array[String]
      }

      type Http => {
        method: String,
        path: String,
        protocol: String,
        "?sourceIp": String,
        "?userAgent": String
      }
    end
  end
end