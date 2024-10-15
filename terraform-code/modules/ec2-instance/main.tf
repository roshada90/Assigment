


# Create IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "ec2_s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    "Owner"   = var.owner
    "UseCase" = var.usecase
  }
}

# Attach Policy to IAM Role
resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3_access_policy"
  description = "S3 access policy for EC2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_name}"
        ]
      },
    ]
  })

  tags = {
    "Owner"   = var.owner
    "UseCase" = var.usecase
  }

}

resource "aws_iam_role_policy_attachment" "s3_access" {
  policy_arn = aws_iam_policy.s3_access_policy.arn
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_instance_profile" "ec2_s3_instance_profile" {
  name = "ec2_s3_access_instance_profile"  # Instance Profile name
  role = aws_iam_role.ec2_role.name
}

# Create a Security Group for the EC2 Instance
resource "aws_security_group" "ec2_sg" {
  name        = "ec2_security_group"
  description = "Allow HTTP and HTTPS traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Owner"   = var.owner
    "UseCase" = var.usecase
  }
}

resource "aws_key_pair" "my_instance_key" {
  key_name   = "my-instance"
  public_key = file("${path.module}/my-instance.pub")
}




resource "aws_instance" "ec2" {
  ami           = "ami-078264b8ba71bc45e"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_instance_key.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_s3_instance_profile.name
  security_groups      = [aws_security_group.ec2_sg.name]

  user_data = <<-EOF
    #!/bin/bash
    # Update and install necessary packages
    sudo yum update -y
    sudo yum install -y python3 python3-pip

    # Set the BUCKET_NAME environment variable
    echo 'export BUCKET_NAME="${var.bucket_name}"' >> /etc/environment
    source /etc/environment

    # Create a virtual environment and install dependencies
    app_location="/home/ec2-user/python-app"
    python3 -m venv $app_location/venv
    source $app_location/venv/bin/activate

    # Create the app.py file on the EC2 instance
    cat <<EOL > $app_location/app.py
    ${file("${path.module}/../../../python-app/app.py")}
    EOL

    # Create the requirements.txt file on the EC2 instance
    cat <<EOL > $app_location/requirements.txt
    ${file("${path.module}/../../../python-app/requirements.txt")}
    EOL

    # Install dependencies from requirements.txt
    pip install -r $app_location/requirements.txt

    # Run the application
    nohup python3 $app_location/app.py > app.log 2>&1 &

    EOF

  tags = {
    "Owner"   = var.owner
    "UseCase" = var.usecase
  }
}
