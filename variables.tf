variable "location" {
  type        = string
  description = "Azure region where the resources should be deployed."
  nullable    = false
}

variable "identity_resource_group_name" {
  type        = string
  description = "The name of the resource group where the managed identity should be created."
  nullable    = false
}

variable "user_assigned_managed_identity_names" {
  type        = object({
    plan = string
    apply = string 
  })
  description = "The names of the managed identities."
  default     = null
}

variable "application_name" {
  type        = string
  description = "The name of the application."
  nullable    = false
}

variable "environment_name" {
  type        = string
  description = "The name of the environment."
  nullable    = false
}

variable "resource_groups" {
  type = map(object({
    name     = string
    location = optional(string)
    tags     = optional(map(string), null)
    create   = optional(bool, true)
  }))
  description = "A map of resource groups to create. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time."
  nullable    = false
}

variable "storage_account_resource_id" {
  type        = string
  description = "The resource ID of the storage account. Only required if `storage_account_creation_enabled` is set to `false`."
  default = null
}

variable "storage_account_name" {
  type        = string
  description = "The name of the storage account."
  default = null
}

variable "storage_account_container_name" {
  type        = string
  description = "The name of the storage account container."
  default = null
}

variable "storage_account_creation_enabled" {
  type        = bool
  description = "Whether to create a storage account."
  default     = true
  nullable    = false
}

variable "use_private_networking" {
  type        = bool
  description = "Whether to enable private networking for the Key Vault."
  default     = true
  nullable    = false
}

variable "virtual_network_resource_id" {
  type        = string
  description = "The resource ID of the virtual network."
  default     = null
}

variable "subnet_storage_resource_id" {
  type        = string
  description = "The resource ID of the subnet."
  default     = null
}

variable "virtual_network_name" {
  type        = string
  description = "The name of the virtual network."
  default     = null
}

variable "subnet_name_storage" {
  type        = string
  description = "The name of the subnet."
  default     = null
}

variable "subnets" {
  type = map(object({
    name     = string
    address_prefix = optional(string)
    address_prefixes = optional(list(string))
    security_group_resource_id = optional(string, null)
    route_table_resource_id = optional(string, null)
  }))
  description = "A map of subnets to create. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time."
  default     = {}
  nullable    = false
}

variable "role_assignment_scope" {
  type        = string
  description = "The scope at which the role assignment should be created."
  nullable    = false
  validation {
    condition     = contains(["subscription", "resource_group"], var.role_assignment_scope)
    error_message = "The role assignment scope must be `subscription` or `resource_group`."
  }
}

variable "diagnostic_settings" {
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.
DESCRIPTION  
  nullable    = false

  validation {
    condition     = alltrue([for _, v in var.diagnostic_settings : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
  validation {
    condition = alltrue(
      [
        for _, v in var.diagnostic_settings :
        v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
      ]
    )
    error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id`, must be set."
  }
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}



variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}
