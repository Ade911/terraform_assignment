variable "aws_region" {
  description = "The AWS region to deploy resources into."
  default     = "us-west-2"
}

variable "instance_type" {
  description = "The EC2 instance type."
  default     = "t2.micro"
}

variable "ami_id" {
  description = "The ID of the AMI to use for the EC 2 instances."
   default =  "ami-05134c8ef96964280"
}


variable "subnet_id" {
  description = "The ID of the subnet to deploy the EC2 instance into is provided here."
}

variable "security_group_ids" {
  description = "A list of security group IDs to attach to the EC2 instance."
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to apply to AWS resources."
  type        = map(string)
}

