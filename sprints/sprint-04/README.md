

# Sommaire

* [**1. Les objectifs pris par le groupe sur le sprint**](#1-les-objectifs-pris-par-le-groupe-sur-le-sprint)
* [**2. La finalité de ces objectifs à la fin du sprint**](#2-la-finalité-de-ces-objectifs-à-la-fin-du-sprint)
* [**3. Membres du groupe et leurs rôles**](#3-membres-du-groupe-et-leurs-rôles)
* [**4. Les problèmes rencontréss**](#4.-Les-problèmes-rencontrés)
* [**5. Les décisions techniques**](#5-les-décisions-techniques)
* [**6. Ce qu'il reste à faire**](#6-ce-quil-reste-à-faire)

---

# 1. Les objectifs pris par le groupe sur le sprint

## Objectifs initiaux du Sprint 4

* **VOIP** - Mettre en place un serveur de téléphonie sur IP avec FreePBX.
* **VOIP** - Créer des lignes téléphoniques VoIP manuellement ou automatiquement.
* **VOIP** - Déployer le client 3CX sur les postes clients.
* **VOIP** - Valider la communication téléphonique entre deux clients.
* **ACTIVE DIRECTORY** - Mettre en place de nouvelles règles RH.
* **ACTIVE DIRECTORY** - Gérer le départ des collaborateurs sans suppression des comptes.
* **ACTIVE DIRECTORY** - Automatiser la désactivation et le déplacement des comptes concernés.
* **ACTIVE DIRECTORY** - Automatiser la féminisation des intitulés de postes.
* **ACTIVE DIRECTORY** - Mettre en place plusieurs contrôleurs de domaine et répartir les rôles FSMO.
* **SÉCURITÉ** - Mettre en place un serveur WSUS pour la gestion des mises à jour.
* **SÉCURITÉ** - Mettre en place un accès sécurisé aux ressources d'administration.
* **DÉPLOIEMENT DE MASSE** - Mettre en place une solution de déploiement Windows 11 avec WDS / MDT.
* **SUPERVISION** - Intégrer les équipements à la supervision.
* **DOCUMENTATION** - Documenter l'installation, la configuration et les procédures réalisées.

## Objectifs ajoutés par la fusion BillU / EcoTechSolutions

Un partenariat entre **BillU** et **EcoTechSolutions** a été signé. Dans le cadre de cette fusion, notre groupe a dû intégrer l'infrastructure EcoTechSolutions à celle de BillU.

Les objectifs ajoutés étaient :

* **FIREWALL** - Mettre à jour les règles pfSense afin de permettre une communication contrôlée entre les deux entreprises.
* **VPN** - Mettre en place un VPN site-à-site IPsec entre BillU et EcoTechSolutions.
* **ACTIVE DIRECTORY** - Mettre en place une gestion AD commune entre les deux entreprises.
* **ACTIVE DIRECTORY** - Mettre en place une relation de confiance entre les domaines BillU et EcoTechSolutions.
* **DNS** - Mettre en place une résolution DNS entre les deux domaines.
* **DNS** - Mettre en place une solution de DNS Split-Brain / DNS Policy pour gérer le NAT.
* **SUPERVISION** - Mettre en place une supervision commune entre BillU et EcoTechSolutions.
* **PARTAGE DE DOSSIERS** - Mettre en place des dossiers partagés accessibles entre les deux entreprises.
* **SÉCURITÉ** - Permettre aux administrateurs autorisés d'accéder aux interfaces de gestion nécessaires.
* **ACCÈS DISTANT** - Gérer les accès SSH, RDP et web d'administration entre les deux infrastructures.

---

# 2. La finalité de ces objectifs à la fin du sprint

Tous les objectifs du Sprint 4 ont été atteints à **100 %**.

## Objectifs finalisés côté BillU

* Le serveur **FreePBX** a été installé et configuré.
* Les extensions VoIP ont été créées.
* La communication téléphonique entre deux clients a été validée.
* Le client 3CX a été préparé pour les postes utilisateurs.
* Les règles RH Active Directory ont été automatisées :

  * désactivation des comptes des collaborateurs sortants ;
  * déplacement des comptes dans une OU dédiée ;
  * automatisation de la féminisation des intitulés de postes.
* Les rôles AD et les contrôleurs de domaine ont été préparés.
* Le serveur WSUS a été mis en place.
* La solution de déploiement de masse **WDS / MDT** a été mise en place.
* Le déploiement Windows 11 sur une machine vierge a été validé.
* La supervision avec Zabbix a été préparée et utilisée pour intégrer les nouveaux équipements.
* Les documents GitHub liés aux différents services ont été préparés ou mis à jour.

## Objectifs finalisés côté EcoTechSolutions

* L'infrastructure EcoTechSolutions a été créée sur Proxmox.
* Le firewall pfSense EcoTechSolutions a été installé et configuré.
* Le serveur **AD DS / DNS / DHCP EcoTechSolutions** a été mis en place.
* Les utilisateurs EcoTechSolutions ont été créés automatiquement dans l'Active Directory à partir d'un fichier CSV.
* Un serveur de stockage / sauvegarde EcoTechSolutions a été créé.
* Un poste client EcoTechSolutions a été créé et intégré au domaine.
* Les dossiers partagés EcoTechSolutions ont été préparés.
* Le serveur de stockage EcoTechSolutions est accessible via son nom DNS depuis BillU.
* Les accès d'administration nécessaires ont été configurés.

## Objectifs finalisés pour la fusion BillU / EcoTechSolutions

* Le VPN site-à-site IPsec entre BillU et EcoTechSolutions est opérationnel.
* Le NAT/BINAT IPsec a été configuré afin de résoudre le conflit d'adressage réseau.
* Les routes nécessaires ont été ajoutées côté BillU.
* Les serveurs EcoTechSolutions sont joignables depuis BillU via leurs adresses NATées.
* Le DNS inter-domaines fonctionne.
* Le DNS Split-Brain / DNS Policy a été mis en place afin que BillU résolve les serveurs EcoTechSolutions avec leurs IP NATées.
* Le contrôleur de domaine EcoTechSolutions est joignable par son nom DNS depuis BillU.
* Le serveur de stockage EcoTechSolutions est joignable par son nom DNS depuis BillU.
* Les règles pfSense ont été organisées avec des alias afin de limiter les flux au nécessaire.
* Les ports nécessaires à Active Directory, DNS, SMB, RDP, SSH et Zabbix ont été identifiés et configurés.
* La relation de confiance entre les domaines BillU et EcoTechSolutions a été mise en place.
* La supervision commune a été préparée avec l'intégration des équipements EcoTechSolutions dans Zabbix.
* Les administrateurs EcoTechSolutions peuvent accéder aux ressources autorisées selon les règles définies.

---

# 3. Membres du groupe et leurs rôles

Semaine 1 :

| Membre | Rôle | Missions principales                                                     |
| ------ | ---- | ------------------------------------------------------------------------ |
| Brice  | SM   | Suivi fonctionnel, priorisation et validation des objectifs              |
| Xavier | TECH | Administration système, Active Directory, services Windows               |
| Cédric | PO   | Réseau, pfSense, VPN IPsec, NAT/BINAT, DNS, supervision et documentation |

Semaine 2 : 
| Membre | Rôle | Missions principales                                                     |
| ------ | ---- | ------------------------------------------------------------------------ |
| Brice  | PO   | Suivi fonctionnel, priorisation et validation des objectifs              |
| Xavier | TECH | Administration système, Active Directory, services Windows               |
| Cédric | SM   | Réseau, pfSense, VPN IPsec, NAT/BINAT, DNS, supervision et documentation |



---

# 4. Les problèmes rencontrés

Lors de ce Sprint 4, nous avons rencontré plusieurs difficultés techniques sur les différents objectifs mis en place.

Problème sur la VoIP avec pfSense

Lors de la mise en place de la téléphonie sur IP avec FreePBX et les clients 3CX, nous avons rencontré des problèmes de communication liés aux règles du pare-feu pfSense.

Les clients pouvaient parfois joindre le serveur, mais la connexion VoIP ne fonctionnait pas correctement. Le problème venait principalement du filtrage des flux nécessaires à la VoIP, notamment les ports liés au SIP et aux communications audio.

Nous avons dû analyser les flux réseau, adapter les règles pfSense et vérifier la connectivité entre les clients, le serveur FreePBX et les différents réseaux concernés.

Problème d'encodage dans Active Directory

Pour la gestion IT des nouvelles règles RH, nous avons rencontré un problème d'encodage lors de l'import ou de la modification des informations utilisateurs dans l'Active Directory.

Certains noms ou intitulés de postes contenant des accents ou des caractères spéciaux apparaissaient avec des caractères bizarres dans l'AD.

Le problème venait principalement de l'encodage utilisé dans les fichiers CSV et dans les scripts PowerShell. Nous avons dû corriger l'encodage des fichiers et adapter les scripts afin que les caractères spéciaux soient correctement pris en compte.

Problème avec le serveur de gestion des mises à jour WSUS

Lors de la mise en place du serveur WSUS, nous avons rencontré beaucoup d'attente avant que les postes clients remontent correctement dans la console.

Même après la configuration des GPO et du serveur WSUS, les machines ne sont pas apparues immédiatement. Il a fallu attendre les cycles de rafraîchissement des stratégies de groupe et forcer certains postes à contacter le serveur de mises à jour.

Nous avons donc utilisé plusieurs commandes de vérification et de mise à jour côté client afin de valider que les postes communiquaient bien avec WSUS.

Problème de dépendances sur le serveur bastion

Lors de l'installation du serveur bastion, nous avons rencontré des problèmes liés aux dépendances nécessaires au bon fonctionnement de la solution choisie.

Certaines dépendances n'étaient pas installées ou n'étaient pas dans la bonne version, ce qui bloquait l'installation ou le lancement du service.

Nous avons dû identifier les paquets manquants, corriger l'installation et relancer la configuration afin d'obtenir un serveur bastion fonctionnel.

Problème de déploiement de masse avec Proxmox

Lors de la mise en place du déploiement de masse, nous avons rencontré un problème au niveau de Proxmox.

La machine cliente ne démarrait pas correctement sur le réseau pour lancer l'installation via le serveur de déploiement. Le problème venait de la configuration du boot réseau de la VM et de l'ordre de démarrage.

Nous avons dû vérifier la configuration PXE, l'ordre de boot de la machine virtuelle, la carte réseau utilisée et les paramètres DHCP nécessaires au démarrage réseau.

Après correction, le poste client a pu démarrer sur le réseau et lancer le déploiement de Windows.

Problème de NAT lors de la fusion BillU / EcoTechSolutions

Lors de la fusion entre BillU et EcoTechSolutions, nous avons rencontré un problème important d'adressage réseau.

Les deux entreprises utilisaient des plages réseau qui se chevauchaient. Le réseau EcoTechSolutions était en :

172.16.20.0/24

Cependant, côté BillU, les réseaux internes utilisaient déjà une plage plus large en :

172.16.0.0/16

Cela provoquait des conflits de routage, car les machines BillU considéraient le réseau EcoTechSolutions comme faisant déjà partie de leur propre réseau interne.

Pour résoudre ce problème, nous avons mis en place un NAT/BINAT IPsec. EcoTechSolutions garde son adressage réel en 172.16.20.0/24, mais BillU voit ce réseau sous la forme :

10.20.20.0/24

Exemples :

172.16.20.253 → 10.20.20.253
172.16.20.10  → 10.20.20.10
172.16.20.254 → 10.20.20.254

Cette solution a permis d'éviter le conflit d'adressage tout en conservant la communication entre les deux entreprises via le VPN site-à-site.

Problème de règles pfSense lors de la fusion

La mise en place des règles pfSense entre BillU et EcoTechSolutions a été complexe.

À cause du NAT IPsec, il fallait faire attention aux adresses utilisées selon le côté du pare-feu :

Côté BillU : adresses EcoTech NATées en 10.20.20.x
Côté EcoTech : adresses réelles en 172.16.20.x

Certaines règles ne fonctionnaient pas au départ, car nous utilisions parfois l'adresse NATée au mauvais endroit. Par exemple, une règle côté EcoTech ne devait pas utiliser 10.20.20.254, mais l'adresse réelle 172.16.20.254.

Pour identifier les problèmes, nous avons temporairement utilisé des règles plus larges de type Any Allow. Cela nous a permis de confirmer que le VPN et le NAT fonctionnaient bien. Ensuite, nous avons progressivement remplacé ces règles par des règles plus précises avec des alias pfSense.

Les règles finales ont été organisées autour des flux nécessaires :

DNS ;
Active Directory ;
SMB ;
RDP ;
SSH ;
Zabbix ;
accès aux interfaces d'administration ;
ping inter-site pour les tests.

Cette étape a demandé plusieurs tests avant d'obtenir une communication stable et sécurisée entre les deux infrastructures.

# 5. Les décisions techniques

## Réseau et sécurité

* Conservation du LAN EcoTechSolutions en `172.16.20.0/24`.
* Mise en place d'un VPN site-à-site IPsec entre BillU et EcoTechSolutions.
* Mise en place d'un NAT/BINAT IPsec pour éviter le conflit d'adressage.
* Utilisation du réseau NATé `10.20.20.0/24` pour représenter EcoTechSolutions côté BillU.
* Création de routes statiques sur les routeurs BillU afin de joindre le réseau NATé EcoTechSolutions.
* Utilisation d'alias pfSense pour rendre les règles plus lisibles et plus sécurisées.
* Mise en place d'un `Deny all` en fin de règles pfSense afin de bloquer tout trafic non autorisé.
* Limitation des accès d'administration aux postes autorisés.

## DNS

* Mise en place de redirecteurs conditionnels entre les domaines.
* Côté BillU :

```text
EcoTechSolutions.lan → 10.20.20.253
```

* Côté EcoTechSolutions :

```text
BillU.lan → 172.16.130.253
```

* Mise en place d'une politique DNS Split-Brain / DNS Policy afin que BillU reçoive les IP NATées des serveurs EcoTechSolutions.
* Ajout des entrées DNS nécessaires pour :

  * le contrôleur de domaine EcoTechSolutions ;
  * le serveur de stockage EcoTechSolutions.

## Active Directory

* Choix d'une relation de confiance plutôt qu'une fusion complète de domaines.
* Conservation des deux domaines AD :

  * `BillU.lan`
  * `EcoTechSolutions.lan`
* Mise en place d'une relation de confiance entre les deux domaines.
* Vérification de la résolution DNS entre les deux domaines.
* Vérification de la découverte des contrôleurs de domaine avec `nltest`.
* Utilisation d'alias pfSense pour limiter les flux AD aux contrôleurs de domaine.
* Ouverture des ports nécessaires au fonctionnement AD :

  * DNS ;
  * Kerberos ;
  * LDAP / LDAPS ;
  * SMB ;
  * Global Catalog ;
  * RPC ;
  * NTP.

## Supervision

* Conservation de Zabbix comme solution de supervision.
* Ajout des serveurs EcoTechSolutions dans la supervision.
* Autorisation des flux Zabbix entre EcoTechSolutions et BillU :

  * agents EcoTechSolutions vers serveur Zabbix BillU ;
  * accès web Zabbix pour les administrateurs EcoTechSolutions.
* Supervision des équipements et services suivants :

  * pfSense EcoTechSolutions ;
  * contrôleur de domaine EcoTechSolutions ;
  * serveur de stockage EcoTechSolutions ;
  * services DNS / DHCP / AD DS ;
  * disponibilité réseau.

## Partage de dossiers

* Mise en place d'un serveur de stockage EcoTechSolutions.
* Mise en place d'un partage accessible entre les deux entreprises.
* Utilisation de règles SMB ciblées sur le port TCP 445.
* Préparation de la gestion des droits via groupes Active Directory.
* Validation de l'accès au serveur de stockage EcoTechSolutions par son nom DNS depuis BillU.

---

# 6. Ce qu'il reste à faire

Tous les objectifs du Sprint 4 ont été finalisés.

À la fin de ce Sprint 4, tous les objectifs ont été atteints à 100 %. L'infrastructure EcoTechSolutions est fonctionnelle, le VPN IPsec NATé est opérationnel, la résolution DNS inter-domaines fonctionne, la relation de confiance AD est mise en place, la supervision commune est opérationnelle et les partages inter-entreprises sont prêts à être utilisés.
