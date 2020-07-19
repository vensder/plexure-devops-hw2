# Task 2 (IaC)

[![Terraform](https://github.com/vensder/plexure-devops-hw2/workflows/Terraform/badge.svg)](https://github.com/vensder/plexure-devops-hw2/actions?query=workflow%3ATerraform)

Write a Terraform Template or ARM Template to provision a VM machine in Azure or AWS cloud with an apache web server installed on it and the index page should print "Hello Plexure!" on the Browser, the VM Provisioned should be tagged as "Web Server" and should run behind a Load Balancer.

* Use Network Security Best Practices to provision the VM.
* Surprise us with your creative approach.

[Bonus Points]: Write an Ansible Role or a chef recipe to install and configure the webserver on the VM.

## Implementation

The GitHub Actions CI system validates and checks the format of the templates for Terraform versions:
`0.12.7`, `0.12.20`, `0.12.28`.

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

You will see the outputs at the end of applying, for example:

```sh
Outputs:

elb_hostname = plexure-elb-311963932.us-east-1.elb.amazonaws.com
jump_host_public_ip = 54.210.113.15
jump_host_public_name = ec2-54-210-113-15.compute-1.amazonaws.com
web_server_private_ip = 10.20.1.164

```

Use `elb_hostname` to access to URL from Web browser:

![The Diagram](./img/screenshot.png?raw=true)

The public IP address of the jump host and private IP address of the webserver can help you to access to a web server for debugging or for provisioning using Ansible/Chef configuration management systems.

## Run Ansible role for Web server

Go to `ansible` directory, create the Python 3 virtual environment, and install ansible in it:

```sh
virtualenv -p python3 env
source env/bin/activate
pip install ansible
```

To be able to run Ansible playbook through the Jump (Bastion) host, add IP addresses to the configuration files.

Put the IP addresses of the webserver (private IP) and jump host (public IP) into the `inventory/hosts` file.

Change the Jump Host IP address/hostname in the `ssh.cfg` according to the terraform output.

Apply the playbook:

```sh
ansible-playbook playbook.yml
 ___________________
< PLAY [webservers] >
 -------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||

 ________________________
< TASK [Gathering Facts] >
 ------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||

ok: [10.20.1.164]
 ____________________________
< TASK [apache : Update apt] >
 ----------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||

changed: [10.20.1.164]
 ________________________________
< TASK [apache : Install Apache] >
 --------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||

ok: [10.20.1.164]
 _____________________________________________
< TASK [apache : Create custom document root] >
 ---------------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||

ok: [10.20.1.164]
 __________________________________
< TASK [apache : Set up HTML file] >
 ----------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||

ok: [10.20.1.164]
 ____________
< PLAY RECAP >
 ------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||

10.20.1.164                : ok=5    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Also, you can simply get access to the webserver via Jump host:

```sh
ssh -l ubuntu 10.20.1.164 -F ./ssh.cfg
```
