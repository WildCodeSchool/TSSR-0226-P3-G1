# Configuration de Redmine

## 1. Configuration Apache

### Vhost — `/etc/apache2/sites-available/redmine.conf`


```apache
# The passenger module (from the libapache2-mod-passenger package) must be
# enabled

PassengerDefaultUser www-data

<VirtualHost *:80>
    # Specify the ServerName.
    ServerName redmine.Billu.lan

    # Set Rails to production mode.
    RailsEnv production

    # Change PassengerAppGroupName and REDMINE_INSTANCE for other instances.
    PassengerAppGroupName redmine_default
    SetEnv REDMINE_INSTANCE "default"

    # Set the document root.
    DocumentRoot /usr/share/redmine/public

    # Set the directory options.
    <Directory "/usr/share/redmine/public">
        Allow from all
        Options -MultiViews
        Require all granted
    </Directory>
</VirtualHost>

<VirtualHost *:443>
    ServerName redmine.Billu.lan
    RailsEnv production

    PassengerAppGroupName redmine_default
    SetEnv REDMINE_INSTANCE "default"

    DocumentRoot /usr/share/redmine/public

    <Directory "/usr/share/redmine/public">
        Allow from all
        Options -MultiViews
        Require all granted
    </Directory>

    SSLEngine on
    SSLCertificateFile /etc/ssl/passbolt/redmine.crt
    SSLCertificateKeyFile /etc/ssl/passbolt/redmine.key

    ErrorLog ${APACHE_LOG_DIR}/redmine_error.log
    CustomLog ${APACHE_LOG_DIR}/redmine_access.log combined
</VirtualHost>
```

## 2. Base de données

Gérée automatiquement par `dbconfig-common` à l'installation du paquet :

- Base : `redmine`
- Utilisateur et mot de passe générés automatiquement, stockés dans `/etc/dbconfig-common/redmine.conf`
- Connexion effective définie dans `/etc/redmine/default/database.yml`

## 3. Authentification LDAP (Active Directory)

**Administration → Modes d'authentification → Nouveau mode d'authentification**

|Champ|Valeur|
|---|---|
|Nom|`BillU AD`|
|Hôte|`172.16.130.253` (contrôleur de domaine)|
|Port|`389`|
|Compte|`SVC_REDMINE@BillU.lan`|
|Mot de passe|(mot de passe du compte de service)|
|Base DN|`OU=BU_Users,DC=BillU,DC=lan`|
|Timeout|`5` secondes|
|Création des utilisateurs à la volée|✅ Activé|

### Mapping des attributs

|Champ Redmine|Attribut AD|
|---|---|
|Attribut Identifiant|`sAMAccountName`|
|Attribut Prénom|`givenName`|
|Attribut Nom|`sn`|
|Attribut Email|`mail`|

### Pré-requis côté compte de service AD (`SVC_REDMINE`)

- Compte de domaine standard (aucune délégation/droit spécial nécessaire — la lecture des attributs utilisateurs est accordée par défaut au groupe "Utilisateurs authentifiés")
- Onglet **Compte** :
    - ✅ "Le mot de passe n'expire jamais"
    - ✅ "L'utilisateur ne peut pas changer de mot de passe"

### Vérification

Le test de connexion se fait depuis la **liste** des modes d'authentification (`Administration → Modes d'authentification`), via le lien **"Tester"** — pas depuis le formulaire d'édition lui-même.

## 4. Paramètres généraux

**Administration → Paramètres → Général**

- **Langue par défaut** : French (Français) — appliquée à tout compte créé via LDAP (AD ne transmettant pas d'attribut de langue)
- **Détection automatique de la langue du navigateur** : à désactiver si l'on souhaite forcer le français pour tous, indépendamment du navigateur client

## 5. Structuration projet

### Projet créé

- **Nom** : `Suivi Produits - Demande Clients`
- **Objectif** : pont entre le service client (remontée de demandes/retours clients) et le développement (traitement technique)
- **Modules activés** : Demandes, Gantt, Calendrier

### Trackers

|Tracker|Usage|Workflow copié de|
|---|---|---|
|Retour Client|Création de demandes par le service client|Tracker existant (ex: Tâche)|
|Anomalie|Bug logiciel confirmé|Retour Client|
|Évolution|Demande de nouvelle fonctionnalité|Retour Client|

### Membres et rôles

|Utilisateur|Rôle|Justification|
|---|---|---|
|`sandersson`|Rapporteur|Crée des demandes, suit leur avancement, commente — pas de gestion technique|
|`rmartinez`|Développeur|Prend en charge les demandes, change les statuts, assigne du temps|

### Champ personnalisé (optionnel)

**Administration → Champs personnalisés → Demandes** → champ texte `Client concerné`, pour tracer l'origine commerciale de chaque demande.

## 6. Déploiement du raccourci bureau via GPO

### Création du raccourci (GPP)

**Configuration utilisateur → Préférences → Paramètres Windows → Raccourcis**

|Champ|Valeur|
|---|---|
|Action|**Remplacer** (pas "Créer" — sinon les modifications ultérieures, ex. icône, ne sont jamais réappliquées sur un raccourci déjà existant)|
|Nom|`Raccourcis Internet\Redmine` (le sous-dossier est inclus directement dans le nom pour que le raccourci soit rangé automatiquement)|
|Type de cible|URL|
|Emplacement|Bureau|
|Cible|`https://redmine.billu.lan`|
