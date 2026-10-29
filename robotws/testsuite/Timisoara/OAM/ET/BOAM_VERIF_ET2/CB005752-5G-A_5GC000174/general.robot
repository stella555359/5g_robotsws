*** Settings ***
Documentation
...    Author: Andreea Zaharia (andreea-oana.zaharia@nokia.com)
...    Maintainer: Andreea Zaharia (andreea-oana.zaharia@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC001525-SA-TA
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB005752-5G-A_5GC000174/general.robot

Resource    ./resources/CB005752-5G-A_5GC000174.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot

#Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN   master_classicalbts_all
#...    CLOUD_5G_O_E_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD   CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#...    CA_BTS_OAM_FMRECOV    #QCP_BTS_OAM    QCD_MN_BTS_OAM   #21A_classicalbts  #20Bb1_classicalbts  SBTS21B  SBTS22R1  SBTS22R2


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

#Configuration backup
#    [Tags]    CRT        REMOVED_20_07_22_regr_opt   #SBTS22R3
#    [Documentation]
#    ...
#    CB005752-5G-A-_5GC000174_Configuration_backup


#Activation for pre-downloaded SW
#    [Tags]    CRT       REMOVED_20_07_22_regr_opt   #SBTS22R3
#   [Documentation]
#    ...
#   CB005752-5G-A-_5GC000174_Activation_for_pre-downloaded_SW


#Software rollback
 #   [Tags]    CRT    SBTS00    SBTS23R1
 #   [Documentation]
 #   ...
 #   CB005752-5G-A-_5GC000174_Software_rollback

#Save SW history report
#    [Tags]    CRT    REMOVED_20_07_22_regr_opt   #SBTS22R3
#    [Documentation]
#    ...
#   CB005752-5G-A-_5GC000174_Save_SW_history_report


Save SW update report
    [Tags]    CRT    SBTS00     SBTS23R1   #SBTS22R3
    [Documentation]
    ...
    CB005752-5G-A-_5GC000174_Save_SW_update_report

