output "load_balancer_inventory" {
  description = "Inventario básico de Load Balancers"
  value = length(data.oci_load_balancer_load_balancers.all_lbs.load_balancers) > 0 ? {
    for lb in data.oci_load_balancer_load_balancers.all_lbs.load_balancers :
    lb.display_name => {
      id               = lb.id
      ip_addresses     = lb.ip_address_details
      is_private       = lb.is_private
      shape            = lb.shape_details
      lifecycle_state  = lb.state
      subnet_ids       = lb.subnet_ids
      backend_sets     = try(keys(data.oci_load_balancer_backend_sets.lb_backend_sets[lb.id].backend_sets), [])
      certificates     = try(length(data.oci_load_balancer_certificates.lb_certificates[lb.id].certificates), 0) > 0 ? "SSL_CONFIGURED" : "NO_SSL"
    }
  } : {}
}

output "load_balancer_summary" {
  description = "Resumen de Load Balancers"
  value = {
    total_load_balancers = length(data.oci_load_balancer_load_balancers.all_lbs.load_balancers)
    public_load_balancers = length([
      for lb in data.oci_load_balancer_load_balancers.all_lbs.load_balancers :
      lb if !lb.is_private
    ])
    private_load_balancers = length([
      for lb in data.oci_load_balancer_load_balancers.all_lbs.load_balancers :
      lb if lb.is_private
    ])
    total_backend_sets = length(data.oci_load_balancer_load_balancers.all_lbs.load_balancers) > 0 ? sum([
      for lb_id, bs in data.oci_load_balancer_backend_sets.lb_backend_sets :
      length(bs.backend_sets)
    ]) : 0
    ssl_configured = length(data.oci_load_balancer_load_balancers.all_lbs.load_balancers) > 0 ? length([
      for lb in data.oci_load_balancer_load_balancers.all_lbs.load_balancers :
      lb if try(length(data.oci_load_balancer_certificates.lb_certificates[lb.id].certificates), 0) > 0
    ]) : 0
  }
}

output "has_load_balancers" {
  description = "Indica si existen Load Balancers en el compartment"
  value = length(data.oci_load_balancer_load_balancers.all_lbs.load_balancers) > 0
}