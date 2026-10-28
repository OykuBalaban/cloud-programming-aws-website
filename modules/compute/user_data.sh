#!/bin/bash
set -ux

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)

mkdir -p /var/www/html
cat > /var/www/html/index.html <<HTML
<!doctype html>
<html>
<head><title>Hello World</title></head>
<body style="font-family: Arial; text-align: center; margin-top: 100px;">
  <h1>Hello World</h1>
  <p>instance: $INSTANCE_ID</p>
  <p>zone: $AZ</p>
</body>
</html>
HTML

# nginx comes from the AL2023 repos via the S3 endpoint, python is the fallback if that fails
if dnf install -y nginx; then
  cp /var/www/html/index.html /usr/share/nginx/html/index.html
  systemctl enable --now nginx
else
  cat > /etc/systemd/system/hello-web.service <<UNIT
[Unit]
Description=fallback web server
After=network.target

[Service]
WorkingDirectory=/var/www/html
ExecStart=/usr/bin/python3 -m http.server 80
Restart=always

[Install]
WantedBy=multi-user.target
UNIT
  systemctl daemon-reload
  systemctl enable --now hello-web
fi
