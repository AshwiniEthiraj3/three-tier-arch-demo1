# Small image with MySQL client only
FROM debian:bookworm-slim

# Install mysql client + basics
RUN apt-get update \
 && apt-get install -y --no-install-recommends mysql-client curl ca-certificates bash coreutils \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /loader

# Copy scripts and runner
COPY scripts/ ./scripts/
COPY run.sh ./run.sh

# Make shell scripts executable (ignore if none match)
RUN chmod +x ./run.sh && chmod -f +x ./scripts/*.sh || true

ENTRYPOINT ["./run.sh"]
