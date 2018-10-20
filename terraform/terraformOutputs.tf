output "oracle_dns" {
  value = ["${aws_instance.testDatabaseAsCode_oracle.*.public_dns}"]
}

output "oracle_ip" {
  value = ["${aws_instance.testDatabaseAsCode_oracle.*.public_ip}"]
}