#+--------------------------------------------------------------------+
#|                              Network                               |
#+--------------------------------------------------------------------+

resource "aws_vpc" "voice_translator_VPC" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
      Name  = "voice_translator_VPC"
  }
}

resource "aws_eip" "voice_translator_EIP" {
  vpc = true
}

#+--------------------------------------------------------------------+
#|                              Subnets                               |
#+--------------------------------------------------------------------+

resource "aws_subnet" "voice_translator_public" {
  vpc_id                  = "${aws_vpc.voice_translator_VPC.id}"
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"

  tags = {
      Name  = "voice_translator_public_subnet"
  }  
}

resource "aws_subnet" "voice_translator_private" {
  vpc_id                  = "${aws_vpc.voice_translator_VPC.id}"
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "${var.region}b"

  tags = {
      Name  = "voice_translator_private_subnet"
  }  
}

#+--------------------------------------------------------------------+
#|                             Gateways                               |
#+--------------------------------------------------------------------+

resource "aws_internet_gateway" "voice_translator_IG" {
  vpc_id = "${aws_vpc.voice_translator_VPC.id}"

  tags = {
      Name  = "voice_translator_IG"
  }  
}

resource "aws_nat_gateway" "voice_translator_NGW" {
  allocation_id = "${aws_eip.voice_translator_EIP.id}"
  subnet_id     = "${aws_subnet.voice_translator_public.id}"

  tags = {
      Name  = "voice_translator_NGW"
  }  
}

#+--------------------------------------------------------------------+
#|                           Route Tables                             |
#+--------------------------------------------------------------------+

resource "aws_route_table" "voice_translator_public" {
  vpc_id = "${aws_vpc.voice_translator_VPC.id}"

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.voice_translator_IG.id}"
  }

  tags = {
      Name  = "voice_translator_public_RT"
  } 
}

resource "aws_route_table" "voice_translator_private" {
  vpc_id = "${aws_vpc.voice_translator_VPC.id}"

  route {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = "${aws_nat_gateway.voice_translator_NGW.id}"
  }

  tags = {
      Name  = "voice_translator_private_RT"
  } 
}

resource "aws_route_table_association" "voice_translator_public" {
    subnet_id      = "${aws_subnet.voice_translator_public.id}"
    route_table_id = "${aws_route_table.voice_translator_public.id}"
}

resource "aws_route_table_association" "voice_translator_private" {
    subnet_id      = "${aws_subnet.voice_translator_private.id}"
    route_table_id = "${aws_route_table.voice_translator_private.id}"
}

#+--------------------------------------------------------------------+
#|                           Security Group                           |
#+--------------------------------------------------------------------+

resource "aws_security_group" "voice_translator_SG" {
  name        = "VoiceTranslatorEc2SecurityGroup"
  description = "Voice Translator Security Group"
  vpc_id      = "${aws_vpc.voice_translator_VPC.id}"

  ingress {
    from_port  = 22
    to_port    = 22
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  ingress {
    from_port  = 8080
    to_port    = 8080
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port  = 80
    to_port    = 80
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port  = 443
    to_port    = 443
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port  = 80
    to_port    = 80
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port  = 443
    to_port    = 443
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
      Name  = "VoiceTranslatorEc2SecurityGroup"
  } 
}
