#!/bin/bash

# Use the provided BASE_DIR argument or default to the current directory
BASE_DIR="${1:-$(pwd)}"

# Log the base directory being used
echo "Using BASE_DIR: $BASE_DIR"

# Prompt to confirm if you'd like to proceed
read -p "Continue with the provided BASE_DIR? (y/n): " confirm
if [ "$confirm" != "y" ]; then
  echo "Script aborted."
  exit 1
fi

echo "Setting up the directories"

# Create top-level directories for Redis and Sentinel
for port in {7001..7005}; do
  instance_dir="$BASE_DIR/redis_$port"
  mkdir -p "$instance_dir"

  # Log the current Redis instance being processed
  echo "Configuring Redis instance: $port"

  # Create Redis configuration file
  cat > "$instance_dir/redis.conf" <<EOL
port $port
bind 0.0.0.0
protected-mode no
logfile "redis_$port.log"
EOL

  # Create Sentinel configuration file
  sentinel_port=$((port + 20000))

  # Log the Sentinel configuration
  echo "Configuring Sentinel for Redis instance: $port, Sentinel port: $sentinel_port"

  cat > "$instance_dir/sentinel.conf" <<EOL
port $sentinel_port
sentinel monitor mymaster 127.0.0.1 $port 3
sentinel down-after-milliseconds mymaster 5000
sentinel parallel-syncs mymaster 1
logfile "sentinel_$port.log"
EOL

  # Generate Docker Compose entry for this Redis-Sentinel instance
  cat >> "$BASE_DIR/docker-compose.yml" <<EOL
    redis-$port:
      container_name: redis-$port
      image: redis:latest
      command: ["redis-server", "--bind", "redis", "--port", "6379"]
    networks:
      mynetwork:
        driver: bridge
EOL

  # Log that the Redis instance and Sentinel configuration are created
  echo "Redis instance $port and Sentinel configuration created."

done

# Append the Docker Compose footer
cat >> "$BASE_DIR/docker-compose.yml" <<EOL
version: '3'
services:
EOL

# Log completion of the Docker Compose file creation
echo "Docker Compose file created in $BASE_DIR"
