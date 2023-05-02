provider "google" {
  project     = "stable-sylph-86807"
  region      = "europe-west2"
}

resource "google_compute_instance_from_machine_image" "tpl" {
  provider = google-beta
  project  = "stable-sylph-86807"
  name     = "${var.PROJECT_NAME}"
  zone     = "europe-west2-a"

  source_machine_image = "projects/stable-sylph-86807/global/machineImages/vm"

  // Override fields from machine image
  can_ip_forward = false
  labels = {
    my_key = "my_value"
  }

 // metadata = {
 //   foo = "bar"
  //}

  metadata = {
    sshKeys = "${var.PROJECT_NAME}:${file("./config-sandbox/id_rsa.pub")}"
  }


  metadata_startup_script = "sudo su; adduser --disabled-password ${var.PROJECT_NAME}; touch /home/${var.PROJECT_NAME}/.ssh/authorized_keys; su $USER; ssh-keygen -t rsa; touch .ssh/authorized_keys "
  
  provisioner "file" {
  source = "./authorized_keys"
  destination = "/home/${var.PROJECT_NAME}/.ssh/authorized_keys"

  connection {
    type = "ssh"
    host = google_compute_instance_from_machine_image.tpl.network_interface.0.access_config.0.nat_ip
    user = "${var.PROJECT_NAME}"
    private_key = "${file("./config-sandbox/id_rsa")}"
    agent = "false"
  }
}


  provisioner "local-exec" {
    command = <<EOT
      echo "[proxy]
35.189.87.212 ansible_user=esokia
[nodes]
${google_compute_instance_from_machine_image.tpl.network_interface.0.network_ip} ansible_user=${var.PROJECT_NAME}
[nodes:vars]
ansible_ssh_common_args='-o ProxyCommand=\"ssh -W %h:%p esokia@35.189.87.212 -i esokia\"' " > host
ansible-playbook main.yml --extra-vars "user=${var.PROJECT_NAME} server=${google_compute_instance_from_machine_image.tpl.network_interface.0.network_ip} " -i host
    EOT
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module
  }
}




      //ansible-playbook main.yml --extra-vars "user=${var.PROJECT_NAME} server=google_compute_instance_from_machine_image.tpl.network_interface.0.network_ip " -i 127.0.0.1
      //ansible-playbook main.yml --extra-vars "user=${var.PROJECT_NAME} server=google_compute_instance_from_machine_image.tpl.network_interface.0.access_config.0.nat_ip" -i 127.0.0.1

