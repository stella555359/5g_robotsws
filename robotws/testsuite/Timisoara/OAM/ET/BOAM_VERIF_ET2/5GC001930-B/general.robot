*** Settings ***

Documentation
...    Author: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Maintainer: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC001930-B
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC001930-B/general.robot

Resource    ./resources/5GC001930-B.robot

#Trunk regression moved on ABIO Parity
#Force Tags   STATE_CONFIGURED  5G_RAN_TDD  5G_RAN  20Bb1_classicalbts   #master_classicalbts_all  
#...    CLOUD_5G_KL_AP_NSA_FS_CMWV
#...    CA_BTS_OAM_FMRECOV    QCP_BTS_OAM    QCD_MN_BTS_OAM

Suite Setup       Suite Preconditions
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
5GC001930-B_Simplified_Site_View_BBMOD_and_SMOD_visualization_in_Mobile_WEBEM
   # [Tags]   CIT
    [Documentation]
    ...
    5GC001930-B_Simplified_Site_View_BBMOD_and_SMOD_visualization_in_Mobile_WEBEM

5GC001930-B_Simplified_Site_View_RMOD_visualization_in_Mobile_WEBEM
   # [Tags]   CRT
    [Documentation]
    ...
    5GC001930-B_Simplified_Site_View_RMOD_visualization_in_Mobile_WEBEM

5GC001930-B_Simplified_Site_View_cells_visualization_in_Mobile_WEBEM
   # [Tags]   CRT
    [Documentation]
    ...
    5GC001930-B_Simplified_Site_View_cells_visualization_in_Mobile_WEBEM
