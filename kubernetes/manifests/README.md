# Kubernetes specific instructions
This README contains instructions related to the kubernetes exercises

Once the kubernetes cluster is up, creating a pod is just a kubectl run command.

Start a single instance of nginx
```bash
$ kubectl run nginx --image=nginx
```
Start a single instance of nginx and let the container expose port 80
```bash
$ kubectl run nginx --image=nginx --port=80
```

Start a replicated instance of nginx

```bash
$ kubectl run nginx --image=nginx --replicas=5
```

Dry run. Print the corresponding API objects in yaml format without creating them. This step can be used to create a manifest file example to create a pod

```bash
$ kubectl run nginx --image=nginx --dry-run=client -o yaml
```

Create a service for a replicated nginx, which serves on port 80 and connects to the containers on port 8000

```bash
$ kubectl expose rc nginx --port=80 --target-port=8000
```

A service can be created even against the manifest file. The details are automatically picked from the manifest file
```bash
$ kubectl expose -f nginx_pod.yml --port=80 --target-port=8000
```

Running the commands alone to perform certain actions on kubernetes are not trackable. Hence, it becomes a good idea to maintain the configurations using manifest files. That way, configurations can be version controlled.

```bash
$ kubectl create -f nginx_pod.yml
```

The create option can be used only once, when creating the objects for the first time. However, kubectl apply is a better option that can be used the same way any number of times.

```bash
$ kubectl apply -f nginx_pod.yml
```

The expose the port 80, we can apply the nginx_service.yml

```bash
$ kubectl apply -f nginx_service.yml
```

To create a replicaset of nginx pods. Instead of single pod, replicaset allows multiple number of pods run distributed. When any of the pods get deleted/stopped, replicaset automatically runs a new pod on any of the available nodes to ensure the same number of replicas are always running.

```bash
$ kubectl apply -f nginx_replicaset.yml

$ kubectl get rs
NAME               DESIRED   CURRENT   READY   AGE
nginx              3         3         3       24h
$
```

Though replicaset can help to maintain the high-availability of the service, deployment is a better way to wrap the distributed into them.

```bash
$ kubectl apply -f nginx_deployment.yml

$ kubectl get deploy
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   3/3     3            3           24h
$

$ kubectl describe deploy nginx
Name:                   nginx
Namespace:              training
CreationTimestamp:      Sat, 20 Apr 2024 20:42:38 +0000
Labels:                 run=nginx
Annotations:            deployment.kubernetes.io/revision: 2
Selector:               run=nginx
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  run=nginx
  Containers:
   nginx:
    Image:        nginx:1.18.0
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Progressing    True    NewReplicaSetAvailable
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  nginx (0/0 replicas created), nginx-869c8cb64d (0/0 replicas created)
NewReplicaSet:   nginx-66cc6d8c94 (3/3 replicas created)
Events:          <none>
$

```
