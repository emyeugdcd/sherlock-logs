/*
 * =====================================================================
 *  NOTE: This Jenkinsfile has been commented out for studying purposes.
 *  I have migrated to using GitHub Actions for CI/CD instead!
 *  You can find the GitHub Actions workflow in .github/workflows/deploy.yml
 * =====================================================================
 */
/*
pipeline {
    agent any
    environment {
        BACKEND_IP = '192.168.56.14'
        WEB1_IP = '192.168.56.12'
        WEB2_IP = '192.168.56.13'
    }
    stages {
        stage('Test & Quality Gates') {
            steps {
                sh 'echo "Running Static Analysis..."'
                sh 'echo "Simulating Go Linting and Node.js testing..."'
                sh 'echo "Testing Passed successfully!"'
            }
        }
        stage('Build Artifacts') {
            steps {
                sh 'echo "Building Docker Images (Handled dynamically on Target VMs to utilize Vagrant Sync)"'
            }
        }
        stage('Deploy & Rollback Strategy') {
            steps {
                // Deploy Backend
                sh """
                ssh -o StrictHostKeyChecking=no devops@${BACKEND_IP} '
                    docker stop vitals-backend-app || true
                    docker rename vitals-backend-app vitals-backend-old || true
                    cd /vagrant/backend && docker build -t vitals-backend:latest .
                    docker run -d --name vitals-backend-app --restart always -p 8080:8080 vitals-backend:latest
                    
                    sleep 5
                    if ! curl -s http://localhost:8080/metrics > /dev/null; then
                        echo "HEALTHCHECK FAILED! Executing Rollback..."
                        docker rm -f vitals-backend-app
                        docker rename vitals-backend-old vitals-backend-app
                        docker start vitals-backend-app
                        exit 1
                    else
                        docker rm -f vitals-backend-old || true
                    fi
                '
                """
                // Deploy Frontend to Web1
                sh """
                ssh -o StrictHostKeyChecking=no devops@${WEB1_IP} '
                    docker stop vitals-frontend-app || true
                    docker rename vitals-frontend-app vitals-frontend-old || true
                    cd /vagrant/frontend && docker build -t vitals-frontend:latest .
                    docker run -d --name vitals-frontend-app --restart always -p 3000:3000 -e BACKEND_URL=http://192.168.56.14:8080 vitals-frontend:latest
                    
                    sleep 5
                    if ! curl -s http://localhost:3000 > /dev/null; then
                        echo "HEALTHCHECK FAILED! Executing Rollback..."
                        docker rm -f vitals-frontend-app
                        docker rename vitals-frontend-old vitals-frontend-app
                        docker start vitals-frontend-app
                        exit 1
                    else
                        docker rm -f vitals-frontend-old || true
                    fi
                '
                """
                // Deploy Frontend to Web2
                sh """
                ssh -o StrictHostKeyChecking=no devops@${WEB2_IP} '
                    docker stop vitals-frontend-app || true
                    docker rename vitals-frontend-app vitals-frontend-old || true
                    cd /vagrant/frontend && docker build -t vitals-frontend:latest .
                    docker run -d --name vitals-frontend-app --restart always -p 3000:3000 -e BACKEND_URL=http://192.168.56.14:8080 vitals-frontend:latest
                    
                    sleep 5
                    if ! curl -s http://localhost:3000 > /dev/null; then
                        echo "HEALTHCHECK FAILED! Executing Rollback..."
                        docker rm -f vitals-frontend-app
                        docker rename vitals-frontend-old vitals-frontend-app
                        docker start vitals-frontend-app
                        exit 1
                    else
                        docker rm -f vitals-frontend-old || true
                    fi
                '
                """
            }
        }
    }
    post {
        success {
            sh 'echo "ALERT: Deployment Successful! Slack/Discord notified via webhook."'
        }
        failure {
            sh 'echo "ALERT: Deployment FAILED! Rollback triggered. Ops team notified."'
        }
    }
}
*/
