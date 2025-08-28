  user_data = <<-EOF
              #!/bin/bash
              sudo yum install -y httpd
              sudo systemctl enable httpd
              sudo systemctl start httpd
              echo "<h1>Hello from EC2 behind ALB</h1>" > /var/www/html/index.html
              EOF
