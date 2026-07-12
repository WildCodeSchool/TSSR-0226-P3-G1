# Audit Serveurs Linux — Lynis

Rapport d'audit de sécurité système Linux/Unix
Domaine BillU.lan — Audit Lynis
Date : 12 juillet 2026

---

## 1. Objectif du document

Ce document présente les résultats d'un audit de sécurité mené sur l'ensemble des serveurs Linux du lab, réalisé à l'aide de l'outil **Lynis** (CISOfy). L'audit couvre le durcissement système : configuration du noyau, méthodes d'authentification, logiciels installés, configuration réseau et pare-feu. Il décrit le périmètre audité, les résultats de l'audit initial, les actions correctives mises en œuvre, puis les résultats de l'audit final permettant de mesurer l'amélioration de la posture de sécurité de chaque serveur.

## 2. Périmètre de l'audit

| Serveur | Rôle | IP | Statut de l'audit |
|---|---|---|---|
| Web-Externe | Serveur web exposé sur Internet | 10.0.3.20 | Audité |
| Mail | Serveur de messagerie (Postfix) | 10.0.3.10 | Audité |
| Graylog | Centralisation de logs (MongoDB, OpenSearch) | 172.16.130.137 | Audité |
| Intranet-Password-Projet | Portail intranet, gestion de mots de passe, suivi de projet | 172.16.130.138 | Audité |
| Sauvegarde | Serveur de sauvegarde | 172.16.130.239 | Audité |
| GLPI | Gestion de parc informatique | 172.16.160.251 | Audité |

## 3. Méthodologie

### 3.1 Installation de Lynis

```bash
sudo apt install lynis -y
```
(sur FreePBX, basé sur Sangoma Linux, l'installation se ferait via `dnf`/`yum` — non applicable ici faute d'accès SSH)

### 3.2 Exécution centralisée depuis un poste d'administration Windows

Un script PowerShell a été utilisé pour lancer l'audit à distance (SSH) sur l'ensemble des serveurs, installer Lynis si absent, exécuter le scan, puis rapatrier les rapports (`lynis-report.dat` et `lynis.log`) pour analyse centralisée :

```powershell
$servers = @{
    "10.0.3.20"      = "Web-Externe"
    "172.16.130.137" = "Graylog"
    "10.0.3.10"      = "Mail"
    "172.16.130.138" = "Intranet-Password-Projet"
    "172.16.130.239" = "Sauvegarde"
    "172.16.160.251" = "GLPI"
}

foreach ($ip in $servers.Keys) {
    ssh root@$ip "if command -v apt >/dev/null; then which lynis || (apt update -qq && apt install lynis -y -qq); fi"
    ssh root@$ip "lynis audit system --quiet"
    scp root@${ip}:/var/log/lynis-report.dat "$outputDir\lynis-report-$($servers[$ip]).dat"
    scp root@${ip}:/var/log/lynis.log "$outputDir\lynis-log-$($servers[$ip]).log"
}
```

### 3.3 Consolidation des résultats

Extraction automatisée du Hardening Index et du nombre de warnings/suggestions par serveur via PowerShell (`Select-String` sur les champs `hardening_index=`, `warning[]=`, `suggestion[]=` des fichiers `.dat`).

## 4. Audit initial

### 4.1 Synthèse des scores

![warnings avant](/components/AUDIT/Ressources/premiere_synthese.png)

| Serveur | Hardening Index | Warnings | Suggestions |
|---|---|---|---|
| Mail | 66 | 3 | 53 |
| GLPI | 64 | 3 | 53 |
| Intranet-Password-Projet | 64 | 2 | 52 |
| Graylog | 63 | 3 | 49 |
| Sauvegarde | 63 | 2 | 49 |
| Web-Externe | 62 | 4 | 54 |

**Constat général** : scores homogènes (62-66/100), cohérents avec des serveurs installés sans durcissement spécifique préalable. Le serveur le plus exposé (Web-Externe, accessible depuis Internet) affiche logiquement le score le plus bas et le plus de warnings — priorité de traitement confirmée.

### 4.2 Détail des warnings identifiés

