*** Settings ***
Documentation
...    Author: Madalin Budulan (madalin.budulan@nokia.com)
...    Maintainer: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC000470-E-a_5GC001525-SA
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d /opt/ute/logs/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/5GC000470-E-a_5GC001525-SA/general.robot

Resource    ./resources/5GC000470-E-a_5GC001525-SA.robot

Force Tags   STATE_CONFIGURED  RAN_5G  RAN_5G_TDD  5G_RAN_TDD  5G_RAN  SBTS00   SBTS22R4   SBTS23R1   master_classicalbts_all
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CA_BTS_OAM_FMRECOV
# QCP_BTS_OAM    QCD_MN_BTS_OAM     #21A_classicalbts  #20Bb1_classicalbts   SBTS21B   SBTS22R1  SBTS22R2

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

[1.0] 5GC000470-E-a_5GC001525-SA_Fault_generation_10
    [Tags]   CIT   SBTS22R1  SBTS22R2  SBTS22R3
    [Documentation]
    ...
    5GC000470-E-a_5GC001525-SA_Fault_generation_10


[1.0] 5GC000470-E-a_5GC001525-SA_Fault_generation_23
    [Tags]   CRT
    [Documentation]
    ...
    5GC000470-E-a_5GC001525-SA_Fault_generation_23
