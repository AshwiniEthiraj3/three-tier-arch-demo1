FROM debian:bullseye-slim

# Install tools + mysql client
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl bash coreutils dos2unix default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Scripts + SQL
WORKDIR /root
COPY scripts/convert.sh /root/convert.sh
COPY scripts/cities.csv /root/cities.csv
COPY scripts/20-ratings.sql /docker-entrypoint-initdb.d/20-ratings.sql
COPY run.sh /root/run.sh

# Fix line endings
RUN dos2unix /root/*.sh

# Run script
ENTRYPOINT ["/usr/bin/env", "bash","/root/run.sh"]

