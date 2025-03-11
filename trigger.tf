resource "aws_lambda_event_source_mapping" "relay" {
  function_name    = aws_lambda_function.relay.function_name
  event_source_arn = local.kafka_cluster_arn
  enabled          = true

  batch_size        = var.batch_size
  starting_position = var.starting_position
  topics            = var.topics
}
