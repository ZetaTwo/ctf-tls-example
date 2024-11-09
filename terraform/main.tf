terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "6.10.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.0.0-alpha1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
  }

}

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "ID of the Cloudflare zone"
  type        = string
}

provider "google-beta" {
  project = "ctf-tls-test"
  region  = "europe-north1"
  zone    = "europe-north1-a"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "google_service_account" "challenges" {
  provider     = google-beta
  account_id   = "challenge"
  display_name = "Service account for challenges"
}

resource "google_compute_instance" "challenges" {
  provider     = google-beta
  name         = "challenges"
  machine_type = "n2-standard-2"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = google_compute_network.ctftest.name

    access_config {
      // Ephemeral public IP
    }
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.challenges.email
    scopes = ["cloud-platform"]
  }
}

resource "google_dns_managed_zone" "ctftest1" {
  provider    = google-beta
  name        = "ctftest1"
  dns_name    = "ctftest1.zetatwo.dev."
  description = "DNS Zone for CTF TLS test"
}

resource "google_dns_record_set" "challenges" {
  provider = google-beta
  name     = "${google_dns_managed_zone.ctftest1.dns_name}"
  type     = "A"
  ttl      = 300

  managed_zone = google_dns_managed_zone.ctftest1.name

  rrdatas = [google_compute_instance.challenges.network_interface[0].access_config[0].nat_ip]
}

resource "google_dns_record_set" "chall1" {
  provider = google-beta
  name     = "chall1.${google_dns_record_set.challenges.name}"
  type     = "A"
  ttl      = 300

  managed_zone = google_dns_managed_zone.ctftest1.name

  rrdatas = [google_compute_instance.challenges.network_interface[0].access_config[0].nat_ip]
}

resource "google_dns_record_set" "chall2" {
  provider = google-beta
  name     = "chall2.${google_dns_record_set.challenges.name}"
  type     = "A"
  ttl      = 300

  managed_zone = google_dns_managed_zone.ctftest1.name

  rrdatas = [google_compute_instance.challenges.network_interface[0].access_config[0].nat_ip]
}

resource "cloudflare_dns_record" "ctftest1-ns" {
  for_each = toset(google_dns_managed_zone.ctftest1.name_servers)
  zone_id = var.cloudflare_zone_id
  name    = google_dns_managed_zone.ctftest1.name
  content = each.value
  type    = "NS"
  ttl     = 1
}

locals {
  hosts = [
    {
      "hostname": google_compute_instance.challenges.name,
      "domains": [
        google_dns_record_set.chall1.name,
        google_dns_record_set.chall2.name
      ]
    }
  ]
}

resource "local_file" "ansible_inventory" {
  filename = "inventory.yml"
  content = yamlencode({
    "hosts" : { "hosts" : { for host in local.hosts : "${host.hostname}" => {"ansible_host": host.hostname, "domains": host.domains} } }
  })
  file_permission = "644"
}

resource "google_compute_network" "ctftest" {
  provider     = google-beta
  name = "ctftest"
}

resource "google_compute_firewall" "firewall_iap_ssh" {
  name     = "allow-iap-ssh"
  provider = google-beta
  network  = google_compute_network.ctftest.name
  
  source_ranges = ["35.235.240.0/20"] # IAP IP range

  allow {
    protocol = "tcp"
    ports    = ["22"] # SSH
  }
}

resource "google_compute_firewall" "firewall_http_https" {
  name     = "allow-http-https"
  provider = google-beta
  network  = google_compute_network.ctftest.name
  
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"] # HTTP, HTTPS
  }
}
