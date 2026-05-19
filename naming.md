# Sommaire
- [**1. Présentation du document**](#1-présentation-du-document)
- [**2. Nom des matériels**](#2-nom-des-matériels)
- [**3. Nom des ordinateurs (VM/CT)**](#3-nom-des-ordinateurs-vmct)
- [**4.Active Directory**](#4-active-directory)
  - [**4.1 Nom des utilisateurs**](#41-nom-des-utilisateurs)
  - [**4.2 Nom des groupes**](#42-nom-des-groupes)
  - [**4.3 Nom des Unités d'Organisation**](#43-nom-des-unités-dorganisation)
  - [**4.4 Nom des GPO**](#44-nom-des-gpo)
# 1. Présentation du document

*Ce document a pour but de recenser différentes conventions de nommage de l'infrastructure du projet.* 
# 2. Nom des matériels

Pour les serveur , nous avons choisis d'offusquer leurs noms de cette façon : 

Convention :
`BV-<NUMERO VLAN>-<ID>`

| Éléments    | Description            |
| ----------- | ---------------------- |
| BV          | Machine serveur        |
| NUMERO VLAN | Numéro VLAN du serveur |
| ID          | Numéro unique          |

## 2.1 Serveur du projet

| Nom       | Rôle     |
| --------- | -------- |
| BV-130-01 | AD/DS    |
| BV-130-02 | DHCP     |
| BV-130-03 | DNS      |
| BV-140-01 | ADMIN    |
| BV-150-01 | STOCKAGE |

# 3. Nom des ordinateurs (VM/CT)

Pour les ordinateurs, nous avons choisis les noms de cette façon : 

Convention :
`BU-<DEPARTEMENT>-<SERVICE>-<ID>`

| Éléments    | Description   |
| ----------- | ------------- |
| BU          | Poste client  |
| DEPARTEMENT | Département   |
| SERVICE     | Service       |
| ID          | Numéro unique |

**Développement logiciel = DL**

| Service                | Abrévation | Exemple      |
| ---------------------- | ---------- | ------------ |
| Développement          | DEV        | BU-DL-DEV-01 |
| Test et qualité        | TEQ        | BU-DL-TEQ-01 |
| Analyse et concéption  | AEC        | BU-DL-AEC-01 |
| Recherche et prototype | REP        | BU-DL-REP-01 |

**Communication et Relations publiques = CR** 

| Service                | Abrévation | Exemple      |
| ---------------------- | ---------- | ------------ |
| Communications interne | CI         | BU-CR-CI-01  |
| Relation médias        | RM         | BU-CR-RM-01  |
| Gestion des marques    | GDM        | BU-CR-GDM-01 |

**Département Juridique = DJ**

| Service                              | Abrévation | Exemple      |
| ------------------------------------ | ---------- | ------------ |
| Protection des données et conformité | PDC        | BU-DJ-PDC-01 |
| Propriété intellectuelle             | PI         | BU-DJ-PI-01  |
| Droit des sociétés                   | DS         | BU-DJ-DS-01  |

**Direction = DIR**

| Département              | Abrévation | Exemple     |
| ------------------------ | ---------- | ----------- |
| Direction                | DIR        | BU-DIR-01   |

**DSI = DSI**

| Service                            | Abrévation | Exemple       |
| ---------------------------------- | ---------- | ------------- |
| Exploitation                       | EXP        | BU-DSI-EXP-01 |
| Administration Systèmes et Réseaux | ASS        | BU-DSI-ASS-01 |
| Support                            | SUP        | BU-DSI-SUP-01 |

**Finances et Comptabilités = FC** 

| Service              | Abrévation | Exemple      |
| -------------------- | ---------- | ------------ |
| Finances             | FIN        | BU-FC-FIN-01 |
| Service Comptabilité | SC         | BU-FC-SC-01  |

**QHSE = QHS**

| Service                  | Abrévation | Exemple       |
| ------------------------ | ---------- | ------------- |
| Gestion environnementale | GE         | BU-QHS-GE-01  |
| Contrôle Qualité         | CQ         | BU-QHS-CQ-01  |
| Certification            | CER        | BU-QHS-CER-01 |

**Service Commercial = SCO** 

| Service        | Abrévation | Exemple       |
| -------------- | ---------- | ------------- |
| Service Client | SCL        | BU-SCO-SCL-01 |
| ADV            | ADV        | BU-SCO-ADV-01 |
| Service achat  | SAC        | BU-SCO-SAC-01 |

**Service Recrutement = RCT** 

| Service             | Abrévation | Exemple      |
| ------------------- | ---------- | ------------ |
| Service recrutement | SR         | BU-RCT-SR-01 |

# 4. Active Directory
## 4.1 Nom des utilisateurs

## Compte utilisateurs

Pour le nommage des utilisateurs dans **l'Active Directory**, nous avons choisis cette convention : 

`nom.prenom` 

Exemple : `gaillard.remi`

- en minuscules
- sans accents
- sans espaces
- sans caractères spéciaux

En cas d’homonymie : `nom.prenom.date_de_naissance (au format DDMMYYYY)`
Les comptes utilisateurs sont personnels et non partagés.

Exemple : `gaillard.remi`
		 `gaillard.remi.01031988`

## Comptes administrateurs

Les comptes administrateur sont distincts des comptes utilisateurs standards. Ils ne sont pas utilisés pour la messagerie ou la navigation.

`nom.prenom.spe`

Exemple : `gaillard.remy.spe`

| Type           | Nom               |
| -------------- | ----------------- |
| Utilisateur    | gaillard.remi     |
| Administrateur | gaillard.remi.spe |

## 4.2 Nom des groupes
## 4.3 Nom des Unités d'Organisation
## 4.4 Nom des GPO 
