*** Settings ***
Documentation
...    Author: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Maintainer: Andreea Zaharia (andreea-oana.zaharia@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC002056-AZ_5GC001930-A
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC002056-AZ_5GC001930-A/general.robot

Resource    ./resources/5GC001930-A.robot

#Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all     SBTS22R4  SBTS23R1
#...    CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD    CA_BTS_OAM_FMRECOV
#QCP_BTS_OAM    QCD_MN_BTS_OAM    #21A_classicalbts   SBTS21B  SBTS22R1  SBTS22R2  SBTS22R3   
#                                                  SBTS00    - transfered to ST

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
5GC001930-A-a_ABION_Display_SW_information_in_Mobile_WEBEM
    [Tags]   CRT     #merged with ABION_Display_Basic_BTS_information_in_Mobile_WEBEM
    [Documentation]
    ...
    5GC001930-A-a_ABION_Display_SW_information_in_Mobile_WEBEM


#5GC001930-A-a_ABION_Display_Basic_BTS_information_in_Mobile_WEBEM
#    [Tags]   CRT
#    [Documentation]
#    ...
#    5GC001930-A-a_ABION_Display_Basic_BTS_information_in_Mobile_WEBEM

