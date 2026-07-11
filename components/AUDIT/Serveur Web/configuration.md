# Rapport d'audit - Serveur web Apache (www.BillU.lan)
 
Outil : Nikto v2.6.0
Cible : www.billu.lan (10.0.3.20) - Apache/2.4.67 (Debian), DMZ derriere pfSense
Date : 10 juillet 2026
 
## Contexte
 
Audit de securite du serveur web realise avec Nikto. Un premier scan a donne des resultats faussés : le trafic etait intercepte par le portail captif pfSense avant d'atteindre le serveur. Apres contournement de ce point, l'audit reel d'Apache a permis d'identifier plusieurs faiblesses de configuration, corrigees ci-dessous.

## Failles identifiées et corrections apportées

| Faille détectée | Correction appliquée |
| --- | --- |
| Fuite de l'IP interne du pare-feu (10.0.2.1) dans le header Location | UseCanonicalName On + remplacement de %{HTTP_HOST} par www.BillU.lan dans la règle de redirection HTTPS |
| Version et OS du serveur exposés (Apache/2.4.67 Debian) | ServerTokens Prod + ServerSignature Off dans security.conf |
| Headers de sécurité manquants (X-Content-Type-Options, Referrer-Policy, Content-Security-Policy, Permissions-Policy) | Ajout des directives Header always set correspondantes dans le vhost |
| HSTS manquant en HTTPS | Strict-Transport-Security ajouté sur le vhost 443 uniquement |
| Fuite d'inode via l'ETag (CVE-2003-1418) | FileETag MTime Size |


## Résultats

Les captures ci-dessous montrent la configuration finale (www . conf) ainsi que les résultats des scans Nikto après correction, en HTTP et en HTTPS.

![http](/components/AUDIT/Ressources/http.png)


![https](/components/AUDIT/Ressources/https.png)


![conf](/components/AUDIT/Ressources/modifsite.png)

## Recommandations restantes


Vérifier le remplacement de X-Frame-Options (déprécié) par la directive frame-ancestors de la CSP.
Réévaluer l'usage de la compression HTTP (gzip/deflate) sur les pages sensibles (risque BREACH).
Planifier des scans Nikto réguliers pour suivre l'évolution du durcissement.

