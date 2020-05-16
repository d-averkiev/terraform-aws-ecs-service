data "template_file" "service" {
  template = coalesce(var.service_task_container_definitions, file("${path.module}/container-definitions/service.json.tpl"))

  vars = {
    name = var.service_name
    image = var.service_image
    command = jsonencode(var.service_command)
    memory = var.service_task_container_memory
    port = var.service_port
    region = var.region
    log_group = local.log_group_name
  }
}

resource "aws_ecs_task_definition" "service" {
  family = "${var.component}-${var.service_name}-${var.deployment_identifier}"
  container_definitions = data.template_file.service.rendered

  network_mode = var.service_task_network_mode

  cpu = var.service_task_size_cpu == 0 ? null : var.service_task_size_cpu
  memory = var.service_task_size_memory == 0 ? null : var.service_task_size_memory

  task_role_arn = var.service_role

  dynamic "volume" {
    for_each = var.service_volumes
    content {
      name = volume.value.name
      host_path = volume.value.host_path
    }
  }
}
