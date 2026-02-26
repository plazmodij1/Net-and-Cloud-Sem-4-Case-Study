variable "dev" {
  default = "dev"
}

variable "profile" {
  default = "marko-student"  
}

#aurora service parameters
  #deletion_protection = false
  #skip_final_snapshot = true
  # 3. For Serverless v2, define your capacity limits
  #serverlessv2_scaling_configuration {
  #  max_capacity = 1.0
  #  min_capacity = 0.5 # Lowest possible setting to save money
  #