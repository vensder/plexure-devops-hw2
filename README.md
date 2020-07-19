# Task 2 (IaC)

[![Terraform](https://github.com/vensder/plexure-devops-hw2/workflows/Terraform/badge.svg)](https://github.com/vensder/plexure-devops-hw2/actions?query=workflow%3ATerraform)

Write a Terraform Template or ARM Template to provision a VM machine in Azure or AWS cloud with an apache web server installed on it and the index page should print "Hello Plexure!" on the Browser, the VM Provisioned should be tagged as "Web Server" and should run behind a Load Balancer.

* Use Network Security Best Practices to provision the VM.
* Surprise us with your creative approach.

[Bonus Points]: Write an Ansible Role or a chef recipe to install and configure the webserver on the VM.

## Implementation

The Terraform templates provision the new VPC in AWS with two subnets, one of them is public faced, another one is private. For VPC provisioning we reuse the VPC module from another personal project.

The EC2 instance with Apache Web server is placed in the Private subnet and doesn't have Public IP.

In the Public subnet, we have Internet Gateway, Elastic Load Balancer, NAT Gateway with Elastic IP, and Jump Host for access to the Web server host.

![The Diagram](./img/diagram.png?raw=true)

To install Apache Web server and run it with custom web page we pass the script to the User data for the EC2 (see `ec2.tf` file):

```sh
#!/usr/bin/env bash
sudo apt-get update
sudo apt-get -y install apache2
sudo systemctl enable apache2
echo '''
<h1>Hello Plexure!</h1>
</br>
<img src="https://pbs.twimg.com/profile_banners/587083303/1559785690/1500x500" style="width:70%";>
''' | sudo tee /var/www/html/index.html
sudo systemctl restart apache2
```

To apply templates to your infrastructure export AWS KEY and Secret to the environment variables first:

```sh
export AWS_ACCESS_KEY_ID='XXX..........'
export AWS_SECRET_ACCESS_KEY='XXx........'
```

Then run terraform commands:

```sh
terraform plan
terraform apply
```

You will see the outputs at the end of applying:

```sh
Outputs:

elb_hostname = plexure-elb-1638876154.us-east-1.elb.amazonaws.com
jump_host_public_ip = 3.88.201.140
web_server_private_ip = 10.20.1.113
```

Use `elb_hostname` to access to URL from Web browser:

![The Diagram](./img/screenshot.png?raw=true)

The public IP address of the jump host and private IP address of the webserver can help you to access to a web server for debugging or for provisioning using Ansible/Chef configuration management systems.
