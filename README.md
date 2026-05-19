# Projet 3 – Construction d’une infrastructure réseau

# Sommaire

1.  [**Présentation du projet**](#1-présentation-du-projet)
2.  [**Contexte de l'entreprise**](#2-contexte-de-lentreprise)
3.  [**Objectifs finaux**](#3-objectifs-finaux)
    - [**Objectifs principaux**](#31-objectifs-principaux)
    - [**Objectifs secondaires**](#32-objectifs-secondaires)
4. [**Vue d'ensemble des composants**](#4-vue-densemble-des-composants)
5. [**Services déployés**](#5-services-déployés)
6. [**Organisation de la documentation**](#6-organisation-de-la-documentation)
7. [**Accès a la documentation**](#7-accès-a-la-documentation)

# 1. Présentation du projet

Ce projet est réalisé dans le cadre de la formation **TSSR - Technicien Supérieur Systèmes et Réseaux**. L'objectif global de ce projet est la conception, la mise en place et la documentation complète d'une nouvelle infrastructure réseau pour la société **BillU**.

Le projet est conditionné comme dans un contexte professionnel réel, avec une organisation par sprints, une gestion des objectifs et une documentation structurée.

# 2. Contexte de l'entreprise

**BillU** est une société spécialisée dans le développement de solutions logicielles de facturation. 
Basée a Paris, dans le 20e arrondissement, elle rassemble **196 collaborateurs** répartis dans **9 départements stratégiques**.
Elle est également une filiale du groupe international **RemindMe**.
Un partenariat est en cours , il faudrait donc prévoir un accès réseau avec une entité externe.

## Situation actuelle

L'infrastructure actuelle présente de nombreuses failles / limites :

- Poste clients en workgroup
- Absence de serveurs interne
- Sécurité inexistante
- Réseau basé sur une box FAI et des répéteurs WIFI
- Stockage et sauvegardes non professionnels
- Mauvaise gestions des comptes et mot de passes

Ces contraintes rendent le système d'information : 

- peu sécurisé
- peu évolutif
- difficile à administrer

C'est pour cela qu'une **refonte complète de l'infrastructure réseau** est nécessaire. 

# 3. Objectifs finaux

## 3.1 Objectifs principaux
- Analyse du sujet d'entreprise
## 3.2 Objectifs secondaires

# 4. Vue d'ensemble des composants

L'infrastructure cible reposera sur :

- Une **architecture réseau** segmentée par VLANs
- Un **domaine Active Directory** pour la gestion centralisée des identités
- Des **services d’infrastructure** dédiés (DNS, DHCP, fichiers, sauvegarde)
- Une séparation claire des rôles
- Une infrastructure **sécurisée, évolutive et documentée**
- Les détails techniques sont volontairement **non décrits ici** et sont disponibles dans la documentation dédiée.

# 5. Services déployés

Les principaux services mis en place dans le cadre du projet sont :

- Active Directory Domain Service (AD DS)
- DNS
- DHCP
- Serveur de fichiers
- Services de sauvegarde
- Outils d'administration
- Infrastructure réseau (VLAN, routage, pare-feu)

# 6. Organisation de la documentation

La documentation du projet est structurée de cette façon 

## Architecture (HLD)

- Vue global de l'infrastructure
- Contexte, périmètre, réseau, sécurité
- Sert à comprendre comment l'infrastructure SI est construite

## Components (LLD)

- Conception technique détaillée
- Configuration des serveurs et services
- Information prévisionnelles matériels et logiciels 

## Opérations (DEX)

- Documentation d'exploitation
- Procédures d'administration
- Procédures utilisateur

# 7. Accès a la documentation 

- **Nomenclature** : [naming.md](naming.md)
- **Architecture (HLD)** : [architecture](architecture)
- **Components (LLD)** : [components](components)
- **Operations (DEX)** : [operations](operations)
- **Sprints** : [sprints](sprints)
