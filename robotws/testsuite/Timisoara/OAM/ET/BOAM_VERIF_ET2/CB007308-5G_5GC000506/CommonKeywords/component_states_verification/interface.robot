*** Settings ***
Documentation
...    Author: damian.muszynski@nokia.com
...    Maintainer: damian.muszynski@nokia.com
...    Team in charge: I_EXT_5G_IV_WRO_OAM3_GMS


Resource    OnAirCheckers/CheckOnAir.robot

Resource    OnResetCheckers/GNSS_first_reset_checkers.robot
Resource    OnResetCheckers/BBMOD_reset_checkers.robot
Resource    OnResetCheckers/RU_reset_checkers.robot

Resource    OnLockedCheckers/BBMOD_locked_checkers.robot
Resource    OnLockedCheckers/Cell_locked_checkers.robot
Resource    OnLockedCheckers/COAM_BTS_locked_checkers.robot
Resource    OnLockedCheckers/RU_locked_checkers.robot
