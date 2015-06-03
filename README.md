# Create CoreOS instances on DigitalOcean using Terraform and TLS certificates.
I use terraform to create new CoreOS instances on Digital Ocean.
I wanted to have etcd secured by TLS, so this terraform template will sign and upload certificates using etcd-ca.

This is a very simple demo, designed for the example below:
![img](https://coreos.com/docs/cluster-management/setup/cluster-architectures/dev.png)

For a production environment you will have to modify this example according to [this document](https://coreos.com/docs/cluster-management/setup/cluster-architectures/)

# Links
## Software
* [CoreOS](coreos.com)
* [etcd](https://github.com/coreos/etcd)
* [etcd-ca](https://github.com/coreos/etcd-ca)
* [Terraform](https://terraform.io/)

## Documentation
* [CoreOS Cluster architectures](https://coreos.com/docs/cluster-management/setup/cluster-architectures/)
* [Bootstrap etcd2 video](https://www.youtube.com/watch?v=duUTk8xxGbU)
* [etcd security](https://github.com/coreos/etcd/blob/master/Documentation/security.md)
* [Setting up a secure etcd cluster](http://blog.dixo.net/2015/05/setting-up-a-secure-etcd-cluster/)
* [CoreOS Etcd and Fleet with Encryption and Authentication](https://medium.com/@gargar454/coreos-etcd-and-fleet-with-encryption-and-authentication-27ffefd0785c)
* [Deploying CoreOS cluster with etcd secured by TLS/SSL](http://blog.skrobul.com/securing_etcd_with_tls/)

# TLS certificates
The TLS certificates are created and signed by [etcd-ca](https://github.com/coreos/etcd-ca)  
When Terraform bootstraps a new CoreOS instance, etcd-ca will generate and sign a the certificates.  It will then use the file provisioner to scp the certificate and key for each server.
The client certificates for the worker are pregenerated and assumed to be in:
`./etcd-ca-depot/client.host.crt` and `./tmp/client.key.insecure`

## Setting up the CA
```
# create a CA
etcd-ca --depot-path etcd-ca-depot init --passphrase "trfrm" --organization "My Org"

# create the client certificate and key
etcd-ca --depot-path etcd-ca-depot new-cert --passphrase 'trfrm' client
etcd-ca --depot-path etcd-ca-depot sign --passphrase 'trfrm' client
etcd-ca --depot-path etcd-ca-depot export --insecure --passphrase 'trfrm' client | tar xvf -
rm -f client.crt
mv client.key.insecure tmp/
```

# CoreOS cloud-config
There are two user data files located in user_data. The etcd1.yml config will bootstrap an etcd server.
worker.yml is the cloud-config for the fleet worker. You will need to edit the worker template to add the etcd1 public IP. 

## How do I know the etcd-1 ip?
Because it's not possible to know for sure what the IP address for a droplet is, we are going to run terraform twice. 
First, terraform will create two digital ocean instances - etcd1 and coreos-01
Once terraform creates the instances, edit worker.yml with the etcd1 ip address.
Running `terraform taint digitalocean_droplet.coreos-01` will mark the worker instance for recreation.
Run `terraform apply` again to recreate the instance, this time with the correct etcd IP.

# Terraform commands.
```
# apply configuration  
terraform apply trfrm
# refresh state
terraform refresh
# recreate a resource
# for example, the worker
terraform taint digitalocean_droplet.coreos-01
# destroy everything
terraform destroy trfrm

# enable debug logging for terraform
TF_LOG=1 terraform apply trfrm
```

