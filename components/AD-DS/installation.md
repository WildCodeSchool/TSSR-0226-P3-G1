## Rôles
Nous avons installer les rôles AD-DS en même temps que le rôle de DNS afin de synchroniser les deux et ne pas avoir de problèmes de noms par la suite.
Les roles ont ete ajouté a partir de manage comme decrit dans la partie DNS

![role](Ressources/ad-ds1.png)
Une fois installée nous avons promus le serveur en controlleur de domaine.
Puis nous avons créé le fôret que nous avons nommé **BillU.lan**:

![foret](Ressources/ad-ds2.png)

Nous avons lancé l'outil de configuration HelloMyDir afin de parametrer notre forêt selon les bonnes pratiques en vigueur et avons obtenu plusieurs parametres de sécruties supplementaires:

Les PSO:

![PSO](Ressources/pso.png)

ou encore des parametres par defaut de securité qui s'appliquent à tout le domaine:

![defaut](Ressources/default.png)

Nous avons ensuite continuer en configurant nos differentes GPO que vous nous aviez demandé:

## Les GPO

### Les GPO sécurité:

-Politique de mot de passe (complexité, longueur, etc.):

![password](Ressources/gpo-password.png)

-Restriction d'installation de logiciel pour les utilisateurs:

![Restriction](Ressources/gpo-logicielrestriction.png)

-Blocage de l'accès à la base de registre:

![registry](Ressources/gpo-registryblock.png)

-Blocage complet ou partiel au panneau de configuration:

![controlpanel](Ressources/gpo-controlpanel.png)

-Restriction des périphériques amovible:

![peripheriques](Ressources/gpo-devicerestriction.png)

ainsi que:

![peripheriques2](Ressources/gpo-devicerestriction-2.png)

-Gestion du pare-feu:

![FW](Ressources/gpo-FW-lvl1.png)

-Forçage du type d'utilisation sécurisée du bureau à distance:
Nous avons renforcer fortement les connexions rdp avec authentification et encryption:

![RDP](Ressources/gpo-rdp.png)

mais aussi avec des logs

![RDP2](Ressources/gpo-rdp-2.png)

-Limitation des tentatives d'élévation de privilèges:

![credential](Ressources/gpo-limitationcredential.png)

-Politique de sécurité PowerShell:

![PS](Ressources/gpo-powershell.png)

### Les GPO Standards

-Mappage de lecteurs:

![lecteurs](Ressources/mappage-lecteur.png)

-Gestion de l'alimentation:

![alimentation](Ressources/gpo-powermanagement.png)

-Fond d'écran:

![wallpaper](Ressources/wallpaper.png)



