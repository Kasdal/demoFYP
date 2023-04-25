#!/usr/bin/env groovy

@Library('jenkins-shared')_

pipeline {
    agent any
    tools {
        maven 'maven'
    }
    environment {
        IMAGE_NAME = "kasdal/myapp:app-${env.BUILD_NUMBER}"
        MY_IP = credentials('MY_IP')
        JENKINS_IP = credentials('JENKINS_IP')
    }
    stages {
        stage('build app') {
            steps {
               script {
                  echo 'building application jar...'
                  buildPackage()
               }
            }
        }
        stage('build image') {
            steps {
                script {
                   echo 'building docker image...'
                   buildDockerImage(env.IMAGE_NAME)
                   loginDocker()
                   pushDockerImage(env.IMAGE_NAME)
                }
            }
        }
        stage('provision EKS') {
    environment {
        AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('jenkins_aws_secret_access_key_id')
        TF_VAR_env_prefix = 'test'
    }
    steps {
        script {
            dir('terraform') {
                sh "terraform init"
                sh "terraform apply -auto-approve"
                sh "terraform output -raw kubeconfig > kubeconfig.yaml"
                sh "aws eks update-kubeconfig --region us-east-1 --name myapp-eks-cluster --kubeconfig kubeconfig.yaml"
            }
        }
    }
}
        stage('deploy to EKS') {
            steps {
                script {
                    sh "sed -i 's|\\${IMAGE}|${env.IMAGE_NAME}|g' k8s-deployment.yaml"
                    sh 'kubectl apply -f k8s-deployment.yaml'
                }
            }
        }
    }
}
