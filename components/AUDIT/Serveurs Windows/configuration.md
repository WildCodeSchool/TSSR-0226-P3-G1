[1. Audit des permissions NTFS avec AccessEnum](Audit-des-permissions-NTFS-avec-AccessEnum)
[**2. Audit des permissions avec AccessChk**](2.-Audit-des-permissions-avec-AccessChk)




## 1. Audit des permissions NTFS avec AccessEnum

### Objectif

L'objectif de cet audit est de vérifier les permissions NTFS appliquées sur le dossier de partage principal du serveur de stockage.

Cet audit permet de contrôler que les utilisateurs et les groupes Active Directory disposent uniquement des accès nécessaires à leurs dossiers respectifs.

L'objectif est également d'identifier d'éventuelles permissions trop larges, comme :

- `Everyone`
- `Domain Users`
- `Authenticated Users`
- droits en écriture non justifiés
- droits de modification ou de contrôle total trop permissifs

---

### Périmètre de l'audit

L'audit a été réalisé sur le serveur de stockage Windows.

Dossier audité :

```text
K:\Shares\Dossier_partage
```

Ce dossier contient les espaces partagés de l'entreprise, notamment :

- les dossiers personnels des utilisateurs ;
- les dossiers communs ;
- les dossiers de départements ;
- les dossiers liés aux services de l'entreprise.

---

### Outil utilisé

L'outil utilisé pour cet audit est `AccessEnum`, fourni par Microsoft Sysinternals.

AccessEnum permet d'analyser rapidement les permissions NTFS appliquées sur une arborescence de dossiers.

Il affiche notamment :

- les chemins analysés ;
- les groupes ou utilisateurs ayant des droits en lecture ;
- les groupes ou utilisateurs ayant des droits en écriture ;
- les éventuelles permissions particulières.

---

### Lancement de l'audit

L'outil `AccessEnum` a été lancé directement depuis le serveur de stockage afin d'analyser les permissions NTFS locales.

Chemin sélectionné dans AccessEnum :

```text
K:\Shares\Dossier_partage
```

L'audit a ensuite été lancé avec le bouton `Scan`.

Cette méthode permet d'analyser le dossier parent ainsi que l'ensemble des sous-dossiers présents dans l'arborescence.

---

### Résultat du scan AccessEnum

Le scan AccessEnum a permis de visualiser les permissions NTFS appliquées aux différents dossiers.

Les dossiers personnels des utilisateurs sont configurés de manière à limiter l'accès à :

- l'utilisateur propriétaire du dossier ;
- les administrateurs ;
- les groupes d'administration nécessaires.

Exemple observé :

```text
K:\Shares\Dossier_partage\Utilisateurs\nom_utilisateur
```

Le dossier personnel est accessible en écriture uniquement par l'utilisateur concerné et les administrateurs.

![Scan_AccessEnum](Ressources/Scan_AccessEnum.png)
---

### Analyse des dossiers de départements

Les dossiers de départements sont cloisonnés par groupes Active Directory.

Chaque service dispose de son propre groupe, qui est autorisé uniquement sur le dossier correspondant.

Exemples observés :

| Dossier | Groupe autorisé |
|---|---|
| `Departement\Commercial` | `GrpCommercial` |
| `Departement\Communication` | `GrpCommunication` |
| `Departement\Developpement_Logiciels` | `GrpDeveloppement` |
| `Departement\Direction` | `GrpDirection` |
| `Commun\Departements\DSI` | `BU_DL_Commun_DSI_M` |
| `Commun\Departements\Direction` | `BU_DL_Commun_Direction_M` |
| `Commun\Transverse` | `BU_DL_Commun_Transverse_M` |

Cette organisation permet de respecter le principe du moindre privilège.

Chaque groupe dispose uniquement des droits nécessaires sur son propre espace de travail.

---

### Vérification des droits sur le dossier racine

Le dossier racine du partage a également été vérifié depuis l'onglet `Security`.

Chemin vérifié :

```text
K:\Shares\Dossier_partage
```

Les droits observés sont les suivants :

| Groupe / utilisateur | Droits |
|---|---|
| `SYSTEM` | Droits système |
| `Administrators` | Contrôle total |
| `Users` | Lecture, exécution et affichage du contenu |

Les utilisateurs disposent uniquement des droits nécessaires pour parcourir l'arborescence.

Les droits d'écriture sont ensuite appliqués uniquement sur les sous-dossiers autorisés par groupe ou par utilisateur.

---

### Vérification complémentaire des permissions de partage SMB

En complément de l'audit NTFS réalisé avec AccessEnum, les permissions du partage SMB ont été vérifiées depuis les propriétés du dossier partagé.

Chemin :

```text
Dossier_partage
→ Properties
→ Share Permissions
```

Lors de la vérification, le groupe `Everyone` était présent dans les permissions du partage.

