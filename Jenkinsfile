pipeline {
    agent any
    
    environment {
        JAVA_HOME = 'C:\\Program Files\\Java\\jdk-25'
        PATH = "${JAVA_HOME}\\bin;${PATH}"
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
                bat 'mvn clean compile -DskipTests'
                script {
                    echo '========== Build Complete =========='
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    echo '========== Stage: Unit Tests =========='
                    echo "Running ProductServiceTest..."
                }
                bat 'mvn test -Dtest=ProductServiceTest'
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
