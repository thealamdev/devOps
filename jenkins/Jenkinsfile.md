## 5 Nov, 2026 – Jenkins Jobs, Pipelines, and Plugins Explained with a Hands-On Demo

### Jenkinsfile follow Groovy langulage for automation the pipeline 

- [x] environment variable
- [x] params in Jenkinsfile
- [x] parameters use if else conditions
- [x] parameters use with booleanParam & choice & use script (switch, if else)
- [x] When condition use in Jenkinsfile
- [x] post action block for notificaiton
- [x] private repo add on jenkins pipeline


### Environment variable

```groovy
  environment {
    IMAGE_URL = "jenkins/images.jpg"
  }

  stage: {
    step: echo "${IMAGE_URL}"
  }
```

### Parameters & if else conditions

```groovy
  parameters {
    string(
      env: '.env',
      defaultValue: '.env.local'
    )
  }
  
  stages {
    stage('build'){
       echo "${params.env}"
    }
  }
```

### Full Jenkinsfile that have all regardings codes
```Jenkinsfile
pipeline {
    agent any
    
    parameters {
        string(
            name: 'IMAGE_URL',
            defaultValue: "/docker.io/username/repository:tag",
            description: 'Enter the image URL'
        )

        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'production'],
            description: 'Select the environment'
        )

        booleanParam(
            name: 'ENABLE_FEATURE',
            defaultValue: true,
            description: 'Enable or disable the feature'
        )
    }

    environment {
        APP_URL_DEV = "https://dev.eventmetro.com"
        APP_URL_STAGE = "https://stage.eventmetro.com"
        APP_URL_PROD = "https://eventmetro.com"
    }

    stages {
        stage('Select Environment') {
            steps {
                script {
                    switch(params.ENVIRONMENT) {
                        case 'dev':
                            env.APP_URL = env.APP_URL_DEV
                        break

                        case 'staging':
                            env.APP_URL = env.APP_URL_STAGE

                        case 'production':
                            env.APP_URL = env.APP_URL_PROD

                        default:
                            error('Invalid environment selected')

                    }
                }

                echo "Selected Environment: ${params.ENVIRONMENT}"
                echo "Application URL: ${env.APP_URL}"
            }
        }
        stage('test') {
            
            steps {
                echo "Testing application: ${env.APP_URL}"
                echo "Docker Image URL: ${params.IMAGE_URL}"

                script {
                    if(params.ENABLE_FEATURE){
                        echo "Feature is enabled"
                    } else {
                        echo "Feature is disabled"
                    }
                }

                echo 'Application test completed successfully!'
            }
        }

        stage('build') {
           
            when {
                expression { return params.ENVIRONMENT == 'production' }
            }
              
            steps {
                echo "Building for ${params.ENVIRONMENT}"
                echo "Using image: ${params.IMAGE_URL}"

                echo 'Project build completed successfully!'
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed!'
        }

        success {
            echo "SUCCESS: ${params.ENVIRONMENT} deployment completed!"
        }

        failure {
            echo "FAILED: ${params.ENVIRONMENT} deployment failed!"
        }

        unstable {
            echo 'WARNING: Pipeline is unstable!'
        }

        aborted {
            echo 'Pipeline was aborted!'
        }

        cleanup {
            echo 'Cleaning up resources...'
        }
    }
}
```
> success
## References

- [YouTube – Jenkins Declarative Pipeline Tutorial with Hands-On Demo)](https://youtu.be/A4vlacpzEiw?si=kJ1eWfGSqa3sDjoz)
- [Jenkins Official Documentation](https://www.jenkins.io/doc/)
- [Github Practice project](https://github.com/thealamdev/jenkins-pipeline.git)