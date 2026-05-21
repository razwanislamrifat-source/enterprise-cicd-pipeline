def dockerImage
pipeline {
    agent any
    environment {
        APP_NAME = 'advanced-cicd-app'
        APP_VERSION = '2.0.0'
        SONARQUBE_URL = 'http://sonarqube:9000'
        DOCKER_IMAGE = "razwanff/${APP_NAME}:${APP_VERSION}"
    }
    stages {
        stage('Build') {
            steps {
                sh 'cd app && mvn clean package -Dmaven.test.skip=true'
            }
        }
        stage('Unit Test') {
            steps {
                sh 'cd app && mvn surefire-report:report'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh 'cd app && mvn sonar:sonar -Dsonar.projectKey=advanced-cicd-razwan -Dsonar.projectName=Advanced-CICD-Pipeline'
                }
            }
        }
        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    script {
                        def qualityGate = waitForQualityGate()
                        if (qualityGate.status != 'OK') {
                            error "Pipeline aborted: Quality Gate status is ${qualityGate.status}"
                        }
                    }
                }
            }
        }
        stage('Docker Build') {
            steps {
                script {
                    dockerImage = docker.build("${env.DOCKER_IMAGE}")
                }
            }
        }
        stage('Docker Push') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        dockerImage.push()
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh 'chmod +x deploy.sh && ./deploy.sh'
            }
        }
    }
    post {
        always {
            echo "Pipeline completed with status: ${currentBuild.currentResult}"
        }
    }
}
