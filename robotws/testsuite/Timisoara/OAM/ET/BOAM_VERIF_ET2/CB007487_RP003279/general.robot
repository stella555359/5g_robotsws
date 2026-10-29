*** Settings ***
Documentation
...    Author: Izabela Muntean (izabela.muntean@nokia.com)
...    Maintainer: Izabela Muntean (izabela.muntean@nokia.com)
...    Group in charge: RAN_BOAM_VERIF
...    References: doors
...    Feature Description: CB007487
...    Sample execution: /
...

Resource    ./resources/CB007487.robot

#Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all    SBTS00
#...    CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD
#...    CA_BTS_OAM_FMRECOV

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
CB007487_Capacity_unit_Hot_remove_CPRI
    [Tags]   CRT
    [Documentation]
    ...
    CB007487_Capacity_unit_Hot_remove_CPRI