| Finding | Serveurs concernés | Sévérité | Description |
|---|---|---|---|
| **DBS-1820** | Graylog | Critique | Instance MongoDB accessible sans authentification — n'importe quel utilisateur réseau peut lire/modifier les bases de données |
| **PKGS-7392** | Les 6 serveurs | Élevé | Présence d'un ou plusieurs paquets système avec des CVE connues non corrigées |
| **NETW-2705 / NETW-2704** | Les 6 serveurs | Moyen | Résolveurs DNS configurés injoignables (dont `172.16.130.253` et `8.8.8.8` sur Web-Externe) |
| **TIME-3185** | GLPI | Faible | `systemd-timesyncd` non synchronisé récemment |
| **MAIL-8818** | Mail | Faible | Fuite d'information (nom du logiciel et version) dans la bannière SMTP |

## 5. Actions correctives mises en œuvre

### 5.1 Mise à jour des paquets système (PKGS-7392)

Mise à jour appliquée sur l'ensemble des serveurs :
```bash
apt update && apt upgrade -y
```

Conflits de configuration rencontrés et arbitrés (conservation des configurations personnalisées existantes) :
- **Postfix** (serveur Mail) : conservation de la configuration actuelle (`No configuration` à l'invite de l'assistant Postfix)
- **Zabbix Agent 2** (plusieurs serveurs) : conservation du fichier de configuration modifié (`N` à l'invite dpkg)

### 5.2 Sécurisation de MongoDB sur Graylog (DBS-1820)

**Constat** : le port MongoDB (27017) était accessible sans authentification, exposant l'intégralité des bases de données (dont celle de Graylog contenant les comptes utilisateurs et la configuration).

**Remédiation appliquée**, en 3 temps pour éviter toute interruption de service :

1. Sauvegarde préalable (`mongodump`, copie des fichiers de configuration)
2. Création d'un compte administrateur MongoDB (`admin`, rôle `root`) et d'un compte applicatif dédié (`graylog`, rôle `readWrite` limité à la base `graylog`)
3. Activation de l'authentification (`security.authorization: enabled` dans `/etc/mongod.conf`) **après** avoir renseigné les nouveaux identifiants dans **les deux fichiers de configuration Graylog concernés** : `/etc/graylog/server/server.conf` **et** `/etc/graylog/datanode/datanode.conf` (le composant Datanode, qui embarque OpenSearch, dispose de sa propre chaîne de connexion MongoDB, distincte du serveur principal — point de configuration facilement oublié)

**Vérification** :
```bash
# Sans identifiants — doit échouer
mongosh --eval "db.adminCommand('listDatabases')"
# → MongoServerError: Command listDatabases requires authentication

# Avec identifiants — doit réussir
mongosh -u admin -p '********' --authenticationDatabase admin --eval "db.adminCommand('listDatabases')"
# → Liste des 4 bases retournée avec succès
```

Non-régression confirmée : service Graylog opérationnel après redémarrage, interface web accessible, inputs de collecte de logs (Beats, Syslog UDP, Syslog SNORT) repassés en état `RUNNING`.

### 5.3 Correction de la désynchronisation NTP sur GLPI (TIME-3185)

**Investigation** : le contrôleur de domaine (source de temps de référence, `172.16.130.253`) fonctionnait en mode `Free-running System Clock` (Stratum 1 local, `Root Dispersion: 10.0000000s`) — fiabilité insuffisante pour que `systemd-timesyncd` accepte la synchronisation, bien que le port NTP (UDP/123) du DC ait été confirmé ouvert et fonctionnel (`ntpdate -q` réussi).

**Cause racine** : le trafic NTP sortant (UDP/123) du contrôleur de domaine vers Internet était bloqué par le pare-feu périmétrique (pfSense).

**Remédiation appliquée** :

1. Création d'une règle pfSense (Firewall → Rules) autorisant le trafic UDP/123 sortant depuis l'IP du DC vers Internet
2. Configuration de W32Time sur le DC pour synchroniser sur des pools NTP externes fiables :
```powershell
w32tm /config /manualpeerlist:"0.fr.pool.ntp.org,0x8 1.fr.pool.ntp.org,0x8 time.windows.com,0x8" /syncfromflags:manual /reliable:yes /update
Restart-Service w32time
w32tm /resync /force
```
3. Attente de plusieurs cycles de synchronisation pour stabilisation du Root Dispersion (Stratum passé de 1 à 2)
4. Redémarrage de `systemd-timesyncd` sur GLPI

**Vérification finale** :
```
System clock synchronized: yes
NTP service: active
```

**Bénéfice induit** : cette correction améliore également la fiabilité du protocole Kerberos pour l'ensemble du domaine (sensible aux écarts d'horloge), au-delà du seul périmètre GLPI.

