*** Settings ***
Documentation
...    Author: Madalin Budulan (madalin.budulan@nokia.com)
...    Maintainer: Zaharia Andreea-Oana (andreea-oana.zaharia@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB007944
...    Sample execution: /
...

Resource    ./resources/CB007944.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all    SBTS00    SBTS22R4  SBTS23R1
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    CA_BTS_OAM_FMRECOV    #SBTS22R3

Suite Setup       Run Keywords  Suite Preconditions
...               AND           Prepare testline for CB007944
Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Run Keywords  Test Postconditions
...               AND       Remove already used preparation files


*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True


*** Test Cases ***
CB007944_SW_Pre_check_No_available_disk_space_in_single_core_mode
    [Tags]   CRT
    [Documentation]
    ...
    CB007944_SW_Pre_check_No_available_disk_space_in_single_core_mode


