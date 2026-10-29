*** Settings ***
Documentation
...    Author: Radu Turcu (radu.turcu@nokia.com)
...    Maintainer: Radu Turcu (radu.turcu@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC000766-A
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/testsuite/OAM/ET/BTS_OAM_VERIF_ET1/5GC000766-A/general.robot

Resource    ./resources/5GC000766-A.robot

Force Tags   STATE_CONFIGURED  5G_RAN_FDD  5G_RAN  master_classicalbts_all   #21A_classicalbts
...    CLOUD_5G_KL_AP_NSA_FS_CMWV_TDD     SBTS00
...    CA_RAN_BOAM_VERIF

Suite Setup       Suite Preconditions
Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions  #With Reset Site

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

*** Test Cases ***

#Test1_Cells_n25_set_DualSectorBFProf_plus_minus_30degree_5MHz
#    [Tags]   CRT        QC_122280
#    [Documentation]
#    ...  RU AAFB, Cells band = n25, BW = 5MHz
#    Test1 - Cells_n25_set_DualSectorBFProf_plus_minus_30degree_5MHz

5GC000766-A Test2 - Cells_n66_set_DualSectorBFProf_plus_minus_30degree_5MHz
    [Tags]   CRT
    [Documentation]
    ...  RU AAIB, Cells band = n66, BW = 5MHz
    Test2 - Cells_n66_set_DualSectorBFProf_plus_minus_30degree_5MHz

5GC000766-A Test3 - Cells_n66_set_DualSectorBFProf_plus_minus_30degree_20MHz
    [Tags]   CRT
    [Documentation]
    ...  RU AAIB, Cells band = n66, BW = 20MHz
    Test3 - Cells_n66_set_DualSectorBFProf_plus_minus_30degree_20MHz

5GC000766-A Test4 - WebEM shall display the most important cell parameters in separate Details panel for cell selected on the BTS Runtime View
    [Tags]   CRT
    [Documentation]
    ...
    Test4 - WebEM shall display the most important cell parameters in separate Details panel for cell selected on the BTS Runtime View









