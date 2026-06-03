
# Configuration du routage

## Routeur R1 - Cœur de réseau

### Configuration des interfaces

```bash
configure

set interfaces ethernet eth0 address 10.0.2.254/24
set interfaces ethernet eth1 address 10.0.1.1/30
set interfaces ethernet eth2 address 10.0.0.1/30

commit
save
```

### Routes statiques

```bash
configure

set protocols static route 172.16.0.0/17 next-hop 10.0.1.2
set protocols static route 172.16.128.0/17 next-hop 10.0.0.2

commit
save
```

---

## Routeur R2 - Réseau Développement

### Configuration des interfaces

```bash
configure

set interfaces ethernet eth0 address 10.0.1.2/30
set interfaces ethernet eth1 address 172.16.127.254/17

commit
save
```

### Route statique

```bash
configure

set protocols static route 172.16.128.0/17 next-hop 10.0.1.1

commit
save
```

---

## Routeur R3 - Réseau Serveurs

### Configuration des interfaces

```bash
configure

set interfaces ethernet eth0 address 10.0.0.2/30
set interfaces ethernet eth1 address 172.16.128.1/17

commit
save
```

### Route statique

```bash
configure

set protocols static route 172.16.0.0/17 next-hop 10.0.0.1

commit
save
```

---

## Vérification

### Afficher les interfaces

```bash
show interfaces
```

### Afficher la table de routage

```bash
show ip route
```

### Tests

Depuis R2 :

```bash
ping 10.0.1.1
ping 172.16.128.1
```

Depuis R3 :

```bash
ping 10.0.0.1
ping 172.16.127.254
```

## Dépannage

### Vérifier les routes

```bash
show ip route
```

### Vérifier les interfaces

```bash
show interfaces
```

### Vérifier la configuration

```bash
show configuration commands
