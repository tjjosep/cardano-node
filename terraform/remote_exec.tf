
# We're using a little trick here so we can run the provisioner without
# destroying the VM. Do not do this in production.

# If you need ongoing management (Day N) of your virtual machines a tool such
# as Chef or Puppet is a better choice. These tools track the state of
# individual files and can keep them in the correct configuration.

# Here we do the following steps:
# Sync everything in files/ to the remote VM.
# Set up some environment variables for our script.
# Add execute permissions to our scripts.
# Run the deploy_app.sh script.
# resource "null_resource" "configure-cat-app" {
#   depends_on = [aws_eip_association.this_cardano_node_eip_assoc]

#   triggers = {
#     build_number = timestamp()
#   }

#   provisioner "file" {
#     source      = "files/"
#     destination = "/home/ubuntu/"

#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = tls_private_key.this_cardano_node_pvt_key.private_key_pem
#       host        = aws_eip.this_cardano_node_eip.public_ip
#     }
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo add-apt-repository universe",
#       "sudo apt -y update",
#       "sudo apt -y install apache2",
#       "sudo systemctl start apache2",
#       "sudo chown -R ubuntu:ubuntu /var/www/html",
#       "chmod +x *.sh",
#       "PLACEHOLDER=${var.placeholder} WIDTH=${var.width} HEIGHT=${var.height} PREFIX=${var.prefix} ./deploy_app.sh",
#     ]

#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = tls_private_key.this_cardano_node_pvt_key.private_key_pem
#       host        = aws_eip.this_cardano_node_eip.public_ip
#     }
#   }
# }

