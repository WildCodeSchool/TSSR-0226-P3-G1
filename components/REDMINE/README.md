## Solution retenue

**Redmine**, version **6.0.5** (paquet officiel Debian `redmine-mysql`).

Redmine a été choisi car :

- Disponible en **paquet natif Debian 13** 
- Léger, libre
- Intégration native avec l'authentification **LDAP/Active Directory**

## Architecture

Redmine a été mutualisé sur le **même serveur web interne** que Passbolt, pour centraliser les outils "métier interne" sur une seule machine plutôt que de multiplier les VM.

```
Serveur web interne (Debian 13 — BV-130-138 — 172.16.130.138)
 ├── Apache2
 │    ├── vhost "interne.BillU.lan"   (site existant)
 │    ├── vhost "passbolt.BillU.lan"  (gestionnaire de mots de passe)
 │    └── vhost "redmine.BillU.lan"   (suivi de projet — ce document)
 ├── Passenger (intégration Apache ↔ Ruby on Rails)
 ├── MariaDB (base dédiée "redmine", gérée par dbconfig-common)
 └── Ruby (fourni par le paquet redmine-mysql)
```

## Accès

|Élément|Valeur|
|---|---|
|URL|`https://redmine.BillU.lan`|
|Authentification|Compte local **ou** compte Active Directory (LDAP configuré, voir CONFIGURATION.md)|
|Compte admin local|`admin` (mot de passe changé après la première connexion)|

## Authentification centralisée (LDAP/AD)

Un mode d'authentification LDAP (`BillU AD`) a été configuré pour permettre aux utilisateurs de se connecter avec leurs identifiants Active Directory habituels, sans création manuelle de compte (option "Création des utilisateurs à la volée" activée). Voir détail dans `CONFIGURATION.md`.

## Structuration mise en place

- **Projet** : `Suivi Produits - Demande Clients` — sert de pont entre le service client (remontée de demandes) et le développement (traitement)
- **Trackers personnalisés** : `Retour Client`, en complément des trackers par défaut
- **Membres** :
    
    |Utilisateur|Rôle|
    |---|---|
    |`sandersson` (service client)|Rapporteur|
    |`rmartinez` (développeuse)|Développeur|
    

## Accès simplifié pour les utilisateurs

Un raccourci vers `https://redmine.BillU.lan` est déployé automatiquement sur le bureau des postes via **GPO** (Préférences de stratégie de groupe → Raccourcis), avec une icône personnalisée.

## Documentation associée

- `INSTALLATION.md` — étapes d'installation détaillées
- `CONFIGURATION.md` — configuration Apache, LDAP, projets, GPO
