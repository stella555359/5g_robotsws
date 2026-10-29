*** Settings ***
Documentation
...    Author: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Maintainer: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC002399-A-a3
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB008313/5GC002399/general.robot

Resource    ./resources/5GC002399.robot

Force Tags   STATE_CONFIGURED  RAN_5G  RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all
...    CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    CA_BTS_OAM_FMRECOV    #QCP_BTS_OAM   QCD_MN_BTS_OAM  #21A_classicalbts  #20Bb1_classicalbts SBTS22R1

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
[1.0] 5GC002399-A-a3_BTS_Site_reset_L2RT
    [Tags]   CIT   SBTS22R1  SBTS22R2   SBTS00   SBTS22R3   SBTS22R4   SBTS23R1
    [Documentation]
    ...     Test modified after feature 5GC002399-A-B1
    BTS_Site_reset_L2RT

[1.0] 5GC002399-A-a3_BTS_commissioning_L2RT
    [Tags]   CRT    SBTS22R3
    [Documentation]
    ...     Test modified after feature 5GC002399-A-B1
    BTS_commissioning_L2RT


