pipeline {
    agent {
        // This spins up a custom pod for this build
        kubernetes {
            yaml '''
            apiVersion: v1
            kind: Pod
            spec:
              serviceAccountName: jenkins # Required if you're deploying with kubectl later
              containers:
              - name: docker
                image: docker:cli
                command:
                - cat
                tty: true
                volumeMounts:
                - mountPath: /var/run/docker.sock
                  name: docker-sock
              volumes:
              - name: docker-sock
                hostPath:
                  path: /var/run/docker.sock
            '''
        }
    }

    environment {
        DOCKER_HUB_USER = "mohanpothula"
        IMAGE_NAME = "my-hello-app"
        IMAGE_TAG = "${env.BUILD_ID}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/mohanpothula/kcna-lab-app.git'
            }
        }

        stage('Docker Build') {
            steps {
                // We must explicitly run these steps inside the 'docker' container we defined above
                container('docker') {
                    sh 'docker build -t $DOCKER_HUB_USER/$IMAGE_NAME:$IMAGE_TAG .'
                }
            }
        }

        stage('Docker Push') {
            steps {
                container('docker') {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-id', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh 'echo $PASS | docker login -u $USER --password-stdin'
                        sh 'docker push $DOCKER_HUB_USER/$IMAGE_NAME:$IMAGE_TAG'
                    }
                }
            }
        }

        stage('K8s Deploy') {
            steps {
                // Using the default Jenkins jnlp container for kubectl commands
                sh 'curl -LO "https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl"'
                sh 'chmod +x ./kubectl'
                sh './kubectl set image deployment/my-app my-container=$DOCKER_HUB_USER/$IMAGE_NAME:$IMAGE_TAG --record'
            }
        }
    }

    post {
        success {
            echo "Successfully deployed version ${env.IMAGE_TAG} to Kubernetes!"
        }
    }
}
