# Kubernetes Elasticsearch Cluster

## Creates a configurable Elasticsearch cluster in Kubernetes with linked storage
Terraform module for Azure to create a configurable Elasticsearch cluster in AKS. 

## Configuration
You can use the existing Kubernetes (Helm charts)[https://github.com/elastic/helm-charts] to configure the ELK Cluster configuration.

> This is still a work in progress as it needs Output and Variable Files added.

Installs following resources:
- azurerm_resource_group
- kubernetes_storage_class
- elasticsearch_client
- elasticsearch_master
- elasticsearch_data