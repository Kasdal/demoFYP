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
        stage('build') {
            steps {
                script {
                    gv.buildPackage()
                }
            }
        }
        stage('build docker image') {
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