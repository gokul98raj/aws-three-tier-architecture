provider "aws" {
  region = "eu-central-1"
}






output "vpc_id" {
  value = aws_vpc.main_vpc.id
}
