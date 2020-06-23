# Install 

## Source: https://cloud.google.com/kubernetes-engine/docs/quickstart#local-shell

# 

To install `gcloud` and `kubectl`, perform the following steps:

1. [Install the Cloud SDK](https://cloud.google.com/sdk/install), which includes the `gcloud` command-line tool.

1. After installing Cloud SDK, install the `kubectl` command-line tool by running the following command:

        gcloud components install kubectl

## Configure gcloud

Configuring default settings makes it easier to run `gcloud` commands, because `gcloud` requires that you specify the project and compute zone in which you want to work. You can also specify these settings or override default settings with flags, such as `--project`, `--zone`, and `--cluster`, in your `gcloud` commands.

### Setting a default project

Run the following command, replacing `project-id` with your project ID:

    gcloud config set project <project-id>

### Setting a default compute zone

Run the following command, replacing `compute-zone` with your compute zone, such as __europe-west2-a__:

    gcloud config set compute/zone <compute-zone>

## Build the container image

1. Set the `PROJECT_ID` environment variable to your Google Cloud project ID (project-id). The `PROJECT_ID` variable will be used to associate the container image with your project's Container Registry.

        set -x PROJECT_ID <project-id>
        set -x PROJECT_NAME <project-name> 
        set -x PROJECT_VSN_TAG <project-version-tag>

1. Build and tag the Docker image:

        docker build -t gcr.io/$PROJECT_ID/$PROJECT_NAME:$PROJECT_VSN_TAG .
        
    Running this command does not upload the image yet.

1. Run the `docker images` command to verify that the build was successful:

        docker images

    Output:
            
        REPOSITORY                                TAG                 IMAGE ID            CREATED             SIZE
        gcr.io/hello-elixir-278607/hello-elixir   v1                  70b867c1d7d4        9 days ago          21.3MB
        alpine                                    3.11                f70734b6a266        8 weeks ago         5.61MB

## Push the Docker image to Container Registry

You need to upload the container image to a registry so that your GKE cluster can download and run it.
   
1. Configure the Docker command-line tool to authenticate to Container Registry:
   
        gcloud auth configure-docker
   
1. Push the Docker image you just built to Container Registry:
   
        docker push gcr.io/$PROJECT_ID/$PROJECT_NAME:$PROJECT_VSN_TAG
   
## Creatie a GKE cluster

1. The following command creates a one-node cluster. Replace `cluster-name` with the name of your cluster:

    gcloud container clusters create <cluster-name> --num-nodes=1

1. After the cluster has been created you can 

    $ gcloud container clusters list                                                                                                                                                                                           2.8m  Fri 19 Jun 2020 02:40:59 PM CEST
    NAME                  LOCATION        MASTER_VERSION  MASTER_IP     MACHINE_TYPE   NODE_VERSION    NUM_NODES  STATUS
    hello-elixir-cluster  europe-west2-a  1.14.10-gke.36  34.89.25.247  n1-standard-1  1.14.10-gke.36  1          RUNNING

1. Run the following command to see the cluster's two worker VM instances:
   
        gcloud compute instances list
   
   Output:
   
       NAME                                           ZONE        MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP    STATUS
       gke-hello-cluster-default-pool-d8b498d3-0d6r  us-east1-b  n1-standard-1               10.142.0.4   35.237.4.149   RUNNING
       gke-hello-cluster-default-pool-d8b498d3-k29m  us-east1-b  n1-standard-1               10.142.0.3   34.75.248.193  RUNNING
       gke-hello-cluster-default-pool-d8b498d3-vcrj  us-east1-b  n1-standar

## Deploy the application

1. Create a Kubernetes Deployment for your Docker image.
   
        kubectl create deployment hello-elixir-deployment --image=gcr.io/$PROJECT_ID/$PROJECT_NAME:$PROJECT_VSN_TAG
   
   Set the baseline number of Deployment replicas to 3.
   
   kubectl scale deployment hello-app --replicas=3
   
   Create a HorizontalPodAutoscaler resource for your Deployment.
   
   kubectl autoscale deployment hello-app --cpu-percent=80 --min=1 --max=5
   
1. To see the Pods created, run the following command:
   
        kubectl get pods
        
    Output:
    
        NAME                                     READY   STATUS    RESTARTS   AGE
        hello-elixir-deployment-c4b579b8-mfb26   1/1     Running   0          17s


## Expose the sample app to the internet

1. Use the `kubectl` expose command to generate a Kubernetes Service for the hello-app deployment.

        kubectl expose deployment $PROJECT_NAME-deployment --name=$PROJECT_NAME-service --type=LoadBalancer --port 80 --target-port 8080

    Here, the ~ flag specifies the port number configured on the Load Balancer, and the ~ flag specifies the port number that the container is listening on.

1. Run the following command to get the Service details:

        kubectl get service

    Output:
    
        NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)        AGE
        hello-elixir-service   LoadBalancer   10.3.247.251   35.246.90.46   80:31625/TCP   21m
        kubernetes             ClusterIP      10.3.240.1     <none>         443/TCP        85m

