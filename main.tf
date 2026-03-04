provider "aws" {
    region = "us-east-1"    
}

resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = { Name = "my_vpc" }
}

resource "aws_subnet" "my_subnet" {
    vpc_id            = aws_vpc.my_vpc.id
    availability_zone = "us-east-1a"
    cidr_block        = "10.0.1.0/24"
    tags = { Name = "my_subnet" }
}

resource "aws_security_group" "my_sg" {
    name        = "my_sg"
    description = "Allow SSH and HTTP"
    vpc_id      = aws_vpc.my_vpc.id
    
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id
    tags = { Name = "my_igw" }
}

resource "aws_route_table" "my_rt" {
    vpc_id = aws_vpc.my_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_igw.id
    }
}

resource "aws_route_table_association" "my_rta" {
    subnet_id      = aws_subnet.my_subnet.id
    route_table_id = aws_route_table.my_rt.id
}

resource "aws_instance" "my_instance" {
    ami                         = "ami-051a31ab2f4d498f5"
    instance_type               = "t2.micro"
    key_name                    = "chaithra"
    subnet_id                   = aws_subnet.my_subnet.id
    # Note: Using security_groups with VPC IDs can sometimes be finicky; 
    # vpc_security_group_ids is usually preferred for VPC instances.
    vpc_security_group_ids      = [aws_security_group.my_sg.id]
    associate_public_ip_address = true
    
    tags = { Name = "my_instance" }
}

output "publicIP" {
    value = aws_instance.my_instance.public_ip
} 
