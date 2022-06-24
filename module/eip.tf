# Create Elastic IP for transfer family server
resource "aws_eip" "eip" {
  count = length(var.availability-zones)
  vpc   = true
}
