def registry = 'https://tgvrdhn.jfrog.io'
pipeline {
    agent {
        node {
            label 'maven'
        }
    }

environment {
    PATH = "/opt/apache-maven-3.9.4/bin:$PATH"
}
    stages {
        stage ('Build'){
            steps {
                echo "------Build Started ---------"
                sh 'mvn clean deploy -Dmaven.test.skip=true'
                echo "------Build Completed ---------"
            }
        }
        stage ("Test") {
            steps {
                echo "-------- unit test started -------"
                sh 'mvn surefire-report:report'
                echo "--------- unit test completed --------"
            }
        }
        stage("SonarQube analysis") {
            environment {
            scannerHome = tool 'tgvrdhn-sonar-scaner'
            }
            steps {
                withSonarQubeEnv('tgvrdhn-sonarqube-server') { 
                sh "${scannerHome}/bin/sonar-scanner"
                }
            }
        }
        stage("Quality Gate"){
            steps {
                script {
                    timeout(time: 1, unit: 'HOURS') { // Just in case something goes wrong, pipeline will be killed after a timeout
                    def qg = waitForQualityGate() // Reuse taskId previously collected by withSonarQubeEnv
                    if (qg.status != 'OK') {
                    error "Pipeline aborted due to quality gate failure: ${qg.status}"
                    }
                    }
                }    
            }
        }
        stage("Jar Publish") {
            steps {
                script {
                    echo '<--------------- Jar Publish Started --------------->'
                     def server = Artifactory.newServer url:registry+"/artifactory" ,  credentialsId:"artifact-cred"
                     def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}";
                     def uploadSpec = """{
                          "files": [
                            {
                              "pattern": "jarstaging/(*)",
                              "target": "libs-release-local/{1}",
                              "flat": "false",
                              "props" : "${properties}",
                              "exclusions": [ "*.sha1", "*.md5"]
                            }
                         ]
                     }"""
                     def buildInfo = server.upload(uploadSpec)
                     buildInfo.env.collect()
                     server.publishBuildInfo(buildInfo)
                     echo '<--------------- Jar Publish Ended --------------->'  
                }
            }   
        }
    }
}