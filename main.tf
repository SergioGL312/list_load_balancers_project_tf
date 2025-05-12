provider "oci" {
  tenancy_ocid     = local.tenancy
  user_ocid        = local.user
  fingerprint      = local.fingerprint
  private_key_path = local.key_file
  region           = local.region
}

# Obtener todos los Load Balancers en el compartment
data "oci_load_balancer_load_balancers" "all_lbs" {
  compartment_id = local.target_compartment_id
}

# Obtener los backend sets de cada Load Balancer
data "oci_load_balancer_backend_sets" "lb_backend_sets" {
  for_each = {
    for lb in data.oci_load_balancer_load_balancers.all_lbs.load_balancers :
    lb.id => lb.display_name
  }
  load_balancer_id = each.key
}

# Obtener los certificados SSL de cada Load Balancer
data "oci_load_balancer_certificates" "lb_certificates" {
  for_each = {
    for lb in data.oci_load_balancer_load_balancers.all_lbs.load_balancers :
    lb.id => lb.display_name
  }
  load_balancer_id = each.key
}