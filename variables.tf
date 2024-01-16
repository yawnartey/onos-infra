#andlanc-dev vpc cidr block definition
variable "onos-cidr" {
  description = "onos vpc cidr block"
  type        = string
  default     = "10.2.0.0/16" 
}

#andlanc-dev subnet cidr block definition
variable "onos-subnet-cidr" {
  description = "onos subnet cidr block"
  type        = string
  default     = "10.2.0.0/16" 
}