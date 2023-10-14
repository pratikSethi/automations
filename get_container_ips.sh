# List of container names or IDs
redis_container_list=("redis-7001" "redis-7002" "redis-7003" "redis-7004" "redis-7005")
sentinel_container_list=("sentinel-27001" "sentinel-27002" "sentinel-27003" "sentinel-27004" "sentinel-27005")

# Loop through the containers and get their IP addresses
for container_name_or_id in "${redis_container_list[@]}"; do
  container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container_name_or_id")
  echo "IP address of $container_name_or_id: $container_ip"
done


# Loop through the containers and get their IP addresses
for container_name_or_id in "${sentinel_container_list[@]}"; do
  container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container_name_or_id")
  echo "IP address of $container_name_or_id: $container_ip"
done
