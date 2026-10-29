*** Settings ***


Documentation
...    Author:
...    Maintainer:
...    Test Description: Fault_triggered_automatic_snapshot_to_remote_LSS_via_sftp_when_fault_is_detected_in_BTS
...    Confluence link: link
...    Group in charge:
...    References: doors
...    QualityCenter:
...    Sample execution:
...    Execution: pybot -v CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d /opt/ute/logs/
...    testsuite/WMP/SOAM3/5G/5GC001542-RA/general.robot
...    Dryrun: pybot -t "5GC001542_RA_Fault_triggered_automatic_snapshot_to_remote_LSS_via_sftp_when_fault_is_detected_in_BTS"
...    --dryrun --log NONE  --report NONE --output NONE
...    -v CONFIGURATION:dryrun -C off -d /home/ute/logs -L TRACE testsuite/WMP/SOAM3/5G/5GC001542-RA/general.robot
...    Dryrun: pybot -t "5GC001542_RA_Fault_triggered_automatic_snapshot_to_remote_LSS_via_sftp_when_fault_is_detected_in_BTS"
...    --dryrun --log NONE  --report NONE --output
...    NONE -v CONFIGURATION:dryrun -C off -d /home/ute/logs -L TRACE testsuite/WMP/SOAM3/5G/5GC001542-RA/general.robot
...    Review: -
...    AC/REQ:

Resource    ./resources/5GC001542-RA.robot

#Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN   SBTS00     SBTS23R1
#...    CLOUD_5G_CLASSICAL_FULLRACK_ASILL_ABIOB1B3_AEQN_ECPRI_ASILR_ABIOB4B6_ENB
#...    CA_OAM    CA_MANO_SOAM3   CA_BTS_OAM_VERIF    master_classicalbts_all   #SBTS22R2   SBTS22R3

#
Suite Setup       Run Keywords      5GC001542-RA.UTE TL Preparation
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
[1.0] 5GC001542_RA_Fault_triggered_automatic_snapshot_to_remote_LSS_via_sftp_when_fault_is_detected_in_BTS
    [Tags]    CRT
    5GC001542_RA_Fault_triggered_automatic_snapshot_to_remote_LSS_via_sftp_when_fault_is_detected_in_BTS




