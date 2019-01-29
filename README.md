# DevOps_Jenkin_Ansible_Terraform_Azure

1. Created sample application using <b>spring-boot</b>

2. <b>Maven</b> for build and <b>Nexus</b> for dependency and packaging

3. <b>SonarQube</b> for code quality and vulnerability check

4. <b>Terraform</b> for provisioning VM on <b>Azure</b>

5. <b>Ansible</b> to install java and run application on VM 

6. <b>Jmeter</b> for load testing

7. Destroy VM from Azure

## Steps to install private repo on Azure VM

https://medium.com/@incubusattax/setting-up-nexus-oss-in-azure-3d5f38e1f53c

## steps to connect repo from project and maven settings.xml

###Changes in pom.xml
'''
<repositories>
        <repository>
            <id>spring-releases</id>
            <url>https://repo.spring.io/libs-release</url>
        </repository>
        <repository>
            <id>maven-public</id>
            <url>http://nexu-dellemc.eastus.cloudapp.azure.com:8081/repository/maven-public/</url>
        </repository>
    </repositories>
    <pluginRepositories>
        <pluginRepository>
            <id>spring-releases</id>
            <url>https://repo.spring.io/libs-release</url>
        </pluginRepository>
    </pluginRepositories>

    <distributionManagement>
        <repository>
            <id>nexus-dellemc</id>
            <url>http://nexu-dellemc.eastus.cloudapp.azure.com:8081/repository/nexus-dellemc/</url>
        </repository>
    </distributionManagement>
    '''
###Settings.xml
 '''
 <server>
      <id>nexus-dellemc</id>
      <username>admin</username>
      <password>admin123</password>
</server>


<server>
      <id>maven-public</id>
      <username>admin</username>
      <password>admin123</password>
</server>
'''
----

'''
<mirror>
      <id>central</id>
      <name>central</name>
      <url>http://nexu-dellemc.eastus.cloudapp.azure.com:8081/repository/maven-public/</url>
      <mirrorOf>*</mirrorOf>
    </mirror>

'''

'''
 ##Install Sonar Qube
    
    
 ## CI/CD Pipeline Jenkinfile 
 
 '''
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
                            az login -u <AZUREUSERID> -p <Azure Password>
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
                                  sshpass -p <VM PASSWORD> ansible-playbook /Users/Shared/Jenkins/Home/workspace/ansible_master/ansible/playbooks/deploy.yml -i /Users/Shared/Jenkins/Home/workspace/ansible_master/ansible/environments/test/hosts -s -U root -u <VMUSERNAME> -k                
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
                            az login -u <REPLACEUSERNAME> -p <REPLACE PASSWORD>
                            terraform destroy -auto-approve
                            '''
                }
            }
        }
    }
}




 '''
