
# Sommaire

- [**1. Les objectifs pris par le groupe sur le print**](#1-les-objectifs-pris-par-le-groupe-sur-le-sprint)
- [**2. La finalité de ces objectifs à la fin du sprint**](#2-la-finalité-de-ces-objectifs-à-la-fin-du-sprint)
- [**3. Membre du groupe et leurs rôles**](#3-membre-du-groupe-et-leurs-rôles)
- [**4. Les problèmes rencontrés**](#4-les-problèmes-rencontrés)
- [**5. Les décisions techniques**](#5-les-décisions-techniques)
- [**6. Ce qu'il reste à faire**](#6-ce-quil-reste-à-faire)

# 1. Les objectifs pris par le groupe sur le sprint

- DOSSIERS PARTAGES - Mettre en place des dossiers réseaux pour les utilisateurs
- STOCKAGE AVANCÉ - Mettre en place du RAID 1 sur un serveur
- STOCKAGE AVANCÉ - Mettre en place LVM sur un serveur
- SAUVEGARDE - Mettre en place une sauvegarde de données
- ACTIVE DIRECTORY - Gestion des objets AD
- SUPERVISION - Mise en place d'une supervision de l'infrastructure réseau
- WEB - Mettre en place un serveur WEB INTERNE
- WEB - Mettre en place un serveur WEB EXTERNE
- JOURNALISATION - Mise en place d'une gestion des logs centralisée
- JOURNALISATION - Mise en place d'une journalisation des scripts PowerShell
- MESSAGERIE - Mise en place d'un serveur de messagerie

# 2. La finalité de ces objectifs à la fin du sprint

Tous les objectifs ont été atteints a 100% lors de ce sprint 3

# 3. Membre du groupe et leurs rôles

| Membre   | Rôle       |
| -------- | ---------- |
| Brice    | PO         |
| Xavier   | TECH       |
| Cédric   | SM         |
# 4. Les problèmes rencontrés

Lors de ce troisième sprint, nous avons rencontré plusieurs difficultés lors de la mise en place du serveur de messagerie local iRedMail.

L'un des principaux problèmes concernait la communication entre le serveur de messagerie situé dans la DMZ et les services présents sur le réseau local. Les règles de filtrage du pare-feu pfSense empêchaient certains flux nécessaires au fonctionnement de la messagerie, notamment les échanges DNS et l'accès au partage SMB utilisé pour la synchronisation des utilisateurs Active Directory. Après analyse et création des règles adéquates, la communication entre la DMZ et le réseau local a été rétablie.

Nous avons également rencontré des difficultés lors de l'automatisation de la création des boîtes mail à partir des utilisateurs Active Directory. Plusieurs erreurs dans les scripts de synchronisation et les requêtes MariaDB ont nécessité des phases de tests et de correction avant d'obtenir une création automatique fonctionnelle des comptes.

Enfin, lors de la configuration des clients de messagerie, les connexions via Thunderbird ont été bloquées par certaines règles du pare-feu pfSense. Après vérification des services Postfix et Dovecot ainsi que l'ouverture des ports nécessaires, les utilisateurs ont pu accéder à leurs boîtes mail et échanger des messages normalement.

Problème d’installation sur zabbix 

Problème de compréhension de graylog


# 5. Les décisions techniques

- **Serveur**
  - Messagerie
  

- **PC**
  - Déployement des Clients de Messagerie sur les Pc Client
    


# 6. Ce qu'il reste à faire

Tout a été finalisé pendant ce sprint 3 , nous sommes prêt a attaquer le sprint 4.
