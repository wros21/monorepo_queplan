# Red VPC principal
resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460

  depends_on = [google_project_service.apis]
}

# Subred privada para AlloyDB
resource "google_compute_subnetwork" "private_subnet" {
  name          = "${var.project_id}-private-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id

  # Habilitar acceso privado a Google APIs
  private_ip_google_access = true
}

# Subred para Cloud Run VPC Connector
resource "google_compute_subnetwork" "connector_subnet" {
  name          = "${var.project_id}-connector-subnet"
  ip_cidr_range = "10.1.0.0/28"
  region        = var.region
  network       = google_compute_network.vpc.id
}

# Reserva de IP para peering con Google Services
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "${var.project_id}-private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id

  depends_on = [google_project_service.apis]
}

# Conexión de peering con Google Services
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]

  depends_on = [google_project_service.apis]
}

# VPC Connector para Cloud Run
resource "google_vpc_access_connector" "connector" {
  name          = "${var.project_id}-vpc-connector"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.1.0.0/28"

  depends_on = [
    google_project_service.apis,
    google_compute_subnetwork.connector_subnet
  ]
}

# Reglas de firewall
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.project_id}-allow-internal"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.project_id}-allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}
