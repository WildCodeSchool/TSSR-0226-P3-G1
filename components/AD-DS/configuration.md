## Configurations des GPO des groupes Admins T0 et T1

**SEC-Admin-T0:**

Appliquée sur l'OU : Domain Controllers

![logon](Ressources/t0-1.png)

![](Ressources/t0-2.png)

![](Ressources/t0-3.png)

**SEC-Admin-T1:**

Appliquée sur l'OU : Serveur t1


![](Ressources/t1-1.png)

![](Ressources/t1-2.png)

![](Ressources/t1-3.png)

![](Ressources/t1-4.png)

**SEC-PC-Admin**

Appliquée au PC-admin

![](Ressources/pc-admin.png)


## Application des differentes GPO aux groupes USERS et COMPUTERS correspondant:

Afin d'appliquer nos gpo nouvellement crée il suffit de les link directement à l'OU sur laquelle on veut les appliquer:

![](Ressources/link.png)

Puis on observe que tout est bien ajouté:

![](Ressources/applicationgpo.png)

Et enfin on verifie directement sur un PC client de test que tou marche bien:

![](Ressources/apli-gpo.png)

![](Ressources/apli-gpo2.png)
