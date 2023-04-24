def buildPackage() {
    echo "build the application..."
    sh 'mvn clean package -DfinalName=java-maven-app-\\${project.version}-' + "${env.BUILD_NUMBER}"
}

def getAppVersion() {
    def pom = readMavenPom file: 'pom.xml'
    return pom.getVersion()
}

def buildDockerImage(appVersion) {
    echo "build the docker image..."
    withCredentials([usernamePassword(credentialsId: 'docker-cred', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
        def imageName = "$USER/myapp:$env.IMAGE_NAME"
        sh "docker build --build-arg APP_VERSION=${appVersion} --build-arg BUILD_NUMBER=$env.BUILD_NUMBER -t $imageName ."
        sh "echo $PASS | docker login -u $USER --password-stdin"
        sh "docker push $imageName"
    }
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


def deployTheApp() {
    echo 'deploy the application...'
}

return this
