
# Routage BillU 
## Présentation

Cette documentation décrit la mise en place de l'infrastructure de routage du projet BillU.

L'architecture repose sur trois routeurs VyOS permettant de relier les différents réseaux de l'entreprise :

- R1 : Routeur cœur de réseau
    
- R2 : Réseau Développement
    
- R3 : Réseau Serveurs
    

Le routage est assuré à l'aide de routes statiques.

## Architecture

### Réseaux utilisés

| Bridge  | Réseau          | Description          |
| ------- | --------------- | -------------------- |
| vmbr100 | 10.0.2.0/24     | LAN BillU            |
| vmbr101 | 10.0.1.0/30     | Liaison R1 ↔ R2      |
| vmbr102 | 10.0.0.0/30     | Liaison R1 ↔ R3      |
| vmbr103 | 172.16.0.0/17   | Réseau Développement |
| vmbr104 | 172.16.160.251/17 | Réseau Serveurs      |

## Documentation

- [Installation](https://github.com/WildCodeSchool/TSSR-0226-P3-G1/blob/main/components/VYOS/Installation.md)
    
- [Configuration](https://github.com/WildCodeSchool/TSSR-0226-P3-G1/blob/main/components/VYOS/configuration.md)
    

## Technologies utilisées

- Proxmox VE
    
- VyOS 1.5
    
- Routage statique
    
- Bridges Linux
    


