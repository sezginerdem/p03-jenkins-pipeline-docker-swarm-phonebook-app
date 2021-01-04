pipeline {
    agent {
        label 'master'
    }
    environment{
        PATH=sh(script:"echo $PATH:/usr/local/bin", returnStdout:true).trim()
        AWS_REGION = "us-east-1"
        AWS_ACCOUNT_ID=sh(script:'export PATH="$PATH:/usr/local/bin" && aws sts get-caller-identity --query Account --output text', returnStdout:true).trim()
        ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        APP_REPO_NAME = "sezgin-repo/phonebook-app"
        APP_NAME = "phonebook"
        AWS_STACK_NAME = "Sezgin-Phonebook-App-${BUILD_NUMBER}"
        CFN_TEMPLATE="phonebook-docker-swarm-cfn-template.yml"
        CFN_KEYPAIR="ec2key"
        HOME_FOLDER = "/home/ec2-user"
        GIT_FOLDER = sh(script:'echo ${GIT_URL} | sed "s/.*\\///;s/.git$//"', returnStdout:true).trim()
    }
    stages{
        stage('creating ECR Repository') {
            steps {
                echo 'creating ECR Repository'
                sh """
                aws ecr create-repository \
                  --repository-name ${APP_REPO_NAME} \
                  --image-scanning-configuration scanOnPush=false \
                  --image-tag-mutability MUTABLE \
                  --region ${AWS_REGION}
                """
            script {
                while(true) {
                        
                        echo "Docker Grand Master is not UP and running yet. Will try to reach again after 10 seconds..."
                        sleep(10)

                        ip = sh(script:'aws ec2 describe-instances --region ${AWS_REGION} --filters Name=tag-value,Values=docker-grand-master Name=tag-value,Values=${AWS_STACK_NAME} --query Reservations[*].Instances[*].[PublicIpAddress] --output text | sed "s/\\s*None\\s*//g"', returnStdout:true).trim()

                        if (ip.length() >= 7) {
                            echo "Docker Grand Master Public Ip Address Found: $ip"
                            env.MASTER_INSTANCE_PUBLIC_IP = "$ip"
                            break
                        }
                    }
                }
            }
        }
        stage('Test the infrastructure') {
            steps {
                echo echo "Testing if the Docker Swarm is ready or not, by checking Viz App on Grand Master with Public Ip Address: ${MASTER_INSTANCE_PUBLIC_IP}:8080"
            }
        }


        stage('building Docker Image') {
            steps {
                echo 'building Docker Image'
                sh 'docker build --force-rm -t "$ECR_REGISTRY/$APP_REPO_NAME:latest" .'
                sh 'docker image ls'
            }
        }
        stage('pushing Docker image to ECR Repository'){
            steps {
                echo 'pushing Docker image to ECR Repository'
                sh 'aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin "$ECR_REGISTRY"'
                sh 'docker push "$ECR_REGISTRY/$APP_REPO_NAME:latest"'           
           
            }
        }
        stage('creating infrastructure for the Application') {
            steps {
                echo 'creating infrastructure for the Application'
                sh "aws cloudformation create-stack --region ${AWS_REGION} --stack-name ${AWS_STACK_NAME} --capabilities CAPABILITY_IAM --template-body file://${CFN_TEMPLATE} --parameters ParameterKey=KeyPairName,ParameterValue=${CFN_KEYPAIR}"
            }
        }
        stage('Deploying the Application') {
            steps {
                echo 'Deploying the Application'
    
            }
        }
    }    
    post {
        always {
            echo 'Goodbye ALL... Please come back soon'
        }
        failure {
            echo 'Sorry but you messed up...'
        }
        success {
            echo 'You are the man/woman...'
        }
    }
}