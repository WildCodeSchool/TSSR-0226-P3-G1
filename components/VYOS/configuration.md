# Configuration du routage - Projet BillU

## Objectif

Cette documentation décrit la configuration des interfaces réseau et du routage statique entre les différents réseaux de l'infrastructure BillU.

L'architecture repose sur trois routeurs VyOS :

* R1 : Routeur cœur de réseau
* R2 : Réseau Développement
* R3 : Réseau Serveurs

Le routage est assuré à l'aide de routes statiques.

---

# Architecture réseau

## Réseaux utilisés

| Bridge  | Réseau          | Description          |
| ------- | --------------- | -------------------- |
| vmbr100 | 10.0.2.0/24     | LAN BillU            |
| vmbr101 | 10.0.1.0/30     | Liaison R1 ↔ R2      |
| vmbr102 | 10.0.0.0/30     | Liaison R1 ↔ R3      |
| vmbr103 | 172.16.0.0/17   | Réseau Développement |
| vmbr104 | 172.16.160.251/17 | Réseau Serveurs      |

---

# Étape 1 - Configuration des interfaces

## Routeur R1 - Cœur de réseau

### Configuration IP

```bash
configure

set interfaces ethernet eth0 address 10.0.2.2/24
set interfaces ethernet eth1 address 10.0.1.1/30
set interfaces ethernet eth2 address 10.0.0.1/30

commit
save
```

### Description des interfaces

| Interface | Réseau          |
| --------- | --------------- |
| eth0      | LAN BillU       |
| eth1      | Liaison vers R2 |
| eth2      | Liaison vers R3 |

---

## Routeur R2 - Réseau Développement

### Configuration IP

```bash
configure

set interfaces ethernet eth0 address 10.0.1.2/30
set interfaces ethernet eth1 address 172.16.127.254/17

commit
save
```

### Description des interfaces

| Interface | Réseau               |
| --------- | -------------------- |
| eth0      | Liaison vers R1      |
| eth1      | Réseau Développement |

---

## Routeur R3 - Réseau Serveurs

### Configuration IP

```bash
configure

set interfaces ethernet eth3 address 172.16.128.1/17
set interfaces ethernet eth4 address 10.0.0.2/30

commit
save
```

### Description des interfaces

| Interface | Réseau          |
| --------- | --------------- |
| eth4      | Liaison vers R1 |
| eth3      | Réseau Serveurs |

---

# Étape 2 - Configuration des routes statiques

## Routeur R1

### Routes configurées

```bash
configure

set protocols static route 172.16.0.0/17 next-hop 10.0.1.2
set protocols static route 172.16.128.0/17 next-hop 10.0.0.2

commit
save
```

### Explication

* Le réseau Développement est accessible via R2.
* Le réseau Serveurs est accessible via R3.

---

## Routeur R2

### Route configurée

```bash
configure

set protocols static route 172.16.128.0/17 next-hop 10.0.1.1

commit
save
```

### Explication

Le trafic destiné au réseau Serveurs est envoyé vers R1.

---

## Routeur R3

### Route configurée

```bash
configure

set protocols static route 172.16.0.0/17 next-hop 10.0.0.1

commit
save
```

### Explication

Le trafic destiné au réseau Développement est envoyé vers R1.

---
# Étape 3 - Configuration du DHCP Relay

## Objectif

Le DHCP Relay permet aux postes clients situés sur un réseau différent de celui du serveur DHCP d'obtenir automatiquement une adresse IP.

Le serveur DHCP utilisé dans l'infrastructure BillU possède l'adresse :

```text
172.16.130.253
```

---

## Routeur R1

### Configuration

```bash
configure

set service dhcp-relay listen-interface eth1
set service dhcp-relay upstream-interface eth2
set service dhcp-relay server 172.16.130.253

commit
save
```

### Explication

| Paramètre               | Description                                                   |
| ----------------------- | ------------------------------------------------------------- |
| listen-interface eth1   | Réception des requêtes DHCP provenant du réseau Développement |
| upstream-interface eth2 | Envoi des requêtes vers le réseau Serveurs                    |
| server 172.16.130.253   | Adresse du serveur DHCP                                       |

---

## Routeur R2

### Configuration

