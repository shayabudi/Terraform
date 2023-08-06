terraform
{
    required_providers
{
    aws = {
    source = "hashicorp/aws"
version = "4.16"
}
}

required_version = ">= 1.0.0"
}



provider
"aws"
{
    region = "eu-west-1"
}

resource
"aws_instance" "web"
{
    ami = "ami-00aab5dfc482cf66d"
instance_type = var.env == "prod" ? "t2.micro": "t2.nano"
vpc_security_group_ids = [aws_security_group.sg_web.id]
depends_on = [
    aws_s3_bucket.data_bucket
]
tags = {
    Name = "${var.resource_alias}-${var.env}"

}
}

resource
"aws_security_group" "sg_web"
{
    name = "${var.resource_alias}-${var.env}-sg"

ingress
{
    from_port = "8080"
to_port = "8080"
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

tags = {
    Env = var.env
Terraform = true
}
}
resource
"aws_s3_bucket" "data_bucket"
{
    bucket = "${var.resource_alias}-${var.env}-bucket"

tags = {
    Name = "${var.resource_alias}-bucket"
Env = var.env
Terraform = true
}

}
module
"app_vpc"
{
    source = "terraform-aws-modules/vpc/aws"
version = "3.14.0"

name = "${var.resource_alias}-vpc"
cidr = var.vpc_cidr

azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

enable_nat_gateway = false

tags = {
    Name = "${var.resource_alias}-vpc"
Env = var.env
Terraform = true
}
}