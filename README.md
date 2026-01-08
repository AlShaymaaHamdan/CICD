# Node.js CI/CD Pipeline :
______
This repository contains an automated CI/CD pipeline for building, packaging, containerizing, promoting, and deploying a Node.js application using:

GitHub Actions

AWS ECR (Elastic Container Registry)

EC2 Instance (Node.js App running in Docker)

The workflow is fully automated and runs on:
```bash
push to main
pull_request to main
```
## Pipeline Overview 
The workflow consists of 6 jobs, executed in this order:

1- prepare
Extracts the version, uploads version artifact.

2- config_aws
Configures AWS credentials and ECR login.

3- build
Installs Node.js dependencies, packages the app, uploads build artifacts.

4- docker
Builds Docker image, pushes it to AWS ECR using the extracted version.

5- promote
Finds last test tag and "promotes" it to production based on logic in promote.sh.

6- deploy
SSH into EC2 server, pulls promoted image, stops old container, runs new version.

## AWS Configuration
1. Create IAM User for GitHub Actions

2. Attach Policy "AmazonEC2ContainerRegistryPowerUser" to the user.
3. Create Access Key and save the credentials.
4. Create ECR Repository (cicd-shaymaa)
5. Launch EC2 server and configure it.
 EC2 Configuration:
  - install Docker on it.
  - Configure the EC2 SG: Inbound Rules (SSH, HTTP, Port 3000)

## GitHub Configuration:
  Add these secrets to GH Actions Secrets:
  - AWS_ACCESS_KEY_ID
  - AWS_SECRET_ACCESS_KEY
  - AWS_REGION
  - AWS_ECR_URI
  - PUPLIC_IP
  - HOST_NAME
  - PRIVATE_KEY
 


## Shell Scripts Used in the WF
 - **version_extract.sh**: Extracts the app version from package.json and saves it to version.yaml.
 - **load_version.sh**: Loads the saved version from version.yaml into environment variables for later steps.
 - **package_artifact.sh**: Packages the application files into a build artifact directory (artifacts/).
 - **extract_artifact.sh**: Extracts the packaged build artifact back into the workspace for Docker image creation.
 - **promote.sh**: Identifies the latest test-tagged Docker image in ECR and promotes it to production by setting the BASE_TAG.
_____

## Workflow Explanation
**Job**: prepare
**Purpose**: Extract version information from package.json
**Steps**:
Checkout repository
Run version_extract.sh to extract version
Upload version.yaml as artifact

**Job**: build
**Purpose**: Build the Node.js application
**Steps**:
Download version artifact
Setup Node.js environment (v20)
Install dependencies with npm cache
Package application into artifacts
Upload build artifacts
**Dependencies**: prepare

**Job**: docker
**Purpose**: Build and push Docker image to ECR
**Steps**:
Download version and build artifacts
Extract application artifacts
Configure AWS credentials
Login to ECR
Build and push Docker image with version tag
**Dependencies**: build
**Docker Image Tag: <ECR_URI>/cicd-shaymaa:<VERSION>**

**Job**: promote
**Purpose**: Promote tested image to stable tag
**Steps**:
Login to AWS ECR
Run promote.sh to tag image as stable
Output the promoted tag for deployment
**Dependencies**: docker
**Output: BASE_TAG=stable**

**Job**: deploy
**Purpose**: Deploy container to remote server
**Steps**:
SSH into deployment server
Login to ECR from server
Pull the promoted image
Stop and remove old container
Start new container on port 3000
**Dependencies**: promote

## Dockerfile
This is the Dockerfile used to build and run the Node.js application inside a container:
```bash
# -------- runtime stage --------
FROM node:20-slim

WORKDIR /usr/src/app

COPY app/ ./

EXPOSE 3000

CMD [ "node", "app.js" ]

```
**Notes**
- The application files must be inside an app/ directory.
- The container exposes port 3000.

## Deployment


The pipeline triggers automatically on:
* Push to main branch
* Pull Request to main branch
```bash
# Deploy via push
git add .
git commit -m "Deploy new version"
git push origin main
```
