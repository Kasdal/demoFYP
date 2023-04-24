def buildPackage() {
    echo 'build the package...'
    sh "mvn versions:set"
    sh "mvn clean package"
    def pom = readMavenPom file: 'pom.xml'
    def newVersion = pom.getVersion()
    env.NEW_VERSION = newVersion
}

def buildDockerImage() {
    echo "build the docker image..."
    withCredentials([usernamePassword(credentialsId: 'docker-cred', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
        def imageName = "$USER/myapp:$env.IMAGE_NAME"
        sh "docker build --build-arg JAR_NAME=java-maven-app-${env.NEW_VERSION}.jar -t kasdal/myapp:${env.NEW_VERSION} ."
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
