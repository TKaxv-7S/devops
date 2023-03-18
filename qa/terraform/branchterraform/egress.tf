
# right now this points to clientQA. needs the droplet id for the egress client to make a snapshot
resource "digitalocean_droplet_snapshot" "egress_snapshot" {
  droplet_id = "344553038"
  name       = "clientQA-1678592527249"
}

resource "digitalocean_droplet" "egress" {
  image = digitalocean_droplet_snapshot.egress_snapshot.id
  #image = "lxc-1674164060623"
  name = var.egress
  size = "s-2vcpu-2gb-intel"
  ipv6 = true
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]
  tags = [var.egress, var.branch]

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.pvt_key)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # install netclient
      "apt-get -y update",
      "apt-get -y update",
      "snap install go --classic",
      "snap install go --classic",
      "apt install -y wireguard-tools gcc",
      "apt install -y wireguard-tools gcc"
    ]
  }
}

data "digitalocean_droplet" "egressserverip" {
  name       = var.egress
  depends_on = [digitalocean_droplet.egress]
}

resource "local_file" "egressipaddresses" {
  depends_on = [data.digitalocean_droplet.egressserverip]
  content    = data.digitalocean_droplet.egressserverip.ipv4_address
  filename   = "ipaddress${var.egress}.txt"

}