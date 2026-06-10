terraform {
  required_version = ">= 1.10"

  backend "s3" {
    bucket       = "navag-minecraft-project"
    key          = "minecraft/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
