# Software - Infrastructure BillU / EcoTechSolutions

# Sommaire

- [1. Objectif du document](https://chatgpt.com/c/6a1fc1eb-0e68-83eb-bc71-ba7ec97c7d1d?mweb_fallback=1#1-objectif-du-document)
    
- [2. Systèmes d'exploitation](https://chatgpt.com/c/6a1fc1eb-0e68-83eb-bc71-ba7ec97c7d1d?mweb_fallback=1#2-syst%C3%A8mes-dexploitation)
    
- [3. Services Microsoft](https://chatgpt.com/c/6a1fc1eb-0e68-83eb-bc71-ba7ec97c7d1d?mweb_fallback=1#3-services-microsoft)
    
- [4. Services Linux](https://chatgpt.com/c/6a1fc1eb-0e68-83eb-bc71-ba7ec97c7d1d?mweb_fallback=1#4-services-linux)
    
- [5. Services réseau et sécurité](https://chatgpt.com/c/6a1fc1eb-0e68-83eb-bc71-ba7ec97c7d1d?mweb_fallback=1#5-services-r%C3%A9seau-et-s%C3%A9curit%C3%A9)
    
- [6. Supervision et journalisation](https://chatgpt.com/c/6a1fc1eb-0e68-83eb-bc71-ba7ec97c7d1d?mweb_fallback=1#6-supervision-et-journalisation)
    
- [7. Messagerie](https://chatgpt.com/c/6a1fc1eb-0e68-83eb-bc71-ba7ec97c7d1d?mweb_fallback=1#7-messagerie)
    
- [8. VoIP](https://chatgpt.com/c/6a1fc1eb-0e68-83eb-bc71-ba7ec97c7d1d?mweb_fallback=1#8-voip)
    
- [9. Déploiement de masse](https://chatgpt.com/c/6a1fc1eb-0e68-83eb-bc71-ba7ec97c7d1d?mweb_fallback=1#9-d%C3%A9ploiement-de-masse)
    
- [10. Outils d'administration](https://chatgpt.com/c/6a1fc1eb-0e68-83eb-bc71-ba7ec97c7d1d?mweb_fallback=1#10-outils-dadministration)
    

---

# 1. Objectif du document

Ce document présente l'ensemble des logiciels, systèmes d'exploitation, rôles, services et applications utilisés dans l'infrastructure BillU et EcoTechSolutions.

Il permet d'identifier les solutions retenues, leur rôle dans l'infrastructure et leur emplacement.

---

# 2. Systèmes d'exploitation

|Système|Utilisation|
|---|---|
|Windows Server 2022 GUI|AD DS, DNS, DHCP, WSUS, WDS / MDT|
|Windows Server Core|Contrôleur de domaine secondaire, stockage|
|Windows 11|Postes clients et postes d'administration|
|Debian 13|GLPI, iRedMail, services Linux|
|Linux|Zabbix, Graylog, serveurs web, bastion|
|pfSense|Pare-feu, filtrage, VPN IPsec|
|FreePBX|Serveur de téléphonie IP|

---

# 3. Services Microsoft

|Service / Rôle|Utilisation|
|---|---|
|Active Directory Domain Services|Gestion centralisée des utilisateurs, groupes et ordinateurs|
|DNS|Résolution de noms interne|
|DHCP|Attribution automatique des adresses IP|
|GPO|Application de stratégies de sécurité et de configuration|
|WSUS|Gestion centralisée des mises à jour Windows|
|WDS|Déploiement réseau de Windows|
|MDT|Automatisation du déploiement Windows|
|FSMO|Répartition des rôles Active Directory|
|SMB|Partages de fichiers|
|RDP|Administration distante Windows|

---

# 4. Services Linux

|Service / Logiciel|Utilisation|
|---|---|
|GLPI|Gestion de parc informatique et ticketing|
|Zabbix|Supervision de l'infrastructure|
|Graylog|Journalisation centralisée|
|iRedMail|Serveur de messagerie|
|Serveur web interne|Hébergement du site interne|
|Serveur web externe|Hébergement du site externe|
|MariaDB|Base de données utilisée par certains services|
|SSH|Administration distante Linux|
|LVM|Gestion avancée du stockage Linux|

---

# 5. Services réseau et sécurité

|Solution|Utilisation|
|---|---|
|pfSense BillU|Pare-feu principal BillU|
|pfSense EcoTechSolutions|Pare-feu principal EcoTechSolutions|
|VPN IPsec site-à-site|Communication sécurisée entre BillU et EcoTechSolutions|
|NAT/BINAT IPsec|Gestion du conflit d'adressage entre les deux entreprises|
|Règles pfSense|Filtrage des flux réseau|
|Alias pfSense|Simplification et sécurisation des règles|
|Bastion|Accès sécurisé d'administration|
|Relation de confiance AD|Accès contrôlé entre les domaines BillU et EcoTechSolutions|
|DNS Split-Brain / DNS Policy|Résolution DNS adaptée au NAT inter-site|

---

# 6. Supervision et journalisation

|Solution|Utilisation|
|---|---|
|Zabbix Server|Supervision des serveurs, services et équipements réseau|
|Zabbix Agent|Remontée des informations des machines supervisées|
|ICMP Ping|Test de disponibilité réseau|
|Graylog|Centralisation et consultation des logs|
|Journalisation PowerShell|Suivi des scripts exécutés|
|Logs pfSense|Analyse des flux bloqués ou autorisés|

---

# 7. Messagerie

|Solution|Utilisation|
|---|---|
|iRedMail|Serveur de messagerie interne|
|Postfix|Service SMTP|
|Dovecot|Services IMAP / POP|
|Roundcube|Webmail|
|Thunderbird|Client de messagerie|
|MariaDB|Stockage des comptes et informations de messagerie|

---

# 8. VoIP

|Solution|Utilisation|
|---|---|
|FreePBX|Serveur de téléphonie sur IP|
|Asterisk|Moteur VoIP utilisé par FreePBX|
|3CX|Client softphone installé sur les postes|
|SIP|Protocole de signalisation VoIP|
|RTP|Flux audio des communications|
|Extensions VoIP|Lignes téléphoniques des utilisateurs|

---

# 9. Déploiement de masse

|Solution|Utilisation|
|---|---|
|WDS|Démarrage réseau et déploiement d'image Windows|
|MDT|Automatisation du déploiement Windows 11|
|PXE|Boot réseau des postes clients|
|Image Windows 11|Système déployé sur les machines|
|GPO|Configuration des postes après intégration au domaine|

---

# 10. Outils d'administration

|Outil|Utilisation|
|---|---|
|RSAT|Administration Active Directory depuis un PC Admin|
|PowerShell|Scripts d'automatisation et administration Windows|
|SSH|Administration distante Linux|
|RDP|Administration distante Windows|
|Interface web pfSense|Administration des pare-feu|
|Interface web GLPI|Gestion de parc et ticketing|
|Interface web Zabbix|Supervision|
|Interface web iRedMail / Roundcube|Administration et accès messagerie|
|Interface web FreePBX|Administration VoIP|
|Proxmox|Gestion des machines virtuelles|

