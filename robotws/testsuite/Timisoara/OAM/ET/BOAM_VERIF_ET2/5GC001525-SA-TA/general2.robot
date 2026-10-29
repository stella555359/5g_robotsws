*** Settings ***
Documentation
...    Author: Madalin Budulan (madalin.budulan@nokia.com)
...    Maintainer: Anca Secea (anca.secea@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC001525-SA-TA
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/5GC001525-SA-TA/general.robot

Resource    ./resources/5GC001525-SA-TA.robot
#Resource    ./resources/keyword.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN   SBTS00  SBTS22R4  SBTS23R1
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD      master_classicalbts_all
...    CA_BTS_OAM_FMRECOV   #QCP_BTS_OAM   QCD_MN_BTS_OAM      # 21A_classicalbts    SBTS22R2  SBTS22R3

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
5GC001525-SA-TA-Fault_generation_29
    [Tags]   CRT
    [Documentation]
    ...
    Fault_generation_29



