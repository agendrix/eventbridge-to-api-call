terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
