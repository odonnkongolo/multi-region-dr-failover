terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# The default provider (Primary Region: Ireland)
provider "aws" {
  region = "eu-west-1"
}

# The alias provider (Backup Region: London)
provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}