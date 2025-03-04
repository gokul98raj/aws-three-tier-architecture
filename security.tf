resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    rule_no    = 110
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = { Name = "public_nacl" }
}

resource "aws_network_acl_association" "public_nacl_association" {
  subnet_id      = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  network_acl_id = aws_network_acl.public_nacl.id

}

resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "10.0.3.0/24"
    from_port  = 3306
    to_port    = 3306
  }

  ingress {
    rule_no    = 110
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "10.0.5.0/24"
    from_port  = 5432
    to_port    = 5432
  }

  tags = { Name = "private_nacl" }
}

resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_security_group.db_sg.id]
  }

  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_security_group.app_sg.id]
  }
  tags = { Name = "web_sg" }
}

resource "aws_network_acl_association" "private_nacl_association" {
  subnet_id      = [aws_subnet.web_subnet_1.id, aws_subnet.web_subnet_2.id, aws_subnet.app_subnet_1.id, aws_subnet.app_subnet_2.id, aws_subnet.db_subnet_1.id, aws_subnet.db_subnet_2.id]
  network_acl_id = aws_network_acl.private_nacl.id

}

resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.main_vpc.id
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }
  egress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.db_sg.id]
  }
}

resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main_vpc.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }
}