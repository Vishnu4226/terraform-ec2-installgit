locals {
  settings = yamldecode(file("values.yaml"))
}
module "data_ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"
  name = local.settings.data.name
  ami                    = local.settings.data.imageid
  instance_type          = local.settings.data.instancetype
  key_name               = local.settings.data.keypair
  monitoring             = true
  user_data = <<EOF
<powershell>
Start-Process -Wait -FilePath "terraform-ec2-installgit\Git-2.33.1-64-bit.exe" -Argument "/silent" -PassThru
Restart-Computer
</powershell>
EOF
  vpc_security_group_ids = [local.settings.data.securitygroupid, aws_security_group.datainstancesg.id]
  root_block_device = [{
           delete_on_termination = "true"
		   device_name           = "/dev/sda1"
           encrypted             = "true"
           volume_size           = "100"
  }]
  ebs_block_device = [{
           delete_on_termination = "true"
		   device_name           = "/dev/xvdf"
           encrypted             = "true"
           volume_size           = "100"
  }]
  subnet_id              = local.settings.data.subnetid
  tags = {
    Description               = "Database Instance for EAMI Rx with EFT Prenote Middle 3 Tier TARB 275 RFC 32",
	"DHCS:SupportContact"       = "genady.gidenko@dhcs.ca.gov",
	"DHCS:ManagedBy"            = "genady.gidenko@dhcs.ca.gov",
	"DHCS:ProgramContact"       = "genady.gidenko@dhcs.ca.gov",
	"DHCS:Environment"          = "Capman Dev 3285",
	"DHCS:ApplicationName"      = "EAMI Rx with EFT Prenote Middle 3 Tier TARB 275 RFC 32",
	"DHCS:BackupPolicy"         = "Group C",
	"DHCS:DataClassification"   = "PHI,PII",
	"DHCS:SupportGroup"         = "genady.gidenko@dhcs.ca.gov",
	"Dhcs:Fips199Categorization" = "High",
	"DHCS:Description"          = "Database Instance for EAMI Rx with EFT Prenote Middle 3 Tier TARB 275 RFC 32"
  }
}

resource "aws_security_group" "datainstancesg" {
  name                   = "securityGroupdatainstance22"
  description            = "datansg"
  vpc_id                 = "vpc-71777f09"


  ingress {
    from_port            = "1433"
    to_port              = "1433"
    protocol             = "tcp"
    cidr_blocks          = ["10.0.0.0/8"]
  }
  ingress {
    from_port            = "3389"
    to_port              = "3389"
    protocol             = "tcp"
    cidr_blocks          = ["10.0.0.0/8"]
  }
  ingress {
    from_port            = "1433"
    to_port              = "1433"
    protocol             = "tcp"
    cidr_blocks          = ["10.0.0.0/8"]
  }
}
