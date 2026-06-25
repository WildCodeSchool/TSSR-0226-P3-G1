
# Projet BillU - Serveur VoIP FreePBX

## Présentation

Ce document présente la mise en place du service de téléphonie sur IP pour le projet **BillU**.

Le serveur VoIP est basé sur **FreePBX** et permet aux utilisateurs de l’entreprise de communiquer entre eux via des extensions SIP/PJSIP.  
Les postes clients utilisent le logiciel **3CX Phone** comme client VoIP.

## Objectifs

Les objectifs du sprint VoIP étaient les suivants :

- Mettre en place un serveur de téléphonie sur IP.
    
- Utiliser la solution **FreePBX**.
    
- Créer des lignes VoIP pour les utilisateurs.
    
- Automatiser la création des extensions depuis un export Active Directory.
    
- Installer le client **3CX Phone** sur les postes utilisateurs via GPO.
    
- Tester la communication téléphonique entre deux clients.
    

## Infrastructure

| Élément         | Valeur           |
| --------------- | ---------------- |
| Solution VoIP   | FreePBX          |
| Nom de la VM    | ServFreePBX      |
| Nom machine     | BV-130-156       |
| Hyperviseur     | Proxmox          |
| Réseau          | DMZ              |
| Bridge Proxmox  | vmbr105          |
| Adresse IP      | 172.16.130.30/24 |
| Nom DNS         | pbx.billu.lan    |
| Port SIP        | UDP 5060         |
| Ports RTP audio | UDP 10000-20000  |
| Client VoIP     | 3CX Phone        |

## Fonctionnement général

Le serveur FreePBX est placé dans la DMZ.  
Les postes clients du réseau LAN se connectent au serveur VoIP via le nom DNS interne :

```text
pbx.billu.lan
```

Les utilisateurs Active Directory ont été exportés dans un fichier CSV.  
Un script sur FreePBX permet ensuite de générer automatiquement :

- un numéro d’extension ;
    
- un nom d’affichage ;
    
- un secret SIP ;
    
- un fichier d’import FreePBX.
    

Les extensions sont ensuite importées dans FreePBX et configurées en **PJSIP**.

## Résultat obtenu

Les extensions ont été créées automatiquement dans FreePBX.

Exemples :

|Utilisateur AD|Extension|Nom|
|---|--:|---|
|rmartinez|1254|Martinez Rafaella|
|sandersson|1256|Andersson Sven|

Les clients 3CX ont été installés sur les postes utilisateurs via une GPO ordinateur.

Test réalisé :

```text
1254 appelle 1256
1256 sonne
Communication audio validée
```

## Fichiers importants sur FreePBX

|Fichier|Rôle|
|---|---|
|/root/freepbx_voip_map.csv|Correspondance utilisateur AD / extension|
|/root/freepbx_sip_secrets.csv|Secrets SIP des extensions|
|/root/extensions_import-fixed.csv|Fichier d’import utilisé pour FreePBX|
|/root/Script|Script de génération des extensions|

## Sécurité

Le fichier suivant contient des secrets SIP et ne doit pas être publié sur GitHub :

```text
/root/freepbx_sip_secrets.csv
```

Les mots de passe et secrets doivent être conservés dans un gestionnaire de mots de passe sécurisé.

## Commandes utiles

Afficher les endpoints PJSIP :

```bash
asterisk -rx "pjsip show endpoints"
```

Afficher les clients connectés :

```bash
asterisk -rx "pjsip show contacts"
```

Vérifier une extension précise :

```bash
asterisk -rx "pjsip show endpoint 1256"
```

Recharger FreePBX :

```bash
fwconsole reload
```

Redémarrer FreePBX/Asterisk :

```bash
fwconsole restart
```

## Validation

Le service VoIP est opérationnel lorsque :

- le serveur FreePBX est joignable ;
    
- le DNS `pbx.billu.lan` résout vers 172.16.130.30 ;
    
- les extensions sont visibles dans FreePBX ;
    
- les extensions apparaissent en PJSIP ;
    
- les clients 3CX s’enregistrent correctement ;
    
- un appel entre deux postes clients fonctionne.
