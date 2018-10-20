resource "aws_key_pair" "testDatabaseAsCode_key_pair" {
  key_name = "testDatabaseAsCode_key_pair"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}