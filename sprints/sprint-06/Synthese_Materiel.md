# Tableau de synthèse des éléments du schéma

# Inventaire des machines - Infrastructure Proxmox

| ID | Nom (GUI Proxmox) | Nom (machine) | Type | OS | Fonction principale | Carte(s) réseau (vmbr) | Adresse IP / CIDR | Disque(s) : Taille / Libre / Libre % | RAM totale | RAM utilisée (moy.) |
|----|---|---|---|---|---|---|---|---|---|---|
| 100 | G1-pfsense | pfSense.Billu.lan | VM | Linux | Pare-feu | vmbr2, vmbr100, vmbr105 | 192.168.1.2/24<br>10.0.2.1/24<br>10.0.3.1/24 | 10 Go / 6,5 Go / 65 % | 2 GiB | 72 % |
| 101 | G1-PC-ADMIN | PC-Admin | VM | Windows 10 | PC admin | vmbr103 | 172.16.16.16/17 | 54 Go / 20 Go / 37 % | 4 Go | 76 % |
| 102 | G1-BV-100-101 | BV-100-101 | VM | Windows Server 2022 | AD DS, DNS, DHCP | vmbr104 | 172.16.130.253/17 | 100 Go / 64 Go / 64 % | 4 Go | 66 % |
| 103 | G1-BV-130-140 | BV-130-140 | VM | Debian 13 | Serveur web public | vmbr105 | 10.0.3.20/24 | 15 Go / 12 Go / 80 % | 1 Go | 79 % |
| 104 | G1-BU-DL-DEV-01 | BU-DL-DEV-01 | VM | Windows 10 | PC client DEV | vmbr103 | 172.16.0.1/17 | 40 GiB / 3 Go / 7,5 % | 4 Go | 76 % |
| 105 | G1-BV-130-105 | BV-130-105 | VM | Windows Server 2022 Core | AD DS secondaire | vmbr104 | 172.16.130.252/17 | 30 Go / 28 Go / 93 % | 1 Go | 38 % |
| 106 | G1-BV-130-153 | BV-130-153 | VM | Windows Server 2022 | Serveur de stockage de fichiers | vmbr104 | 172.16.130.250/17 | Disque 1 : 32 Go / 16 Go / 50 %<br>Disque 2+3 (RAID1) : 50 Go / 48 Go / 96 % | 4 Go | 62 % |
| 107 | G1-PC-Zabbix | PC-Zabbix | VM | Ubuntu 24.04 | Supervision Zabbix | vmbr103 | 172.16.17.17/17 | 70 Go / 20 Go / 29 % | 4 Go | 80 % |
| 108 | G1-BV-130-137 | BV-130-137 | VM | Debian 13 | Graylog | vmbr104 | 172.16.130.137/17 | 65 Go / 47 Go / 72 % | 8 Go | 87 % |
| 109 | G1-BV-130-155 | BV-130-155 | VM | Debian 13 | Serveur mail | vmbr105 | 10.0.3.10 | 15 Go / 8 Go / 53 % | 4 Go | 75 % |
| 111 | G1-PC-SNORT | PC-Snort | VM | Ubuntu 24.04 | Snort (IDS/IPS) | vmbr103, vmbr100, vmbr104 | 10.0.2.6/24<br>172.16.0.6/17<br>172.16.130.225/17 | 40 Go / 23 Go / 57,5 % | 4 Go | 82 % |
| 112 | G1-BU-SCO-SCL-01 | BU-SCO-SCL-01 | VM | Windows 10 | PC client comptabilité | vmbr103 | 172.16.0.4/17 | 40 Go / 7 Go / 17,5 % | 4 Go | 75 % |
| 113 | G1-BV-130-113 | BV-130-113 | VM | Windows Server 2022 Core | AD DS secondaire | vmbr104 | 172.16.130.113/17 | 40 Go / 28 Go / 70 % | 1 Go | 35 % |
| 114 | G1-BV-130-156 | BV-130-156 | VM | Debian 13 | FreePBX (téléphonie) | vmbr104 | 172.16.130.30/17 | 32 Go / 18 Go / 56 % | 4 Go | 84 % |
| 115 | G1-PC-GUACAMOLE | PC-Guacamole | VM | Ubuntu 24.04 | Serveur bastion | vmbr105 | 10.0.3.40/24 | 30 Go / 13 Go / 43 % | 4 Go | 86 % |
| 117 | G1-BV-130-117 | BV-130-117 | VM | Windows Server 2025 | Serveur WSUS | vmbr104 | 172.16.130.117/17 | Disque 1 : 100 Go / 32 Go / 32 %<br>Disque 2 : 60 Go / 20 Go / 33 % | 6 Go | 80 % |
| 143 | G1-BV-130-138 | BV-130-138 | VM | Debian 13 | Serveur web intranet (gestion de projet, mots de passe, suivi de projet) | vmbr104 | 172.16.130.138/17 | 15 Go / 9 Go / 60 % | 3 Go | 39 % |
| 144 | G1-BV-130-139 | BV-130-139 | VM | Debian 13 | Serveur de sauvegarde | vmbr104 | 172.16.130.239/17 | Disque 1 : 15 Go / 13 Go / 87 %<br>Disque 2 : 50 Go / 42 Go / 84 % | 1 Go | 64 % |
| 145 | G1-BV-130-145 | BV-130-145 | VM | Debian 13 | Serveur GLPI | vmbr104 | 172.16.160.251/17 | 15 Go / 4 Go / 27 % | 1 Go | 68 % |
| 146 | G1-ROUTEUR3 | Routeur3 | VM | VyOS | Routeur | vmbr102, vmbr104 | 172.16.128.1/17<br>10.0.0.2/30 | 4 Go / 2 Go / 50 % | 1 Go | 76 % |
| 147 | G1-ROUTEUR2 | Routeur2 | VM | VyOS | Routeur | vmbr101, vmbr103 | 10.0.1.2/30<br>172.16.127.254/17 | 4 Go / 2 Go / 50 % | 1 Go | 76 % |
| 148 | G1-ROUTEUR1 | Routeur1 | VM | VyOS | Routeur cœur de réseau | vmbr100, vmbr101, vmbr102 | 10.0.2.2/24<br>10.0.1.1/30<br>10.0.0.1/30 | 4 Go / 2 Go / 50 % | 1 Go | 76 % |
| 149 | G1-BV-130-121 | BV-130-121 | VM | Windows Server 2022 | WDS | vmbr104 | 172.16.130.121/17 | Disque 1 : 32 Go / 14 Go / 44 %<br>Disque 2 : 80 Go / 52 Go / 65 % | 4 Go | 75 % |
