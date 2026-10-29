*** Settings ***
Documentation
...    Author: Monika Szlovak (monika.szlovak@nokia.com)
...    Maintainer: Monika Szlovak (monika.szlovak@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB005750_5G_EB_ET_5GC000371
...    Sample execution: /opt/ute/python3/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d /opt/ute/logs/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB005750_5G_EB_ET_5GC000371/general.robot

Resource    ./resources/CB005750_5G_EB_ET_5GC000371.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN    SBTS00   SBTS23R1   master_classicalbts_all
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    CA_BTS_OAM_FMRECOV    #QCP_BTS_OAM    QCD_MN_BTS_OAM   #21A_classicalbts  SBTS21B  SBTS22R1  SBTS22R3  SBTS22R4   SBTS23R1

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
#[1.0] CB005750-5G-EB-ET_5GC000371-Snapshot_collection_is_triggered_by_radio_recovery
#    [Tags]   CRT
#    [Documentation]
#    ...
#    CB005750-5G-EB-ET_5GC000371-Snapshot_collection_is_triggered_by_radio_recovery

[1.0] CB005750-5G-EB-ET_5GC000371-Snapshot_collection_is_triggered_by_autonomous_radio_recovery
    [Tags]   CRT
    [Documentation]
    ...
    CB005750-5G-EB-ET_5GC000371-Snapshot_collection_is_triggered_by_autonomous_radio_recovery

[1.0] CB005750-5G-EB-ET_5GC000371-Collect_logs_after_FCT_Critical_Process_Crash
    [Tags]   CRT
    [Documentation]
    ...
    CB005750-5G-EB-ET_5GC000371-Collect_logs_after_FCT_Critical_Process_Crash

