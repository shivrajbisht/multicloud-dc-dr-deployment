# ==============================================================================
# AZURE REDIS / VALKEY MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "id" {
  description = "Resource ID of the Azure Cache for Redis"
  value       = azurerm_redis_cache.redis.id
}

output "hostname" {
  description = "SSL Hostname of the Redis cache"
  value       = azurerm_redis_cache.redis.hostname
}

output "ssl_port" {
  description = "Secure SSL TLS Port"
  value       = azurerm_redis_cache.redis.ssl_port
}
