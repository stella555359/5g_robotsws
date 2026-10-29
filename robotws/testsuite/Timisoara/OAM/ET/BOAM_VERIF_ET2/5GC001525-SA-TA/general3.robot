*** Settings ***
Documentation
...    Author: Madalin Budulan (madalin.budulan@nokia.com)
...    Maintainer: Anca Secea (anca.secea@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC001525-SA-TA
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC001525-SA-TA/general.robot

Resource    ./resources/5GC001525-SA-TA.robot
#Resource    ./resources/keyword.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN      SBTS00   SBTS22R4  SBTS23R1    master_classicalbts_all
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD              #21A_classicalbts 
...    CA_BTS_OAM_FMRECOV    #QCP_BTS_OAM   QCD_MN_BTS_OAM     #20Bb1_classicalbts  SBTS21B  SBTS22R1  SBTS22R2  SBTS22R3

Suite Setup       run keywords  Suite Preconditions
...               AND           Download SW
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
5GC001525-SA-TA-Fault_generation_30
    [Tags]   CRT
    [Documentation]
    ...
   Fault_generation_30
