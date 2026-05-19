# Sommaire
- [**1. Découpage des VLAN**](#1-découpage-des-vlan)
  - [**1.1 VLAN Utilisateurs**](#11-vlan-utilisateurs)
  - [**1.2 VLAN Servers**](#12-vlan-servers)
- [**2. Configuration IP des materiels**](#2-configuration-ip-des-materiels)
  - [**2.1 Adresses IP des routeurs**](#21-adresses-ip-des-routeurs)
# 1. Découpage des VLAN 

## 1.1 VLAN Utilisateurs

Les VLAN utilisateurs sont découpés en fonction des besoins de chaque services. Le choix des plages IP sont adaptées aux nombre de personnes et prennent en compte les possiblités de croissance futurs.
Ils sont répartis comme suit:

- **VLAN 2 - Developpement**   
**Réseau :** 172.16.2.0/24   
**IP :** de 172.16.2.1 à 172.16.2.254 soit 252 ip disponibles

- **VLAN 4 - Juridique**  
**Réseau :** 172.16.4.0/24  
**IP :** de 172.16.4.1 à 172.16.4.63 soit 62 ip disponibles

- **VLAN 6 - Direction + QHSE + Recrutement**   
**Réseau :** 172.16.6.0/24   
**IP :** de 172.16.6.1 à 172.16.6.63 soit 62 ip disponibles

- **VLAN 8 - Commercial** 
**Réseau :** 172.16.8.0/24   
**IP :** de 172.16.8.1 à 172.16.8.127 soit 126 ip disponibles

- **VLAN 10 - DSI**  
**Réseau :** 172.16.10.0/24   
**IP :** de 172.16.10.1 à 172.16.10.63 soit 62 ip disponibles

- **VLAN 12 - Comptabilité** 
**Réseau :** 172.16.12.0/26   
**IP :** de 172.16.12.1 à 172.16.12.63 soit 62 ip disponibles

- **VLAN 14 - Communication**  
**Réseau :** 172.16.14.0/26   
**IP :** de 172.16.14.1 à 172.16.14.63 soit 62 ip disponibles

## 1.2 VLAN Servers

Les VLAN serveurs ont été nommés et decoupés afin de repondre aux besoins de sécurités et d'isolations

- **VLAN 130 - Regroupe entre autres les serveurs AD/DS DNS et DHCP mais pourra aussi d'autres serveurs selon les besoins**  
**Réseau :** 172.16.130.0/24
**IP :** de 172.16.130.1 à 172.16.130.254 soit 254 ip disponibles

- **VLAN 140 - ADMIN VLAN spécial d'aministration**  
**Réseau :** 172.16.140.0/24   
**IP :** de 172.16.140.1 à 172.16.140.254 soit 254 ip disponibles

- **VLAN 150 - STOCKAGE Regroupe nos serveurs de stockage**
**Réseau :** 172.16.150.0/24   
**IP :** de 172.16.150.1 à 172.16.150.254 soit 254 ip disponibles

# 2. Configuration IP des materiels

## 2.1 Adresses IP des routeurs
- **R0 - Routeur principal des serveurs** 
**Interfaces:**  
g0/1 : 172.16.128.1  
g0/0 : 10.0.0.2  

- **R1 - Routeur faissant le lien entre les utilisateurs, les serveurs et le bastion**  
g0/0 : 192.168.1.1  
g0/1 : 10.0.0.1  
g0/2 : 172.16.127.254  

- **Firewall/Bastion - En construction**  
g0/1 : 192.168.1.2  
