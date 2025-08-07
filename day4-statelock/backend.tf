terraform {
backend "s3" {
bucket = "nagarajunareshit"
key = "day4/terraform.tfstate"
region = "us-east-1"
 #use_lockfile = true #s3 supports this feature but teraaform version > 1.10, latest version >=1.10
}
}