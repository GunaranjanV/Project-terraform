pipeline {
    agent any

    parameters {
        choice(
            name: 'terraformAction',
            choices: ['Apply', 'Destroy'],
            description: 'Choose your terraform action to perform'
        )
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    stages {
        stage("Git checkout") {
            steps {
                git branch: 'main', url: 'https://github.com/GunaranjanV/Project-terraform.git'
            }
        }

        stage("Terraform Init") {
            steps {
                sh 'terraform init'
            }
        }

        stage("Terraform Plan") {
            steps {
                sh 'terraform plan -out=tfplan'
                sh 'terraform show -no-color tfplan > tfplan.txt'
            }
        }

        stage("Terraform Approve") {
            steps {
                script {
                    // Read plan file if needed
                    def plan = readFile 'tfplan.txt'

                    // Prompt user for approval
                    def userInput = input(
                        message: "Do you want to proceed with the ${params.terraformAction} action?",
                        parameters: [
                            booleanParam(
                                defaultValue: false,
                                description: 'Review your plan before approving',
                                name: 'approve'
                            )
                        ]
                    )

                    // Save approval decision into environment variable
                    env.APPROVE = userInput.toString()
                }
            }
        }

        stage("Terraform Apply/Destroy") {
            when {
                expression { return env.APPROVE == 'true' }
            }
            steps {
                script {
                    if (params.terraformAction == 'Apply') {
                        sh 'terraform apply -auto-approve tfplan'
                    } else if (params.terraformAction == 'Destroy') {
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }
    }
}
