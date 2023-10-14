#!/bin/bash

# Sample Usage
# ./teardown-sentinel-cluster.sh 7001 5
# Will remove 5 containers named sentinel-700[1...5]

# Default values
initial_port=${1:-7001}
total_containers=${2:-5}

# Print the selected values
echo "Using initial port number: $initial_port"
echo "Number of containers to remove: $total_containers"

# Loop through and remove containers

echo "Removing $total_containers redis containers starting at $initial_port"
for ((port = initial_port; port < initial_port + total_containers; port++)); do
  container_name="redis-$port"

  # Check if the container exists before attempting to remove it
  if docker ps -a --format "{{.Names}}" | grep -q "^$container_name$"; then
    echo "Stopping and removing $container_name"
    docker stop "$container_name"
    docker rm "$container_name"
  else
    echo "$container_name does not exist."
  fi
done

sentinel_port=$((initial_port + 20000)) # Add 20000

echo "Removing $total_containers sentinel containers starting at $sentinel_port"

for ((port = sentinel_port; port < sentinel_port + total_containers; port++)); do
  container_name="sentinel-$port"
  # Check if the container exists before attempting to remove it
  if docker ps -a --format "{{.Names}}" | grep -q "^$container_name$"; then
    echo "Stopping and removing $container_name"
    docker stop "$container_name"
    docker rm "$container_name"
  else
    echo "$container_name does not exist."
  fi
done
