variable "env" {
    type = string
}

variable "lambda_sg_id" {
    type = string
}

variable "db_username"{
    default = "MarkoAdminStudent"
}

variable "db_name" {
    default = "mydatabase"
}

variable "writer_instance" {
  default = "db.t3.medium"
}

variable "db_port" {
  default = "3306"
}

variable "subnet_group_name" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}