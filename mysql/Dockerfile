FROM mysql:8.0

# Install curl (optional if not available)
RUN apt-get update && apt-get install -y curl

# Copy your custom scripts (optional: or fetch from S3 during container run)
COPY scripts/convert.sh /root/convert.sh
COPY scripts/config.sh /root/config.sh

RUN chmod +x /root/convert.sh /root/config.sh


