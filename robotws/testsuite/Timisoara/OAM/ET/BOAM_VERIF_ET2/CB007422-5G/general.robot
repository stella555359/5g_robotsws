*** Settings ***
Documentation
...    Author: Dan Novacescu (dan.novacescu@nokia.com)
...    Maintainer: Dan Novacescu (dan.novacescu@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:CB007422-5G
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/CB007422-5G/general.robot

Resource    ./resources/CB007422-5G.robot

#Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN    SBTS00      SBTS23R1   master_classicalbts_all
#...    CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD     ##CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#...    CA_BTS_OAM_VERIF    #QCP_BTS_OAM  QCD_MN_BTS_OAM    #SBTS21B  SBTS22R1  SBTS22R3  SBTS22R4


Suite Setup       Suite Preconditions
Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions for CB007422
Test Teardown     Test Postconditions for CB007422

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True


*** Test Cases ***
CB007422-5G-1_Fault_4592_triggering_with_actFaultSignature
    [Tags]   CIT   SBTS22R1   SBTS22R2
    [Documentation]
    CB007422-5G-1_Fault_4592_triggering_with_actFaultSignature

CB007422-5G-2_Fault_4383_triggering_with_actFaultSignature
    [Tags]   CRT
    [Documentation]
    CB007422-5G-2_Fault_4383_triggering_with_actFaultSignature


