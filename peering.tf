resource "aws_vpc_peering_connection" "roboshop_peer" {
  count = var.is_peering_required ? 1 : 0
  peer_vpc_id   = data.aws_vpc.default.id
  vpc_id        = aws_vpc.roboshop.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

   auto_accept = true

  tags = merge(
    var.vpc_peering_tags,
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-default"
    }
  )

  
}

resource "aws_route" "public_peer" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.public_table.id
  destination_cidr_block    =  data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.roboshop_peer[count.index].id
}

resource "aws_route" "private_peer" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.private_table.id
  destination_cidr_block    =  data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.roboshop_peer[count.index].id
}

resource "aws_route" "database_peer" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.database_table.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.roboshop_peer[count.index].id

}

resource "aws_route" "default_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = data.aws_route_table.main.id
  destination_cidr_block    = var.cidr_block
  vpc_peering_connection_id  = aws_vpc_peering_connection.roboshop_peer[count.index].id
}
