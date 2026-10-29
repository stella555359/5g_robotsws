*** Settings ***
Documentation
...    Author: Izabela Muntean
...    Maintainer: Izabela Muntean
...    Test Description: Software management
...    Execution: /opt/ute/python/bin/robot -v CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d
...    /opt/ute/logs/ testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB007310-5G-A/5GC001576-DA_5GC000174/general.robot
...    Dryrun: /opt/ute/python/bin/robot -t "1.0 Activation_for_pre-downloaded_SW"
...    --dryrun --log NONE --report NONE --output NONE -v CONFIGURATION:dryrun -C off -d /home/ute/logs -L TRACE
...    testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB007310-5G-A/5GC001576-DA_5GC000174/general.robot

Resource    ../../resources/pretest_posttest.robot
Resource    ./resources/5GC001576-DA_5GC000174.robot

#Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN    SBTS00   SBTS23R1
#...    CLOUD_5G_CLASSICAL_FULLRACK_ASILL_ABIOB1B3_AEQN_ECPRI_ASILR_ABIOB4B6_ENB
#...    CA_BTS_OAM_VERIF    master_classicalbts_all  # SBTS22R1  SBTS22R2   SBTS22R3

Suite Setup       Run Keywords      5GC001576-DA_5GC000174.UTE TL Preparation
...               AND               Suite Preconditions
...               AND           Download SW

#Suite Setup       Suite Preconditions
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
[1.0] Activation_for_pre-downloaded_SW
    [Tags]    CRT
    [Documentation]
    ...
    5GC001576-DA_Activation_for_pre-downloaded_SW

[1.0] Configuration_backup
    [Tags]    CRT
    [Documentation]
    ...
    5GC001576-DA_Configuration_backup

[1.0] Software_download_reject
    [Tags]    CRT
    [Documentation]
    ...
    5GC001576-DA_Software_download_reject

[1.0] Stop_software_download
    [Tags]    CRT
    [Documentation]
    ...
    5GC001576-DA_Stop_software_download

[1.0] Save_SW_history_report
    [Tags]    CRT
    [Documentation]
    ...
   5GC001576-DA_Save_SW_history_report

[1.0] Save_SW_update_report
    [Tags]    CRT
    [Documentation]
    ...
    5GC001576-DA_Save_SW_update_report

[1.0] Software_rollback
    [Tags]    CRT
    [Documentation]
    ...
    5GC001576-DA_Software_rollback

