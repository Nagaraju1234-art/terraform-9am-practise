terraform {
backend "s3" {
bucket = "nagarajucivilit"
key = "day4/terraform.tfstate"
region = "us-east-1"
}
}