### 5.4 Masquage de la bannière SMTP (MAIL-8818)

**Constat** : la bannière SMTP exposait le nom du logiciel (Postfix) via la variable `$mail_name`, facilitant le ciblage d'exploits connus par un attaquant.

**Remédiation** :
```bash
postconf -e "smtpd_banner = \$myhostname ESMTP"
systemctl restart postfix
```

**Vérification** :
```bash
telnet localhost 25
# 220 mail.billu.lan ESMTP
```
Bannière ne révélant plus que le hostname, sans nom de logiciel ni version.

### 5.5 Redémarrage des systèmes (KRNL-5830)

Redémarrage planifié de l'ensemble des serveurs afin d'appliquer pleinement les mises à jour (notamment noyau) installées lors de l'étape 5.1.

## 6. Audit final

### 6.1 Synthèse des scores après correctifs

![warnings apres](/components/AUDIT/Ressources/derniere_synthese.png)

| Serveur | Hardening Index (avant → après) | Warnings (avant → après) |
|---|---|---|
| GLPI | 64 → 64 | 3 → **1** |
| Graylog | 63 → 63 | 3 → **1** |
| Intranet-Password-Projet | 64 → 64 | 2 → **1** |
| Mail | 66 → 66 | 3 → **1** |
| Sauvegarde | 63 → 61 | 2 → 2 |
| Web-Externe | 62 → 62 | 4 → **3** |

### 6.2 Warnings restants après remédiation

| Serveur | Warning restant | Statut |
|---|---|---|
| GLPI | NETW-2705 (DNS) | Non traité — hors périmètre de cette itération |
| Graylog | NETW-2705 (DNS) | Non traité — hors périmètre de cette itération |
| Intranet-Password-Projet | NETW-2705 (DNS) | Non traité — hors périmètre de cette itération |
| Mail | NETW-2705 (DNS) | Non traité — hors périmètre de cette itération |
| Sauvegarde | KRNL-5830 + NETW-2705 | Reboot à confirmer (uptime à vérifier) + DNS non traité |
| Web-Externe | NETW-2704 (x2) + NETW-2705 | Non traité — hors périmètre de cette itération |

**Constat** : l'intégralité des findings traités lors de cette campagne (MongoDB, paquets vulnérables, NTP, bannière SMTP, redémarrage) ont été corrigés avec succès et vérifiés. Seul le sujet DNS (résolveurs injoignables) reste ouvert, ainsi qu'un point de vérification sur le serveur Sauvegarde.

## 7. Synthèse comparative

L'ensemble des actions correctives a permis de réduire le nombre de warnings de sécurité de **17 à 9** sur les 6 serveurs audités (soit une réduction d'environ 47 %), avec l'élimination complète de la vulnérabilité la plus critique (accès MongoDB non authentifié sur Graylog). Les Hardening Index restent globalement stables, la marge de progression restante étant désormais concentrée sur la résolution DNS, un sujet transverse identifié mais volontairement mis de côté dans le cadre de cette itération.

## 8. Points en suspens

| Point | Détail | Action recommandée |
|---|---|---|
| **Résolution DNS (NETW-2705/2704)** | 2 résolveurs injoignables sur l'ensemble des serveurs, dont un pointant vers `172.16.130.253` (IP du DC) | Fiabiliser la configuration DNS des serveurs Linux, vérifier le routage entre sous-réseaux (`10.0.3.x` / `172.16.130.x` / `172.16.160.x`) |
