resource "aws_vpc" "roboshop" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
   enable_dns_hostnames = "true"

  tags = merge(
    var.tags,
    local.common_tags,{
        Name="${var.project}-${var.environment}"
    }
  )
}

resource "aws_internet_gateway" "roboshop_gw" {
  vpc_id = aws_vpc.roboshop.id

  tags = merge(
    var.tags,
    local.common_tags,{
        Name="${var.project}-${var.environment}"
    }
  )
}

resource "aws_subnet" "private" {
  count=length(var.private_cidr)
  vpc_id     = aws_vpc.roboshop.id
  cidr_block = var.private_cidr[count.index]

  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.private_subnet_tags,
    local.common_tags,{
        Name="${var.project}-${var.environment}-private-${local.az_names[count.index]}"
    }
  )
}

resource "aws_subnet" "public" {
  count=length(var.pub_cidr)
  vpc_id     = aws_vpc.roboshop.id
  cidr_block = var.pub_cidr[count.index]

  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.public_subnet_tags,
    local.common_tags,{
        Name="${var.project}-${var.environment}-public-${local.az_names[count.index]}"
    }
  )
}

resource "aws_subnet" "database" {
  count=length(var.database_cidr)
  vpc_id     = aws_vpc.roboshop.id
  cidr_block = var.database_cidr[count.index]

  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.database_subnet_tags,
    local.common_tags,{
        Name="${var.project}-${var.environment}-database-${local.az_names[count.index]}"
    }
  )
}

resource "aws_route_table" "public_table" {
  vpc_id = aws_vpc.roboshop.id

  tags = merge(
    var.private_route_table_tags,
    local.common_tags,{
        Name="${var.project}-${var.environment}-public"
    }
  )

}

resource "aws_route_table" "private_table" {
  vpc_id = aws_vpc.roboshop.id

  tags = merge(
    var.private_route_table_tags,
    local.common_tags,{
        Name="${var.project}-${var.environment}-private"
    }
  )

}

resource "aws_route_table" "database_table" {
  vpc_id = aws_vpc.roboshop.id

  tags = merge(
    var.database_route_table_tags,
    local.common_tags,{
        Name="${var.project}-${var.environment}-database"
    }
  )

}



 resource "aws_route" "public_route" {
     route_table_id         = aws_route_table.public_table.id
     destination_cidr_block = "0.0.0.0/0"# Example: Route all traffic
     gateway_id             = aws_internet_gateway.roboshop_gw.id # Example: Through an internet gateway
   }

 resource "aws_route" "private_route" {
     route_table_id         = aws_route_table.private_table.id
     destination_cidr_block = "0.0.0.0/0"  # Example: Route all traffic
     nat_gateway_id =  aws_nat_gateway.roboshop_nat.id# Example: Through an internet gateway
   }

 resource "aws_route" "database_route" {
     route_table_id         = aws_route_table.database_table.id
     destination_cidr_block = "0.0.0.0/0"# Example: Route all traffic
     gateway_id             = aws_nat_gateway.roboshop_nat.id # Example: Through an internet gateway
   }

  resource "aws_eip" "roboshop_eip" {
  domain   = "vpc"
  tags = merge(
    var.eip_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}"
    }
  )
}

resource "aws_nat_gateway" "roboshop_nat" {
  allocation_id = aws_eip.roboshop_eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.nat_gateway_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}"
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.roboshop_gw]
}

resource "aws_route_table_association" "public" {
  count= length(var.pub_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_table.id
}

resource "aws_route_table_association" "private" {
  count= length(var.private_cidr)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_table.id
}

resource "aws_route_table_association" "database" {
  count= length(var.database_cidr)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database_table.id
}
