resource "aws_db_subnet_group" "postgresql" {
  name_prefix = "${var.name}-db-subnet-group-"
  subnet_ids  = ["${split(",", lookup(var.db, "subnets"))}"]

  tags = "${merge(var.default_tags, map( "Name", "${var.name}-db-subnet-group"))}"
}

resource "aws_db_instance" "postgresql" {
  engine                 = "postgres"
  identifier             = "${var.name}"
  name                   = "${lookup(var.db, "name")}"
  allocated_storage      = "${lookup(var.db, "allocated_storage")}"
  engine_version         = "${lookup(var.db, "engine_version")}"
  instance_class         = "${lookup(var.db, "instance_class")}"
  password               = "${lookup(var.db, "password")}"
  username               = "${lookup(var.db, "username")}"
  multi_az               = "${lookup(var.db, "multi_az")}"
  port                   = "${lookup(var.db, "port")}"
  vpc_security_group_ids = ["${aws_security_group.postgresql.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.postgresql.id}"
  skip_final_snapshot    = true

  tags = "${merge(var.default_tags, map( "Name", "${var.name}-pgsql"))}"
}

resource "aws_security_group" "postgresql" {
  name_prefix = "${var.name}-db-sg-"
  description = "Allow http(s) access from var.allowed_networks."
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = "${lookup(var.db, "port")}"
    to_port         = "${lookup(var.db, "port")}"
    protocol        = "tcp"
    security_groups = ["${lookup(var.db, "source_security_groups")}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(var.default_tags, map( "Name", "${var.name}-pgsql-sg"))}"
}
