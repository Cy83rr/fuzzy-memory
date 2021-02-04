variable "location" {
  default = "westeurope"
}

variable "admin_username" {
  default = "admin"
}

variable "admin_password" {
  default = ""
}

variable "linux_nodes" {
  description = "Map of linux nodes, where the key is the VM name. Remember to generate password"
  type = map(map(string))
  default = {
    "testlinux1" = {
        #name = "testlinux1"
        size = "Standard_B2ms"
        nic = ""
        pass = ""
    }
    "testlinux2" = {
        #name = "testlinux2"
        size = "Standard_B2ms"
        nic = ""
        pass = ""
    }
  }
}
