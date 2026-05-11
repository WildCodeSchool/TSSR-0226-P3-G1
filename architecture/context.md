# Sommaire
- [**1. Contexte de l'entreprise**](#1-contexte-de-lentreprise)
- [**2. Situation actuelle**](#2-situation-actuelle)
- [**3. Besoin fonctionnels principaux**](#3-besoin-fonctionnels-principaux)
- [**4. Besoin fonctionnels secondaires**](#4-besoin-fonctionnels-secondaires)
- [**5. Public cible**](#5-public-cible)

# 1. Contexte de l'entreprise

## Présentation de l'entreprise BillU

**BillU** est une filiale dynamique du groupe international **RemindMe**, un acteur majeur comptant plus de 2000 collaborateurs répartis sur plusieurs continents. 

**Informations clés :**
- **Secteur d'activités :** Développement de logiciels, spécialisé dans le domaine de la facturation
- **Localisation :** Paris, 20ᵉ arrondissement
- **Collaborateurs :** 196
- **Structure :** 9 départements stratègiques
- **Groupe parent :** RemindMe (+ de 2000 collaborateurs répartis sur plusieurs continents)

## Structure 

- **Communication et Relations publiques** 
  - Communication interne
  - Relation Médias
  - Gestion des marques

- **Département Juridique**
  - Protection des données et conformité
  - Propriété intellectuelle
  - Droit des sociétés

- **Développement logiciel**
  - Développement
  - Tests et qualité
  - Analyse et conception
  - Recherche et Prototype

- **Direction**

- **DSI**
  - Exploitation
  - Administration Systèmes et Réseaux
  - Support
  - Développement et Intégration

- **Finance et Comptabilité**
  - Finance
  - Service Comptabilité

- **QHSE**
  - Gestion environnementale
  - Contrôle Qualité
  - Certification

- **Service Commercial**
  - Service Client
  - ADV
  - Service Achat

- **Service Recrutement**

## Contexte du projet

Nous sommes une société prestataire de services mandatée par la société **BillU**. L'objectif final de ce projet est de mettre en place une nouvelle infrastructure réseau, tout en sachant qu'un partenariat est en cours et pourrait aboutir dans les prochains mois. Il peut impliquer un accès réseau avec une entité externe.

L'infrastructure doit être capable de : 

- Supporter la croissance des effectifs et l'extension potentielle
- Garantir la sécurité des données sensibles
- Faciliter la collaboration inter-départements et avec de futurs partenaires

# 2. Situation actuelle

## Infrastructure existante

**Parc informatique :**
- 100% de PC portables de marques très hétérogènes
- Aucun serveur ni matériel réseau
- 1 NAS grand public pour le stockage

**Réseau :**
- Réseau en wifi fourni par une box FAI et des répéteurs wifi
- Plage d'adressage : 172.16.10.0/24
- Aucun équipement réseau (switch/routeur/firewall)

**Messagerie :**
- Messagerie hébergée en cloud sur le web (format : prénom.nom@billu.com)

**Sécurité et gestion des accès :**
- Configuration en workgroups (pas d'Active Directory)
- Comptes locaux avec mots de passe stockés locament
- Pas de politique de sécurité centralisée
- Turnover élevé (stagiaires, alternants, CDD) fait que les mots de passe sont redonnés aux personnels au fur-et-à-mesure de leur arrivée

**Stockage et données :**
- NAS accessible seulement aux ordinateurs des encadrants (responsable et directeurs) et au personnel du département Développement logiciel
- Les autres collaborateurs stockent leurs données dans des drives en cloud
- Aucune redondance matérielle

**Sauvegarde :**
- Sauvegardes faites ponctuellement sur le NAS
- Pas de durée de rétention

**Téléphonie :**
- Téléphonie fixe et mobile aléatoire suivant les utilisateurs

**Nomadisme :**
- Pas de télétravail mis en place
- Aucun accès aux données en dehors du site (sauf pour la messagerie)


# 3. Besoin fonctionnels principaux
# 4. Besoin fonctionnels secondaires
# 5. Public cible

