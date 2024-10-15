# One2N Assignment

This repository contains the code and configuration for deploying an EC2 instance along with necessary IAM roles, Security Groups, and S3 access policies. The implementation leverages **Python's Boto3 library** for interacting with AWS services.

## Project Overview

The project uses **Boto3** in Python for interaction with AWS resources, and EC2 is used to host the application. The deployment configuration is managed using Terraform.

While large-scale traffic solutions might use load balancers with EC2 targets, in this case, a single EC2 instance was used due to the following reasons:

- **Cost-effectiveness**: Given the relatively low expected traffic, EC2 provided a more cost-efficient solution compared to other services like **Elastic Load Balancers** or **Kubernetes**.
- **Simplicity**: EC2 offers a straightforward and manageable way to host a small application without overengineering the solution.
- **Control**: Hosting on EC2 allows full control over the underlying server, making it easier to customize security settings, IAM roles, and policies.

## Key Technologies Used

- **Boto3 Library**: Used in Python for managing AWS resources such as EC2, S3, and IAM roles.
- **EC2**: Used to deploy the application with appropriate IAM roles, Security Groups, and S3 access policies.
- **Terraform**: Used to automate infrastructure deployment including setting up EC2, IAM, and Security Groups.

## Assumptions

The following assumptions were made for the setup of this project:

1. **S3 bucket**: An S3 bucket is assumed to be created **before** running the Terraform code.
2. **S3 Name**: The S3 bucket name is provided to the Terraform code as an environment variable for seamless integration.
3. **AWS Access**: An AWS access key and secret key with appropriate permissions are provided to run the Terraform code.

## Project Features

- **EC2 Deployment**: The application is hosted on an EC2 instance with a custom security group and IAM roles for secure access.
- **S3 Access Policy**: The EC2 instance is granted access to S3 for handling file storage.
- **IAM Roles**: EC2 has an attached IAM role with restricted permissions for accessing necessary AWS resources.

## Setup Instructions

1. **Clone the Repository**:

```bash
git clone https://github.com/yourusername/one2n-assignment.git
cd one2n-assignment
```

2. **Set up environment variables**: 

```bash 
export S3_BUCKET_NAME=<your-s3-bucket-name>
export AWS_ACCESS_KEY_ID=<your-access-key>
export AWS_SECRET_ACCESS_KEY=<your-secret-key>
```

3. **Run Terraform command**:
```bash
cd terraform/
terraform init
terraform apply
```

4. **Access the site**:
```bash 
http://<virutal_machine_public_ip>:5000
```

## Video Demo
Below is the video demo of above site.

[![Watch the video]](https://github.com/user-attachments/assets/be7e6f28-0102-4c39-8462-02407613e85b)

## Future Considerations
If the application scales and the traffic increases, consider setting up an Elastic Load Balancer (ELB) with EC2 targets to distribute traffic across multiple instances.
Auto-scaling can be introduced for dynamic scaling of EC2 instances based on traffic.