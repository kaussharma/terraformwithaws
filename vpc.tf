#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "clarkdemo" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
     "Name", "clark-eks-demo-node",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "clarkdemo" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.clarkdemo.id}"

  tags = "${
    map(
     "Name", "clark-eks-demo-node",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "clarkdemo" {
  vpc_id = "${aws_vpc.clarkdemo.id}"

  tags {
    Name = "clark-eks-demo"
  }
}

resource "aws_route_table" "clarkdemo" {
  vpc_id = "${aws_vpc.clarkdemo.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.clarkdemo.id}"
  }
}

resource "aws_route_table_association" "clarkdemo" {
  count = 2

  subnet_id      = "${aws_subnet.clarkdemo.*.id[count.index]}"
  route_table_id = "${aws_route_table.clarkdemo.id}"
}
