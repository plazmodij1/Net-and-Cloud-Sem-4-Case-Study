variable "env" {
    type = string
}

variable "region" {
    type = string
}

variable "email" {
    type = string
}

variable "alb_arn" {
    type = string
}

variable "rate_limit" {
    type = number
    default = 100
}