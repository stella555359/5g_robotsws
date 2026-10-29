*** Settings ***


Documentation
...    Author:
...    Maintainer:
...    Test Description:
...    Confluence link: link
...    Group in charge:
...    References: doors
...    QualityCenter:
...    Sample execution:
...    Execution: pybot -v CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d /opt/ute/logs/
...    testsuite/WMP/SOAM3/5G/5GC001526-TA/general.robot
...    Dryrun: pybot -t "[1.0] 5G1526_TA_Snapshot_collection_is_triggered_by_autonomous_radio_recovery" --dryrun --log NONE
...    --report NONE --output NONE
...    -v CONFIGURATION:dryrun -C off -d /home/ute/logs -L TRACE testsuite/WMP/SOAM3/5G/5GC001526-TA/general.robot
...    Dryrun: pybot -t "[1.0] 5G1526_TA_Snapshot_collection_is_triggered_by_autonomous_radio_recovery" --dryrun --log NONE
...    --report NONE --output
...    NONE -v CONFIGURATION:dryrun -C off -d /home/ute/logs -L TRACE testsuite/WMP/SOAM3/5G/5GC001526-TA/general.robot
...    Review: -
...    AC/REQ:

Resource    ./resources/5GC001526-MA.robot

Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN   SBTS00   SBTS22R4   SBTS23R1
...    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AZQG_CPRI_ENB
...    CA_OAM    CA_MANO_SOAM3   CA_BTS_OAM_VERIF    master_classicalbts_all  #SBTS22R2  SBTS22R3

#Suite Setup       Run Keywords  Suite Preconditions
Suite Setup       Run Keywords      5GC001526-MA.UTE TL Preparation
...               AND               Suite Preconditions


Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            False
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             False

*** Test Cases ***
[1.0] BTS_shall_raise_Fault_1898_EFaultId_PpsRefMissAl_with_severity_Major_when_BTS_does_not_receive_PPS_signal_from_any_of_the_configured_source
    [Tags]    CRT
    BTS_shall_raise_Fault_1898_EFaultId_PpsRefMissAl_with_severity_Major_when_BTS_does_not_receive_PPS_signal_from_any_of_the_configured_source




