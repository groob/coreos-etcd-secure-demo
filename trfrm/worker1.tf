resource "digitalocean_droplet" "coreos-01" {
	image = "coreos-alpha"
	name = "coreos-01"
	region = "nyc3"
	size = "512mb"
	ssh_keys = ["96173"]
	private_networking = true
	user_data = "${file("user_data/worker.yml")}"

	connection {
		user = "core"
		key_file = "~/.ssh/id_rsa"
	}
	provisioner "file" {
		source = "etcd-ca-depot/ca.crt"
		destination = "/home/core/ca.crt"

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
output "coreos-01 public ip" {
	value = "${digitalocean_droplet.coreos-01.ipv4_address}"
}
