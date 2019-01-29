# DevOps_Jenkin_Ansible_Terraform_Azure

1. Created sample application using <b>spring-boot</b>

2. <b>Maven</b> for build and <b>Nexus</b> for dependency and packaging

3. <b>SonarQube</b> for code quality and vulnerability check

4. <b>Terraform</b> for provisioning VM on <b>Azure</b>

5. <b>Ansible</b> to install java and run application on VM 

6. <b>Jmeter</b> for load testing

7. Destroy VM from Azure

# Steps to install private repo on Azure VM

https://medium.com/@incubusattax/setting-up-nexus-oss-in-azure-3d5f38e1f53c

# steps to connect repo from project and maven settings.xml

in pom.xml

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
    
    Settings.xml
    
    #Install Sonar Qube
    
    
