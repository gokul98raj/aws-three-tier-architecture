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

resource "aws_network_acl_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  network_acl_id = aws_network_acl.public_nacl.id

}

resource "aws_network_acl_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
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

# NACL Associations for Private Subnets
resource "aws_network_acl_association" "web_subnet_1_association" {
  subnet_id      = aws_subnet.web_subnet_1.id
  network_acl_id = aws_network_acl.private_nacl.id
}

resource "aws_network_acl_association" "web_subnet_2_association" {
  subnet_id      = aws_subnet.web_subnet_2.id
  network_acl_id = aws_network_acl.private_nacl.id
}

resource "aws_network_acl_association" "app_subnet_1_association" {
  subnet_id      = aws_subnet.app_subnet_1.id
  network_acl_id = aws_network_acl.private_nacl.id
}

resource "aws_network_acl_association" "app_subnet_2_association" {
  subnet_id      = aws_subnet.app_subnet_2.id
  network_acl_id = aws_network_acl.private_nacl.id
}

resource "aws_network_acl_association" "db_subnet_1_association" {
  subnet_id      = aws_subnet.db_subnet_1.id
  network_acl_id = aws_network_acl.private_nacl.id
}

resource "aws_network_acl_association" "db_subnet_2_association" {
  subnet_id      = aws_subnet.db_subnet_2.id
  network_acl_id = aws_network_acl.private_nacl.id
}

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  vpc_id      = aws_vpc.main_vpc.id
  
  tags = {
    Name = "web_sg"
  }
}

# App Security Group
resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  vpc_id      = aws_vpc.main_vpc.id
  
  tags = {
    Name = "app_sg"
  }
}

# DB Security Group
resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  vpc_id      = aws_vpc.main_vpc.id
  
  tags = {
    Name = "db_sg"
  }
}

# Separate Ingress and Egress Rules to Break Cycles

# Web SG Rules
resource "aws_security_group_rule" "web_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
}

resource "aws_security_group_rule" "web_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
}

resource "aws_security_group_rule" "web_egress_db" {
  type              = "egress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = aws_security_group.db_sg.id
  security_group_id = aws_security_group.web_sg.id
}

# App SG Rules
resource "aws_security_group_rule" "app_ingress_web" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = aws_security_group.web_sg.id
  security_group_id = aws_security_group.app_sg.id
}

resource "aws_security_group_rule" "app_egress_db" {
  type              = "egress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  source_security_group_id = aws_security_group.db_sg.id
  security_group_id = aws_security_group.app_sg.id
}

# DB SG Rules
resource "aws_security_group_rule" "db_ingress_app_mysql" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = aws_security_group.app_sg.id
  security_group_id = aws_security_group.db_sg.id
}

resource "aws_security_group_rule" "db_ingress_app_postgres" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  source_security_group_id = aws_security_group.app_sg.id
  security_group_id = aws_security_group.db_sg.id
}

/*resource "aws_security_group" "web_sg" {
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
}*/