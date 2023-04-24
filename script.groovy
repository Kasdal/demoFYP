def buildPackage() {
    echo "build the application..."
    sh 'mvn clean package'
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

def incrementVersion() {
    echo 'incrementing app version...'
    sh 'mvn build-helper:parse-version versions:set \
        -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} \
        versions:commit'
    def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'
    def version = matcher[0][1]
    env.IMAGE_NAME = "$version-$BUILD_NUMBER"
}

return this
