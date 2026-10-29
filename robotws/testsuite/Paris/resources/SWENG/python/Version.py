# ===============================================================================================================
# Version Management
# 1 - Update version in confluence :
#     https://confluence.ext.net.nokia.com/display/5GFTPARIS/AF+%28SWENG%29+Delivery+Announcement+to+NPS+VRF+teams
#
# 2 - Regenerate the documentation when version is modified:
#     To so this update, connect to the documentation serverand run the command hereafter
#     ssh sweng5G@10.183.129.164 (no password needed)
#     cd /CinqG/sweng5G/doc_sweng ; ./doc ; ./stat ; ./ver_reduce
# ---------------------------------------------------------------------------------------------------------------
# Versioning suggested rules : sweng version X.Y.Z
#
# X :
# -	Major modification of the operation of an existing block* (refactoring).
# -	Major functional modification related to adaptation to new constraints (UTE, HW, framework)
# -	Addition of a large functional block*
#
# Y :
# -	Modification of existing KW/method interface for external use WITHOUT backward compatibility
#   (requires test suite modification).
# -	Addition of KW/method for external use (functional addition in an existing block*)
# -	Functional addition in an existing block* (addition of KW/method for external use, support of new topology)
#
# Z :
# -	Modification of existing KW/method interface for external use WITH backward compatibility
#   (no need to modify test suites).
# -	Modification of existing KW/method interface for internal use in SWENG.
# -	Addition of KW/method for internal SWENG use
# -	Internal code modification WITH behavior change (functional)
# -	Bug fixes
#
# Ignore (no version modification) :
# -	Internal code modification WITHOUT behavior change (functional)
# -	Code cleaning
#
# (*) block : files, groups of KW/methods developed for a functionality,
# e.g. : ReadConfig.py, Connect.robot, Oam.robot, Capture.robot,...
# ===============================================================================================================

SWENG_VERSION = "5.4.5"
