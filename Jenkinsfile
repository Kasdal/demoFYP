#!/usr/bin/env groovy

pipeline {
    agent any
    tools {
        maven 'maven'
    }
    stages {
        stage('build') {
            steps {
                script {
                    echo "Build the application..."
                    sh "mvn package"
                }
            }
        }
        stage('build docker image') {
            steps {
                script {
                    echo "Build the docker image..."
                    withCredentials()([usernamePassword(credentialsId: 'docker-cred', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "docker build -t $USER/myapp:app-1.0 ."
                        sh "echo $PASS docker login -u $USER --password-stdin"
                        sh "docker push $USER/myapp:app-1.0"
                    }
                }
            }
        }
        stage('test') {
            steps {
                script {
                    echo "Test the application..."
                }
            }
        }
    }
}
