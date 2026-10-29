*** Settings ***
Documentation
...    Author: Andreea Zaharia (andreea-oana.zaharia@nokia.com)
...    Maintainer: Andreea Zaharia (andreea-oana.zaharia@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC001525-SA-TA
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/CB005752-5G-A_5GC000174/resources/CB005752-5G-A_5GC000174.robot

Resource    ./resources/CB005752-5G-A_5GC000174.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot

#Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN   SBTS00    SBTS23R1   master_classicalbts_all
#...    CLOUD_5G_O_E_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD   CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD   #CLOUD_5G_O_E_AP_KL_SANSA_FS_CPRI_CMWV_FDD
#...    CA_BTS_OAM_FMRECOV    #QCP_BTS_OAM  QCD_MN_BTS_OAM    #21A_classicalbts  #20Bb1_classicalbts  SBTS21B  SBTS22R1   SBTS22R2   SBTS22R3


Suite Setup       Run Keywords    Suite Preconditions
...               AND             Download SW
Suite Teardown    Suite Postconditions
Test Setup        Run Keywords    Reach OnAir Setup for OE
...               AND             Test Preconditions
Test Teardown     Run Keywords    Reach OnAir Teardown
...               AND             Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

*** Test Cases ***
Software download reject.
#    [Tags]   CRT
    [Documentation]
    ...
    CB005752-5G-A-_5GC000174_Software_download_reject


Robustness Stop software download.
 #   [Tags]    CRT
    [Documentation]
    ...
    CB005752-5G-A-_5GC000174_Robustness_Stop_software_download