Afin d'améliorer la sécurité, ce groupe a été retiré.

La configuration finale du partage est la suivante :

| Groupe | Full Control | Change | Read | Rôle |
|---|---:|---:|---:|---|
| `GRP-T2-ADMIN` | Oui | Oui | Oui | Administration complète du partage |
| `Domain Users` | Non | Oui | Oui | Accès réseau au partage pour les utilisateurs du domaine |
| `Everyone` | Non | Non | Non | Groupe supprimé du partage |

![Droit_admin](Ressources/Droit_Admin.png)
![Droit_Domaine_User](Ressources/Droit_Domaine_User.png)
---

### Explication de la configuration

La sécurité d'accès au partage repose sur deux niveaux de permissions :

| Niveau | Rôle |
|---|---|
| Permissions de partage SMB | Autorisent l'accès au partage depuis le réseau |
| Permissions NTFS | Définissent précisément les droits sur les dossiers et fichiers |

Dans cette configuration :

- `Domain Users` peut accéder au partage depuis le réseau ;
- `GRP-T2-ADMIN` peut administrer le partage ;
- les permissions NTFS limitent ensuite l'accès aux dossiers autorisés ;
- chaque groupe métier accède uniquement à son propre dossier ;
- le groupe `Everyone` n'est plus utilisé sur le partage.

---

### Points de contrôle réalisés

Les vérifications suivantes ont été réalisées :

| Point contrôlé | Résultat |
|---|---|
| Scan du dossier parent avec AccessEnum | OK |
| Scan des sous-dossiers | OK |
| Vérification des dossiers utilisateurs | OK |
| Vérification des dossiers de départements | OK |
| Présence de groupes métiers dédiés | OK |
| Cloisonnement des accès par service | OK |
| Vérification des permissions SMB | OK |
| Suppression du groupe `Everyone` du partage | OK |
| Conservation de l'accès réseau pour `Domain Users` | OK |
| Administration réservée au groupe `GRP-T2-ADMIN` | OK |

---

### Risques recherchés pendant l'audit

L'audit avait pour objectif d'identifier les mauvaises pratiques suivantes :

| Risque recherché | Exemple |
|---|---|
| Accès trop large | `Everyone` avec droits d'écriture |
| Droits excessifs | `Domain Users` avec contrôle total |
| Mauvais cloisonnement | Tous les services accèdent au même dossier |
| Dossier sensible trop ouvert | Comptabilité accessible à tous |
| Permissions non maîtrisées | Droits hérités non contrôlés |

Aucune anomalie critique de ce type n'a été constatée sur les dossiers de départements affichés.

---

### Conclusion

L'audit réalisé avec AccessEnum a permis de vérifier les permissions NTFS du dossier de partage principal du serveur de stockage.

Les résultats montrent que les dossiers sont correctement organisés par service et par utilisateur.

Les dossiers de départements sont cloisonnés grâce à des groupes Active Directory dédiés. Chaque groupe dispose uniquement des droits nécessaires sur son propre dossier.

Une vérification complémentaire des permissions SMB a également été réalisée. Le groupe `Everyone` a été retiré du partage afin de renforcer la sécurité.

La configuration finale permet donc :

- un accès réseau contrôlé au partage ;
- une administration réservée aux administrateurs ;
- un cloisonnement des droits par service ;
- une limitation des accès selon les groupes Active Directory ;
- une réduction des permissions trop larges.

L'audit est considéré comme conforme aux bonnes pratiques de sécurité Windows Server.


## 2. Audit des permissions avec AccessChk

### Objectif

L'objectif de cet audit est de vérifier précisément les droits d'accès appliqués sur le dossier de partage principal du serveur de stockage à l'aide de l'outil `AccessChk`.

Contrairement à AccessEnum, qui donne une vue globale des permissions NTFS, AccessChk permet de tester les droits d'un groupe ou d'un utilisateur précis sur un dossier ciblé.

L'audit permet notamment de vérifier :

- si les utilisateurs du domaine disposent ou non de droits d'écriture sur la racine du partage ;
- si les administrateurs disposent bien des droits nécessaires ;
- si le groupe d'administration T2 possède les droits attendus ;
- si les permissions appliquées sont cohérentes avec la politique de sécurité.

---

### Machine utilisée

L'audit AccessChk a été réalisé directement depuis le serveur de stockage Windows.

Serveur concerné :

```text
BV-130-153
``` 
Dossier audité :

K:\Shares\Dossier_partage

L'outil utilisé est :

accesschk64.exe

Il s'agit de la version 64 bits de l'outil AccessChk de Microsoft Sysinternals.

Emplacement de l'outil

L'outil a été lancé depuis le dossier suivant :

C:\Users\Administrator\Desktop\Audit_Windows\tools

Commande utilisée pour se placer dans le dossier :

cd /d C:\Users\Administrator\Desktop\Audit_Windows\tools
Test 1 — Vérification des droits d'écriture de Domain Users

