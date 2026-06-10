output "ecs_cluster_name" {
  description = "Cluster name, used by scripts/20-get-server-ip.sh"
  value       = aws_ecs_cluster.minecraft.name
}

output "ecs_service_name" {
  description = "Service name, used by scripts/20-get-server-ip.sh"
  value       = aws_ecs_service.minecraft.name
}

output "efs_id" {
  description = "EFS file system holding the world data"
  value       = aws_efs_file_system.minecraft_data.id
}
