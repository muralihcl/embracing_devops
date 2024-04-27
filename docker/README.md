# Docker specific instructions
This README contains instructions related to the docker exercises

## Install docker on Ubuntu 22.04 Server

https://docs.docker.com/engine/install/ubuntu/

Follow the instructions available in the above link.

Though the ubuntu snap can help to install a version that is available in the snap repositories, docker installation from docker-ce repositories is always the latest.

## Some common docker commands
```docker run hello-world``` This is a test image and if you get a Hello World message, the docker installation on your distro has been successful.

```docker run -it ubuntu /bin/bash``` This runs the ubuntu image (after pulling if the image already does not exist) and drops the prompt to the container prompt. However, if we exit from the prompt, the container is stopped.

```docker run -itd ubuntu /bin/bash``` This runs the ubuntu image in a detached mode.

```docker ps``` List all the running containers. The option -a can list all the containers, including the stopped ones.

```docker attach <container_id> /bin/bash``` This attaches to the container prompt. However, exiting from the prompt stops the container. If we wish to keep the container running, even after exiting, we need to use Ctrl + PQ.

```docker exec -it <container_id> /bin/bash``` This is the safest way to connect to a running container. Even if we exit the session, the container would keep running.

```docker commit <container_id>``` This command is used to save the changes added to the container manually to the image. However, after manually making the application run on a container, it would be better to make use of the Dockerfile to build the new container image.

## Dockerfile examples - NGINX
(Assuming the docker-ce installation is complete, github repository is cloned and we are inside the docker directory)

nginx/Dockerfile file (This contains instructions to build a custom NGINX docker image from vanilla ubuntu image. The DOT at the end instructs the build command that the Dockerfile exists in the current directory)

```bash
$ cd nginx
$ docker build -t"nginx:v1" .
```

Post this build, the system will have an image nginx:v1. One can run the new container image to start it. The option --name mynginx gives the custom name mynginx to the container that is run. All the container level commands can be run against the name as well, just like the container ID. Hence, having a fixed name can turn out to be useful where we don't have to get the container ID every time we need to run a container specific command.

```bash
$ docker run --rm --name mynginx -itd nginx:v2
4680031457a258d39ed4302fe3261393e536f600f96ba43c64e23ed0e3b89ef0
$ docker ps
CONTAINER ID   IMAGE      COMMAND                  CREATED         STATUS         PORTS     NAMES
4680031457a2   nginx:v2   "/usr/sbin/nginx -g …"   3 seconds ago   Up 2 seconds   80/tcp    mynginx
$
```

The 80/tcp under the PORTS column comes from the EXPOSE command present in the Dockerfile. Now that we are aware that the port 80 is exposed from the container, we can use port mapping to expose the port to the localhost. The curl command hitting the local host's IP address on port 8080 displays a response coming from NGINX. This confirms port mapping within docker.

```bash
$ docker run --rm --name mynginx -itd -p 8080:80 nginx:v2
2e5f5554548570e472001b79d367177a1b7cfc6469ee7b27fc95df5f3278ee6c
$ curl http://192.168.56.24:8080
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
$
```