```bash
configure

set service dhcp-relay listen-interface eth1
set service dhcp-relay upstream-interface eth0
set service dhcp-relay server 172.16.130.253

commit
save
```

### Explication

| Paramètre               | Description             |
| ----------------------- | ----------------------- |
| listen-interface eth1   | Réseau Développement    |
| upstream-interface eth0 | Liaison vers R1         |
| server 172.16.130.253   | Adresse du serveur DHCP |

---

## Routeur R3

### Configuration

```bash
configure

set service dhcp-relay listen-interface eth4
set service dhcp-relay upstream-interface eth3
set service dhcp-relay server 172.16.130.253

commit
save
```

### Explication

| Paramètre               | Description                 |
| ----------------------- | --------------------------- |
| listen-interface eth4   | Réception des requêtes DHCP |
| upstream-interface eth3 | Réseau Serveurs             |
| server 172.16.130.253   | Adresse du serveur DHCP     |

---

## Vérification

Afficher la configuration DHCP Relay :

```bash
show configuration commands | match dhcp-relay
```

Résultat attendu :

```text
set service dhcp-relay listen-interface ...
set service dhcp-relay upstream-interface ...
set service dhcp-relay server 172.16.130.253
```

---

## Dépannage

### Ancienne configuration détectée

Si l'erreur suivante apparaît :

```text
DHCP relay interface is DEPRECATED
```

Supprimer l'ancienne configuration :

```bash
configure

delete service dhcp-relay

commit
save
```

Puis recréer la configuration avec :

```bash
set service dhcp-relay listen-interface ...
set service dhcp-relay upstream-interface ...
set service dhcp-relay server ...
```

### Vérification du service

```bash
show service dhcp-relay
```

### Vérification de la connectivité

```bash
ping 172.16.130.253
```

Le serveur DHCP doit être joignable depuis les routeurs.



# Étape 4 - Sauvegarde de la configuration

Après chaque modification :

```bash
commit
save
```

Sans la commande :

```bash
save
```

la configuration sera perdue après redémarrage du routeur.

---

# Étape 5 - Vérification du routage

## Vérification des interfaces

```bash
show interfaces
```

Vérifier que toutes les interfaces sont présentes et possèdent la bonne adresse IP.

---

## Vérification des routes

```bash
show ip route
```

Résultat attendu :

### R1

```text
172.16.0.0/17      via 10.0.1.2
172.16.128.0/17    via 10.0.0.2
```

### R2

```text
172.16.128.0/17    via 10.0.1.1
```

### R3

```text
172.16.0.0/17      via 10.0.0.1
```

---

# Étape 6 - Tests de connectivité

## Tests depuis R2

### Vérification du lien vers R1

```bash
ping 10.0.1.1
```

### Vérification de l'accès au réseau Serveurs

```bash
ping 172.16.128.1
```

---

## Tests depuis R3

### Vérification du lien vers R1

```bash
ping 10.0.0.1
```

### Vérification de l'accès au réseau Développement

```bash
ping 172.16.127.254
```

---

# Étape 7 - Validation

Le routage est considéré comme opérationnel lorsque :

* R1 communique avec R2.
* R1 communique avec R3.
* R2 atteint le réseau Serveurs.
* R3 atteint le réseau Développement.
* Les routes statiques apparaissent dans la table de routage.
* Les interfaces sont actives.

---

# Dépannage

## Vérifier les interfaces

```bash
show interfaces
```

---

## Vérifier les routes

```bash
show ip route
```

---

## Vérifier la configuration complète

```bash
show configuration commands
```

---

## Vérifier la connectivité

```bash
ping <adresse_ip>
```

---

## Vérifier que la configuration est sauvegardée

```bash
show configuration
```

Si la configuration disparaît après redémarrage, exécuter :

```bash
commit
save
```

---

# Conclusion

L'infrastructure de routage BillU repose sur trois routeurs VyOS utilisant des routes statiques. Le routeur R1 joue le rôle de cœur de réseau et centralise les communications entre le réseau Développement et le réseau Serveurs. Cette architecture constitue la base de l'évolution future du projet avec l'intégration d'une DMZ, d'un bastion d'administration et de règles de sécurité avancées.
