resource "aws_instance" "k8s_node" {
  ami = data.aws_ami.ubuntu
  instance_type = "t3.small"
  subnet_id = var.lambda_private_subnet

  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  iam_instance_profile = aws_iam_instance_profile.k8s_profile.namee

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              # 1. Install AWS CLI
              apt-get install -y unzip
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip && ./aws/install

              # 2. Install k3s
              curl -sfL https://get.k3s.io | sh -
              
              # 3. Get the internal IP and modify the config
              INTERNAL_IP=$(hostname -I | awk '{print $1}')
              sed -i "s/127.0.0.1/$INTERNAL_IP/g" /etc/rancher/k3s/k3s.yaml

              # 4. Convert to Base64 (ignoring line breaks)
              B64_CONFIG=$(base64 -w 0 /etc/rancher/k3s/k3s.yaml)

              # 5. Push straight to AWS Systems Manager
              aws ssm put-parameter \
                --name "/dev-portal/k3s/kubeconfig" \
                --value "$B64_CONFIG" \
                --type "SecureString" \
                --overwrite \
                --region eu-central-1
              EOF

  tags = {
    Name = "${var.env}-k8s-worker"
    Environment = "${var.env}"
  }
}