*** Settings ***
Documentation
...    Author: Perecz Alexandru (alexandru.perecz@nokia.com)
...    Maintainer: Perecz Alexandru (alexandru.perecz@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB008082
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC002421-A/general.robot

Resource    ./resources/CB008082.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN   master_classicalbts_all   SBTS00   SBTS23R1
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD   CA_BTS_OAM_FMRECOV

Suite Setup       Run Keywords  Suite Preconditions
...               AND           ADMIN_CLI Suite Setup
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
[1]CB008082_ADMIN_CLI_getGpsInventoryList
    [Tags]   CRT
    [Documentation]
    ...
    ADMIN_CLI_getGpsInventoryList
