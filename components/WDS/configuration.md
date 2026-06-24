# Configuration — Partage MDT, déploiement et automatisation

Configuration du partage de déploiementde la jonction au domaine, de l'import dans WDS et du réseau PXE. Inclut le **dépannage** des problèmes rencontrés.

---

## 1. Créer le partage de déploiement

1. **Deployment Workbench** (exécuter en administrateur).
2. Clic droit sur **Deployment Shares** → **New Deployment Share**.
3. Chemin : **`E:\DeploymentShare`** 
4. Conserver les valeurs par défaut → _Finish_.
5. **Nom du partage.** Vérifier le nom réel du partage réseau :
 
```powershell
 Get-SmbShare | Where-Object Name -like "Deployment*" | Select-Object Name, Path
 ```
 
Ici le partage s'appelle **`DeploymentShare`** (sans `$`). Le `DeployRoot` du `Bootstrap.ini` doit utiliser **exactement** ce nom.

---

## 2. Importer Windows 11

1. Monter l'ISO Windows 11 (apparaît comme un lecteur, ex. `D:\`).
2. Clic droit sur **Operating Systems** → **Import Operating System**.
3. **Full set of source files** → source : la racine de l'ISO (`D:\`).
4. Nom de destination : `Windows 11 24H2 x64 FR`.

---

## 3. Créer la séquence de tâches

1. Clic droit sur **Task Sequences** → **New Task Sequence**.
2. **ID : `W11`** (court, sans espace — réutilisé dans `CustomSettings.ini`).
3. Nom : `Deploiement Windows 11 Pro`.
4. Template : **Standard Client Task Sequence**.
5. OS : sélectionner l'édition voulue (**Windows 11 Pro**).
6. Clé produit : **Do not specify a product key at this time**.
7. Mot de passe admin local : **Use the specified local Administrator password**.

---

## 4. Les fichiers de règles

Deux fichiers pilotent tout l'automatisme. Propriétés du partage → onglet **Rules**.

### 4.1 — Différence fondamentale (à retenir)

|Fichier|Contenu|Régénérer le boot image après modif ?|
|---|---|---|
|**CustomSettings.ini** (Rules)|Réponses aux pages de l'assistant|**Non** — lu en direct depuis le partage|
|**Bootstrap.ini** (Edit Bootstrap.ini)|Connexion au partage depuis WinPE|**OUI** — embarqué dans le boot image|


### 4.2 — Bootstrap.ini

```ini
[Settings]
Priority=Default

[Default]
DeployRoot=\\BV-130-121\DeploymentShare
UserID=<COMPTE_DE_SERVICE>
UserDomain=BILLU
UserPassword=<MOT_DE_PASSE>
SkipBDDWelcome=YES
```

Points de vigilance :

- `DeployRoot` doit correspondre au **nom réel** du partage .
- `UserID` doit être **identique** au compte réel dans l'AD (une faute de frappe → « invalid credentials »).
- `UserPassword` ne doit **pas contenir de `=`** (le `=` casse le parsing du `.ini`, le mot de passe est tronqué). Les caractères `* - _ !` passent bien.

---

## 5. Les trois modes d'automatisation

Toute la différence se joue dans le `CustomSettings.ini` (section `[Default]`).

### 5.1 — Mode MANUEL

Installation classique depuis l'ISO Windows 11, sans serveur de déploiement. Sert de référence / point de comparaison.

### 5.2 — Mode SEMI-AUTOMATISÉ

L'assistant LiteTouch ne pose que le **nom du poste** et le **choix de la séquence** ; tout le reste est pré-rempli.

```ini
[Settings]
Priority=Default
Properties=MyCustomProperty

[Default]
OSInstall=Y
SkipTaskSequence=NO        ; <-- l'opérateur choisit la séquence
SkipCapture=YES
SkipAdminPassword=YES
AdminPassword=<MOT_DE_PASSE_ADMIN_LOCAL>
SkipProductKey=YES
SkipComputerBackup=YES
SkipBitLocker=YES
SkipApplications=YES
SkipLocaleSelection=YES
KeyboardLocale=fr-FR
UserLocale=fr-FR
UILanguage=fr-FR
SkipTimeZone=YES
TimeZoneName=Romance Standard Time
SkipDomainMembership=YES
JoinWorkgroup=WORKGROUP
SkipSummary=YES
SkipFinalSummary=YES
FinishAction=SHUTDOWN
```

