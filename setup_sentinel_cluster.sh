#!/bin/bash

# Sample usage
# ./setup-sentinel-cluster.sh /Users/pratik.sethi/Documents/Stash/e360/playground/sentinel-setup
# Will setup a cluster where we have 5 redis containers (redis-700[1...5]) and 5 sentinel containers (sentinel-700[1...5])
# Each redis container can be accessed locally at port 700[1...5] and sentinel at 2700[1...5]

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
bind 0.0.0.0
protected-mode no
EOL

  # Add replicaof line for ports other than 7001
  if [ "$port" != "7001" ]; then
    echo "replicaof 172.17.0.3 6379" >> "$instance_dir/redis.conf"
  fi

  # Create Sentinel configuration file
  sentinel_port=$((port + 20000)) # Add 20000

  # Log the Sentinel configuration
  echo "Configuring Sentinel for Redis instance: $port, Sentinel port: $sentinel_port"

  cat > "$instance_dir/sentinel.conf" <<EOL
sentinel monitor mymaster 172.17.0.3 6379 3
sentinel down-after-milliseconds mymaster 5000
sentinel parallel-syncs mymaster 1
EOL

  # Log that the Redis instance and Sentinel configuration are created
  echo "Redis instance $port and Sentinel configuration created."

  # Start Redis container based on the generated configuration
  echo "Starting Redis container for port $port"
  docker run -d --name redis-$port -v $instance_dir/redis.conf:/usr/local/etc/redis/redis.conf -p $port:6379 redis:latest redis-server /usr/local/etc/redis/redis.conf

  # Start Sentinel container based on the generated configuration
  echo "Starting Sentinel container for sentinel_port $sentinel_port"
  docker run -d --name sentinel-$sentinel_port -v $instance_dir/sentinel.conf:/usr/local/etc/redis/sentinel.conf -p $sentinel_port:26379 redis:latest redis-sentinel /usr/local/etc/redis/sentinel.conf --sentinel
done

# Log completion of the container creation
echo "Redis and Sentinel containers created."
