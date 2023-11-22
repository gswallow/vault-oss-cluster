variable "root_cert_common_name" {
  type    = string
  default = "gregonaws.net"
}

variable "allowed_domains" {
  type    = list(string)
  default = ["gregonaws.net"]
}

variable "cert_common_name" {
  type    = string
  default = "breakglass.gregonaws.net"
}
