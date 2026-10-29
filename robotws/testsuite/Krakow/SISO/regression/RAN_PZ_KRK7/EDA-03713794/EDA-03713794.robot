*** Settings ***
Documentation
...    Test suite for regression testing for EDA-03713794
...    authors: Jakub Bialon
...    group: RAN_PZ_KRK_SG_7
...    contact: jakub.bialon@nokia.com

Resource    resources/keywords.robot

Suite Setup    Common Suite Setup With OnAir Test Line Preparation
Suite Teardown    Common Suite Teardown
Test Setup    Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms

*** Variables ***
${UE_CAPABILITIES}    QUECTEL_UE
${UE_DEFAULT_ALIAS_NAME}    UE
${DATA_TRANSFER_DEFAULT_DURATION}    60s
${DEFAULT_PACKET_SIZE}    1380
${DEFAULT_PROTOCOL}    tcp
${DEFAULT_DEVIATION}    80%


*** Test Cases ***
[1][1.0] EDA-03713794_Lock_Unlock_Single_SFP_Check_Cell_Recalculation
    ${fault_10}=    Create Dictionary    alarm_id=7116
    ...                                  fault_id=10
    ...                                  fault_name=No connection to unit
    ...                                  severity=Critical
    ${fault_4003}=    Create Dictionary    alarm_id=7115
    ...                                    fault_id=4003
    ...                                    fault_name=Transmission path failure
    ...                                    severity=Minor
    ${expected_alarms}=    Create List    ${fault_10}    ${fault_4003}
    ${bts_id}=    Get Bts Id    bts_type=gnb
    @{sfp_id_lsit}    Create List    1  2  3  4  5  6  7  8  9  10  11  12
    FOR    ${SFP_id}    IN    @{sfp_id_lsit}
        gnbalarm.Allow Alarm    alarm=${expected_alarms}
        perform_configuration_parameter_recommissioning
        ...                             dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-${SFP_id}/LANE-1
        ...                             parameter=administrativeState
        ...                             operation=update
        ...                             value=Locked
        Sleep    2min    Waiting for SFP lock
        perform_configuration_parameter_recommissioning
        ...                             dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-${SFP_id}/LANE-1
        ...                             parameter=administrativeState
        ...                             operation=update
        ...                             value=Unlocked
        Wait Until Keyword Succeeds    180 sec    5 sec   gnbcell.Verify All Cells Are Onair
        gnbalarm.Disallow Alarm    alarm=${expected_alarms}
    END
    ${fault_49}=    Create Dictionary    alarm_id=7102
    ...                                  fault_id=49
    ...                                  fault_name=Cell blocked
    ...                                  severity=Critical
    ${expected_alarms}=    Create List    ${fault_49}
    gnbalarm.Allow Alarm    alarm=${expected_alarms}
    Check Data Transfer On Both Cells
    gnbalarm.Disallow Alarm    alarm=${expected_alarms}
