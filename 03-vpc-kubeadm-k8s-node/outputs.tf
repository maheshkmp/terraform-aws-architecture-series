output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.k8s_node.id
}

output "public_ip" {
  description = "Persistent Elastic IP assigned to the Kubernetes node"
  value       = aws_eip.k8s_eip.public_ip
}

output "ssh_command" {
  description = "Command to SSH into the EC2 node"
  value       = "ssh -i ${replace(var.ssh_public_key_path, ".pub", "")} ubuntu@${aws_eip.k8s_eip.public_ip}"
}

output "kubeadm_init_command" {
  description = "Command to initialize Kubernetes control plane after SSH"
  value       = "sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-cert-extra-sans=${aws_eip.k8s_eip.public_ip}"
}
