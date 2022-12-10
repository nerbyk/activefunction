module ActiveFunction
  class EventSource
    SOURCES = [
      AWS_CONFIG             = "AwsConfig",
      CODE_COMMIT            = "CodeCommit",
      API_GATEWAY_AUTHORIZER = "ApiGatewayAuthorizer",
      API_GATEWAY_HTTP       = "ApiGatewayHttp",
      CLOUD_FORMATION        = "CloudFormation",
      SES                    = "Ses",
      CLOUD_WATCH_LOGS       = "CloudWatchLogs",
      SNS                    = "Sns",
      DYNAMO_DB              = "DynamoDb",
      KINESIS_FIREHOSE       = "KinesisFirehose",
      COGNITO_SYNC_TRIGGER   = "CognitoSyncTrigger",
      KINESIS                = "Kinesis",
      S3                     = "S3",
      SQS                    = "Sqs"
    ].freeze

    RECORDS_EVENT_SOURCES = {
      "aws:s3"         => S3,
      "aws:dynamodb"   => DYNAMO_DB,
      "aws:sqs"        => SQS,
      "aws:codecommit" => CODE_COMMIT,
      "aws:ses"        => SES,
      "aws:sns"        => SNS,
      "aws:kinesis"    => KINESIS
    }.freeze

    private_constant :RECORDS_EVENT_SOURCES

    def self.call(event)
      case event
      in Records: [{ eventSource:_ }, *], ** then RECORDS_EVENT_SOURCES[event[:Records][0][:eventSource]]
      in { Records: [{ approximateArrivalTimestamp: _ }, *], ** } | { deliveryStreamArn: /\Aarn:aws:kinesis:/, **} then KINESIS_FIREHOSE
      in requestContext: { resourceId: String, **}, ** then API_GATEWAY_HTTP
      in awslogs: { data: String } then CLOUD_WATCH_LOGS
      in StackId:_, RequestType:_, ResourceType:_, ** then CLOUD_FORMATION
      in authorizationToken: "incoming-client-token", ** then API_GATEWAY_AUTHORIZER
      in configRuleId:_, configRuleName:_, configRuleArn:_, ** then AWS_CONFIG
      in eventType: "SyncTrigger", identityId:_, identityPoolId:_, ** then COGNITO_SYNC_TRIGGER
      else 
        raise ArgumentError, "Unknown event source"
      end
    end
  end
end
