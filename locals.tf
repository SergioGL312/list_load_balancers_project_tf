locals {
  config_content = data.local_file.oci_config.content
  profile_name   = var.tenant_name != "" ? var.tenant_name : "DEFAULT"

  profile_regex  = "(?s)\\[${local.profile_name}\\](.*?)(\\[|$)"
  profile_match  = try(regex(local.profile_regex, local.config_content), [])
  profile_block  = try(trimspace(local.profile_match[0]), "")

  user_regex         = "user\\s*=\\s*(ocid1\\.user\\.[^\\s\\n]+)"
  fingerprint_regex  = "fingerprint\\s*=\\s*([^\\s\\n]+)"
  key_file_regex     = "key_file\\s*=\\s*([^\\s\\n]+)"
  tenancy_regex      = "tenancy\\s*=\\s*(ocid1\\.tenancy\\.[^\\s\\n]+)"
  region_regex       = "region\\s*=\\s*([^\\s\\n]+)"

  user        = try(regex(local.user_regex, local.profile_block)[0], "NOT_FOUND")
  fingerprint = try(regex(local.fingerprint_regex, local.profile_block)[0], "NOT_FOUND")
  key_file    = try(regex(local.key_file_regex, local.profile_block)[0], "NOT_FOUND")
  tenancy     = try(regex(local.tenancy_regex, local.profile_block)[0], "NOT_FOUND")
  region      = try(regex(local.region_regex, local.profile_block)[0], "NOT_FOUND")

  target_compartment_id = var.compartment_id != "" ? var.compartment_id : local.tenancy

  all_compartments_map = {
    for comp in data.oci_identity_compartments.all_compartments.compartments :
    comp.id => comp.name
  }
  
  # Agregado: recolecta todos los load balancers en un mapa plano
  all_load_balancers = flatten([
    for compartment_id, compartment_lbs in data.oci_load_balancer_load_balancers.all_lbs : 
    compartment_lbs.load_balancers
  ])
  
  # Crear un mapa con ID del LB como clave
  load_balancers_map = {
    for lb in local.all_load_balancers :
    lb.id => lb
  }
}