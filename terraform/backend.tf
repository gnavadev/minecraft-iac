terraform {
  required_version = ">= 1.10"

  backend "s3" {
    bucket       = "REPLACE-WITH-YOUR-UNIQUE-BUCKET-NAME" # from scripts/00-bootstrap-state.sh
    key          = "minecraft/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true # S3-native locking, no DynamoDB needed
  }
}
