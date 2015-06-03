resource "digitalocean_droplet" "etcd1" {
	image = "coreos-alpha"
	name = "etcd-1"
	region = "nyc3"
	size = "512mb"
	ssh_keys = ["96173"]
	private_networking = true
	user_data = "${file("user_data/etcd1.yml")}"

	connection {
		user = "core"
		key_file = "~/.ssh/id_rsa"
	}
	provisioner "local-exec" {
		command = "SAN=${digitalocean_droplet.etcd1.ipv4_address} PASSPHRASE=trfrm CERTNAME=${digitalocean_droplet.etcd1.name} ./bin/gencert.sh"
	}
	provisioner "file" {
		source = "etcd-ca-depot/ca.crt"
		destination = "/home/core/ca.crt"

	}
	provisioner "file" {
		source = "etcd-ca-depot/${digitalocean_droplet.etcd1.name}.host.crt"
		destination = "/home/core/${digitalocean_droplet.etcd1.name}.host.crt"
	}
	provisioner "file" {
		source = "tmp/${digitalocean_droplet.etcd1.name}.key.insecure"
		destination = "/home/core/${digitalocean_droplet.etcd1.name}.key"
	}
	provisioner "file" {
		source = "etcd-ca-depot/client.host.crt"
		destination = "/home/core/client.host.crt"
	}
	provisioner "file" {
		source = "etcd-ca-depot/client.key.insecure"
		destination = "/home/core/client.key"
	}
	provisioner "remote-exec" {
		inline = [
			"sudo mkdir -p /etc/ssl/etcd/certs",
			"sudo mkdir -p /etc/ssl/etcd/private",
			"sudo mv *.crt /etc/ssl/etcd/certs",
			"sudo mv *.key /etc/ssl/etcd/private",
		]
	}

}

output "etcd1 public ip" {
	value = "${digitalocean_droplet.etcd1.ipv4_address}"
}
