#!/bin/bash

# Script to set up .devcontainer/devcontainer.json in the current directory

# Create .devcontainer directory if it doesn't exist
mkdir -p .devcontainer

# Download the devcontainer.json.image file from the repo and save as devcontainer.json
curl -s https://raw.githubusercontent.com/jpacheco87/devops-devcontainer/refs/heads/main/.devcontainer/devcontainer.json.image -o .devcontainer/devcontainer.json

echo ".devcontainer/devcontainer.json has been created successfully."