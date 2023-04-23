def buildPackage() {
    echo "build the application..."
    sh 'mvn package'
} 

def buildDockerImage() {
    echo "build the docker image..."
    echo "Build the docker image..."
    withCredentials([usernamePassword(credentialsId: 'docker-cred', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
        sh "docker build -t $USER/myapp:app-1.0 ."
        sh "echo $PASS | docker login -u $USER --password-stdin"
        sh "docker push $USER/myapp:app-1.0"
    }
} 

def deployTheApp() {
    echo 'deploy the application...'
} 

return this
