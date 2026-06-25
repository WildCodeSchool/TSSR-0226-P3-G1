# Installation du serveur VoIP FreePBX

## 1. Création de la VM

La VM FreePBX a été créée sur Proxmox.

| Paramètre | Valeur           |
| --------- | ---------------- |
| Nom VM    | ServFreePBX      |
| Machine   | BV-130-156       |
| Usage     | Serveur VoIP     |
| Réseau    | DMZ              |
| Bridge    | vmbr105          |
| IP finale | 172.16.130.30/24 |

Le serveur est placé dans la DMZ comme le serveur de messagerie.

## 2. Installation de FreePBX

L’installation a été réalisée avec l’ISO FreePBX.

Après installation, connexion en console avec le compte administrateur système.

Le clavier a été passé en français.

## 3. Configuration IP temporaire

La configuration réseau a été réalisée sur l’interface `eth0`.

Commandes utilisées :

```bash
ip addr add 172.16.130.30/24 dev eth0
ip route add default via 10.0.3.1 dev eth0
echo "nameserver 172.16.130.253" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
```

Tests :

```bash
ip a
ip route
ping -c 4 10.0.3.1
ping -c 4 8.8.8.8
ping -c 4 google.fr
```

## 4. Configuration réseau persistante

Après validation, la configuration réseau a été rendue persistante.

Vérification :

```bash
systemctl restart network
ip a
ip route
cat /etc/resolv.conf
```

Résultat attendu :

```text
eth1 : 172.16.130.30/24
default via 10.0.3.1
DNS : 172.16.130.253
```

## 5. Accès Web FreePBX

Depuis le poste admin :

```text
http://172.16.130.30/admin
```

ou après configuration DNS :

```text
http://pbx.billu.lan/admin
```

Un compte administrateur FreePBX a été créé lors du premier accès à l’interface.

## 6. Activation FreePBX

Lors de l’assistant de démarrage FreePBX, l’activation du serveur est proposée.

Pour le projet, l’activation commerciale n’est pas nécessaire.

Choix effectué :

```text
Skip
```

## 7. Mise à jour des modules

Les modules FreePBX ont été mis à jour avec :

```bash
fwconsole ma upgradeall
fwconsole reload
fwconsole restart
```

Certaines alertes liées aux modules commerciaux non licenciés peuvent apparaître.  
Elles ne bloquent pas le fonctionnement de base du serveur VoIP.

## 8. Activation SSH

Pour administrer le serveur depuis le poste admin :

```bash
systemctl enable sshd
systemctl start sshd
ss -tlmp | grep :22
```

Test depuis un poste Windows :

```powershell
Test-NetConnection 172.16.130.30 -Port 22
```

Résultat attendu :

```text
TcpTestSucceeded : True
```

## 9. Configuration pfSense

Des règles ont été ajoutées pour permettre l’administration et la téléphonie.

### Règles d’administration

| Source   | Destination    | Port       |
| -------- | -------------- | ---------- |
| PC Admin | 1172.16.130.30 | TCP 22     |
| PC Admin | 172.16.130.30  | TCP 80/443 |

### Règles VoIP

| Source               | Destination   | Port            |
| -------------------- | ------------- | --------------- |
| LAN / postes clients | 172.16.130.30 | UDP 5060        |
| LAN / postes clients | 172.16.130.30 | UDP 10000-20000 |

Ces règles sont créées sur l’interface où le trafic entre dans pfSense, principalement l’interface LAN pour les postes clients.

## 10. Enregistrement DNS

Sur le serveur DNS Windows :

```text
DNS Manager
 > Forward Lookup Zones
  > billu.lan
   > New Host (A)
```

Valeurs :

```text
Name : pbx
IP   : 10.0.3.30
```

Test :

```powershell
nslookup pbx.billu.lan
ping pbx.billu.lan
```

## 11. Préparation du partage SMB

Le fichier CSV des utilisateurs AD est déposé dans un partage SMB.

Partage utilisé :

```text
\\172.16.130.253\mail
```

Sur FreePBX, le fichier est récupéré avec :

```bash
smbclient //172.16.130.253/mail -A /root/.smbcredentials -c "get UtilisateursVoIP.csv /mnt/ad/UtilisateursVoIP.csv"
```

Le fichier `/root/.smbcredentials` contient les identifiants SMB.  
Il ne doit pas être publié.

## 12. Génération des extensions

Le script de génération des extensions est placé ici :

```text
/root/Script
```

Lancement :

```bash
bash /root/Script
```

Fichiers générés :

```text
/root/freepbx_voip_map.csv
/root/freepbx_sip_secrets.csv
/root/extensions_import.csv
```

Le fichier d’import corrigé est :

```text
/root/extensions_import-fixed.csv
```

## 13. Import dans FreePBX

Import des extensions :

```bash
fwconsole bulkimport --type=extensions /root/extensions_import-fixed.csv
fwconsole reload
fwconsole restart
```

Vérification dans l’interface :

```text
Applications > Extensions
```

Les extensions créées apparaissent dans la liste.

## 14. Correction du driver SIP

Après import, les extensions ont été corrigées pour utiliser PJSIP.

Commande :

```bash
mysql -u root asterisk -e "UPDATE sip SET data='chan_pjsip' WHERE keyword='sipdriver' AND id REGEXP '^[0-9]+$' AND CAST(id AS UNSIGNED) BETWEEN 1101 AND 1290;"
```

Rechargement :

```bash
fwconsole reload
fwconsole restart
```

Vérification :

```bash
asterisk -rx "pjsip show endpoint 1256"
```

## 15. Installation du client 3CX par GPO

Une GPO ordinateur a été créée :

```text
Computer-3cx-Install
```

Elle est liée à :

```text
BU_Computers
```

Le package MSI est configuré dans :

```text
Computer Configuration
 > Policies
  > Software Settings
   > Software installation
```

Chemin UNC du package :

```text
\\BillU.lan\SYSVOL\BillU.lan\install\3CXPhone6.msi
```

Sur un poste client :

```powershell
gpupdate /force
shutdown /r /t 0
```

Vérification :

```powershell
gpresult /r /scope computer
```

## 16. Configuration des clients 3CX

Exemple poste `rmartinez` :

```text
Extension : 1254
ID : 1254
PBX : 172.16.130.30
Transport : UDP
```

Exemple poste `sandersson` :

```text
Extension : 1256
ID : 1256
PBX : 172.16.130.30
Transport : UDP
```

Le mot de passe est récupéré depuis :

```bash
grep ",1256," /root/freepbx_sip_secrets.csv
```

Ce fichier contient des secrets et ne doit pas être partagé.

## 17. Tests finaux

Voir les contacts connectés :

```bash
asterisk -rx "pjsip show contacts"
```

Tester un appel :

```text
1254 appelle 1256
1256 décroche
Audio validé
```

## 18. Dépannage

Vérifier que FreePBX écoute sur le port SIP :

```bash
ss -lump | grep 5060
```

Vérifier les transports PJSIP :

```bash
asterisk -rx "pjsip show transports"
```

Capturer les paquets SIP :

```bash
tcpdump -ni any udp port 5060
```

Activer les logs PJSIP :

```bash
asterisk -rvvv
pjsip set logger on
```

Vérifier un endpoint :

```bash
asterisk -rx "pjsip show endpoint 1256"
```

## 19. Résultat

Le serveur FreePBX est installé et fonctionnel.  
Les extensions sont générées à partir de l’AD, importées dans FreePBX et utilisées par les postes clients via 3CX.

La communication entre deux postes clients a été validée.
