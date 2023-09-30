provider "aws_vpc" test {}

resource "aws_vpc" "test" {
    cidr_block = "10.0.0.0/16"
  
  tags= {
    Name = Action-tes
  }
}