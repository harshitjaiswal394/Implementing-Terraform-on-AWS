#############################################################################
# VARIABLES
#############################################################################

variable "region_1" {
  type    = string
  default = "us-east-1"
}

variable "region_2" {
  type    = string
  default = "us-west-1"
}

variable "vpc_cidr_range_east" {
  type    = string
  default = "10.10.0.0/16"
}

variable "public_subnets_east" {
  type    = list(string)
  default = ["10.10.0.0/24", "10.10.1.0/24"]
}

variable "vpc_cidr_range_west" {
  type    = string
  default = "10.11.0.0/16"
}

variable "public_subnets_west" {
  type    = list(string)
  default = ["10.11.0.0/24", "10.11.1.0/24"]
}

#############################################################################
# PROVIDERS
#############################################################################

provider "aws" {
  version = "~> 2.0"
  region  = var.region_1
  profile = "infra"
  alias = "east"
}

provider "aws" {
  version = "~> 2.0"
  region  = var.region_2
  profile = "infra"
  alias = "west"
}

#############################################################################
# DATA SOURCES
#############################################################################

data "aws_availability_zones" "azs_east" {
    provider = aws.east
}

data "aws_availability_zones" "azs_west" {
    provider = aws.west
}

#############################################################################
# RESOURCES
#############################################################################  

module "vpc_east" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.33.0"

  name = "prod-vpc-east"
  cidr = var.vpc_cidr_range_east

  azs            = slice(data.aws_availability_zones.azs_east.names, 0, 1)
  public_subnets = var.public_subnets_east

  providers = {
      aws = aws.east
  }

  tags = {
    Environment = "prod"
    Region = "east"
    Team        = "infra"
  }

}

module "vpc_west" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.33.0"

  name = "prod-vpc-west"
  cidr = var.vpc_cidr_range_west

  azs            = slice(data.aws_availability_zones.azs_west.names, 0, 1)
  public_subnets = var.public_subnets_west

  providers = {
      aws = aws.west
  }

  tags = {
    Environment = "prod"
    Region = "west"
    Team        = "infra"
  }

}

#############################################################################
# OUTPUTS
#############################################################################

output "vpc_id_east" {
  value = module.vpc_east.vpc_id
}

output "vpc_id_west" {
  value = module.vpc_west.vpc_id
}
