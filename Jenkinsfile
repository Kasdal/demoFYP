#!/usr/bin/env groovy

@Library('jenkins-shared')

def gv

pipeline {
    agent any
    tools {
        maven 'maven'
    }
    stages {
        stage("init") {
            steps {
                script {
                    gv = load "script.groovy"
                }
            }
        }
        stage('build') {
            steps {
                script {
                    buildPackage()
                }
            }
        }
        stage('build docker image and push to docker hub') {
            steps {
                script {
                    buildDockerImage 'kasdal/myapp:app-2.0'
                    loginDocker()
                    pushDockerImage 'kasdal/myapp:app-2.0'
                }
            }
        }
        stage('deploy') {
            steps {
                script {
                    gv.deployTheApp()
                }
            }
        }
    }
}