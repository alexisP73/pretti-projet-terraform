# Diagramme d'Architecture Technique (DAT)

## Composants par environnement (ex: dev)
- **Resource Group** : `myapp-dev-rg`
- **Virtual Network** : `myapp-dev-vnet` (10.0.0.0/16)
  - Subnet `web` : 10.0.1.0/24 → VMs web
  - Subnet `db` : 10.0.2.0/24 → VM db
- **NSG** :
  - `web-nsg` : autorise HTTP (80), SSH (22) depuis Internet
  - `db-nsg` : autorise SSH (22) depuis web subnet uniquement
- **VMs** :
  - `web-0`, `web-1` (Standard_B1s, Linux)
  - `db-0` (Standard_B2s, Linux)
- **Load Balancer** : répartit HTTP vers les VMs web
- **Public IP** : attribuée au Load Balancer
- **Storage Account** : diagnostics logs

## Flux
Internet → Public IP → Load Balancer → VMs web → VM db (si besoin)
