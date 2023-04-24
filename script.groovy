def buildPackage() {
    echo "build the application..."
    sh 'mvn clean package'
}

def buildDockerImage() {
    echo "build the docker image..."
    echo "Build the docker image..."
    withCredentials([usernamePassword(credentialsId: 'docker-cred', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
        def imageName = "$USER/myapp:$env.IMAGE_NAME"
        sh "docker build --build-arg APP_VERSION=$env.IMAGE_NAME -t $imageName ."
        sh "echo $PASS | docker login -u $USER --password-stdin"
        sh "docker push $imageName"
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
