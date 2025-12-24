# Infrastructure Azure multi-environnement avec Terraform

Projet DevOps CloudTech Solutions  
Déploiement automatisé d'environnements **dev**, **staging**, **prod** sur Microsoft Azure.

## Composants
- Virtual Network (VNet) avec subnets web/db
- 3 VMs Linux (2 web + 1 db)
- Load Balancer + Public IP
- NSG + Storage Account pour diagnostics

## Outils
- Terraform (IaC)
- Azure Cloud
- GitHub + Terraform Cloud (CI/CD)
- Vault (gestion des secrets)
- Sentinel (gouvernance)

Voir [docs/architecture.md] pour le diagramme.