1. Copy the EXTERNAL_IP address to the clipboard (for instance: 35.246.90.46):

        curl 35.246.90.46/isItWorking


kubectl get deployments                                                                                                                         3183ms  Mon 22 Jun 2020 10:25:41 AM CEST
NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
hello-elixir-deployment   1/1     1            1           2d20h


kubectl describe deployments/hello-elixir-deployment                                                                                            3356ms  Mon 22 Jun 2020 12:26:59 PM CEST
Name:                   hello-elixir-deployment
Namespace:              default
CreationTimestamp:      Fri, 19 Jun 2020 15:33:20 +0200
Labels:                 app=hello-elixir-deployment
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=hello-elixir-deployment
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=hello-elixir-deployment
  Containers:
   hello-elixir:
    Image:        gcr.io/hello-elixir-278607/hello-elixir:v1
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   hello-elixir-deployment-c4b579b8 (1/1 replicas created)
Events:          <none>


##

1. 
gcloud compute instances list                                                                                                                                                                                      1333ms  Mon 22 Jun 2020 10:13:04 AM CEST
NAME                                                 ZONE            MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP  STATUS
gke-hello-elixir-cluster-default-pool-aa41271b-cbdm  europe-west2-a  n1-standard-1               10.154.0.6   34.89.46.55  RUNNING


1. 
gcloud compute ssh gke-hello-elixir-cluster-default-pool-aa41271b-cbdm




gcloud container images list
gcloud container clusters list 

gcloud container clusters delete hello-elixir-cluster
gcloud container images delete gcr.io/hello-elixir-278607/hello-elixir:v1 --force-delete-tags

gcloud compute instances list                                                                                                                                                                                          1158ms  Mon 22 Jun 2020 09:47:53 AM CEST
NAME                                                 ZONE            MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP  STATUS
gke-hello-elixir-cluster-default-pool-aa41271b-cbdm  europe-west2-a  n1-standard-1               10.154.0.6   34.89.46.55  RUNNING


Note: it may take a few minutes for the Load Balancer to be provisioned, and you may see a <pending> IP address in the meantime.
Now that the hello-app pods are exposed to the internet via a Kubernetes Service, you can open a new browser tab, and navigate to the Service IP address you copied to the clipboard. You should see a Hello, World! message along with a Hostname field. The Hostname corresponds to one of the three hello-app pods serving your HTTP request to your browser.



Use the gcloud tool to configure two default settings: your default project and compute zone.

Your project has a project ID, which is its unique identifier. When you first create a project, you can use the automatically generated project ID or you can create your own.

Your compute zone is a location in the region where your clusters and their resources live. For example, us-west1-a is a zone in the us-west region.



# Debugging

## Viewing a Container’s Logs

In Kubernetes, _logs_ are considered to be whatever a container writes to the standard output and standard error streams.


To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

    sudo -i -u webapp env `grep -h "^\s*[A-Z]\{1,\}" /etc/default/webapp* | xargs` /data/webapp/public/current/bin/kx_widget console
    sudo -i -u webapp env `grep -h "^\s*[A-Z]\{1,\}" /etc/default/webapp* | grep -v 'GOOGLE' | xargs` /data/webapp/public/current/bin/kx_widget start_iex
    
    
    docker build -t hello-elixir .
    docker run --rm -p 127.0.0.1:8080:8080 -it hello-elixir
    
    
    
    