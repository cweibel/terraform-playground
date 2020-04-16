locals {
    configure_postgres_template = "templates/configure-cf-rds.tpl"
    configure_postgres_output_file = "configure-postgres.sh"
    artifact_folder = "artifacts"
}



data "template_file" "template_configure_databases" {
  template = "${file("./${local.configure_postgres_template}")}"

  vars = {
    external_cc_database_name =                 "ccdb"
    external_bbs_database_name =                 "bbs"

  }
}


resource "local_file" "local_file_configure_databases" {
    content     = "${data.template_file.template_configure_databases.rendered}"
    filename = "${local.artifact_folder}/${local.configure_postgres_output_file}"
}



resource "null_resource" "export_rendered_configure_postgres_template" {

  # Force this resource to regenerate each time
  triggers = {
    run_every_time = "${uuid()}"
  }

  # No point in executing until the db is running 
  depends_on = [ "data.template_file.template_configure_databases" ]

  provisioner "local-exec"  {
      command = "${local.artifact_folder}/${local.configure_postgres_output_file} "
  }
}

output "postgres_configuration_artifact"   { value = "PostgreSQL file is in ${local.artifact_folder}/${local.configure_postgres_output_file}" }