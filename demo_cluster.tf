provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_security_group" "demo_habitat_sg" {
  name        = "demo-habitat-sg-allow-all"
  description = "allow all inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9631
    to_port     = 9631
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9638
    to_port     = 9638
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9638
    to_port     = 9638
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "demo_cluster" {
  count         = 3
  ami           = "ami-ba602bc2"
  instance_type = "t2.micro"
  key_name      = "${var.key_name}"

  security_groups = [
    "${aws_security_group.demo_habitat_sg.name}",
  ]

  provisioner "remote-exec" {
    inline = [
      "curl https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | sudo bash",
      "sudo groupadd hab",
      "sudo useradd -g hab hab",
    ]

    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("${var.key_path}")}"
    }
  }

  tags {
    Name = "Nell-demo-cluster"
  }
}

output "cluster_ips" {
  value = "${aws_instance.demo_cluster.*.public_ip}"
}
