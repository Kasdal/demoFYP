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
        stage('test the application') {
            steps {
                script {
                    echo 'running tests...'
                    sh 'mvn test'
                }
            }
        }
        stage('build image and push to dockerhub') {
            steps {
                script {
                   echo 'building docker image...'
                   buildDockerImage(env.IMAGE_NAME)
                   loginDocker()
                   pushDockerImage(env.IMAGE_NAME)
                }
            }
        }
        stage('provision server') {
            environment {
                AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key_id')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins_aws_secret_access_key_id')
                TF_VAR_env_prefix = 'test'
            }
            steps {
                script {
                    dir('terraform') {
                        sh "terraform init"
                        sh "terraform apply -auto-approve -var=\"my_ip=${env.MY_IP}\" -var=\"jenkins_ip=${env.JENKINS_IP}\""
                        EC2_PUBLIC_IP = sh(
                            script: "terraform output ec2_public_ip",
                            returnStdout: true
                        ).trim()
                    }
                }
            }
        }
        stage('deploy') {
            environment {
                DOCKER_CREDS = credentials('docker-cred')
            }
            steps {
                script {
                   echo "waiting for EC2 server to initialize" 
                   sleep(time: 180, unit: "SECONDS") 

                   echo 'deploying docker image to EC2...'
                   echo "${EC2_PUBLIC_IP}"

                   def shellCmd = "bash /home/ec2-user/server-cmds.sh ${IMAGE_NAME} ${DOCKER_CREDS_USR} ${DOCKER_CREDS_PSW}"
                   def ec2Instance = "ec2-user@${EC2_PUBLIC_IP}"

                   sshagent(['server-ssh-key']) {
                       sh "scp -o StrictHostKeyChecking=no server-cmds.sh ${ec2Instance}:/home/ec2-user"
                       sh "scp -o StrictHostKeyChecking=no docker-compose.yml ${ec2Instance}:/home/ec2-user"
                       sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"
                   }
                }
            }
        }
    }
}
