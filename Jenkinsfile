pipeline {
    agent any

/*    agent {

        label "master"

    }
*/
    tools {

        // Note: this should match with the tool name configured in your jenkins instance (JENKINS_URL/configureTools/)

        maven "Maven 3.6.0"

    }

    environment {
        //  Define all variables

        // This can be nexus3 or nexus2

        NEXUS_VERSION = "nexus3"

        // This can be http or https

        NEXUS_PROTOCOL = "http"

        // Where your Nexus is running

        NEXUS_URL = "172.16.101.138:8081"

        // Repository where we will upload the artifact

        NEXUS_REPOSITORY = "nexus_repo"

        // Jenkins credential id to authenticate to Nexus OSS

        NEXUS_CREDENTIAL_ID = "nexus"

        PROJECT = 'tpmgnew'

        APPNAME = 'my-first-microservice'

        SERVICENAME = "${appName}-backend"

        IMAGEVERSION = 'development'

        NAMESPACE = 'development'

        IMAGETAG = "anandjain420/${PROJECT}:${IMAGEVERSION}.${env.BUILD_NUMBER}"
    }

    stages {

        stage("mvn build") {

            steps {

                script {

                    // If you are using Windows then you should use "bat" step

                    // Since unit testing is out of the scope we skip them

                    sh "mvn package -DskipTests=true"

                }

            }

        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-6') {

                    sh "mvn sonar:sonar"
                }
            }
        }
        stage("publish to nexus") {

            steps {

                script {

                    // Read POM xml file using 'readMavenPom' step , this step 'readMavenPom' is included in: https://plugins.jenkins.io/pipeline-utility-steps

                    pom = readMavenPom file: "pom.xml";

                    // Find built artifact under target folder

                    filesByGlob = findFiles(glob: "target/*.${pom.packaging}");

                    // Print some info from the artifact found

                    echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"

                    // Extract the path from the File found

                    artifactPath = filesByGlob[0].path;

                    // Assign to a boolean response verifying If the artifact name exists

                    artifactExists = fileExists artifactPath;

                    if(artifactExists) {

                        echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}";

                        nexusArtifactUploader(

                                nexusVersion: NEXUS_VERSION,

                                protocol: NEXUS_PROTOCOL,

                                nexusUrl: NEXUS_URL,

                                groupId: pom.groupId,

                                version: pom.version,

                                repository: NEXUS_REPOSITORY,

                                credentialsId: NEXUS_CREDENTIAL_ID,

                                artifacts: [

                                        // Artifact generated such as .jar, .ear and .war files.

                                        [artifactId: pom.artifactId,

                                         classifier: '',

                                         file: artifactPath,

                                         type: pom.packaging],

                                        // Lets upload the pom.xml file for additional information for Transitive dependencies

                                        [artifactId: pom.artifactId,

                                         classifier: '',

                                         file: "pom.xml",

                                         type: "pom"]

                                ]

                        );

                    } else {

                        error "*** File: ${artifactPath}, could not be found";

                    }

                }

            }

        }

// Build the docker Image

        stage('Building image') {

            steps {

                sh("docker build -t ${IMAGETAG} .")
            }
        }

        //Push the image to docker registry
        stage('Push image to registry') {

            steps {

                sh("docker push ${IMAGETAG}")
            }

        }

        // Deploy Application
        stage('Deploy Application') {

            steps { 
                
                script {

                switch (NAMESPACE) {
                //Roll out to Dev Environment
                    case "development":
                        // Create namespace if it doesn't exist
                        sh("kubectl get ns ${NAMESPACE} || kubectl create ns ${NAMESPACE}")
                        //Update the imagetag to the latest version
                        sh("sed -i.bak 's#name:#name: ${APPNAME}#' ./k8s/development/*.yaml")
                        sh("sed -i.bak 's#app:#app: ${APPNAME}#' ./k8s/development/*.yaml")
                        sh("sed -i.bak 's#apps:#apps: ${APPNAME}#' ./k8s/development/*.yaml")
                        sh("sed -i.bak 's#anandjain420/${PROJECT}:${IMAGEVERSION}#${IMAGETAG}#' ./k8s/development/*.yaml")
                        //Create or update resources
                        sh("kubectl --namespace=${NAMESPACE} apply -f k8s/development/deployment.yaml")
                        sh("kubectl --namespace=${NAMESPACE} apply -f k8s/development/service.yaml")
                    }
                
                }

            }

        }

    }

}
