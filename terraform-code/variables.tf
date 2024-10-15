variable "bucket_name" {
  description = "Name of S3 bucket"
  type = string
  default = "roshada-assignment"
}

variable "aws_access_key" {
  description = "AWS Access Key"
  type = string
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type = string
}