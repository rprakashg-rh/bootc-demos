# Ansible automation playbooks 


## Install and Configure Otel collector
Steps to install and configure Otel collector is automated using an Ansible playbook. 

First we create an Ansible vault to store the token used to write to influx db

```sh
ansible-vault create vars/secrets.yml
```

Run the playbook as shown below to install and configure Otel collector on the target RHEL host

```sh
ansible-playbook 
```