# load the init template
data "template_file" "app_init" {
   template = "${file("./scripts/app/init.sh.tpl")}"
   vars = {
      db_host="mongodb://${module.db.db_instance}:27017/posts"
   }
}

module "app" {
 source = "./modules/app_tier"
 name = "${var.name}"
 app_ami_id = "${var.app_ami_id}"
 cidr_block = "${var.cidr_block}"
 vpc_id = "${aws_vpc.vpc.id}"
 igw = "${aws_internet_gateway.vpc-igw.id}"
 user_data = "${data.template_file.app_init.rendered}"
}

module "db" {
source = "./modules/db_tier"
name = "${var.name}"
db_ami_id = "${var.db_ami_id}"
cidr_block = "${var.cidr_block}"
vpc_id = "${aws_vpc.vpc.id}"
igw = "${aws_internet_gateway.vpc-igw.id}"
security_group_id = "${module.app.security_group_id}"
subnet_cidr_block = "${module.app.subnet_cidr_block}"
}

provider "aws" {
  region  = "eu-west-1"
}

# create a vpc
resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr_block}"

  tags = {
    Name = "${var.name}"
  }
}

# internet gateway
resource "aws_internet_gateway" "vpc-igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "${var.name}"
  }
}
