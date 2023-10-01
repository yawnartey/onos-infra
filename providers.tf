terraform {

  required_version = "1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }

    backend "s3" {
        bucket = "terraform-statefile-onos"
        key    = "terraform-statefile-onos.tfstate"
        region = "us-east-1"
        profile = "personal_1"
    }
}

provider "aws" {
  region  = "us-east-1"
  profile = "personal_1"
}
