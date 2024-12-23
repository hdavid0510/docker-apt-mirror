pipeline{
	agent any
	options {
		parallelsAlwaysFailFast()
	}
	environment {
		IMAGE_NAME="hdavid0510/apt-mirror"
		REGISTRY_CREDENTIALS=credentials('dockerhub-credential')
		IMAGE_TAG='dev'
	}

	stages {
		stage('Build images') {
			parallel {
				stage('linux/amd64') {
					steps {
						echo 'Building linux/amd64'
						sh 'docker buildx build --push --platform linux/amd64,linux/arm64 -t $IMAGE_NAME:$IMAGE_TAG .'
					}
				}
			}
		}
		stage('Init') {
			steps {
				echo 'Dockerhub login'
				sh 'echo $REGISTRY_CREDENTIALS_PSW | docker login -u $REGISTRY_CREDENTIALS_USR --password-stdin'
				echo "Pushing ${IMAGE_NAME} from branch ${IMAGE_TAG}, Build #${env.BUILD_ID} @${env.JENKINS_URL} "
				sh 'docker buildx build --push --platform linux/amd64,linux/arm64 -t $IMAGE_NAME:$IMAGE_TAG .'
			}
		}
	}
	post {
		always {
			sh 'docker logout'
		}
	}
}
