

---

# 1. Configuration des groupes WSUS

## 1.1 Activer le ciblage côté client

Par défaut, WSUS attend une affectation manuelle des machines aux groupes. Pour que l'affectation soit pilotée par les GPO, activer le ciblage côté client :

1. Console WSUS → **Options** → **Computers**
2. Sélectionner **« Use Group Policy or registry settings on computers »**
3. **OK**

 Ce réglage est verrouillé pendant la synchronisation initiale (message _« Cannot save configuration because the server is synchronizing »_). Il doit être validé une fois la
 synchronisation terminée (statut **Idle**). Sans lui, WSUS ignore le groupe envoyé par les GPO et range toutes les machines dans _Unassigned Computers_.

## 1.2 Créer les groupes Clients / Serveurs / DC

1. Console WSUS → **Computers** → clic droit sur **All Computers** → **Add Computer Group…**
2. Créer les trois groupes :

|Groupe WSUS|Machines concernées|
|---|---|
|**Clients**|Postes utilisateurs|
|**Serveurs**|Serveurs membres Windows|
|**DC**|Contrôleurs de domaine|

Les noms doivent être saisis à l'identique dans les GPO (respect de la casse et de l'orthographe).

---

# 2. GPO de ciblage par OU

Trois GPO sont créées dans la console **Gestion des stratégies de groupe** (`gpmc.msc`), chacune liée à l'OU correspondante. Toutes les valeurs se trouvent dans :

```
Computer Configuration
└── Policies
    └── Administrative Templates
        └── Windows Components
            └── Windows Update
```

|GPO|OU de liaison|
|---|---|
|WSUS - Clients|Postes_Utilisateurs|
|WSUS - Serveurs|BU_Computers\Serveurs\Windows_serveurs|
|WSUS - DC|Domain Controllers|

## 2.1 Paramètres communs

Les deux paramètres suivants sont identiques dans les trois GPO (seul le nom du groupe change) :

**Specify intranet Microsoft update service location** → _Enabled_

|Champ|Valeur|
|---|---|
|Set the intranet update service…|`http://BV-130-117.BillU.lan:8530`|
|Set the intranet statistics server|`http://BV-130-117.BillU.lan:8530`|
|Set the alternate download server|_(vide)_|

 L'URL désigne le service web WSUS : protocole **HTTP**, nom DNS du serveur (**BV-130-117.BillU.lan**, plus stable qu'une IP), et port **8530** (port WSUS par défaut en HTTP ; 8531 pour le HTTPS).

**Enable client-side targeting** → _Enabled_, avec le nom du groupe correspondant à chaque GPO.

## 2.2 GPO WSUS - Clients

|Paramètre|Valeur|
|---|---|
|Enable client-side targeting|`Clients`|
|Configure Automatic Updates|_Enabled_ — **4 — Auto download and schedule the install**|
|Scheduled install day / time|Every day / 06:00|
|Automatic Updates detection frequency|_Enabled_ — 6 heures (pratique en lab)|

Comportement : les postes téléchargent et installent automatiquement, avec redémarrage planifié hors heures d'activité.

## 2.3 GPO WSUS - Serveurs

|Paramètre|Valeur|
|---|---|
|Enable client-side targeting|`Serveurs`|
|Configure Automatic Updates|_Enabled_ — **3 — Auto download and notify for install**|
|No auto-restart with logged on users…|_Enabled_|

Comportement : téléchargement automatique, mais installation et redémarrage déclenchés manuellement par l'administrateur.

## 2.4 GPO WSUS - DC

|Paramètre|Valeur|
|---|---|
|Enable client-side targeting|`DC`|
|Configure Automatic Updates|_Enabled_ — **2 — Notify for download and notify for install**|
|No auto-restart with logged on users…|_Enabled_|
|Always automatically restart at the scheduled time|_Disabled_ / Not Configured|

Comportement : contrôle maximal. Le contrôleur de domaine signale les mises à jour disponibles mais n'effectue aucune action sans validation. Les DC sont patchés manuellement, un par un, pour ne jamais perdre l'authentification du domaine.

 Une **nouvelle** GPO est créée sur l'OU _Domain Controllers_ — ne pas modifier la _Default Domain Controllers Policy_ existante.

---

# 3. Application et vérification

## 3.1 Forcer l'application des GPO

Sur une machine de test de chaque type :

```powershell
gpupdate /force
UsoClient StartScan
```

`UsoClient StartScan` remplace l'ancienne commande `wuauclt /detectnow` sur les versions récentes de Windows.

## 3.2 Vérifier le ciblage côté machine

Confirmer que la GPO a bien écrit les valeurs attendues dans le registre :

```powershell
Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" | Select-Object WUServer, TargetGroup
```

Résultat attendu (exemple pour un client) :

```
WUServer                            TargetGroup
--------                            -----------
http://BV-130-117.BillU.lan:8530    Clients
```

Vérifier également que la bonne GPO est appliquée :

```powershell
gpresult /r /scope:computer
```

## 3.3 Vérifier le rattachement côté WSUS

1. Console WSUS → **Computers** → rafraîchir (F5)
2. Les machines doivent apparaître dans **Clients**, **Serveurs** ou **DC** selon leur OU

 Au premier contact, une machine peut apparaître dans _Unassigned Computers_ avant d'être reclassée au cycle suivant (compter 10 à 20 min). Si les machines restent durablement dans _Unassigned_, vérifier que le réglage _Options → Computers → Use Group Policy…_ (voir 1.1) a bien été validé.

---

# 4. Approbation des mises à jour

WSUS ne distribue que les mises à jour **approuvées** par l'administrateur. Sans approbation, aucune mise à jour ne s'installe, même si tout le reste est correctement configuré.

## 4.1 Approbation manuelle

1. Console WSUS → **Updates** → **All Updates**
2. Régler les filtres **Approval : Unapproved** et **Status : Any**, puis _Refresh_
3. Sélectionner les mises à jour → clic droit → **Approve…**
4. Choisir **« Approved for Install »** sur le ou les groupes voulus

La démarche recommandée tire parti de la séparation en groupes : approuver d'abord pour **Clients** (test), puis pour **Serveurs**, et enfin pour **DC** une fois la stabilité confirmée.

## 4.2 Approbation automatique

Pour automatiser l'approbation de certaines classifications :

1. Console WSUS → **Options** → **Automatic Approvals**
2. Définir une règle (ex. _Critical Updates_ + _Security Updates_) pour un ou plusieurs groupes

 Pratique courante : approbation automatique pour les **Clients**, mais approbation **manuelle** conservée pour les **Serveurs** et surtout les **DC**.

---
