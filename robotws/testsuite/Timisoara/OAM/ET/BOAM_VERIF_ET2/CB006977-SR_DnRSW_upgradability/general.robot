*** Settings ***
Documentation
...    Author: Andreea Zaharia (andreea-oana.zaharia@nokia.com)
...    Maintainer: Andreea Zaharia (andreea-oana.zaharia@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB006977
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/CB006977-SR_DnRSW_upgradability/general.robot

Resource    ./resources/CB006977.robot
Resource    ./resources/keyword.robot
Resource    ./resources/CB006977_keywords.robot
#Resource    ../5GC001525-SA-TA/resources/keyword.robot
#Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot


Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all     SBTS00     SBTS22R4  SBTS23R1
...    	   	CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...         CA_BTS_OAM_FMRECOV   #QCP_BTS_OAM   QCD_MN_BTS_OAM   #21A_classicalbts  #20Bb1_classicalbts  SBTS21B  SBTS22R2   SBTS22R3


Suite Setup       run keywords    Suite Preconditions
...               AND             Download SW
Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

*** Test Cases ***
DnRSW_Download_and_Distribution
    [Tags]    CRT
    [Documentation]
    ...
    DnRSW_Download_and_Distribution

DnRSW_functionality_shall_not_be_impacted_by_BTS_SW_Rollback
    [Tags]    CRT
    [Documentation]
    ...
    DnRSW_functionality_shall_not_be_impacted_by_BTS_SW_Rollback

#SW_Update_Abort_during_DnRSW_Distribution
#    [Tags]    CRT
#    [Documentation]
#    ...
#    SW_Update_Abort_during_DnRSW_Distribution

