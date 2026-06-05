# Sommaire

- [**1. Les objectifs pris par le groupe sur le print**](#1-les-objectifs-pris-par-le-groupe-sur-le-sprint)
- [**2. La finalité de ces objectifs à la fin du sprint**](#2-la-finalité-de-ces-objectifs-à-la-fin-du-sprint)
- [**3. Membre du groupe et leurs rôles**](#3-membre-du-groupe-et-leurs-rôles)
- [**4. Les problèmes rencontrés**](#4-les-problèmes-rencontrés)
- [**5. Les décisions techniques**](#5-les-décisions-techniques)
- [**6. Ce qu'il reste à faire**](#6-ce-quil-reste-à-faire)

# 1. Les objectifs pris par le groupe sur le sprint

- Création d'un domaine AD/DS
- Mise en place d'un PC d'administration
- Mise en place d'un serveur DNS
- Mise en place d'un serveur DHCP
- Mise en place des GPO
- Logiciel de gestion de parc et de ticketing (GLPI)
- Gestion d'un firewall pfSense
- Mise en place du réseau de l'infrastructure (Switch/Routeur)
- Automatisation par script de l'installation du rôle AD/DS sur un serveur Windows Server Core
- Synchronisation des objects avec l'AD sur GLPI

# 2. La finalité de ces objectifs à la fin du sprint

Tous les objectifs ont été atteints a 100% lors de ce sprint 2

# 3. Membre du groupe et leurs rôles

| Membre   | Rôle       |
| -------- | ---------- |
| Brice    | SM         |
| Xavier   | PO         |
| Cédric   | Tech       |
# 4. Les problèmes rencontrés

Lors de ce premier sprint, nous avons rencontrés quelques problèmes sur la mise en place du serveur GLPI lors de la synchronisation avec LDAP.  
Une erreur de frappe dans la config nous a empêché de synchroniser avec LDAP, erreur corrigée.  
Lors de la mise en place de certaines GPO , plusieurs bugs sont apparus. GPO mise à jours , plus aucun problèmes. 
Nous avons intégrés les routeurs après la mise en place de l'adresse IP, ce qui nous a un peu bloqué le temps de tout remettre en place.
Un problème de template nous à fait perdre quelques heures sur la connexion en RPD, le problème a été corrigé en créant une nouvelle VM.


# 5. Les décisions techniques

- **Serveur**
  - Serveur AD/DS , DNS et DHCP (Windows server 2022 GUI)
  - Serveur GLPI (Debian-13)
  - Serveur AD/DS Second DC (Windows server Core)


- **PC**
  - PC ADMIN
  - Déploiement des GPO 


# 6. Ce qu'il reste à faire

Tout a été finalisé pendant ce sprint 1 , nous sommes prêt a attaquer le sprint 2.
