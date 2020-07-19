resource "aws_key_pair" "pub_key" {
  key_name   = "pub_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDfKSiUnU/u8WSn1VWab7p4xJuZgOnN9ydbKUGAGGU5jCSMH2njWsU4KRtdvrWGcSkFSNiufzFs6cXqIOi1fhM6t5weJGLsqL9cpRQgS7oUSMOeo6vii45xksNUU4tLHjz6RCCOnKmleUwPmFffVrWiCgnzwQcWBQQ7wvLoUt2qC58b9dFuh2ueNizanWaCTXCL2675on6kvB9rfbQXJ1cZy+y/z0Tsxp74wv3AuzclZDUSoX5xcEwJr7VN6HPfjAm0ZpJxHPgjPXoceqzWVs896pEfOqxAKH0eK4FW5FBM8EQSjspjpehYM4pWT4h5VmhEznYcD0kBaAopvdxSwg4P my@key"
}

resource "aws_instance" "web_server" {
  key_name      = aws_key_pair.pub_key.key_name
  ami           = var.ami[var.aws_region]
  instance_type = "t3.nano"
  subnet_id     = module.vpc.private_subnet_id
  vpc_security_group_ids = [
    aws_security_group.ssh_allowed.id,
    aws_security_group.http_allowed.id,
    aws_default_security_group.default.id
  ]
  user_data = <<EOF
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
EOF


  tags = {
    Name = "Web Server"
  }
}

resource "aws_instance" "jump_host" {
  key_name      = aws_key_pair.pub_key.key_name
  ami           = var.ami[var.aws_region]
  instance_type = "t3.nano"
  subnet_id     = module.vpc.public_subnet_id
  vpc_security_group_ids = [
    aws_security_group.ssh_allowed.id,
    aws_default_security_group.default.id
  ]
  tags = {
    Name = "Jump Host"
  }
}