### 5.3 — Mode COMPLÈTEMENT AUTOMATISÉ (avec jonction au domaine)

Aucune question, aucune intervention. Version finale du projet.

```ini
[Settings]
Priority=Default
Properties=MyCustomProperty

[Default]
OSInstall=Y

; --- Séquence imposée (full-auto) ---
TaskSequenceID=W11
SkipTaskSequence=YES
SkipComputerName=YES

; --- Jonction automatique au domaine ---
SkipDomainMembership=YES
JoinDomain=BillU.lan
DomainAdmin=<COMPTE_JONCTION>
DomainAdminDomain=BILLU
DomainAdminPassword=<MOT_DE_PASSE>
MachineObjectOU=OU=Postes_Utilisateurs,OU=BU_Computers,DC=BillU,DC=lan

; --- Mot de passe administrateur local ---
SkipAdminPassword=YES
AdminPassword=<MOT_DE_PASSE_ADMIN_LOCAL>

; --- Pages sautées ---
DoCapture=NO
SkipCapture=YES
SkipProductKey=YES
SkipComputerBackup=YES
SkipBitLocker=YES
SkipApplications=YES

; --- Langue / région (FR) ---
SkipLocaleSelection=YES
KeyboardLocale=fr-FR
UserLocale=fr-FR
UILanguage=fr-FR
SkipTimeZone=YES
TimeZoneName=Romance Standard Time

; --- Fin ---
SkipSummary=YES
SkipFinalSummary=YES
FinishAction=SHUTDOWN
```

Points de vigilance :

- `SkipAdminPassword=YES` **ne suffit pas seul** : il faut la ligne `AdminPassword=` en face, sinon MDT repose quand même la question.
- Choisir un mot de passe admin **respectant la complexité Windows** (maj + min + chiffre + ~10 car.), sinon Windows le refuse silencieusement.
- Le compte `DomainAdmin` doit avoir le **droit de joindre des machines au domaine** et de créer l'objet dans l'OU cible.
- Le DN de l'OU (`MachineObjectOU`) doit correspondre **exactement** à l'AD. Le copier depuis l'éditeur d'attributs plutôt que le taper :
    ```powershell
    Get-ADOrganizationalUnit -Filter 'Name -eq "Postes_Utilisateurs"' | Select DistinguishedName
    ```

---

## 6. Générer le boot image

1. Propriétés du partage → onglet **General** → **Platforms Supported** : décocher **x86**, garder **x64** (clients 100 % UEFI/x64).
2. Onglet **Windows PE** → Platform **x64** → décocher **« Generate a Lite Touch bootable ISO image »** (inutile pour le PXE, et évite l'échec « disque plein »).
3. Clic droit sur le partage → **Update Deployment Share** → **« Completely regenerate the boot images »**.

 Résultat : `E:\DeploymentShare\Boot\LiteTouchPE_x64.wim`.

---

## 7. Importer le boot image dans WDS

1. Console WDS → clic droit sur **Images de démarrage** → **Ajouter une image de démarrage**.
2. Pointer vers `E:\DeploymentShare\Boot\LiteTouchPE_x64.wim`.



---

## 8. VM cliente (machine vierge)

| Paramètre      | Valeur                                 | Raison                                     |
| -------------- | -------------------------------------- | ------------------------------------------ |
| BIOS           | **OVMF (UEFI)**                        | Requis par Windows 11                      |
| TPM            | **2.0**                                | Requis par Windows 11                      |
| EFI Disk       | présent, Secure Boot (pre-enroll keys) | Requis par Windows 11                      |
| Machine        | q35                                    | —                                          |
| Disque         | 50–64 Go                               | —                                          |
| Réseau         | **e1000** sur `vmbr103`                | e1000 a le pilote PXE + pilote WinPE natif |
| **Boot Order** | **réseau (1er), disque (2e)**          |                                            |

---

## 9. Validation du résultat

Après un déploiement complètement automatisé :

1. La machine s'installe seule, rejoint le domaine, s'éteint.
2. Au démarrage : écran de connexion **« Autre utilisateur / Connectez-vous à BILLU »** → la machine est jointe au domaine. 
3. Dans **Utilisateurs et ordinateurs AD** → OU `Postes_Utilisateurs` : l'objet ordinateur de la machine apparaît → preuve de la jonction automatique.