Le premier test a consisté à vérifier si le groupe Domain Users disposait de droits d'écriture sur la racine du partage.

Commande utilisée :

accesschk64.exe -accepteula -d -w "BILLU\Domain Users" "K:\Shares\Dossier_partage"

Résultat obtenu :

No matching objects found.

Analyse :

Le résultat No matching objects found indique qu'AccessChk n'a trouvé aucun droit d'écriture pour le groupe Domain Users sur le dossier racine.

Conclusion :

BILLU\Domain Users ne possède pas de droit d'écriture direct sur la racine du partage.

Ce résultat est conforme aux bonnes pratiques, car les utilisateurs du domaine ne doivent pas pouvoir créer ou modifier librement des fichiers directement à la racine du partage.

Capture associée :

06_accesschk_domain_users_racine_no_write.png
Test 2 — Vérification des droits des administrateurs locaux

Le deuxième test a permis de vérifier que le groupe local BUILTIN\Administrators possède bien les droits nécessaires sur le dossier racine.

Commande utilisée :

accesschk64.exe -accepteula -d -w "BUILTIN\Administrators" "K:\Shares\Dossier_partage"

Résultat obtenu :

RW K:\Shares\Dossier_partage

Analyse :

Le résultat RW signifie :

Lettre	Signification
R	Read
W	Write

Le groupe BUILTIN\Administrators dispose donc bien de droits en lecture et en écriture sur le dossier audité.

Conclusion :

Les administrateurs locaux disposent bien des droits nécessaires sur la racine du partage.

Capture associée :

07_accesschk_administrators_racine_rw.png
Test 3 — Vérification des droits du groupe GRP-T2-ADMIN

Le troisième test a permis de vérifier les droits du groupe d'administration T2 sur le dossier racine.

Commande utilisée :

accesschk64.exe -accepteula -d -w "BILLU\GRP-T2-ADMIN" "K:\Shares\Dossier_partage"

Résultat obtenu :

RW K:\Shares\Dossier_partage

Analyse :

Le résultat RW indique que le groupe GRP-T2-ADMIN dispose des droits en lecture et en écriture sur le dossier racine du partage.

Ce résultat confirme que le groupe d'administration dispose des permissions nécessaires pour gérer le dossier de partage.

Conclusion :

BILLU\GRP-T2-ADMIN possède bien les droits d'écriture nécessaires sur le dossier K:\Shares\Dossier_partage.

Capture associée :

08_accesschk_grp_t2_admin_racine_rw.png
Synthèse des tests AccessChk
Test	Groupe testé	Chemin audité	Résultat	Conclusion
1	BILLU\Domain Users	K:\Shares\Dossier_partage	No matching objects found	Aucun droit d'écriture direct sur la racine
2	BUILTIN\Administrators	K:\Shares\Dossier_partage	RW	Droits lecture/écriture présents
3	BILLU\GRP-T2-ADMIN	K:\Shares\Dossier_partage	RW	Droits lecture/écriture présents
Interprétation des résultats

Les résultats obtenus montrent que les permissions sont cohérentes :

les utilisateurs du domaine ne disposent pas de droits d'écriture directs sur la racine du partage ;
les administrateurs locaux disposent bien des droits nécessaires ;
le groupe GRP-T2-ADMIN dispose des droits d'administration attendus ;
les droits d'écriture sont réservés aux groupes d'administration ;
les utilisateurs standards sont limités par les permissions NTFS appliquées aux sous-dossiers.

Cette configuration respecte le principe du moindre privilège.

Complément avec les permissions de partage SMB

En complément de l'audit AccessChk, les permissions de partage SMB ont été vérifiées depuis l'interface graphique Windows.

La configuration finale du partage est la suivante :

Groupe	Full Control	Change	Read	Rôle
GRP-T2-ADMIN	Oui	Oui	Oui	Administration complète du partage
Domain Users	Non	Oui	Oui	Accès réseau au partage
Everyone	Non	Non	Non	Groupe supprimé du partage

Cette configuration permet aux utilisateurs du domaine d'accéder au partage réseau, tandis que les droits précis sont ensuite contrôlés par les permissions NTFS.

Conclusion

L'audit AccessChk a permis de valider les droits appliqués sur la racine du partage principal du serveur de stockage.

Les tests montrent que :

Domain Users ne possède pas de droit d'écriture direct sur la racine du partage ;
BUILTIN\Administrators possède les droits nécessaires ;
GRP-T2-ADMIN possède les droits de lecture et d'écriture attendus.

L'audit confirme que les droits d'administration sont bien réservés aux groupes appropriés et que les utilisateurs standards ne disposent pas de droits excessifs sur la racine du partage.

Cette phase complète l'audit réalisé avec AccessEnum et permet de confirmer plus précisément les permissions appliquées à certains groupes critiques.

