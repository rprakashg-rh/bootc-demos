# Ansible automation playbooks 

## Create a VPC in your AWS account
First we are going to create a VPC in your AWS account by running terraform scripts

```sh
cd ./terraform/vpc

terraform init
terraform plan
terraform apply
```

Note down the security group if and public subnet id created after running the terrraform script and update [influx.yml](./vars/influx.yml) and [loki.yml](./vars/loki.yml) file under `vars` directory

## Install configure Influxdb
Follow the instructions in [README](../images/influxdb/README.md) to build RHEL image mode container for InfluxDB and convert the container image to AMI. Note down the AMI ID

Update the AMI ID in [influx.yml](./vars/influx.yml) file

## Launch an EC2 instance to run InfluxDB
Launch an EC2 instance using the AMI we created using the InfluxDB image mode container by running an ansible playbook as shown below

```sh
ansible-playbook --vault-password-file <(echo "$VAULT_SECRET") launch-ec2.yaml -e @vars/influx.yml
```

At this point you can should be able to login to influx using a browser and complete the initial setup. Use `redhat` for org and `vpac-metrics` for bucket name and specify admin user and password

Next we will create a token for Otel collector to write to `vpac-metrics` bucket. 

## Install configure Grafana and Loki
Follow instructions in [README](../images/loki/README.md) to build RHEL image mode container for Grafana/Loki and convert the container image to AMI. Note down the AMI ID

Update the AMI ID in [loki.yml](./vars/loki.yml) file 

## Launch an EC2 instance to run Grafana and Loki
Launch an EC2 instance using the AMI ID we create using the loki image mode container by running an ansible playbook as shown below

```sh
ansible-playbook --vault-password-file <(echo "$VAULT_SECRET") launch-ec2.yaml -e @vars/loki.yml
```

## Install and Configure Otel collector
Steps to install and configure Otel collector is automated using an Ansible playbook. 

First we create an Ansible vault to store the token used to write to influx db

```sh
ansible-vault create vars/secrets.yml
```

Add influx db token as shown below

```yaml
influxdb_token: <redacted>
```

Run the playbook as shown below to install and configure Otel collector on the target RHEL host

```sh
ansible-playbook -i inventory --vault-password-file <(echo "$VAULT_SECRET") install-configure-otelcol.yaml -e @vars/otelcol.yml
```