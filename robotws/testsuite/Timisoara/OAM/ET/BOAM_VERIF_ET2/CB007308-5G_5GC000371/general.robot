*** Settings ***
Documentation
...    Author: Monika Szlovak (monika.szlovak@nokia.com)
...    Maintainer: Monika Szlovak (monika.szlovak@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB007308-5G_5GC000371
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d /opt/ute/logs/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB007308-5G_5GC000371/general.robot

Resource    ./resources/CB007308-5G_5GC000371.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all
...    CLOUD_5G_O_E_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD   #SBTS00  SBTS22R1
...    CA_BTS_OAM_FMRECOV

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
[1.0] CB007308-5G_5GC000371-Collect_logs_after_FCT_Critical_Process_Crash
    [Tags]   CRT
    [Documentation]
    ...
    CB007308-5G_5GC000371-Collect_logs_after_FCT_Critical_Process_Crash

[1.0] CB007308-5G_5GC000371-Snapshot_collection_is_triggered_by_radio_recovery
    [Tags]   CRT
    [Documentation]
    ...
    CB007308-5G_5GC000371-Snapshot_collection_is_triggered_by_radio_recovery

[1.0] CB007308-5G_5GC000371-Snapshot_collection_is_triggered_by_autonomous_radio_recovery
    [Tags]   CRT
    [Documentation]
    ...
    CB007308-5G_5GC000371-Snapshot_collection_is_triggered_by_autonomous_radio_recovery


