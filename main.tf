provider "oci" {
  tenancy_ocid     = local.tenancy
  user_ocid        = local.user
  fingerprint      = local.fingerprint
  private_key_path = pathexpand(local.key_file)
  region           = local.region
}

data "oci_identity_compartments" "all_compartments" {
  compartment_id = local.tenancy
  access_level   = "ACCESSIBLE"
  compartment_id_in_subtree = true
}

# Obtener todos los Load Balancers en cada compartment
data "oci_load_balancer_load_balancers" "all_lbs" {
  for_each       = local.all_compartments_map
  compartment_id = each.key
}

# Obtener los backend sets de cada Load Balancer
data "oci_load_balancer_backend_sets" "lb_backend_sets" {
  for_each = local.load_balancers_map
  load_balancer_id = each.key
}

# Obtener los certificados SSL de cada Load Balancer
data "oci_load_balancer_certificates" "lb_certificates" {
  for_each = local.load_balancers_map
  load_balancer_id = each.key
}