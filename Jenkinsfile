pipeline {
    agent any

    environment {
        // Change these to match your Docker Hub and Image details
        DOCKER_HUB_USER = "mohanpothula"
        IMAGE_NAME = "my-hello-app"
        IMAGE_TAG = "${env.BUILD_ID}" // Best practice: unique tag per build
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/mohanpothula/kcna-lab-app.git'
                // Or if Jenkinsfile is in SCM, you can just use: checkout scm
            }
        }

        stage('Docker Build') {
            steps {
                // Single quotes used so Shell handles interpolation securely
                sh 'docker build -t $DOCKER_HUB_USER/$IMAGE_NAME:$IMAGE_TAG .'
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-id', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    // CRITICAL: Must use single quotes here to prevent credential exposure & groovy errors
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                    sh 'docker push $DOCKER_HUB_USER/$IMAGE_NAME:$IMAGE_TAG'
                }
            }
        }

        
