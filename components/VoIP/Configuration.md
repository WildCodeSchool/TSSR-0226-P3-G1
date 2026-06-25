# Configuration du serveur VoIP FreePBX

## 1. Configuration réseau

Le serveur FreePBX est placé dans la DMZ.

| Élément                | Valeur           |
| ---------------------- | ---------------- |
| Nom de la VM           | ServFreePBX      |
| Machine                | BV-130-156       |
| Usage                  | Serveur VoIP     |
| Interface réseau       | eth0             |
| Bridge Proxmox         | vmbr105          |
| Adresse IP             | 172.16.130.30/24 |
| Passerelle             | 10.0.3.1         |
| DNS interne            | 172.16.130.253   |
| DNS externe secondaire | 8.8.8.8          |

Configuration IP vérifiée avec :

```bash
ip a
ip route
cat /etc/resolv.conf
```

Résultat attendu :

```text
IP FreePBX : 172.16.130.30/24
Route par défaut : 10.0.3.1
DNS : 172.16.130.253
```

## 2. Enregistrement DNS

Un enregistrement DNS de type A a été créé dans la zone interne `billu.lan`.

| Nom | Type | IP            |
| --- | ---- | ------------- |
| pbx | A    | 172.16.130.30 |

Nom complet :

```text
pbx.billu.lan
```

Test depuis un poste client :

```powershell
nslookup pbx.billu.lan
ping pbx.billu.lan
```

Résultat attendu :

```text
pbx.billu.lan -> 172.16.130.30
```

## 3. Configuration pfSense

Le serveur FreePBX étant dans la DMZ, des règles pfSense ont été nécessaires pour autoriser les flux depuis le LAN vers la DMZ.

### Règles LAN vers FreePBX

| Flux | Source              | Destination                 | Port            |
| ---- | ------------------- | --------------------------- | --------------- |
| SIP  | LAN / 172.16.0.0/17 | PBX_FREEPBX / 172.16.130.30 | UDP 5060        |
| RTP  | LAN / 172.16.0.0/17 | PBX_FREEPBX / 172.16.130.30 | UDP 10000-20000 |
| Web  | PC Admin            | PBX_FREEPBX / 172.16.130.30 | TCP 80/443      |
| SSH  | PC Admin            | PBX_FREEPBX / 172.16.130.30 | TCP 22          |

Alias utilisé :

```text
PBX_FREEPBX = 172.16.130.30
```

Les règles doivent être placées au-dessus du Deny All.

## 4. Configuration SIP FreePBX

Dans FreePBX :

```text
Settings > Asterisk SIP Settings
```

Réseaux locaux configurés :

```text
172.16.0.0 / 24
172.16.0.0 / 17
172.16.128.0 / 17 si nécessaire
```

RTP :

```text
Start : 10000
End   : 20000
```

Transport SIP utilisé :

```text
UDP 5060
```

## 5. Création des extensions depuis l’AD

Les utilisateurs Active Directory sont exportés dans un fichier CSV :

```text
UtilisateursVoIP.csv
```

Le fichier est récupéré sur FreePBX via un partage SMB.

Commande utilisée :

```bash
smbclient //172.16.130.253/mail -A /root/.smbcredentials -c "get UtilisateursVoIP.csv /mnt/ad/UtilisateursVoIP.csv"
```

Le script de génération lit ce fichier et crée :

```text
/root/freepbx_voip_map.csv
/root/freepbx_sip_secrets.csv
/root/extensions_import.csv
```

Après correction, le fichier utilisé pour l’import final est :

```text
/root/extensions_import-fixed.csv
```

## 6. Correction PJSIP

Après l’import, les extensions avaient été importées avec le driver :

```text
chan_sip
```

Elles ont été corrigées en :

```text
chan_pjsip
```

Commande SQL utilisée :

```bash
mysql -u root asterisk -e "UPDATE sip SET data='chan_pjsip' WHERE keyword='sipdriver' AND id REGEXP '^[0-9]+$' AND CAST(id AS UNSIGNED) BETWEEN 1101 AND 1290;"
```

Vérification :

```bash
mysql -u root asterisk -e "SELECT id,keyword,data FROM sip WHERE id IN ('1101','1102','1103') AND keyword='sipdriver';"
```

Résultat attendu :

```text
1101 | sipdriver | chan_pjsip
1102 | sipdriver | chan_pjsip
1103 | sipdriver | chan_pjsip
```

Puis rechargement :

```bash
fwconsole reload
fwconsole restart
```

## 7. Vérification des extensions

Vérifier qu’une extension existe en PJSIP :

```bash
asterisk -rx "pjsip show endpoint 1256"
```

Vérifier les contacts connectés :

```bash
asterisk -rx "pjsip show contacts"
```

Exemple attendu quand 3CX est connecté :

```text
1256/sip:1256@172.16.0.4:xxxxx
```

## 8. Configuration 3CX sur les postes clients

Exemple pour l’utilisateur `sandersson` :

| Champ        | Valeur                         |
| ------------ | ------------------------------ |
| Account name | sandersson                     |
| Caller ID    | Andersson Sven                 |
| Extension    | 1256                           |
| ID           | 1256                           |
| Password     | Secret SIP de l’extension      |
| PBX local IP | 172.16.130.30 ou pbx.billu.lan |
| Transport    | UDP                            |

Options avancées :

```text
STUN server : vide
Use 3CX Tunnel : décoché
Outbound Proxy : décoché
SIP transport : UDP
RTP mode : Normal
```

## 9. GPO d’installation 3CX

La GPO utilisée est :

```text
Computer-3cx-Install
```

Elle est liée à l’OU :

```text
BU_Computers
```

Le package MSI est déployé dans :

```text
Computer Configuration
 > Policies
  > Software Settings
   > Software installation
```

La source du package doit être un chemin UNC :

```text
\\BillU.lan\SYSVOL\BillU.lan\install\3CXPhone6.msi
```

Ne pas utiliser de chemin local de type :

```text
C:\Windows\SYSVOL\...
```

## 10. Tests de diagnostic

Tester si le serveur reçoit les paquets SIP :

```bash
tcpdump -ni any udp port 5060
```

Tester depuis un poste Windows :

```powershell
$udp = New-Object System.Net.Sockets.UdpClient
$bytes = [Text.Encoding]::ASCII.GetBytes("test")
$udp.Send($bytes, $bytes.Length, "172.16.130.30", 5060)
$udp.Close()
```

Voir les logs SIP :

```bash
asterisk -rvvv
pjsip set logger on
```

## 11. Points de sécurité

Ne jamais publier sur GitHub :

```text
/root/freepbx_sip_secrets.csv
/root/.smbcredentials
```

Ces fichiers contiennent des informations sensibles.
