```groovy
pipeline {
    agent any

    environment {
        // Change these to match your Docker Hub and Image details
        DOCKER_HUB_USER = "your-username"
        IMAGE_NAME = "kcna-demo-app"
        IMAGE_TAG = "${env.BUILD_ID}" // Best practice: unique tag per build
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/your-repo/kcna-lab-app.git'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-id', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh "echo ${PASS} | docker login -u ${USER} --password-stdin"
                    sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('K8s Deploy') {
            steps {
                // We use 'kubectl set image' for a simple rolling update
                sh "kubectl set image deployment/my-app my-container=${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} --record"
                
                // Or use a manifest
                // sh "kubectl apply -f k8s/deployment.yaml"
            }
        }
    }

    post {
        success {
            echo "Successfully deployed version ${IMAGE_TAG} to Kubernetes!"
        }
    }
}
```
