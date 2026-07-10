Rapport d'audit — Serveur web Apache (www.BillU.lan)

Outil : Nikto v2.6.0
Cible : www.billu.lan (10.0.3.20) — Apache/2.4.67 (Debian), DMZ derrière pfSense
Date : 10 juillet 2026

Contexte

Audit de sécurité du serveur web réalisé avec Nikto. Un premier scan a donné des résultats faussés : le trafic était intercepté par le portail captif pfSense avant d'atteindre le serveur. Après contournement de ce point, l'audit réel d'Apache a permis d'identifier plusieurs faiblesses de configuration, corrigées ci-dessous.

Failles identifiées et corrections apportées

Faille détectéeCorrection appliquéeFuite de l'IP interne du pare-feu (10.0.2.1) dans le header LocationUseCanonicalName On + remplacement de %{HTTP_HOST} par www.BillU.lan dans la règle de redirection HTTPSVersion et OS du serveur exposés (Apache/2.4.67 Debian)ServerTokens Prod + ServerSignature Off dans security.confHeaders de sécurité manquants (X-Content-Type-Options, Referrer-Policy, Content-Security-Policy, Permissions-Policy)Ajout des directives Header always set ... correspondantes dans le vhostHSTS manquant en HTTPSStrict-Transport-Security ajouté sur le vhost :443 uniquementFuite d'inode via l'ETag (CVE-2003-1418)FileETag MTime Size

Résultat

Les captures ci-dessous montrent la configuration finale (www.conf) ainsi que les résultats des scans Nikto après correction, en HTTP et en HTTPS.

![http](/components/AUDIT/Ressources/http.png)


![https](/components/AUDIT/Ressources/https.png)


![conf](/components/AUDIT/Ressources/modifsite.png)

Recommandations restantes


Vérifier le remplacement de X-Frame-Options (déprécié) par la directive frame-ancestors de la CSP.
Réévaluer l'usage de la compression HTTP (gzip/deflate) sur les pages sensibles (risque BREACH).
Planifier des scans Nikto réguliers pour suivre l'évolution du durcissement.

