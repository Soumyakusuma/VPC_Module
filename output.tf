output "vpc_id"{
    value = aws_vpc.roboshop.id
}

output "public_subnet_ids" {
 value=aws_subnet.public[*].id #everything
}

output "private_subnet_ids" {
 value=aws_subnet.private[*].id #everything
}

output "database_subnet_ids" {
 value=aws_subnet.database[*].id #everything
}