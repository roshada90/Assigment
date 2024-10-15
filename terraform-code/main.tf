
# create ec2
module "ec2_instance" {
  source = "./modules/ec2-instance"
  bucket_name = var.bucket_name
  usecase = "One2N Assignment"
  owner = "Roshada"
}

