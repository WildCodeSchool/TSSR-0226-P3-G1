
# Hardware - Infrastructure BillU / EcoTechSolutions

# Sommaire

* [1. Objectif du document](#1-objectif-du-document)
* [2. Infrastructure de virtualisation](#2-infrastructure-de-virtualisation)
* [3. Matériel réseau](#3-matériel-réseau)
* [4. Serveurs BillU](#4-serveurs-billu)
* [5. Serveurs EcoTechSolutions](#5-serveurs-ecotechsolutions)
* [6. Postes clients et postes d'administration](#6-postes-clients-et-postes-dadministration)
* [7. Stockage](#7-stockage)
* [8. Estimation des ressources](#8-estimation-des-ressources)

---

# 1. Objectif du document

Ce document présente l'ensemble des éléments matériels et virtualisés utilisés dans l'infrastructure BillU et EcoTechSolutions.

Il permet d'identifier les machines, les équipements réseau, les serveurs, les postes clients, les ressources allouées et les éléments de stockage nécessaires au bon fonctionnement de l'infrastructure.

---

# 2. Infrastructure de virtualisation

L'infrastructure repose principalement sur l'hyperviseur **Proxmox**.

| Élément                     | Rôle                                                   |
| --------------------------- | ------------------------------------------------------ |
| Proxmox                     | Hébergement des machines virtuelles                    |
| Bridges Proxmox             | Séparation logique des réseaux                         |
| Machines virtuelles Windows | Services Microsoft, AD, DNS, DHCP, WSUS, WDS           |
| Machines virtuelles Linux   | Services web, GLPI, Zabbix, Graylog, iRedMail, FreePBX |
| Machines virtuelles pfSense | Pare-feu, filtrage réseau et VPN IPsec                 |
| Machines clientes           | Tests utilisateurs, GPO, domaine, déploiement          |

---

# 3. Matériel réseau

## Réseau BillU

| Équipement                 | Rôle                                          |
| -------------------------- | --------------------------------------------- |
| pfSense BillU              | Pare-feu principal BillU                      |
| Routeurs internes          | Routage entre les réseaux internes            |
| Switchs / bridges virtuels | Connexion des machines aux différents réseaux |
| LAN utilisateurs           | Réseau des postes utilisateurs                |
| Réseau serveurs            | Réseau des serveurs internes                  |
| DMZ                        | Zone des services exposés ou isolés           |
| Réseau administration      | Accès réservé aux administrateurs             |

## Réseau EcoTechSolutions

| Équipement               | Rôle                                                         |
| ------------------------ | ------------------------------------------------------------ |
| pfSense EcoTechSolutions | Pare-feu principal EcoTechSolutions                          |
| LAN EcoTechSolutions     | Réseau interne EcoTechSolutions                              |
| VPN IPsec                | Communication sécurisée entre BillU et EcoTechSolutions      |
| NAT/BINAT IPsec          | Résolution du conflit d'adressage entre les deux entreprises |

---

# 4. Serveurs BillU

| Nom / Type de serveur    | Système             | Rôle                               |
| ------------------------ | ------------------- | ---------------------------------- |
| Serveur AD DS principal  | Windows Server GUI  | Active Directory, DNS, DHCP        |
| Serveur AD DS secondaire | Windows Server Core | Contrôleur de domaine secondaire   |
| Serveur de stockage      | Windows Server Core | Dossiers partagés et stockage      |
| Serveur GLPI             | Debian              | Gestion de parc et ticketing       |
| Serveur Zabbix           | Linux               | Supervision                        |
| Serveur Graylog          | Linux               | Journalisation centralisée         |
| Serveur web interne      | Linux               | Hébergement du site interne        |
| Serveur web externe      | Linux               | Hébergement du site externe en DMZ |
| Serveur iRedMail         | Debian              | Messagerie interne                 |
| Serveur FreePBX          | Linux / FreePBX     | Téléphonie sur IP                  |
| Serveur WSUS             | Windows Server      | Gestion des mises à jour           |
| Serveur WDS / MDT        | Windows Server      | Déploiement Windows 11             |
| Serveur bastion          | Linux ou Windows    | Accès sécurisé d'administration    |

---

# 5. Serveurs EcoTechSolutions

| Nom / Type de serveur             | Système        | Rôle                               |
| --------------------------------- | -------------- | ---------------------------------- |
| pfSense EcoTechSolutions          | pfSense        | Pare-feu et VPN site-à-site        |
| Serveur AD DS EcoTechSolutions    | Windows Server | Active Directory, DNS, DHCP        |
| Serveur stockage EcoTechSolutions | Windows Server | Stockage, sauvegarde et partages   |
| PC Admin EcoTechSolutions         | Windows        | Administration de l'infrastructure |
| Poste client EcoTechSolutions     | Windows        | Poste utilisateur de test          |

L'infrastructure EcoTechSolutions utilise le réseau réel :

```text
172.16.20.0/24
```

Depuis BillU, ce réseau est vu via le NAT/BINAT IPsec sous la forme :

```text
10.20.20.0/24
```

---

# 6. Postes clients et postes d'administration

| Poste                         | Rôle                                     |
| ----------------------------- | ---------------------------------------- |
| PC Admin BillU                | Administration de l'infrastructure BillU |
| Postes utilisateurs BillU     | Tests GPO, domaine, accès aux services   |
| Postes clients de messagerie  | Tests Thunderbird et iRedMail            |
| Postes clients VoIP           | Tests 3CX et FreePBX                     |
| Poste déployé via WDS / MDT   | Validation du déploiement Windows 11     |
| PC Admin EcoTechSolutions     | Administration côté EcoTechSolutions     |
| Poste client EcoTechSolutions | Test domaine, VPN, DNS et partages       |

---

# 7. Stockage

| Élément                           | Rôle                                         |
| --------------------------------- | -------------------------------------------- |
| RAID 1                            | Tolérance de panne sur le stockage           |
| LVM                               | Gestion flexible du stockage Linux           |
| Dossiers partagés utilisateurs    | Données personnelles des utilisateurs        |
| Dossiers partagés par service     | Données communes par service                 |
| Serveur stockage EcoTechSolutions | Stockage et sauvegarde côté EcoTechSolutions |
| Partages inter-entreprises        | Accès commun entre BillU et EcoTechSolutions |

---

# 8. Estimation des ressources

| Machine / Service                   |  vCPU |      RAM | Stockage estimé |
| ----------------------------------- | ----: | -------: | --------------: |
| pfSense BillU                       |     2 |     2 Go |           20 Go |
| pfSense EcoTechSolutions            |     2 |     2 Go |           20 Go |
| AD DS / DNS / DHCP BillU            |     2 |     4 Go |           60 Go |
| AD DS secondaire BillU              |     2 | 2 à 4 Go |           40 Go |
| AD DS / DNS / DHCP EcoTechSolutions |     2 |     4 Go |           60 Go |
| GLPI                                |     2 |     4 Go |           40 Go |
| Zabbix                              |     2 |     4 Go |           60 Go |
| Graylog                             | 2 à 4 | 4 à 8 Go |           80 Go |
| iRedMail                            |     2 |     4 Go |           60 Go |
| FreePBX                             |     2 | 2 à 4 Go |           40 Go |
| WSUS                                | 2 à 4 | 4 à 8 Go |  100 Go minimum |
| WDS / MDT                           | 2 à 4 |     4 Go |  100 Go minimum |
| Serveur stockage BillU              |     2 |     4 Go |    Selon besoin |
| Serveur stockage EcoTechSolutions   |     2 |     4 Go |    Selon besoin |
| Serveur bastion                     |     2 |     4 Go |           40 Go |
| Client Windows                      |     2 |     4 Go |           60 Go |
