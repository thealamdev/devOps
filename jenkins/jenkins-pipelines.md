# 4 Nov, 2026 – Jenkins Jobs, Pipelines, and Plugins Explained with a Hands-On Demo

## 1. Jenkins Jobs

Jenkins Jobs are tasks or sets of instructions that Jenkins executes to automate software development activities, such as testing, building, and deploying applications.

To create a Jenkins Job:

1. Open the Jenkins Dashboard.
2. Click **New Item**.
3. Enter a name for the job.
4. Select the type of job you want to create.

Jenkins provides several job types, including:
- **Freestyle Project:** Suitable for simple tasks, such as running scripts, building projects, and executing commands.
- **Pipeline:** Used to define and automate a complete CI/CD workflow through a pipeline script.
- **Multibranch Pipeline:** Automatically discovers and manages pipelines for different branches of a Git repository.

## 2. Jenkins Pipelines

A Jenkins Pipeline is a collection of automated steps that define the software delivery process, such as testing, building, and deploying an application.

We can create a Jenkins Pipeline in two different ways.

### Method 1: Pipeline Script (Directly in Jenkins)

We can write the pipeline script directly in the Jenkins Dashboard.

Example:

```groovy
pipeline {
    agent any

    stages {
        stage('Test') {
            steps {
                echo 'Testing the project'
            }
        }

        stage('Build') {
            steps {
                echo 'Project built successfully'
            }
        }
    }
}
```

**Explanation:**
- `pipeline`: Defines the Jenkins Pipeline.
- `agent any`: Allows the pipeline to run on any available Jenkins agent.
- `stages`: Contains all the stages of the pipeline.
- `stage()`: Defines an individual stage, such as Test or Build.
- `steps`: Contains the commands that Jenkins executes.
- `echo`: Prints a message in the Jenkins console output.

### Method 2: Pipeline Script from SCM (Source Code Management)

Instead of writing the pipeline script directly in Jenkins, we can create a file named `Jenkinsfile` inside our project repository.

Steps:

1. Create a `Jenkinsfile` in the root directory of your project.
2. Write your pipeline instructions inside that file.
3. Push the file to a GitHub repository.
4. Create a new Pipeline Job in Jenkins.
5. Select **Pipeline script from SCM** as the Definition.
6. Select Git as the SCM.
7. Provide your GitHub repository URL.
8. Specify the script path as `Jenkinsfile`.

Jenkins will retrieve the `Jenkinsfile` from the GitHub repository and execute the instructions defined inside it.

**Why use this approach?**

- Pipeline instructions stay together with the project source code.
- We can track pipeline changes using Git.
- Team members can collaborate on pipeline configuration.
- We can maintain different pipeline configurations for different branches.

## 3. Jenkins Plugins

Jenkins plugins extend the default functionality of Jenkins by adding new features and integrations.

We can install plugins from:

**Manage Jenkins → Plugins**

For example:

### Blue Ocean

Blue Ocean is a Jenkins plugin that provides a more modern and visually appealing interface for viewing and managing Jenkins Pipelines.

It helps us:
- Visualize pipeline stages.
- Monitor pipeline execution.
- Identify failed stages.
- View pipeline execution details.
- Understand the overall pipeline workflow more easily.

Instead of viewing everything through the traditional Jenkins interface, Blue Ocean provides a more visual representation of pipeline execution.

## Summary

| Topic | What I learned |
|---|---|
| Jenkins Jobs | How to create different types of jobs, such as Freestyle and Pipeline. |
| Jenkins Pipelines | How to automate tasks using pipeline scripts. |
| Jenkinsfile | How to keep pipeline instructions inside the project repository. |
| SCM | How Jenkins retrieves a Jenkinsfile from GitHub. |
| Plugins | How plugins extend Jenkins functionality. |
| Blue Ocean | How to visualize and monitor pipeline stages through a graphical interface. |

> **What I understood:** For simple tasks, we can use Freestyle Projects. For more structured CI/CD workflows, we can use Jenkins Pipelines. Keeping the pipeline configuration in a `Jenkinsfile` inside the GitHub repository makes it easier to maintain and collaborate with other developers.

## References

- [YouTube – Jenkins Jobs, Pipelines, and Plugins (Hands-On Demo)](https://youtu.be/ymX7Uo4r5tE?si=BZQizKjyMFg5Rm10)
- [Jenkins Official Documentation](https://www.jenkins.io/doc/)