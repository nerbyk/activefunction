module ActiveFunction
  class EventSource
    SOURCES = [
      CLOUDFRONT = 'Cloudfront',
      AWS_CONFIG = 'AwsConfig',
      CODE_COMMIT = 'CodeCommit',
      API_GATEWAY_AUTHORIZER = 'ApiGatewayAuthorizer',
      CLOUD_FORMATION = 'CloudFormation',
      SES = 'Ses',
      API_GATEWAY_AWS_PROXY = 'ApiGatewayAwsProxy',
      SCHEDULED_EVENT = 'ScheduledEvent',
      CLOUD_WATCH_LOGS = 'CloudWatchLogs',
      SNS = 'Sns',
      DYNAMO_DB = 'DynamoDb',
      KINESIS_FIREHOSE = 'KinesisFirehose',
      COGNITO_SYNC_TRIGGER = 'CognitoSyncTrigger',
      KINESIS = 'Kinesis',
      S3 =  'S3',
      MOBILE_BACKEND = 'MobileBackend',
      SQS = 'Sqs'
    ].freeze
    
    def self.call(event)
      return API_GATEWAY_AWS_PROXY  if event["pathParameters"] && event["pathParameters"]["proxy"]
      return DYNAMO_DB              if event["Records"] && (event["Records"][0]["EventSource"] == 'aws:dynamodb')
      return SQS                    if event["Records"] && event["Records"][0]["EventSource"] == 'aws:sqs'
      return CLOUD_WATCH_LOGS       if event["awslogs"] && event["awslogs"]["data"]
      return CLOUDFRONT             if event["Records"] && event["Records"][0]["cf"]
      return S3                     if event["Records"] && event["Records"][0]["EventSource"] == 'aws:s3'
      return CLOUD_FORMATION        if event["StackId"] && event["RequestType"] && event["ResourceType"]
      return SCHEDULED_EVENT        if event["source"] == 'aws.events'
      return API_GATEWAY_AUTHORIZER if event["authorizationToken"] == "incoming-client-token"
      return AWS_CONFIG             if event["configRuleId"] && event["configRuleName"] && event["configRuleArn"]
      return CODE_COMMIT            if event["Records"] && (event["Records"][0]["eventSource"] == 'aws:codecommit')
      return SES                    if event["Records"] && (event["Records"][0]["EventSource"] == 'aws:ses')
      return SNS                    if event["Records"] && (event["Records"][0]["EventSource"] == 'aws:sns')
      return KINESIS_FIREHOSE       if event["Records"] && event["Records"][0]["approximateArrivalTimestamp"]
      return KINESIS_FIREHOSE       if event["Records"] && event["deliveryStreamArn"] && event["deliveryStreamArn"].start_with?('arn:aws:kinesis:')
      return COGNITO_SYNC_TRIGGER   if event["eventType"] == 'SyncTrigger' && event["identityId"] && event["identityPoolId"]
      return KINESIS                if event["Records"] && event["Records"][0]["EventSource"] == 'aws:kinesis'
      return MOBILE_BACKEND         if event["operation"] && event["message"]
    end
  end
end