*** Settings ***
Documentation
...    Author: Monika Szlovak (monika.szlovak@nokia.com)
...    Maintainer: Monika Szlovak (monika.szlovak@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB007308-5G_5GC000371
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d /opt/ute/logs/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/CB007308-5G_5GC000371/general.robot

Resource    ./resources/5GC002056-AZ_5GC000371.robot
#Resource     ../resources/admin.robot

#Force Tags   STATE_SW_UPLOADED  RAN_5G  RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all   SBTS00     SBTS22R4
#...    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4-B5_AHEGA_AZNA_CPRI       #SBTS22R1   SBTS22R2  SBTS22R3
#...    CA_BTS_OAM_FMRECOV

#Test moved to OSS based on regression transfer activity

Suite Setup       Run Keywords      UTE TL Preparation
...               AND               Suite Preconditions


Suite Teardown    Suite Postconditions
Test Teardown     Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

*** Test Cases ***
[1.0] ABION_CB008423_5GC000371-Collect_logs_after_FCT_Critical_Process_Crash
    [Tags]   CRT
    [Documentation]
    ...
    ABION_CB008423_5GC000371-Collect_logs_after_FCT_Critical_Process_Crash

[1.0] ABION_CB008423_5GC000371-Snapshot_collection_is_triggered_by_radio_recovery
    [Tags]   CRT
    [Documentation]
    ...
    ABION_CB008423_5GC000371-Snapshot_collection_is_triggered_by_radio_recovery

[1.0] ABION_CB008423_5GC000371-Snapshot_collection_is_triggered_by_autonomous_radio_recovery
    [Tags]   CRT
    [Documentation]
    ...
    ABION_CB008423_5GC000371-Snapshot_collection_is_triggered_by_autonomous_radio_recovery
