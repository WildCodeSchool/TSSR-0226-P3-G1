# Audit de sécurité sur l'infrastructure BillU.lan

- [**1. Objectifs**](#1-objectifs)
- [**2. Mise en place de mesure de sécurité**](#2-mise-en-place-de-mesure-de-sécurité)
- [**3. Audit de l'infrastructure existante**](#3-audit-de-linfrastructure-existante)
- [**4.Tests de pénétration**](#4-tests-de-pénétration)

# 1. Objectifs

L'objectif de cet audit de l'infrastructure `BillU.lan` est de scanner le domaine pour vérifier les failles de sécurité présente et les améliorer.
Plusieurs outils seront installés et utilisés, vous pouvez les retrouvers dans [configuration.md](configuration.md) et [installation.md](installation.md).

# 2. Mise en place de mesure de sécurité

Avant de faire l'audit, nous avons mis en place les mesures de sécurités suivante : 

- Restreindre les connexions des utilisateurs standard aux plages horaires autorisées, tout en permettant le bypass pour les administrateurs.
- Limiter ou désactiver la collecte de données télémétriques sur les postes clients Windows
- Déployer Microsoft LAPS pour gérer automatiquement les mots de passe des comptes administrateurs locaux sur les clients
- Automatiser le déplacement des ordinateurs dans les bonnes OU de l'Active Directory en fonction de critères définis
- Mettre en place une autorité de certification interne et l'utiliser pour signer des scripts et/ou des sites web
- Mettre en place un serveur FreeRADIUS pour créer un portail captif avec authentification et restrictions par groupe AD

# 3. Audit de l'infrastructure existante

Pour réaliser l'audit, nous allons utiliser plusieurs logiciels : 

- **AUDIT SERVEURS WINDOWS** - Utilisation de la suite logiciel SYSINTERNAL
- **AUDIT GLPI** - Utilisation de Glpwnme
- **AUDIT SERVEUR WEB** - Utilisation de Nikto
- **AUDIT SERVEURS LINUX** - Utilisation de Lynis
- **AUDIT ACTIVE DIRECTORY** - Utilisation de PingCastle, PurpleKnight et HardenSysvol

| Étape | Score PingCastle |        
|-------|----------------|
| Audit initial | 50 / 100 |        
| Audit final | 20 / 100 | 

| Étape | Score PurpleKnight |
|-------|----------------|
| Audit initial | 88 / 100 |
| Audit final | 92 / 100 | 


# 4. Tests de pénétration

Et enfin pour finir, nous avons testé des attaques et des défenses sur notre infra après avoir améliorer nos scores donnés par les audits.
- Scan de port avec NMAP
- Exploitation SMB avec MetaSploit
- Phishing / Spear Phishing avec GoPhish
- Déni de service avec hping3
