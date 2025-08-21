module "dev" {
    source = "github.com/Nagaraju1234-art/terraform-9am-practise/day7-module-source"
   ami-id = "ami-08a6efd148b1f7504"
  instance_type = "t2.micro"
}