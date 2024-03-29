resource "azurerm_resource_group" "example" {
  name     = "${trimspace(data.template_file.prefix.rendered)}-aks-rg"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = "${trimspace(data.template_file.prefix.rendered)}-aks-cluster"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "${trimspace(data.template_file.prefix.rendered)}-aks-k8s"

  default_node_pool {
    name       = "default"
    # node_count = 2
    vm_size    = var.size
    enable_auto_scaling = true
    min_count           = "1"
    max_count           = "5"
    enable_node_public_ip = true
    temporary_name_for_rotation = "nodepool1"
  }
  
  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

resource "local_file" "config" {
  content  = azurerm_kubernetes_cluster.example.kube_config_raw
  filename = "/etc/.azure/aks_config"
}
