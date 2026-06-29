# Planning du projet BillU

# Sommaire

* [1. Vue d'ensemble](#1-vue-densemble)
* [2. Calendrier global](#2-calendrier-global)
* [3. Planning détaillé par sprint](#3-planning-détaillé-par-sprint)

  * [3.1. Sprint 01 - Analyse et documentation](#31-sprint-01---analyse-et-documentation)
  * [3.2. Sprint 02 - Socle réseau et services de base](#32-sprint-02---socle-réseau-et-services-de-base)
  * [3.3. Sprint 03 - Services internes, supervision et messagerie](#33-sprint-03---services-internes-supervision-et-messagerie)
  * [3.4. Sprint 04 - Sécurité, VoIP, déploiement et fusion EcoTechSolutions](#34-sprint-04---sécurité-voip-déploiement-et-fusion-ecotechsolutions)
  * [3.5. Sprint 05 - Consolidation et optimisation](#35-sprint-05---consolidation-et-optimisation)
  * [3.6. Sprint 06 - Finalisation et soutenance](#36-sprint-06---finalisation-et-soutenance)
* [4. Répartition estimée des charges](#4-répartition-estimée-des-charges)
* [5. Suivi du planning](#5-suivi-du-planning)

---

# 1. Vue d'ensemble

| Information             | Détail                               |
| ----------------------- | ------------------------------------ |
| Entreprise              | BillU                                |
| Entreprise partenaire   | EcoTechSolutions                     |
| Durée totale            | 10 semaines, soit 50 jours ouvrables |
| Nombre de sprints       | 6 sprints                            |
| Heures estimées totales | 1539 heures                          |
| Équipe                  | 3 personnes                          |
| Méthode de travail      | Gestion par sprint                   |
| Support documentaire    | GitHub                               |

Le projet BillU consiste à concevoir, déployer, sécuriser et documenter une infrastructure réseau complète pour une entreprise.

Le projet comprend la mise en place d'une infrastructure système et réseau avec Active Directory, DNS, DHCP, pfSense, GLPI, dossiers partagés, stockage, sauvegarde, supervision, messagerie, VoIP, WSUS, bastion, déploiement de masse et documentation technique.

À partir du Sprint 4, une fusion avec l'entreprise **EcoTechSolutions** a été ajoutée au périmètre du projet. Cette fusion a nécessité la mise en place d'une communication sécurisée entre les deux infrastructures via VPN site-à-site, NAT/BINAT, règles pfSense, DNS inter-domaines, relation de confiance Active Directory, supervision commune et partages inter-entreprises.

---

# 2. Calendrier global

| Sprint    |      Période |    Durée | Thème principal                                        | État    |
| --------- | -----------: | -------: | ------------------------------------------------------ | ------- |
| Sprint 01 |    Semaine 1 |  5 jours | Analyse et documentation                               | Terminé |
| Sprint 02 | Semaines 2-3 | 10 jours | Socle réseau et services de base                       | Terminé |
| Sprint 03 | Semaines 4-5 | 10 jours | Services internes, supervision et messagerie           | Terminé |
| Sprint 04 | Semaines 6-7 | 10 jours | Sécurité, VoIP, déploiement et fusion EcoTechSolutions | Terminé |
| Sprint 05 | Semaines 8-9 | 10 jours | Consolidation, tests et optimisation                   | À venir |
| Sprint 06 |   Semaine 10 |  5 jours | Finalisation, documentation et soutenance              | À venir |

---

# 3. Planning détaillé par sprint

---

# 3.1. Sprint 01 - Analyse et documentation

## Objectifs principaux

* Analyser en détail le contexte de l'entreprise BillU.
* Créer l'arborescence complète du dépôt GitHub.
* Mettre en place la structure de documentation.
* Réaliser le schéma réseau prévisionnel.
* Réaliser le schéma logique de l'infrastructure.
* Faire le listing du matériel nécessaire.
* Mettre en place une nomenclature de nommage.
* Préparer le planning global du projet.
* Calculer l'estimation ETP.

## Réalisations

* Création de l'arborescence GitHub.
* Création des premiers fichiers de documentation.
* Réalisation des premiers schémas réseau.
* Réalisation d'un schéma Packet Tracer.
* Préparation de la nomenclature matérielle.
* Préparation du planning prévisionnel.
* Répartition initiale des rôles dans l'équipe.

## Problèmes rencontrés

Lors de ce premier sprint, plusieurs difficultés ont été rencontrées sur la mise en place des schémas.

L'adressage IP prévu au départ n'était pas cohérent avec le routage souhaité. Le groupe a donc repris le plan d'adressage afin de repartir sur une base plus propre.

Les premiers schémas n'étaient pas assez clairs. Après retour du formateur, ils ont été retravaillés et remis au propre.

## Décisions techniques

* Prévoir un serveur Windows Server graphique pour les rôles AD DS, DNS et DHCP.
* Prévoir un serveur Windows Server Core pour le stockage.
* Prévoir les équipements réseau nécessaires : routeur, switchs, postes clients et serveurs.
* Prévoir une organisation par services.
* Prévoir un poste ou laptop par utilisateur selon les services.
* Définir une convention de nommage claire pour les serveurs, postes, utilisateurs et groupes.

## Livrables réalisés

* Arborescence GitHub.
* Documentation DAT initiale.
* Documentation HLD initiale.
* Schémas réseau.
* Nomenclature matérielle.
* Planning prévisionnel.
* Fichier de suivi du Sprint 1.

## État du sprint

Tous les objectifs du Sprint 1 ont été atteints à 100 %.

---

# 3.2. Sprint 02 - Socle réseau et services de base

## Objectifs principaux

* Créer un domaine Active Directory.
* Mettre en place un PC d'administration.
* Mettre en place un serveur DNS.
* Mettre en place un serveur DHCP.
* Mettre en place les premières GPO.
* Mettre en place GLPI pour la gestion de parc et le ticketing.
* Gérer un firewall pfSense.
* Mettre en place le réseau de l'infrastructure avec switchs et routeurs.
* Automatiser l'installation du rôle AD DS sur un serveur Windows Server Core.
* Synchroniser les objets Active Directory avec GLPI.

## Réalisations

* Installation du domaine Active Directory BillU.
* Configuration du serveur DNS.
* Configuration du serveur DHCP.
* Création des premières GPO.
* Mise en place du PC d'administration.
* Installation et configuration de GLPI.
* Mise en place de la synchronisation LDAP entre Active Directory et GLPI.
* Mise en place du pare-feu pfSense.
* Configuration du réseau, des routeurs et des premières règles de filtrage.
* Installation d'un second contrôleur de domaine sur Windows Server Core.
* Automatisation de l'installation de certains rôles Windows Server.

## Problèmes rencontrés

Une difficulté a été rencontrée lors de la synchronisation LDAP entre GLPI et Active Directory. Une erreur de frappe dans la configuration empêchait la synchronisation. Après correction, les objets AD ont pu remonter correctement dans GLPI.

Certaines GPO ont également posé problème au départ. Elles ont été corrigées puis appliquées de nouveau.

L'intégration des routeurs après l'adressage IP initial a demandé des ajustements supplémentaires sur le réseau.

Un problème de template de machine virtuelle a aussi provoqué des pertes de temps, notamment pour la connexion RDP. Le problème a été corrigé en recréant une nouvelle VM propre.

## Décisions techniques

* Utilisation d'un serveur Windows Server 2022 GUI pour AD DS, DNS et DHCP.
* Utilisation d'un serveur Debian 13 pour GLPI.
* Utilisation d'un serveur Windows Server Core comme second contrôleur de domaine.
* Mise en place d'un PC Admin dédié.
* Déploiement des GPO depuis Active Directory.
* Utilisation de pfSense comme pare-feu principal.
* Mise en place du routage interne avec plusieurs équipements réseau.

## Livrables réalisés

* Documentation Active Directory.
* Documentation DNS.
* Documentation DHCP.
* Documentation GPO.
* Documentation GLPI.
* Documentation pfSense.
* Documentation réseau.
* Fichier de suivi du Sprint 2.

## État du sprint

Tous les objectifs du Sprint 2 ont été atteints à 100 %.

---

# 3.3. Sprint 03 - Services internes, supervision et messagerie

## Objectifs principaux

* Mettre en place des dossiers réseaux pour les utilisateurs.
* Mettre en place du RAID 1 sur un serveur.
* Mettre en place LVM sur un serveur.
* Mettre en place une sauvegarde de données.
* Gérer les objets Active Directory.
* Mettre en place une supervision de l'infrastructure réseau.
* Mettre en place un serveur web interne.
* Mettre en place un serveur web externe.
* Mettre en place une gestion des logs centralisée.
* Mettre en place une journalisation des scripts PowerShell.
* Mettre en place un serveur de messagerie.

## Réalisations

* Mise en place des dossiers partagés utilisateurs.
* Configuration des droits d'accès aux dossiers partagés.
* Mise en place d'un stockage RAID 1.
* Mise en place de LVM sur un serveur Linux.
* Mise en place d'une solution de sauvegarde.
* Gestion des objets Active Directory.
* Installation et configuration de Zabbix pour la supervision.
* Ajout d'équipements dans la supervision.
* Installation d'un serveur web interne.
* Installation d'un serveur web externe.
* Mise en place d'une solution de journalisation centralisée.
* Mise en place de la journalisation des scripts PowerShell.
* Installation et configuration du serveur de messagerie iRedMail.
* Création automatique des boîtes mail à partir des utilisateurs Active Directory.
* Configuration du webmail.
* Configuration des clients de messagerie Thunderbird.

## Problèmes rencontrés

La mise en place du serveur de messagerie iRedMail a entraîné plusieurs difficultés.

Le serveur de messagerie étant placé dans la DMZ, certaines communications avec le réseau local étaient bloquées par pfSense. Les flux DNS et SMB nécessaires à la synchronisation avec Active Directory ont dû être analysés puis autorisés.

L'automatisation de la création des boîtes mail a également demandé plusieurs corrections. Certaines erreurs dans les scripts et dans les requêtes MariaDB empêchaient la création correcte des comptes.

Des problèmes ont aussi été rencontrés lors de la configuration de Thunderbird. Les ports nécessaires à Postfix et Dovecot ont dû être vérifiés et ouverts dans pfSense.

Enfin, des difficultés ont été rencontrées sur Zabbix lors de l'installation, ainsi que sur la compréhension de Graylog pour la journalisation centralisée.

## Décisions techniques

* Utilisation d'iRedMail pour la messagerie interne.
* Utilisation de Thunderbird comme client de messagerie.
* Utilisation de Zabbix pour la supervision de l'infrastructure.
* Utilisation de règles pfSense dédiées pour autoriser les flux entre la DMZ et le LAN.
* Utilisation de scripts pour automatiser la création des comptes de messagerie.
* Mise en place de services web internes et externes séparés.
* Mise en place d'une journalisation centralisée pour améliorer le suivi des événements.

## Livrables réalisés

* Documentation dossiers partagés.
* Documentation RAID 1.
* Documentation LVM.
* Documentation sauvegarde.
* Documentation Active Directory.
* Documentation supervision Zabbix.
* Documentation serveur web interne.
* Documentation serveur web externe.
* Documentation journalisation.
* Documentation scripts PowerShell.
* Documentation messagerie iRedMail.
* Fichier de suivi du Sprint 3.

## État du sprint

Tous les objectifs du Sprint 3 ont été atteints à 100 %.

---

# 3.4. Sprint 04 - Sécurité, VoIP, déploiement et fusion EcoTechSolutions

## Objectifs principaux initiaux

* Mettre en place un serveur de téléphonie sur IP avec FreePBX.
* Créer des lignes VoIP manuellement ou automatiquement.
* Déployer le client 3CX sur les postes clients.
* Valider la communication téléphonique entre deux clients.
* Mettre en place de nouvelles règles RH dans Active Directory.
* Gérer le départ des collaborateurs sans suppression des comptes.
* Automatiser la désactivation et le déplacement des comptes concernés.
* Automatiser la féminisation des intitulés de postes.
* Mettre en place plusieurs contrôleurs de domaine.
* Répartir les rôles FSMO.
* Mettre en place un serveur WSUS.
* Mettre en place un accès sécurisé aux ressources d'administration.
* Mettre en place un serveur bastion.
* Mettre en place une solution de déploiement Windows 11 avec WDS / MDT.
* Intégrer les équipements à la supervision.
* Documenter les installations, configurations et procédures.

## Objectifs ajoutés par la fusion BillU / EcoTechSolutions

* Mettre à jour les règles pfSense pour permettre une communication contrôlée entre les deux entreprises.
* Mettre en place un VPN site-à-site IPsec entre BillU et EcoTechSolutions.
* Mettre en place une gestion AD commune.
* Mettre en place une relation de confiance entre les domaines BillU et EcoTechSolutions.
* Mettre en place une résolution DNS entre les deux domaines.
* Mettre en place une solution DNS Split-Brain / DNS Policy pour gérer le NAT.
* Mettre en place une supervision commune.
* Mettre en place des dossiers partagés accessibles entre les deux entreprises.
* Permettre aux administrateurs autorisés d'accéder aux interfaces de gestion nécessaires.
* Gérer les accès SSH, RDP et web d'administration entre les deux infrastructures.

## Réalisations côté BillU

* Installation et configuration de FreePBX.
* Création des extensions VoIP.
* Validation de la communication téléphonique entre deux clients.
* Préparation du client 3CX pour les postes utilisateurs.
* Mise en place des règles RH Active Directory :

  * désactivation des comptes des collaborateurs sortants ;
  * déplacement des comptes dans une OU dédiée ;
  * automatisation de la féminisation des intitulés de postes.
* Préparation des rôles AD et des contrôleurs de domaine.
* Mise en place du serveur WSUS.
* Mise en place d'un serveur bastion.
* Mise en place de WDS / MDT.
* Validation du déploiement Windows 11 sur une machine vierge.
* Mise à jour de la supervision avec Zabbix.
* Mise à jour de la documentation GitHub.

## Réalisations côté EcoTechSolutions

* Création de l'infrastructure EcoTechSolutions sur Proxmox.
* Installation et configuration du firewall pfSense EcoTechSolutions.
* Mise en place du serveur AD DS / DNS / DHCP EcoTechSolutions.
* Création automatique des utilisateurs EcoTechSolutions dans l'Active Directory à partir d'un fichier CSV.
* Création d'un serveur de stockage / sauvegarde EcoTechSolutions.
* Création d'un poste client EcoTechSolutions.
* Intégration du poste client au domaine EcoTechSolutions.
* Préparation des dossiers partagés EcoTechSolutions.
* Configuration des accès d'administration nécessaires.

## Réalisations pour la fusion BillU / EcoTechSolutions

* Mise en place du VPN site-à-site IPsec entre BillU et EcoTechSolutions.
* Mise en place du NAT/BINAT IPsec pour résoudre le conflit d'adressage.
* Ajout des routes nécessaires côté BillU.
* Mise en place des règles pfSense inter-sites.
* Mise en place des alias pfSense pour simplifier les règles.
* Mise en place des redirecteurs conditionnels DNS.
* Mise en place du DNS Split-Brain / DNS Policy.
* Validation de la résolution DNS inter-domaines.
* Validation de l'accès aux serveurs EcoTechSolutions via leurs IP NATées.
* Mise en place de la relation de confiance Active Directory.
* Intégration des équipements EcoTechSolutions dans Zabbix.
* Ouverture de l'accès à Zabbix pour les administrateurs EcoTechSolutions.
* Préparation des partages inter-entreprises.

## Problèmes rencontrés

La VoIP a posé des difficultés avec pfSense. Les clients pouvaient parfois joindre le serveur FreePBX, mais la communication VoIP ne fonctionnait pas correctement. Les flux SIP et audio ont dû être vérifiés puis autorisés.

Pour les règles RH Active Directory, un problème d'encodage est apparu. Certains noms ou intitulés de postes contenant des accents affichaient des caractères bizarres dans l'AD. Les fichiers CSV et scripts PowerShell ont dû être corrigés.

WSUS a demandé beaucoup d'attente avant que les postes clients remontent correctement dans la console. Les cycles de GPO et de détection Windows Update ont dû être forcés sur certains postes.

Le serveur bastion a posé des problèmes de dépendances lors de l'installation. Certains paquets manquants ou incompatibles empêchaient le bon démarrage du service.

Le déploiement de masse a rencontré un problème dans Proxmox : le poste client ne démarrait pas correctement en réseau. La configuration du boot PXE, l'ordre de démarrage et la carte réseau de la VM ont dû être vérifiés.

Pour la fusion BillU / EcoTechSolutions, le principal problème venait du chevauchement réseau. EcoTechSolutions utilisait le réseau `172.16.20.0/24`, inclus dans les plages utilisées côté BillU. Le NAT/BINAT IPsec a été mis en place pour présenter EcoTechSolutions côté BillU en `10.20.20.0/24`.

Les règles pfSense inter-sites ont aussi été complexes à mettre en place, car les adresses à utiliser ne sont pas les mêmes selon le côté du pare-feu :

* côté BillU, EcoTechSolutions est vu en `10.20.20.x` ;
* côté EcoTechSolutions, les machines gardent leurs vraies adresses en `172.16.20.x`.

## Décisions techniques

* Utilisation de FreePBX pour la VoIP.
* Utilisation de 3CX comme client VoIP.
* Utilisation de WSUS pour la gestion centralisée des mises à jour.
* Utilisation de WDS / MDT pour le déploiement Windows 11.
* Utilisation d'un serveur bastion pour sécuriser les accès d'administration.
* Conservation du domaine BillU et création du domaine EcoTechSolutions.
* Mise en place d'une relation de confiance plutôt qu'une fusion complète des domaines.
* Conservation du LAN EcoTechSolutions en `172.16.20.0/24`.
* Utilisation du NAT/BINAT IPsec pour éviter le conflit réseau.
* Utilisation du réseau NATé `10.20.20.0/24` pour représenter EcoTechSolutions côté BillU.
* Utilisation de Zabbix pour la supervision commune.
* Mise en place de règles pfSense avec alias pour limiter les flux au nécessaire.

## Livrables réalisés

* Documentation FreePBX.
* Documentation 3CX.
* Documentation règles RH Active Directory.
* Documentation FSMO.
* Documentation WSUS.
* Documentation bastion.
* Documentation WDS / MDT.
* Documentation VPN IPsec.
* Documentation NAT/BINAT.
* Documentation DNS inter-domaines.
* Documentation relation de confiance AD.
* Documentation supervision commune.
* Documentation partages inter-entreprises.
* Fichier de suivi du Sprint 4.

## État du sprint

Tous les objectifs du Sprint 4 ont été atteints à 100 %.

---

# 3.5. Sprint 05 -



---

# 3.6. Sprint 06 -



---

# 4. Répartition estimée des charges

| Sprint    |        Durée | Charge estimée en heures | État    |
| --------- | -----------: | -----------------------: | ------- |
| Sprint 01 |      5 jours |                    154 h | Terminé |
| Sprint 02 |     10 jours |                    308 h | Terminé |
| Sprint 03 |     10 jours |                    308 h | Terminé |
| Sprint 04 |     10 jours |                    308 h | Terminé |
| Sprint 05 |     10 jours |                    308 h | À venir |
| Sprint 06 |      5 jours |                    153 h | À venir |
| **Total** | **50 jours** |               **1539 h** |         |

---

# 5. Suivi du planning

Ce planning est un document évolutif. Il doit être mis à jour à chaque sprint selon l'avancement réel du projet.

À la fin de chaque sprint, les éléments suivants doivent être renseignés :

* objectifs réalisés ;
* objectifs non réalisés ;
* problèmes rencontrés ;
* décisions techniques prises ;
* livrables produits ;
* état du sprint ;
* tâches restantes.

Les quatre premiers sprints sont terminés. Les objectifs des Sprints 1, 2, 3 et 4 ont été atteints à 100 %.


