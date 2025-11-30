pipeline {
    agent any
    
    environment {
        JAVA_HOME = 'C:\\Program Files\\Java\\jdk-25'
        M2_HOME = 'C:\\apache-maven-3.9.4'
        PATH = "${JAVA_HOME}\\bin;${M2_HOME}\\bin;${PATH}"
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
                    bat 'dir'
                }
            }
        }
        
        stage('Build') {
            steps {
                script {
                    echo '========== Stage: Maven Clean Build =========='
                    echo "Compiling and packaging the project..."
                }
                bat 'if exist .mvn\\wrapper\\maven-wrapper.jar del .mvn\\wrapper\\maven-wrapper.jar'
                bat '.\\mvnw clean compile -DskipTests'
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
                bat '.\\mvnw sonar:sonar -Dsonar.projectKey=BusinessManagementProject -Dsonar.sources=src/main -Dsonar.host.url=http://localhost:9000 -Dsonar.login=admin -Dsonar.password=Akrem.05022002'
                script {
                    echo '========== SonarQube Analysis Complete =========='
                    echo 'Code quality analysis results available at: http://localhost:9000'
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    echo '========== Stage: Unit Tests =========='
                    echo "Running ProductServiceTest..."
                }
                bat '.\\mvnw test -Dtest=ProductServiceTest'
                script {
                    echo '========== Tests Complete =========='
                }
            }
        }
        
        stage('Test Reports') {
            steps {
                script {
                    echo '========== Stage: Publishing Test Reports =========='
                }
                junit '**/target/surefire-reports/*.xml'
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
