pipeline {
    agent any
    
    environment {
        JAVA_HOME = 'C:\\Program Files\\Java\\jdk-25'
        M2_HOME = 'C:\\apache-maven-3.9.4'
        PATH = "C:\\Windows\\System32;${JAVA_HOME}\\bin;${M2_HOME}\\bin;${PATH}"
    }
    
    options {
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
    }
    
    stages {
        stage('Git Checkout') {
            steps {
                script {
                    echo '========== Stage: Git Checkout =========='
                    echo "Checking out code from: ${GIT_URL}"
                    echo "Branch: ${GIT_BRANCH}"
                }
                checkout scm
                script {
                    echo '========== Git Checkout Complete =========='
                    echo "Repository cloned successfully"
                }
            }
        }
        
        stage('Build') {
            steps {
                script {
                    echo '========== Stage: Maven Clean Build =========='
                    echo "Compiling and packaging the project..."
                }
                bat '@echo off && if exist .mvn\\wrapper\\maven-wrapper.jar del .mvn\\wrapper\\maven-wrapper.jar'
                bat '@echo off && .\\mvnw clean compile -DskipTests'
                script {
                    echo '========== Build Complete =========='
                }
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                script {
                    echo '========== Stage: SonarQube Code Quality Analysis =========='
                    echo "Running SonarQube scanner for code quality analysis..."
                    echo "Connecting to SonarQube at http://localhost:9000"
                }
                bat '@echo off && .\\mvnw sonar:sonar -Dsonar.projectKey=BusinessManagementProject -Dsonar.sources=src/main -Dsonar.host.url=http://localhost:9000 -Dsonar.token=sqa_f91ba8837d3fe097b578d79f16c8794469e3bb95'
                script {
                    echo '========== SonarQube Analysis Complete =========='
                    echo 'Code quality analysis results available at: http://localhost:9000/dashboard?id=BusinessManagementProject'
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    echo '========== Stage: Unit Tests =========='
                    echo "Running ProductServiceTest..."
                }
                bat '@echo off && .\\mvnw test -Dtest=ProductServiceTest'
                script {
                    echo '========== Tests Complete =========='
                }
            }
        }
        
        stage('Nexus Deploy') {
            steps {
                script {
                    echo '========== Stage: Nexus Artifact Deployment =========='
                    echo "Packaging and preparing artifacts for Nexus deployment..."
                }
                bat '@echo off && .\\mvnw clean package -DskipTests'
                script {
                    echo '========== Artifact Package Created =========='
                    echo "Artifact: target/BusinessProject-0.0.1-SNAPSHOT.jar"
                    echo "Ready for deployment to Nexus Repository"
                    echo "To enable actual deployment, configure distributionManagement in pom.xml"
                }
            }
        }
    }
    
    post {
        always {
            script {
                echo '========== Pipeline Execution Summary =========='
                echo "Build Status: ${currentBuild.result}"
                echo "Build Number: ${BUILD_NUMBER}"
                echo "Build Duration: ${currentBuild.durationString}"
            }
        }
        success {
            script {
                echo '✅ Pipeline executed successfully!'
            }
        }
        failure {
            script {
                echo '❌ Pipeline failed! Check logs above for details.'
            }
        }
    }
}
