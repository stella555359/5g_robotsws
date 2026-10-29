# ===============================================================================================================
# Version Management
# 1 - Update version in confluence :
#     https://confluence.ext.net.nokia.com/display/5GFTPARIS/06+-+AF+Delivery+Announcement+to+NPS+ET+Squads
# 2 - Regenerate the documentation when version is modified
# Tool to generate documentation : robotws5g/resources/sites/NPS/SWENG/doc_gen/SWENG_generate_documentation.sh
# ---------------------------------------------------------------------------------------------------------------
# Regles de versioning :
#
# X :
# -	Modification importante du fonctionnement d un bloc* existant (refactoring).
# -	Modification fonctionnelle importante lie a une adaptation a de nouvelles contraintes (UTE, HW, framework)
# -	Ajout de gros bloc* fonctionnel
#
# Y :
# -	Modification d interface de KW/methode existante a usage externe SANS compatibilite ascendante
#   (necessite une modification de test suite).
# -	Ajout de KW/methode a usage externe (ajout fonctionnel dans un bloc* existant)
# -	Ajout fonctionnel dans un bloc* existant (ajout de KW/methode a usage externe, support de nouvelle topology)
#
# Z :
# -	Modification d interface de KW/methode existante a usage externe AVEC compatibilite ascendante
#   (pas besoin de modification des test suites).
# -	Modification d interface de KW/methode existante a usage interne a SWENG.
# -	Ajout de KW/methode a usage interne SWENG
# -	Modif code interne AVEC modification de comportement (fonctionnel)
# -	Bug fixes
#
# Ignore (pas de modification de version) :
# -	Modif code interne SANS modification de comportement (fonctionnel)
# -	Code cleaning
#
# (*) bloc : fichiers, groupes de KW/methode developpes pour une fonctionnalite,
# ex : ReadConfig.py, Connect.robot, Oam.robot, Capture.robot,...
# ===============================================================================================================

SWENG_VERSION = "2.0.0"
