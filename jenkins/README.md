# Jenkins specific instructions

The URL (https://www.jenkins.io/doc/book/installing/linux/) contains detailed steps that can be followed to deploy Jenkins on a Linux system. Below instructions include the exerpt of the steps available in the above mentioned URL.

## Jenkins installation on Ubuntu 22.04 Server

As Jenkins is a Java based application, we would need to install openJDK first.

```bash
$ sudo apt-get update
$ sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
$ echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
$ sudo apt install fontconfig openjdk-17-jre
$ java -version
$ sudo apt-get install jenkins

$ sudo systemctl start jenkins
$ sudo systemctl enable jenkins

```

## Perform initial configuration

By default, the Jenkins service is made available on the port 8080. The same can be changed in the service file using below change.

```bash
[Service]
Environment="JENKINS_PORT=8081"
```

Initial configuration needs to be done through a web server. We can open the web page from http://192.168.56.33:8080

![Unlock Jenkins, the very first screen](unlock_jenkins.png)

One the first page, the file that can be viewed for the initial password would be displayed.

```bash
$ sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Subsequent customization page will prompt for the plugins that need to be installed. This might be a time taking process depending on the number of plugins selected and the internet speed.

**Install suggested plugins** - to install the recommended set of plugins, which are based on most common use cases.

**Select plugins to install** - to choose which set of plugins to initially install. When you first access the plugin selection page, the suggested plugins are selected by default.

**Note**: Further customization of the plugins can be done through **Manage Jenkins** > **Plugins** page in Jenkins

This page shall be followed by creating a new admin user. Just enter the values and proceed further.

When the Create First Admin User page appears, specify the details for your administrator user in the respective fields and click Save and Finish.

When the Jenkins is ready page appears, click Start using Jenkins.

**Notes**: This page may indicate 'Jenkins is almost ready!' instead. If so, click Restart.

If the page does not automatically refresh after a minute, use your web browser to refresh the page manually.

If required, log in to Jenkins with the credentials of the user you just created and you are ready to start using Jenkins!

## Create first FreeStyle project

We can start with Dashboard => New Item. A free style project would enable us to witness what actually happens in the pipelining.

![Create a new item](new_item.png)

Select the FreeStyle Project and provide a description.

![MyFreeStyleProject](MyFreeStyleProject.png)

Under the configuration, select additional configuration according to the requirement.

![Configure](FSP_Configure.png)

The build triggers and build environments are helpful in defining how the build should initiate (manually triggered or automated) and using what environment should be the build process to be triggered.

![Build Triggers and Build Environments](Build_Triggers.png)

In our example, we are just using an execute shell option. Any Linux command can be run on this.
![Build Steps - Execute Shell](Build_Steps_Shell.png)

If needed, additional build actions canb e added until all the actions are completed.
![Build Steps Execute Shell](Build_Steps_Execute_Shell.png)

We can perform varied list of post build actions. One of them is to clean up workspace.
![Add Post Build Action](Add_Post_Build_Action.png)

Finally, once done, save the Free Style Project and we can then use build option to run it.
![Save FreeStyle Project](Save_FSP.png)

We can now run the Free Style project by clicking on Build Now
![Build Now](Build_Now.png)

Every run can be looked into by detail using the Console Output of the run (click the number from the build history section)
![alt text](Console_Output.png)

The status of the free style project is not very encouraging. Yet, this allows us to make use of Jenkins abilities to pipeline various manual steps which otherwise we should have been doing.
![FreeStyle Project Status](FSP_Status.png)

## Create first Pipeline project

We can start with Dashboard => New Item. A Pipeline project would enable us to witness the actual ability of the Jenkins tool.

![Create a new item](new_item.png)

Select the Pipeline Project
![My Pipeline Project](MyPipelineProject.png)

Include the basic configuration
![My Pipeline Project Configuration](MPP_Configure.png)

Specify the build triggers for the pipeline project
![Build Triggers for Pipeline Project](MPP_Build_Triggers.png)

Pipeline option can be using a embedded Pipeline Script or a script from SCM (eg. GitHub)
![Pipeline Option](Pipeline.png)

In case of pipeline script, we need to specify the pipeline script in the box meant for that.
![Pipeline Script](PipeLine_Script.png)

The actual content might look similar to this.
```bash
pipeline { 
    agent any 
    options {
        skipStagesAfterUnstable()
    }
    stages {
        stage('Build') { 
            steps { 
                sh 'mkdir some_directory' 
            }
        }
        stage('Test'){
            steps {
                sh 'cp /etc/*release some_directory'
            }
        }
        stage('Deploy') {
            steps {
                sh 'ls some_directory; cat some_directory/*release' 
            }
        }
    }
}
```
Save the settings to enable the pipeline Project
![Save Pipeline](PipeLineScript_Save.png)

We can again click on Build now to start the pipeline
![Build Now](Build_Now_Pipeline_Script.png)

The console outputs let us know how the task got completed
![Console Output](MPP_Console_Output.png)

In case if we wish to specify a script from SCM (GitHub), we can do so by specifying the GitHub project path and specify the branch, script name and save the settings.
![Pipeline Script from SCM](Pipeline_Script_from_SCM.png)

![Pipeline Script Name and Save](Pipeline_Script_From_SCM_Save.png)

Once saved, the build now can trigger the Jenkins Pipeline and from the console output, it will be clear that the Jenkinsfile (Script name) is indeed fetched fromthe GitHub repository link provided before.
![Pipeline script from SCM console output](Pipeline_Script_from_SCM_Console_Output.png)

In comparison to the Free Style project, Pipeline Projects have better history visualization.
![Pipeline project History](Pipeline_project_History.png)
