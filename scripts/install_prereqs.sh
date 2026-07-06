#!/bin/bash

set -e

echo "=========================================="
echo " DevOps Prerequisites Installation"
echo "=========================================="

# Update system
echo "Updating packages..."
sudo apt update -y
sudo apt upgrade -y

# Git
echo "Installing Git..."
sudo apt install -y git

# Java 17
echo "Installing OpenJDK 17..."
sudo apt install -y openjdk-17-jdk

# Maven
echo "Installing Maven..."
sudo apt install -y maven

# unzip
sudo apt install -y unzip

# wget & curl
sudo apt install -y wget curl

# Tree
sudo apt install -y tree

# jq
sudo apt install -y jq

# zip
sudo apt install -y zip

# Python
sudo apt install -y python3 python3-pip

# Ansible
echo "Installing Ansible..."
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt update
sudo apt install -y ansible

# Jenkins
echo "Installing Jenkins..."

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | \
sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb \
[signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/ | \
sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install -y jenkins

sudo systemctl enable jenkins
sudo systemctl start jenkins

# Tomcat
echo "Installing Tomcat..."

sudo apt install -y tomcat10 tomcat10-admin

sudo systemctl enable tomcat10
sudo systemctl start tomcat10

# Azure CLI
echo "Installing Azure CLI..."

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Terraform
echo "Installing Terraform..."

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo \
"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update

sudo apt install -y terraform

echo
echo "======================================="
echo "Installed Versions"
echo "======================================="

java -version
echo

mvn -version
echo

git --version
echo

ansible --version | head -1
echo

terraform version
echo

az version | head
echo

jenkins --version || true
echo

echo "======================================="
echo "Installation Completed Successfully"
echo "======================================="
