#!/bin/bash

# Stop and remove all Docker containers
sudo docker stop $(sudo docker ps -aq)
sudo docker rm $(sudo docker ps -aq)

# Remove existing Docker packages
sudo apt-get remove -y docker docker-engine docker.io containerd runc

# Update package lists
sudo apt-get update

# Install necessary dependencies
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker's repository to APT sources
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package lists again
sudo apt-get update

# Install Docker engine
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add current user to the docker group
sudo usermod -aG docker "$USER"

# Enable Docker service to start on boot
sudo systemctl enable docker

# Display Docker version
docker version
