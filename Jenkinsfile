pipeline {
    agent {
        // This spins up a custom pod for this build containing Docker
        kubernetes {
            yaml '''
            apiVersion: v1
            kind: Pod
            spec:
              serviceAccountName: jenkins 
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
        // Automatically injects your Docker Hub namespace and App details
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
                container('docker') {
                    // Single quotes are crucial here so the shell evaluates the variables
                    sh 'docker build -t $DOCKER_HUB_USER/$IMAGE_NAME:$IMAGE_TAG .'
                }
            }
        }

        stage('Docker Push') {
            steps {
                container('docker') {
                    // Make sure the Jenkins UI credential ID is set exactly to 'docker-hub-id'
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-id', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh 'echo $PASS | docker login -u $USER --password-stdin'
                        sh 'docker push $DOCKER_HUB_USER/$IMAGE_NAME:$IMAGE_TAG'
                    }
                }
            }
        }

        stage('K8s Deploy') {
            steps {
                // Download kubectl into the workspace dynamically 
                sh 'curl -LO "https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl"'
                sh 'chmod +x ./kubectl'
                
                // Deploy using a generated manifest. 
                // Using 'apply' will create the deployment if it doesn't exist, and update it if it does.
                sh '''
                cat <<EOF | ./kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-container
        image: $DOCKER_HUB_USER/$IMAGE_NAME:$IMAGE_TAG
        ports:
        - containerPort: 80
EOF
                '''
            }
        }
    }

    post {
        success {
            echo "Successfully built, pushed, and deployed version ${env.IMAGE_TAG} to Kubernetes!"
        }
    }
}
