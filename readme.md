## Terraform demo for OpenStack Days Tokyo 2017

This is a terraform demo created to show how to connect different cloud systems using terraform.

The architecture of the system itself is extremely simple, just a bunch of virtual machines with a basic webpage connected to an OpenStack load balancer.

Brief explanation of the different modules:
01) OpenStack only.
02) AWS only (with an autoscaling group).
03) OpenStack, AWS and GCP servers all connected to an OpenStack load balancer.

To run an example just enter into the module and execute "terraform apply". Remember that AWS and GCP do cost money (shouldn't be more than a few cents with this example).
```bash
cd 03_OpenStack_AWS_GCP
terraform apply
```
After all the instances are initialized, you can see how the load balancer is going through all the created instances with the "multi_curl" script.
```bash
../multi_curl
```
At the end, don't forget to destroy the created instances to prevent over-spending.
```bash
terraform destroy
```

## Requirements

In order to run the examples you need appropriate access to an OpenStack system, AWS and GCP.

#### OpenStack

After running your OpenStack environment's openrc file, make sure to source tf_env.rc and terraform will capture the credentials from the environment variables.
```bash
source tf_env.rc
```

In many cases the OpenStack environments are located behind a proxy. In that case I recommend to use the superb sshutle to make life easier.

https://github.com/apenwarr/sshuttle/blob/master/docs/how-it-works.rst

#### AWS

Terraform will auto-detect your credentials if you have the aws command line toolset installed. Otherwise you may need to export some variables to the environment:
https://github.com/apenwarr/sshuttle/blob/master/docs/how-it-works.rst

#### GCP

You will need a project and the appropriate credentials.
1) Create a project for terraform and find its ID.
   You can find the ID by clicking on the name of the project in the GCP console. That will take you to a screen listing all projects and their IDs.
2) Credentials JSON file. See Hashicorp's page on GCP for details on how to do it. You will have to set the path to this file in the provider section of main.tf.
   https://www.terraform.io/docs/providers/google/index.html
