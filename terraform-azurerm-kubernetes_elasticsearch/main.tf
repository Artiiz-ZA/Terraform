# Locals
locals {
  cluster_name        = "elasticsearch-cluster"
  es_version          = "6.2.3"
  resource_group_name = "elastic-rg"
  location            = "southafricanorth"
  aks_name            = "example-aks1"
  aks_dns_prefix      = "exampleaks1"
  aks_node_pool_name  = "default"
}

# Provider
provider "azurerm" {
  version = "=2.7.0"
  features {}
}

# Creating a resource group
resource "azurerm_resource_group" "elastic_rg" {
  name     = local.resource_group_name
  location = local.location
}

# AKS
resource "azurerm_kubernetes_cluster" "elastic_aks_cluster" {
  name                = local.aks_name
  location            = local.location
  resource_group_name = local.resource_group_name
  dns_prefix          = local.aks_dns_prefix

  default_node_pool {
    name       = local.aks_node_pool_name
    node_count = 3
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.elastic_aks_cluster.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.elastic_aks_cluster.kube_config_raw
}

# Kubernetes Storage
resource "kubernetes_storage_class" "es_ssd" {
  metadata {
    name = "es-ssd"
  }
  storage_provisioner = "kubernetes.io/gce-pd"
  parameters          = {
    type = "pd-ssd"
  }
}

# Elastic Client
module "elasticsearch_client" {
  source                = "kiwicom/elasticsearch/kubernetes"
  version               = "~> 1.0.0"
  cluster_name          = local.cluster_name
  node_group            = "client"
  roles                 = {"data": false, "ingest": true, "master": false}
  es_version            = local.es_version
  namespace             = local.aks_node_pool_name
  replicas              = 2
  master_eligible_nodes = 3
  storage_class_name    = kubernetes_storage_class.es_ssd.metadata[0].name
  storage_size          = "1Gi"
  helm_install_timeout  = 1200
}

# Elastic Master Nodes
module "elasticsearch_master" {
  source                = "kiwicom/elasticsearch/kubernetes"
  version               = "~> 1.0.0"
  node_group            = "master"
  roles                 = {"data": false, "ingest": false, "master": true}
  cluster_name          = local.cluster_name
  es_version            = local.es_version
  namespace             = local.aks_node_pool_name
  replicas              = 3
  master_eligible_nodes = 3
  storage_class_name    = kubernetes_storage_class.es_ssd.metadata[0].name
  storage_size          = "5Gi"
  helm_install_timeout  = 1200
}

# Elastic Data Nodes
module "elasticsearch_data" {
  source                = "kiwicom/elasticsearch/kubernetes"
  version               = "~> 1.0.0"
  node_group            = "data"
  roles                 = {"data": true, "ingest": false, "master": false}
  cluster_name          = local.cluster_name
  es_version            = local.es_version
  namespace             = local.aks_node_pool_name
  replicas              = 3
  master_eligible_nodes = 3
  storage_class_name    = kubernetes_storage_class.es_ssd.metadata[0].name
  storage_size          = "20Gi"
  helm_install_timeout  = 1200
}