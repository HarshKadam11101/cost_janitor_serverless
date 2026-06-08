resource "aws_s3_bucket" "tfstate" {
  bucket = "aws-cost-janitor-terraform-state-bucket"
}

module "alerts" {
  source = "./modules/sns_alerts"

  environment = "dev"
  alert_email = "harshlk11101@gmail.com"
}

module "compute" {
  source  = "./modules/cost_janitor_lambda"
  env     = "dev"
  sns_arn = module.alerts.topic_arn
}

module "scheduler" {
  source               = "./modules/eventbridge_scheduler"
  environment          = "dev"
  lambda_arn           = module.compute.lambda_arn
  lambda_function_name = module.compute.lambda_name
}