# Configuracion para que Cloud Run salga a VPC
resource "google_vpc_access_connector" "serverless_conn" {
  name          = "serverless-conn"
  region        = var.region
  network       = "default"
  ip_cidr_range = "10.8.1.0/28"
}
