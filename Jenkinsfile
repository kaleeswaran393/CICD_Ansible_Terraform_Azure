pipeline {

    agent any

    tools {
        maven 'Maven-3.6.0'
        jdk 'jdk1.8.0'
    }

    stages {

        stage('Build') {
            steps {
                checkout scm
                withEnv(["PATH+MAVEN=${tool 'Maven-3.6.0'}/bin"]) {
                    sh "/Applications/cia/apache-maven-3.6.0/bin/mvn -X clean compile"
                }
            }
        }

        stage('Test') {
            steps {
                echo("Perform Unit Test")
                withEnv(["PATH+MAVEN=${tool 'Maven-3.6.0'}/bin"]) {
                    sh "/Applications/cia/apache-maven-3.6.0/bin/mvn -X clean test"
                }

                junit('**/target/surefire-reports/TEST-*.xml')


                echo("Perform Integration Test")

                echo("SonarQube Integration")
                sh '/Applications/cia/apache-maven-3.6.0/bin/mvn clean package sonar:sonar'

                echo("IBM AppScan for CVE Check")
            }
        }


        stage('Package') {
            steps {
                withEnv(["PATH+MAVEN=${tool 'Maven-3.6.0'}/bin"]) {
                    sh "/Applications/cia/apache-maven-3.6.0/bin/mvn -X clean deploy"
                }

            }
        }

        stage('Provision') {
            steps {
                echo("Provisioning VM on Azure")
                dir("/Users/Shared/Jenkins/Home/workspace/ansible_master/terraform") {
                    sh '''
                            export PATH=$PATH:/usr/local/bin
                            touch output
                            terraform init
                            az login -u kalis2050@yahoo.co.in -p Dakshin893$
                            terraform plan -out=output
                            terraform apply -auto-approve
                            terraform output -json public_ip_address | jq '.value' > /Users/Shared/Jenkins/Home/workspace/ansible_master/ansible/environments/test/hosts
                     '''
                }
            }
        }


        stage('Deploy') {
            steps {
                echo("Deploying Application using Ansible Playbook")
                withEnv(["PATH+ANSIBLE=${tool 'ansible'}/bin"]) {
                    sh '''
                                  export ANSIBLE=/usr/local/Cellar/ansible/2.7.5
                                  export PATH=$PATH:$ANSIBLE/bin:/usr/local/bin
                                  export ANSIBLE_HOST_KEY_CHECKING=False
                                  echo "ANSIBLE = ${ANSIBLE}"
                                  sshpass -p Password1234! ansible-playbook /Users/Shared/Jenkins/Home/workspace/ansible_master/ansible/playbooks/deploy.yml -i /Users/Shared/Jenkins/Home/workspace/ansible_master/ansible/environments/test/hosts -s -U root -u testadmin -k                
                    '''
                }
            }
        }

        stage('Load Test') {
            steps {
                build job: 'JMeter - Freestyle'
            }
        }

        stage('Delete VM?') {
            steps {
                script {
                    def userInput = input(id: 'confirm', message: 'Deploy new build?', parameters: [[$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Deploy', name: 'confirm']])
                }
            }
        }

        stage('Delete VM') {
            steps {
                echo("Provisioning VM on Azure")
                dir("/Users/Shared/Jenkins/Home/workspace/ansible_master/terraform") {
                    sh '''
                            export PATH=$PATH:/usr/local/bin
                            az login -u kalis2050@yahoo.co.in -p Dakshin893$
                            terraform destroy -auto-approve
                            '''
                }
            }
        }
    }
}



