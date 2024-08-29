provider "aws" {
  region     = "us-west-2"
  access_key = "AKIA2UC3AMBRMFOKWBUC"
  secret_key = "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"
}


# cidr block var.vpc_cidr_block
# VPC
resource "aws_vpc" "ass_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "ass_vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "ass_igw" {
  vpc_id = aws_vpc.ass_vpc.id

  tags = {
    Name = "ass_igw"
  }
}

# Public Subnets
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.ass_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Public-subnet"
  }
}




# Route Table for Public Subnets
resource "aws_route_table" "ass_public_rt" {
  vpc_id = aws_vpc.ass_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ass_igw.id
  }

  tags = {
    Name = "ass_public_rt"
  }
}

# Associate Public Subnets with Route Table public_subnet count ass_public_subnet_assoc [count.index]
resource "aws_route_table_association" "ass_public_subnet_assoc" {
  count          = length(aws_subnet.main)
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.ass_public_rt.id
}

# Security Group for Frontend Servers (HTTP/HTTPS access)
resource "aws_security_group" "frontend_sg" {
  vpc_id = aws_vpc.ass_vpc.id

  ingress {
    description      = "Allow HTTP traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow HTTPS traffic"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "frontend_sg"
  }
}

# Security Group for Backend Servers (SSH access)
resource "aws_security_group" "backend_sg" {
  vpc_id = aws_vpc.ass_vpc.id

  ingress {
    description      = "Allow SSH traffic"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "backend_sg"
  }
}


# Backend Servers subnet id [0] key_name,  key_name      = var.terraform_ass_kp.pem  # Ensure you have a key pair specified
resource "aws_instance" "backend_servers" {
  count         = 4  # Number of backend servers to be created
  ami           = "ami-05134c8ef96964280"  # Replace with a valid AMI ID for your region
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id  # Using the first public subnet for backend servers
  vpc_security_group_ids = [aws_security_group.backend_sg.id]

  tags = {
    Name = "backend-server-${count.index}"
  }
}



# Frontend Servers
resource "aws_instance" "frontend_servers" {
  count         = 2
  ami           = "ami-05134c8ef96964280"  # Replace with a valid AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id  # Use the same subnet as backend servers
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]

  tags = {
    Name = "frontend-server-${count.index}"
  }
}


# S3 Bucket
resource "aws_s3_bucket" "ass_bucket" {
  bucket = "my-ass-s3buc-12345"  # Ensure this bucket name is globally unique

  tags = {
    Name        = "ass_bucket"
    Environment = "dev"
  }
}
