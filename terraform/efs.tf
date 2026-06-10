resource "aws_efs_file_system" "minecraft_data" {
  creation_token = "${var.project_name}-data"
  encrypted      = true

  tags = {
    Name = "${var.project_name}-world-data"
  }
}

resource "aws_efs_mount_target" "minecraft_data" {
  for_each = toset(data.aws_subnets.default.ids)

  file_system_id  = aws_efs_file_system.minecraft_data.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_access_point" "minecraft_data" {
  file_system_id = aws_efs_file_system.minecraft_data.id

  posix_user {
    uid = 1000
    gid = 1000
  }

  root_directory {
    path = "/minecraft"
    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = "0755"
    }
  }
}
