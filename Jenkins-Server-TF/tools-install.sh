#!/bin/bash

set -e  # Exit on error

echo "Updating system packages..."
sudo apt update -y

# Installing Java (JDK 17)
echo "Installing OpenJDK 17..."
sudo apt install -y openjdk-17-jdk
java --version || { echo "Java installation failed"; exit 1; }

# Installing Jenkins
echo "Installing Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update -y
sudo apt install -y jenkins

# Installing Docker
echo "Installing Docker..."
sudo apt install -y docker.io
sudo usermod -aG docker jenkins
sudo usermod -aG docker $USER  # Add current user to Docker group
sudo systemctl enable --now docker
sudo chmod 777 /var/run/docker.sock

# Run Jenkins in Docker (Optional)
# docker run -d -p 8080:8080 -p 50000:50000 --name jenkins-container jenkins/jenkins:lts

# Run SonarQube in Docker
echo "Starting SonarQube container..."
docker run -d --name sonar -p 9000:9000 sonarqube:lts

# Installing AWS CLI
echo "Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install -y unzip
unzip awscliv2.zip
sudo ./aws/install
aws --version || { echo "AWS CLI installation failed"; exit 1; }

# Installing Kubectl
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/v1.28.4/bin/linux/amd64/kubectl"
sudo chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client || { echo "Kubectl installation failed"; exit 1; }

# Installing Terraform
echo "Installing Terraform..."
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install -y terraform
terraform -version || { echo "Terraform installation failed"; exit 1; }

# Installing Trivy
echo "Installing Trivy..."
sudo apt-get install -y wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo gpg --dearmor -o /usr/share/keyrings/trivy-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/trivy-keyring.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt update
sudo apt install -y trivy
trivy --version || { echo "Trivy installation failed"; exit 1; }

echo "✅ All installations completed successfully!"
