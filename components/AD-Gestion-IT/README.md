# AD - Gestion IT des nouvelles règles RH


## Présentation

Ce module documente la mise en place de deux processus Active Directory liés aux nouvelles règles RH de l'entreprise BillU :

- gestion informatique des départs de collaborateurs ;

- féminisation des intitulés de postes pour les collaboratrices concernées.

Ces processus permettent de standardiser les actions d'administration, d'éviter les suppressions accidentelles de comptes, de conserver une traçabilité et d'automatiser les modifications RH dans l'Active Directory.


---

## Objectifs du module

### Départ de collaborateurs


Les comptes des collaborateurs qui quittent la société ne doivent pas être supprimés.

Le processus mis en place permet de :


- désactiver le compte AD ;

- conserver le compte pour audit et traçabilité ;

- déplacer le compte dans une OU dédiée ;

- ajouter une description RH au compte ;

- retirer les groupes non nécessaires ;

- générer un fichier de log.

### Féminisation des postes


Les postes tenus par des femmes doivent être féminisés dans l'Active Directory.

Le processus mis en place permet de :


- exporter les utilisateurs AD dans un fichier CSV ;

- identifier les collaboratrices concernées ;

- appliquer automatiquement les règles de féminisation ;

- modifier uniquement l'attribut `Title` ;

- conserver l'attribut `Department` inchangé ;

- générer un fichier de log.

---
## Arborescence conseillée


```text

AD-RH-Rules/

├── README.md

├── INSTALLATION.md

├── CONFIGURATION.md

├── scripts/

│   ├── Disable-Leavers.ps1

│   └── Update-FeminizedTitles.ps1

├── samples/

│   ├── departs_collaborateurs.csv

│   └── feminisation_postes.csv

└── docs/

    ├── captures-depart-collaborateurs/

    └── captures-feminisation-postes/

```


---

## Technologies utilisées

- Windows Server

- Active Directory Domain Services

- PowerShell

- Fichiers CSV

- Active Directory Users and Computers

---
## Scripts utilisés

### Désactivation des collaborateurs sortants


```text

C:\Scripts\Disable-Leavers.ps1

```


Ce script lit un fichier CSV contenant les collaborateurs sortants, désactive leurs comptes, les déplace dans une OU d'archivage et écrit une trace dans un fichier de log.


### Féminisation des postes


```text

C:\Scripts\Update-FeminizedTitles.ps1

```


Ce script lit un fichier CSV contenant les utilisateurs AD et applique les règles de féminisation uniquement aux lignes concernées.


---
## Résultat attendu

À la fin de la mise en place :

- les comptes des anciens collaborateurs sont conservés mais désactivés ;

- les comptes désactivés sont archivés dans une OU dédiée ;

- les intitulés de postes des collaboratrices concernées sont féminisés ;

- les départements ne sont pas modifiés ;

- les actions réalisées sont journalisées.
---
## Captures recommandées

### Départ de collaborateurs

- OU `BU_Anciens_Collaborateurs` créée ;

- utilisateur actif avant traitement ;

- utilisateur désactivé après traitement ;

- utilisateur déplacé dans l'OU d'archivage ;

- description du compte mise à jour ;

- exécution du script ;

- fichier de log généré.

### Féminisation des postes

  
- export CSV des utilisateurs ;

- colonne `PosteFeminise` renseignée ;

- exécution du script en mode test ;

- exécution du script en mode réel ;

- attribut `Title` avant modification ;

- attribut `Title` après modification ;

- vérification que `Department` est inchangé ;

- fichier de log généré.  

---
## Conclusion

Les deux règles RH ont été intégrées à l'administration Active Directory de BillU.

La gestion des départs permet de conserver les comptes sans les supprimer, tout en les désactivant et en les archivant proprement.

La féminisation des postes permet de modifier automatiquement les intitulés visibles dans l'AD, en s'appuyant sur un export CSV validé, sans modifier les autres attributs de l'utilisateur.
