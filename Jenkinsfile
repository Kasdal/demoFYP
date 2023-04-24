#!/usr/bin/env groovy

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
        stage('increment version of the app') {
            steps {
                script {
                    gv.incrementVersion()
                }
            }
        }
        stage('build') {
            steps {
                script {
                    gv.buildPackage()
                }
            }
        }
        stage('build docker image  and push to docker hub') {
            steps {
                script {
                    gv.buildDockerImage()
                }
            }
        }
        stage('test') {
            steps {
                script {
                    gv.deployTheApp()
                }
            }
        }
    }
}
