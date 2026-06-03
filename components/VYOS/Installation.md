
# Installation des routeurs VyOS

## Objectif

Cette documentation décrit les étapes nécessaires au déploiement de l'infrastructure de routage BillU sous Proxmox.

L'architecture repose sur trois routeurs VyOS :

- R1 : Routeur cœur de réseau
    
- R2 : Routeur du réseau Développement
    
- R3 : Routeur du réseau Serveurs
    

Cette documentation couvre uniquement le déploiement des machines virtuelles et le raccordement des interfaces réseau. La configuration IP et le routage sont détaillés dans le fichier `configuration.md`.

---

# Prérequis

Avant de commencer, les éléments suivants doivent être disponibles :

- Serveur Proxmox opérationnel
    
- Template VyOS 1.5 installé
    
- Stockage disponible
    
- Bridges réseau créés
    
- Accès administrateur à Proxmox
    

---

# Architecture réseau

## Bridges Proxmox

|Bridge|Réseau|Description|
|---|---|---|
|vmbr100|10.0.2.0/24|LAN BillU|
|vmbr101|10.0.1.0/30|Liaison R1 ↔ R2|
|vmbr102|10.0.0.0/30|Liaison R1 ↔ R3|
|vmbr103|172.16.0.0/17|Réseau Développement|
|vmbr104|172.16.128.0/17|Réseau Serveurs|

---

# Déploiement des machines virtuelles

## Paramètres communs

Les trois routeurs utilisent les paramètres suivants :

|Paramètre|Valeur|
|---|---|
|Système|VyOS 1.5|
|BIOS|SeaBIOS|
|Machine|i440fx|
|CPU|2 vCPU|
|Mémoire|1 Go|
|Disque|4 Go|
|Contrôleur SCSI|VirtIO SCSI Single|
|Carte réseau|E1000|

---

# Routeur R1 - Cœur de réseau

## Création de la VM

|Paramètre|Valeur|
|---|---|
|Nom|G1-VYOS-R1|
|Rôle|Routeur cœur de réseau|

## Interfaces réseau

|Interface|Bridge|Description|
|---|---|---|
|net0|vmbr100|LAN BillU|
|net1|vmbr101|Liaison vers R2|
|net2|vmbr102|Liaison vers R3|

---

# Routeur R2 - Réseau Développement

## Création de la VM

|Paramètre|Valeur|
|---|---|
|Nom|G1-VYOS-R2|
|Rôle|Réseau Développement|

## Interfaces réseau

|Interface|Bridge|Description|
|---|---|---|
|net0|vmbr101|Liaison vers R1|
|net1|vmbr103|Réseau Développement|

---

# Routeur R3 - Réseau Serveurs

## Création de la VM

|Paramètre|Valeur|
|---|---|
|Nom|G1-VYOS-R3|
|Rôle|Réseau Serveurs|

## Interfaces réseau

|Interface|Bridge|Description|
|---|---|---|
|net0|vmbr102|Liaison vers R1|
|net1|vmbr104|Réseau Serveurs|

---

# Premier démarrage

Démarrer les trois machines virtuelles depuis Proxmox.

## Identifiants par défaut

```text
Utilisateur : vyos
Mot de passe : vyos
```

---

# Vérification des interfaces

Après le démarrage de chaque routeur, vérifier que les interfaces sont correctement détectées :

```bash
show interfaces
```

Résultat attendu :

### R1

```text
eth0
eth1
eth2
```

### R2

```text
eth0
eth1
```

### R3

```text
eth0
eth1
```

---

# Sauvegarde de la configuration

Après chaque modification, exécuter :

```bash
commit
save
```

## Exemple

```bash
configure

set interfaces ethernet eth0 description "LAN"

commit
save
```

Sans la commande :

```bash
save
```

la configuration sera perdue après redémarrage.

---

# Vérifications Proxmox

Depuis l'interface Proxmox :

```text
Datacenter
└── VM
    └── Hardware
```

Vérifier :

- Présence des cartes réseau
    
- Bridge associé à chaque interface
    
- Type E1000
    
- Adresse MAC générée
    

---
# Étapes suivantes

Une fois les trois routeurs VyOS déployés, les interfaces réseau raccordées et leur présence vérifiée, l'installation de l'infrastructure est terminée.

Les étapes suivantes concernent la configuration du réseau et du routage. Afin de séparer clairement l'installation de la configuration, ces opérations sont détaillées dans le document **configuration.md**.

Le fichier **configuration.md** décrit notamment :

- La configuration des adresses IP sur chaque interface.
    
- La configuration des routes statiques sur R1, R2 et R3.
    
- Les commandes de sauvegarde de la configuration.
    
- Les tests de connectivité entre les différents réseaux.
    
- La validation du routage.
    
- Les procédures de dépannage en cas de problème.
    

## Ordre recommandé

1. Création des bridges Proxmox.
    
2. Déploiement des routeurs VyOS.
    
3. Ajout des interfaces réseau.
    
4. Vérification des interfaces détectées par VyOS.
    
5. Consultation du document **configuration.md**.
    
6. Configuration des adresses IP.
    
7. Configuration des routes statiques.
    
8. Tests de connectivité.
    
9. Validation du routage.
    

L'ensemble des commandes et des configurations nécessaires aux étapes 6 à 9 est disponible dans le document **configuration.md**.


L'ensemble des commandes et des configurations nécessaires aux étapes 6 à 9 est disponible dans le document **configuration.md**.
---

# Dépannage

## Interface absente

Vérifier dans Proxmox :

```text
VM
└── Hardware
    └── Network Device
```

Vérifier également :

```bash
show interfaces
```

---

## Interface Down

Vérifier :

- Bridge associé
    
- État de la VM
    
- Configuration réseau Proxmox
    

---

## Configuration perdue après redémarrage

Vérifier que les commandes suivantes ont été exécutées :

```bash
commit
save
```

---

# Conclusion

Les trois routeurs VyOS sont maintenant déployés et raccordés aux différents réseaux de l'infrastructure BillU. La prochaine étape consiste à configurer les adresses IP et les routes statiques décrites dans le document `configuration.md`.
