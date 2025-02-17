terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">=2.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.12.0"
    }
  }
}

# DigitalOcean Provider 설정
provider "digitalocean" {
  token = var.do_token
}

# DigitalOcean API Token - 환경 변수(export TF_VAR_do_token="API Token")로 설정
variable "do_token" {
  description = "DigitalOcean API Token"
  type        = string
}

# 미리 생성한 SSH 키 불러오기
data "digitalocean_ssh_key" "default" {
  name = "jubuntu-oci"
}

# 미리 생성한 싱가포르 VPC 불러오기
data "digitalocean_vpc" "default" {
  name   = "default-sgp1"
}

# Droplet 생성
resource "digitalocean_droplet" "easyshift" {
  name              = "easyshift-prod"
  region            = "sgp1"
  size              = "s-2vcpu-2gb-amd"
  image             = "ubuntu-24-04-x64"
  ssh_keys          = [data.digitalocean_ssh_key.default.id]
  vpc_uuid          = data.digitalocean_vpc.default.id
  monitoring        = true
  tags              = ["Goorm", "Terraform", "Java"]
}

# Droplet이 생성되고 30초 후에 Reserved IP 생성
resource "time_sleep" "wait_for_droplet" {
  depends_on     = [digitalocean_droplet.easyshift]
  create_duration = "14s"
}

# Reserved IP 생성
resource "digitalocean_reserved_ip" "reserved" {
  droplet_id = digitalocean_droplet.easyshift.id
  region = "sgp1"
  depends_on = [time_sleep.wait_for_droplet]
}

# Script에서 사용할 output 출력
output "droplet_ip" {
  value = digitalocean_droplet.easyshift.ipv4_address
}

output "reserved_ip" {
  value = digitalocean_reserved_ip.reserved.ip_address
}
