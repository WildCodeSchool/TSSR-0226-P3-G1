## Audit des permissions NTFS avec AccessEnum

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

