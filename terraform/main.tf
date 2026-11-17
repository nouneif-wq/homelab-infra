# main.tf
locals {
  vms = {
    "k3s-server"  = { node = "pve3", template = 9003, id = 121, ip = "192.168.1.21", mem = 8192,  cores = 4, disk = 40 }
    "k3s-worker1" = { node = "pve1", template = 9001, id = 122, ip = "192.168.1.22", mem = 26624, cores = 8, disk = 120 }
    "k3s-worker2" = { node = "pve2", template = 9002, id = 123, ip = "192.168.1.23", mem = 18432, cores = 8, disk = 100 }
  }
}

resource "proxmox_virtual_environment_vm" "k3s" {
  for_each  = local.vms
  name      = each.key
  node_name = each.value.node
  vm_id     = each.value.id
  on_boot   = true

  clone {
    vm_id = each.value.template
    full  = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.mem
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = each.value.disk
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = "192.168.1.1"
      }
    }
    dns {
      servers = ["192.168.1.1"]
    }
    user_account {
      username = "ubuntu"
      keys     = [trimspace(file("~/.ssh/id_ed25519.pub"))]
    }
  }
}
