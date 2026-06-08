# Sommaire

- [**1. Prérequis**](#1-prérequis)
   - [**1.1 Configuration de la VM Proxmox**](#11-configuration-de-la-vm-proxmox)
- [**2. Ajout des disques dans Proxmox**](#2-ajout-des-disques-dans-proxmox)
   - [**2.1 Ajout du premier disque**](#21-ajout-du-premier-disque)
   - [**2.2 Ajout du deuxième disque**](#22-ajout-du-deuxième-disque)
   - [**2.3 Vérification dans Windows Server**](#23-vérification-dans-windows-server)
- [**3. Initialisation des disques**](#3-initialisation-des-disques)
   - [**3.1 Ouvrir le Gestionnaire de disques**](#31-ouvrir-le-gestionnaire-de-disques)
   - [**3.2 Initialiser les disques**](#32-initialiser-les-disques)

---

# 1. Prérequis

## 1.1 Configuration de la VM Proxmox

| Paramètre       | Valeur               |
|-----------------|----------------------|
| Type            | VM (pas CT)          |
| OS              | Windows Server       |
| Hostname        | BV-130-153           |
| Réseau          | vmbr104              |
| Adresse IP      | 172.16.130.250       |
| Disque système  | C: — disque OS       |
| Disques RAID    | 2 x 30 Go            |

---

# 2. Ajout des disques dans Proxmox

## 2.1 Ajout du premier disque

- Dans l'interface Proxmox :
   - Sélectionner la VM `BV-130-153`
   - Cliquer sur `Hardware`
   - Cliquer sur `Add` > `Hard Disk`
   - Choisir le stockage approprié
   - Définir la taille à `30Go`
   - Cliquer sur `Add`

## 2.2 Ajout du deuxième disque

- Répéter l'opération pour le second disque :
   - Cliquer sur `Add` > `Hard Disk`
   - Choisir le **même stockage** que le premier disque
   - Définir la taille à `30Go`
   - Cliquer sur `Add`

- Résultat attendu dans `Hardware` :

| Taille | Description       |
|--------|-------------------|
| OS     | Disque système    |
| 30 Go  | Premier disque RAID|
| 30 Go  | Deuxième disque RAID|

## 2.3 Vérification dans Windows Server

- Redémarrer la VM si nécessaire
- Les deux nouveaux disques doivent apparaître comme **Non initialisés** dans le Gestionnaire de disques

---

# 3. Initialisation des disques

## 3.1 Ouvrir le Gestionnaire de disques

- Faire un clic droit sur le menu `Démarrer`
- Cliquer sur `Gestion des disques`

- Les deux nouveaux disques apparaissent avec le message `Non initialisé`
- Une fenêtre `Initialiser le disque` s'ouvre automatiquement

## 3.2 Initialiser les disques

- Sélectionner les **deux disques** dans la fenêtre d'initialisation
- Choisir le style de partition `GPT (GUID Partition Table)`
- Cliquer sur `OK`

- Résultat attendu : les deux disques passent en état **En ligne** avec l'espace affiché comme `Non alloué`
