
resource "aws_iam_role" "ec2_instance_role" {
  name = "ec2-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_readonly_attach" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_instance_role.name
}

resource "aws_instance" "main_instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = "devops-key"
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker aws-cli
    systemctl enable docker
    systemctl start docker
    usermod -aG docker ec2-user

    aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 003270868633.dkr.ecr.us-west-2.amazonaws.com

    docker pull 003270868633.dkr.ecr.us-west-2.amazonaws.com/my-python-app:latest

    docker run -d -p 5000:5000 003270868633.dkr.ecr.us-west-2.amazonaws.com/my-python-app:latest
  EOF

  tags = {
    Name = "main-instance"
  }
}
