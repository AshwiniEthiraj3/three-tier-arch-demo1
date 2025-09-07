FROM debian:stable-slim

# tools + mysql client
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl bash coreutils dos2unix mysql-client \
  && rm -rf /var/lib/apt/lists/*

# scripts + data
WORKDIR /root
COPY scripts/convert.sh      /root/convert.sh
COPY run.sh          /root/run.sh
COPY scripts/cities.csv      /root/cities.csv
COPY scripts/20-ratings.sql  /docker-entrypoint-initdb.d/20-ratings.sql

# fix CRLF and make exec
RUN dos2unix /root/*.sh && chmod +x /root/*.sh

# container just runs the one-time job
ENTRYPOINT ["/root/run.sh"]
