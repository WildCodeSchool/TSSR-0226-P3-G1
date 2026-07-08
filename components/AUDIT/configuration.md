# Présentation du document 

- Ce document a pour but d'expliquer les étapes pour corriger les vulnérabilités détéctées suite aux différents audit de sécurité.
- De préference les ajustement seront fait dans l'ordre de priorité via GPO, sinon via PowerShell et pour finir via Interface Graphique.

# Table des matières

- [**1. Déploiement de Windows LAPS (GPO)**](#1-déploiement-de-windows-laps-gpo)
- [**2. Sécurisation par certificat auto signé**](#2-sécurisation-par-certificat-auto-signé) 

## 1. Déploiement de Windows LAPS (GPO)

### Description de la faille
Sans LAPS, le compte **Administrateur local** de chaque machine du domaine partage généralement le même mot de passe.
Si un attaquant compromet une machine, il peut utiliser ce mot de passe pour se connecter en administrateur local sur toutes les autres machines du domaine.
**Windows LAPS** (Local Administrator Password Solution) résout ce problème en générant automatiquement un mot de passe unique par machine, en le stockant chiffré dans l'AD et en le renouvelant à intervalles réguliers.

### Correction
### Etape 1 - Extension du schéma AD
A effectuer une seule fois sur le domaine depuis le DC détenant le rôle **Schema Master**.
```
- Vérifier quel DC détient le rôle Schema Master :
  netdom query fsmo
- Etendre le schéma AD pour Windows LAPS :
  Update-LapsADSchema
```
**Vérification :**
```
Get-ADObject -SearchBase (Get-ADRootDSE).SchemaNamingContext -Filter {name -like "ms-LAPS*"}
```
Les attributs suivants doivent apparaitre :
```
ms-LAPS-EncryptedDSRMPassword
ms-LAPS-EncryptedDSRMPasswordHistory
ms-LAPS-EncryptedPassword
ms-LAPS-EncryptedPasswordHistory
ms-LAPS-Password
ms-LAPS-PasswordExpirationTime
```
---
### Etape 2 - Délégation des permissions sur les OUs
Chaque machine doit avoir le droit d'écrire son propre mot de passe dans l'AD.
La commande suivante est à répéter sur chaque OU contenant des machines :
```
Set-LapsADComputerSelfPermission -Identity "OU=BU_Computers,DC=BillU,DC=lan"
```
![SCHEMA_ETENDUE](Ressources/Schéma_étendu_permissions.png)

---
### Etape 3 - Configuration de la GPO LAPS
**Nom de la GPO :** `GPO-LAPS-Postes-v1.0`
```
- Ouvrir la console GPMC (gpmc.msc)
- Lier la GPO à l'OU BU_Computers (ou Postes_Utilisateurs)
- Clic droit sur la GPO - Edit
- Computer Configuration
  - Policies
    - Administrative Templates
      - System
        - LAPS
```
![GPO1](Ressources/GPO1.png)
![GPO2](Ressources/GPO2.png)

**Parametre 1 - Configure password backup directory**
```
- Enabled
- Backup directory : Active Directory
```
**Parametre 2 - Password Settings**
```
- Enabled
- Password complexity : Large letters + small letters + numbers + special characters
- Password length : 14
- Password age (days) : 30
```
**Parametre 3 - Enable password encryption**
```
- Enabled
```
---
### Etape 4 - Application et vérification
```
- Lancer gpupdate /force sur les machines cibles
- Vérifier la génération du mot de passe depuis le DC :
  Get-LapsADPassword -Identity "NOM-DE-LA-MACHINE" -AsPlainText
```
**Résultat attendu :**
```
ComputerName     : NOM-DE-LA-MACHINE
Account          : Administrateur
Password         : xxxxxxxxxxxxxxx
Source           : EncryptedPassword
DecryptionStatus : Success
AuthorizedDecryptor : BILLU\Domain Admins
```
---
### Etape 5 - Documentation de la rotation
```
- Etat avant rotation :
  Get-LapsADPassword -Identity "NOM-DE-LA-MACHINE" -AsPlainText
- Forcer une rotation manuelle sur le client :
  Reset-LapsPassword
- Etat après rotation :
  Get-LapsADPassword -Identity "NOM-DE-LA-MACHINE" -AsPlainText
````
![VERIF](Ressources/Console_laps_DC.png)

### Résultat
| Element | Avant | Après |
| --- | --- | --- |
| Mot de passe admin local | Identique sur toutes les machines | Unique par machine |
| Stockage du mot de passe | Non géré | Chiffré dans l'AD |
| Renouvellement | Manuel | Automatique tous les 30 jours |
| Accès au mot de passe | Non contrôlé | Réservé aux Domain Admins |
---

## 2. Sécurisation par certificat auto signé

### Description de la faille
Sans certificats TLS, les communications entre les clients et les serveurs web/mail transitent en **clair sur le réseau**.
Un attaquant positionné sur le réseau peut intercepter les identifiants, mots de passe et données sensibles échangés (attaque de type **Man-in-the-Middle**).

La mise en place d'une **PKI interne** (Public Key Infrastructure) basée sur **Windows Server AD CS** (Active Directory Certificate Services) résout ce problème en :
- Générant une **Autorité de Certification (CA) racine de confiance** intégrée à l'AD
- Distribuant automatiquement cette CA à tous les postes du domaine via les GPO
- Permettant d'émettre des certificats TLS signés pour chaque service exposé

---

### Déploiement de la PKI interne (AD CS)

### Etape 1 - Installation du rôle AD CS sur le contrôleur de domaine

 A effectuer depuis le DC principal (`BV-100-101.BillU.lan`) en PowerShell en tant qu'**Administrateur du domaine**.

```powershell
Install-WindowsFeature ADCS-Cert-Authority -IncludeManagementTools

Install-AdcsCertificationAuthority `
  -CAType EnterpriseRootCA `
  -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" `
  -KeyLength 4096 `
  -HashAlgorithmName SHA256 `
  -CACommonName "BillU-CA" `
  -ValidityPeriod Years `
  -ValidityPeriodUnits 10
```

**Vérification :**
```powershell
Get-Service CertSvc
certutil -CAInfo
```

Les résultats attendus sont :
```
Running   CertSvc   Active Directory Certificate Services

CA name: BillU-CA
CA type: 0 -- Enterprise Root CA
CA cert[0]: 3 -- Valid
```

---

### Etape 2 - Installation du rôle Web Enrollment

Le rôle **Web Enrollment** expose une interface web (`/certsrv`) permettant de soumettre des demandes de signature de certificat (CSR) depuis n'importe quelle machine du réseau.

```powershell
Install-WindowsFeature ADCS-Web-Enrollment -IncludeManagementTools
Install-AdcsWebEnrollment
```

**Vérification :**

Depuis un navigateur sur le LAN :
```
http://BV-100-101.BillU.lan/certsrv
```
La page **"Microsoft Active Directory Certificate Services — BillU-CA"** doit s'afficher avec une demande d'authentification Windows.

---

### Etape 3 - Distribution automatique de la CA racine aux postes du domaine

Grâce au type **Enterprise CA**, le certificat racine `BillU-CA` est automatiquement distribué à tous les postes joints au domaine via les **Public Key Policies** de la **Default Domain Policy**.

**Vérification sur un poste client Windows :**
```powershell
gpupdate /force
certutil -store -enterprise Root | findstr "BillU-CA"
```

**Résultat attendu :**
```
================ Certificate 0 ================
Issuer: CN=BillU-CA, DC=BillU, DC=lan
```
---

### Déploiement des certificats TLS sur les serveurs (Debian/Apache)

La procédure suivante est **identique pour chaque serveur**. L'exemple ci-dessous utilise le serveur intranet (`interne.BillU.lan`). Adapter le nom pour chaque service.

### Etape 1 - Génération de la clé privée et du CSR

A effectuer **sur chaque serveur Debian** concerné.

```bash
# Créer le dossier SSL
sudo mkdir -p /etc/apache2/ssl
cd /etc/apache2/ssl

# Générer la clé privée (2048 bits)
sudo openssl genrsa -out interne.key 2048

# Générer le CSR avec le SAN
sudo openssl req -new -key interne.key -out interne.csr -subj "/C=FR/O=BillU/CN=interne.BillU.lan" -addext "subjectAltName=DNS:interne.BillU.lan"

# Sécuriser la clé privée
sudo chmod 600 interne.key
sudo chown root:root interne.key
```
---

### Etape 2 - Signature du CSR via l'interface Web Enrollment

- Depuis un navigateur sur le LAN, aller sur `http://BV-100-101.BillU.lan/certsrv`
- S'authentifier avec `BillU\Administrator`
- Cliquer sur **"Request a certificate"**
- Cliquer sur **"advanced certificate request"**
- Coller le contenu de `interne.csr` dans le champ **"Saved Request"**
- Sélectionner le template **"Web Server"**
- Cliquer sur **"Submit"**
- Sélectionner **"Base 64 encoded"**
- Télécharger **"Download certificate"** (`certnew.cer`)

---

### Etape 3 - Transfert et installation du certificat signé

**Depuis le PC Windows (PowerShell) :**
```powershell
scp C:\Users\VotreUser\Downloads\certnew.cer utilisateur@interne.BillU.lan:/tmp/
```

**Sur le serveur Debian :**
```bash
# Déplacer le certificat au bon endroit
sudo mv /tmp/certnew.cer /etc/apache2/ssl/interne.crt
sudo chmod 644 /etc/apache2/ssl/interne.crt
sudo chown root:root /etc/apache2/ssl/interne.crt

# Vérifier la correspondance clé privée / certificat (les deux hash doivent être identiques)
openssl rsa -noout -modulus -in /etc/apache2/ssl/interne.key | openssl md5
openssl x509 -noout -modulus -in /etc/apache2/ssl/interne.crt | openssl md5
```

**Résultat attendu :**
```
MD5(stdin)= 630f51ddb5272ea346e02de6dbc7083f
MD5(stdin)= 630f51ddb5272ea346e02de6dbc7083f
```

---

### Etape 4 - Configuration du VirtualHost Apache (HTTP + HTTPS)

```bash
sudo nano /etc/apache2/sites-available/interne.conf
```

```apache
<VirtualHost *:80>
    ServerName interne.BillU.lan
    DocumentRoot /var/www/html

    # Redirection automatique vers HTTPS
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

    ErrorLog ${APACHE_LOG_DIR}/interne_error.log
    CustomLog ${APACHE_LOG_DIR}/interne_access.log combined
</VirtualHost>

<VirtualHost *:443>
    ServerName interne.BillU.lan
    DocumentRoot /var/www/html

    SSLEngine on
    SSLCertificateFile /etc/apache2/ssl/interne.crt
    SSLCertificateKeyFile /etc/apache2/ssl/interne.key

    ErrorLog ${APACHE_LOG_DIR}/interne_ssl_error.log
    CustomLog ${APACHE_LOG_DIR}/interne_ssl_access.log combined
</VirtualHost>
```

```bash
# Activer les modules et le site
sudo a2enmod ssl rewrite
sudo a2ensite interne.conf
sudo a2dissite 000-default.conf

# Vérifier la syntaxe et redémarrer
sudo apache2ctl configtest
sudo systemctl restart apache2
```
---

### Etape 5 - Vérification finale

**Vérification côté serveur :**
```bash
curl -v http://interne.BillU.lan/ 2>&1 | grep "HTTP\|Location"
echo | openssl s_client -connect interne.BillU.lan:443 -servername interne.BillU.lan 2>/dev/null | openssl x509 -noout -subject -issuer -dates
```

**Résultat attendu :**
```
HTTP/1.1 301 Moved Permanently
Location: https://interne.BillU.lan/

subject=C=FR, O=BillU, CN=interne.BillU.lan
issuer=DC=lan, DC=BillU, CN=BillU-CA
notBefore=Jun 17 17:30:54 2026 GMT
notAfter=Jun 16 17:30:54 2028 GMT
```

**Vérification navigateur :**

Depuis un poste Windows joint au domaine, ouvrir `https://interne.BillU.lan` — le cadenas doit être fermé sans aucune alerte de sécurité.

---

### Récapitulatif des services sécurisés

| Serveur | Zone | URL | Certificat | Redirection HTTP→HTTPS |
|---|---|---|---|---|
| Intranet | LAN | `https://interne.BillU.lan` | `BillU-CA` | ✅ |
| Vitrine | DMZ | `https://www.BillU.lan` | `BillU-CA` | ✅ |
| Webmail | DMZ | `https://mail.BillU.lan/mail` | `BillU-CA` | — |
| GLPI | LAN | `https://glpi.BillU.lan` | `BillU-CA` | ✅ |

---

## 5. Cas particulier : serveurs en DMZ

Les serveurs en DMZ ne peuvent pas accéder directement à `/certsrv` par défaut, car la règle **"Deny All DMZ > LAN"** bloque l'ensemble du trafic entre les deux zones.

Des règles **spécifiques et restrictives** doivent être ajoutées dans pfSense pour autoriser uniquement les flux nécessaires :

| Source | Destination | Port | Protocole | Justification |
|---|---|---|---|---|
| IP serveur DMZ | `172.16.130.253` | 53 | TCP/UDP | Résolution DNS interne |
| IP serveur DMZ | `172.16.130.253` | 80 | TCP | Accès à `/certsrv` |

Ces règles doivent être placées **avant** la règle "Deny All DMZ > LAN" dans l'ordre d'évaluation pfSense.

**Vérification de la connectivité depuis le serveur DMZ :**
```bash
nslookup BV-100-101.BillU.lan
curl -v http://BV-100-101.BillU.lan/certsrv 2>&1 | head -5
```

**Résultat attendu :**
```
Server: 172.16.130.253
HTTP/1.1 401 Unauthorized
Server: Microsoft-IIS/10.0
```

---

### Résultat

| Elément | Avant | Après |
|---|---|---|
| Protocole des échanges | HTTP (clair) | HTTPS (chiffré TLS 1.2/1.3) |
| Certificat | Absent ou auto-signé (alerte navigateur) | Signé par `BillU-CA` (confiance automatique) |
| Distribution de la confiance | Manuelle (import poste par poste) | Automatique via GPO (Enterprise CA) |
| Visibilité des identifiants sur le réseau | En clair (interceptable) | Chiffrés (non lisibles) |
| Redirection HTTP → HTTPS | Absente | Active (301 Permanent) |
