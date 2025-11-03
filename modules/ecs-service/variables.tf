variable "name" { type = string }
variable "env" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "public_subnet_ids" { type = list(string) }
variable "cpu" {
  type    = number
  default = 512
}
variable "memory" {
  type    = number
  default = 1024
}
variable "container_port" {
  type    = number
  default = 8080
}
variable "desired_count" {
  type    = number
  default = 1
}
variable "image" {
  type    = string
  default = "public.ecr.aws/amazonlinux/amazonlinux:latest"
}
variable "tags" {
  type    = map(string)
  default = {}
}
