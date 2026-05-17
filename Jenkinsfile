def dockerImage

pipeline {
    agent { label 'maven' }

    parameters {
        string(name: 'JFROG_URL', defaultValue: 'your-company.jfrog.io', description: 'JFrog Artifactory URL')
        string(name: 'SONARQUBE_URL', defaultValue: 'https://sonarqube.your-domain.com', description: 'SonarQube Server URL')
    }

    environment {
        PATH = "/opt/apache-maven-3.9.4/bin:${env.PATH}"
        APP_NAME = 'advanced-cicd-app'
        APP_VERSION = '2.0.0'
        JFROG_URL = "${params.JFROG_URL}"
        SONARQUBE_URL = "${params.SONARQUBE_URL}"
    }

    stages {
        stage('Build') {
            steps {
                sh 'mvn clean deploy -Dmaven.test.skip=true'
            }
        }

        stage('Unit Test') {
            steps {
                sh 'mvn surefire-report:report'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')]) {
                        sh """
                            mvn sonar:sonar \
                              -Dsonar.projectKey=advanced-cicd-razwan \
                              -Dsonar.projectName=Advanced-CICD-Pipeline \
                              -Dsonar.host.url=${SONARQUBE_URL} \
                              -Dsonar.login=${SONAR_TOKEN}
                        """
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    script {
                        def qualityGate = waitForQualityGate()
                        if (qualityGate.status != 'OK') {
                            error "Pipeline aborted because Quality Gate status is: ${qualityGate.status}"
                        }
                    }
                }
            }
        }

        stage('Publish JAR to JFrog') {
            steps {
                script {
                    def rtServer = Artifactory.newServer(
                        url: "https://${env.JFROG_URL}/artifactory",
                        credentialsId: 'jfrog-artifactory-credentials'
                    )

                    def uploadSpec = """{
                      \"files\": [
                        {
                          \"pattern\": \"target/*.jar\",
                          \"target\": \"maven-libs-release-local/com/razwan/advanced-cicd-app/${env.APP_VERSION}/\",
                          \"props\": \"buildid=${env.BUILD_ID};commitid=${env.GIT_COMMIT}\"
                        }
                      ]
                    }"""

                    rtServer.upload spec: uploadSpec
                }
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    dockerImage = docker.build("${env.JFROG_URL}/advanced-cicd-docker-local/${env.APP_NAME}:${env.APP_VERSION}-${env.BUILD_NUMBER}")
                }
            }
        }

        stage('Docker Publish') {
            steps {
                script {
                    docker.withRegistry("https://${env.JFROG_URL}", 'docker-registry-credentials') {
                        dockerImage.push()
                        dockerImage.push('latest')
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh './deploy.sh'
            }
        }
    }

    post {
        always {
            echo "Pipeline completed with status: ${currentBuild.currentResult}"
        }
    }
}
