resource "aws_instance" "testDatabaseAsCode_oracle" {
  count = 1
  ami = "ami-759bc50a"
  instance_type = "c5d.9xlarge"
  key_name = "${aws_key_pair.testDatabaseAsCode_key_pair.key_name}"
  security_groups = ["${aws_security_group.testDatabaseAsCode_oracle.name}"]
  root_block_device {
    volume_size = 64
  }
  provisioner "file" {
    connection {
      type = "ssh",
      user = "ubuntu",
      private_key = "${file("~/.ssh/id_rsa")}"
    }
    source      = "../target/testDatabaseAsCode-1.0.jar"
    destination = "/home/ubuntu/testDatabaseAsCode-1.0.jar"
  }
  provisioner "file" {
    connection {
      type = "ssh",
      user = "ubuntu",
      private_key = "${file("~/.ssh/id_rsa")}"
    }
    source      = "../liquibase.properties"
    destination = "/home/ubuntu/liquibase.properties"
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh",
      user = "ubuntu",
      private_key = "${file("~/.ssh/id_rsa")}"
    }
    inline = "mkdir /home/ubuntu/data"
  }
  provisioner "file" {
    connection {
      type = "ssh",
      user = "ubuntu",
      private_key = "${file("~/.ssh/id_rsa")}"
    }
    source      = "../data/"
    destination = "/home/ubuntu/data"
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh",
      user = "ubuntu",
      private_key = "${file("~/.ssh/id_rsa")}"
    }
    script = "terraformProvisionOracleUsingDocker.sh"
  }
  tags {
    Name = "testDatabaseAsCode Oracle ${format("%03d", count.index)}"
  }
}