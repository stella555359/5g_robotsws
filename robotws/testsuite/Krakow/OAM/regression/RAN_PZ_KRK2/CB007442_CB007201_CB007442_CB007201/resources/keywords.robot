*** Settings ***
Documentation
...    Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    Maintainer: Przemyslaw Kusa, przemyslaw.kusa@nokia.com

Library     String
Library     Collections
Library     taf.transport.ssh    WITH NAME    ssh
Library     taf.sbts.oam.coam.admin    WITH NAME    coam
Library     taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME   DuAlarms
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    GnbCellOp
Library     taf.rfrl.bts.devices.du.logs_collecting.basic_logs.GnbLog    WITH NAME    GnbLogs
Library     testsuite.Krakow.OAM.regression.RAN_PZ_KRK2.CB007442_CB007201_CB007442_CB007201.resources.DuCustom.GnbDuCustom
...         WITH NAME    GnbDu

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ./UE_keywords.robot

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${CU_ADDRESS}                      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${CU_USERNAME}                     ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${CU_PASSWORD}                     ${tl.gnbs[0].cu.oam_ssh_connection_details.password}

${LOKI_A_CELL_GROUP}               NRCELLGRP-0
${LOKI_B_CELL_GROUP}               NRCELLGRP-1

${REPORTING_TIME_INTERVAL}         1
${RECEPTION_SLOT}                  1023
${EXCEPTION_SLOT}                  170
${RU_MODE}                         NR_Only
${PRACH_CONFIGURATION_INDEX}       38
${PRACH_ROOT_SEQUENCE_INDEX}       1
${DELAY_PATTERN_DURATION}          0
@{BEAM_ID_PRACH}                   0
${ZERO_CORRELATION_ZONE_CONFIG}    0
${CONSTANT_OFFSET}                 0
${PFA_TARGET_PRACH_ID}             P_None
${PREAMBLE_INDEX}                  0
${ACCEPTED_TIMING_ERROR}           100
${PRACH_SEQ_TYPE}                  Unrestricted

${PUCCH_FORMAT}                    F0
${NUMBER_OF_PUCCH_SYMBOL}          1
@{BEAM_ID_PUCCH}                   0
${PRB_OFFSET}                      0
${LARGEST_PRB_INDEX}               0
${PUCCH_PAYLOAD_CONTENT}           0
${NUMPUCCHSYMBOL}                  1
${NUM_PAYLOAD_BIT}                 1

${FRC_INDEX}                       G_FR2_A3_4
${DIGITAL_OUTPUT_RATE}             Bitrate_115dot2K
${DIGITAL_OUT_TYPE}                SerialRs
@{BEAM_ID}                         0
${BB_SELECTOR}                     0
${UL_DMRS_MAPPING_TYPE}            A

@{ALARMS_LIST}                     BTS Reset Cause

*** Keywords ***
Connect To BTS
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}

    coam.connect_to    bts_host=${bts_host}
    ...                username=${username}
    ...                password=${password}
    ...                name=${connection}

Disonnect From BTS
    [Arguments]    ${connection}=GNB_OAM
    coam.teardown    connection=${connection}

Wait Until All Cells Are Operating Correctly
    Wait Until Keyword Succeeds    15 min    30 sec    Verify All Cells Are Operating Correctly

Verify All Cells Are Operating Correctly
    GnbCellOp.verify_all_cells_are_onair

Connect To ABIO
    ssh.connect_to    hostname=${CU_ADDRESS}
    ...               username=${CU_USERNAME}
    ...               password=${CU_PASSWORD}
    ...               alias=ABIO

Trigger Fault Report After BTS Reset
    Connect To ABIO
    ${pidinfo}    ssh.execute
    ...           command=ps aux | grep "FRI" | grep -v grep | awk '{print $2}'
    ...           connection=ABIO
    ${pidinfo}    Strip String    ${pidinfo}
    ${status}    ssh.execute    command=kill -11 ${pidinfo}    connection=ABIO
    Should Be Empty    ${status}
    [Teardown]    ssh.disconnect    connection=ABIO

Escalate Loki A Reset Procedure
    Repeat Keyword   3x   L1 5G Loki A Reset On Critical Failure

L1 5G Loki A Reset On Critical Failure
    Trigger Loki A Auto Reset
    Wait Until Loki Autonomus Reset Alarm Is Raised
    Verify Loki A Cells Are Not OnAir
    Verify Loki B Cells Are OnAir
    Wait Until All Cells Are Operating Correctly

Escalate Capacity Core Unit 5G L3 SW Reset On Critical Failure
    Repeat Keyword   3x   Trigger Capacity Core Unit 5G L3 SW Reset On Critical Failure

Trigger Capacity Core Unit 5G L3 SW Reset On Critical Failure
    Trigger CPUE Auto Reset
    Wait Until Internal Autonomus Reset Recovery Alarm Is Raised
    Verify Loki A Cells Are OnAir
    Verify Loki B Cells Are OnAir
    Wait Until All Cells Are Operating Correctly

Escalate Capacity Core Unit 5G L2 NRT SW Reset On Critical Failure
    Repeat Keyword   3x   Trigger Capacity Core Unit 5G L2 NRT SW Reset On Critical Failure

Trigger Capacity Core Unit 5G L2 NRT SW Reset On Critical Failure
    Trigger UPUE Auto Reset
    Wait Until Internal Autonomus Reset Recovery Alarm Is Raised
    Verify Loki A Cells Are OnAir
    Verify Loki B Cells Are OnAir
    Wait Until All Cells Are Operating Correctly

Escalate Capacity Core Unit 5G L2 RT SW Reset On Critical Failure
    Repeat Keyword   3x   Trigger Capacity Core Unit 5G L2 RT SW Reset On Critical Failure

Trigger Capacity Core Unit 5G L2 RT SW Reset On Critical Failure
    Trigger L2RT Auto Reset
    Wait Until Internal Autonomus Reset Recovery Alarm Is Raised
    Verify Loki A Cells Are Not OnAir
    Verify Loki B Cells Are OnAir
    Wait Until All Cells Are Operating Correctly

Wait Until Loki Baseband Card Autonomus Reset Alarm Is Raised
    Wait Until Keyword Succeeds    5 min    15 sec    DuAlarms.verify_alarm_is_active
    ...                                               fault_name=Baseband card autonomous reset as recovery action
    ...                                               fault_id=2087

Wait Until RAT Autonomus Reset Alarm Is Raised
    Log To Console    Waiting up to 20 min to trigger "Fault signature for crash or failure" alarm...
    Wait Until Keyword Succeeds    20 min    30 sec    DuAlarms.verify_alarm_is_active
    ...                                                fault_name=Fault signature for crash or failure
    ...                                                fault_id=4590

Wait Until Loki Autonomus Reset Alarm Is Raised
    Wait Until Keyword Succeeds    5 min    15 sec    DuAlarms.verify_alarm_is_active
    ...                                                fault_name=SoC autonomous reset as recovery action
    ...                                                fault_id=2087

Wait Until Rat Autonomus Reset Recovery Alarm Is Raised
    Wait Until Keyword Succeeds    5 min    15 sec    DuAlarms.verify_alarm_is_active
    ...                                               fault_name=RAT autonomous reset as recovery action
    ...                                               fault_id=4383

Wait Until Internal Autonomus Reset Recovery Alarm Is Raised
    Wait Until Keyword Succeeds    5 min    15 sec    DuAlarms.verify_alarm_is_active
    ...                                               fault_name=Internal BTS processes autonomous reset as recovery action
    ...                                               fault_id=4383

Wait Until Loki A Cells Are Not On Air
    Wait Until Keyword Succeeds    1 min    15 sec    Verify Loki A Cells Are Not OnAir

Verify Loki A Cells Are Not OnAir
    Verify Cell Group Cells Are Not OnAir    cell_group=${LOKI_A_CELL_GROUP}

Verify Loki A Cells Are OnAir
    Verify Cell Group Cells Are OnAir    cell_group=${LOKI_A_CELL_GROUP}

Verify Loki B Cells Are OnAir
    Verify Cell Group Cells Are OnAir    cell_group=${LOKI_B_CELL_GROUP}

Verify Cell Group Cells Are OnAir
    [Arguments]    ${cell_group}    ${connection}=GNB_OAM
    Connect To BTS    connection=${connection}
    ${cell_info}   coam.get_subcells_status   timeout=20    connection=${connection}
    ${cells_in_cell_group}    Get from Dictionary    ${cell_info}    ${cell_group}
    Verify All Cells In Cell Group Are OnAir    cells_in_cell_group=${cells_in_cell_group}
    [Teardown]    Disonnect From BTS    connection=${connection}

Verify Cell Group Cells Are Not OnAir
    [Arguments]    ${cell_group}    ${connection}=GNB_OAM
    Connect To BTS    connection=${connection}
    ${cell_info}   coam.get_subcells_status   timeout=20    connection=${connection}
    ${cells_in_cell_group}    Get from Dictionary    ${cell_info}    ${cell_group}
    Verify All Cells In Cell Group Are Not OnAir    cells_in_cell_group=${cells_in_cell_group}
    [Teardown]    Disonnect From BTS    connection=${connection}

Verify Software Version
    [Arguments]    ${connection}=GNB_OAM
    Connect To BTS    connection=${connection}
    ${sw_version}    coam.get_sw_version    connection=${connection}
    ${result}    Run Keyword And Return Status    Should Contain Any
    ...                                           ${sw_version}
    ...                                           12.400    14.400    22R1    22R2    21B
    [Return]    ${result}

Verify All Cells In Cell Group Are OnAir
    [Arguments]   ${cells_in_cell_group}    ${connection}=GNB_OAM
    ${result}    Verify Software Version    connection=${connection}
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${cell_list}    Get Dictionary Keys    ${cells_in_cell_group}
    FOR  ${cell}  IN   @{cell_list}
        ${eachcell}    Get From Dictionary    ${cells_in_cell_group}    ${cell}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${eachcell['NRCELL_R']['administrativeState']}     ${unlocked}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${eachcell['NRCELL_R']['operationalState']}   ${enabled}
        Run Keyword If    ${result}    Run Keyword And Continue On Failure
        ...    Should Be Equal As Strings    ${eachcell['NRCELL_R']['availabilityStatus']}    Online
    END

Verify All Cells In Cell Group Are Not OnAir
    [Arguments]   ${cells_in_cell_group}    ${connection}=GNB_OAM
    ${result}    Verify Software Version    connection=${connection}
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${disabled}    Set Variable If    ${result}    Disabled    disabled
    ${cell_list}    Get Dictionary Keys    ${cells_in_cell_group}
    FOR  ${cell}  IN   @{cell_list}
        ${eachcell}    Get From Dictionary    ${cells_in_cell_group}    ${cell}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${eachcell['NRCELL_R']['administrativeState']}    ${unlocked}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${eachcell['NRCELL_R']['operationalState']}    ${disabled}
    END

Lock Lane From SFP Via GUI
    [Arguments]    ${hw_name}=ABIO    ${object_name}=RF1    ${lane_id}=LANE-1
    GnbDu.lock_lane_from_sfp_via_gui    hw_name=${hw_name}
    ...                                   object_name=${object_name}
    ...                                   lane_id=${lane_id}

Unlock Lane From SFP Via GUI
    [Arguments]    ${hw_name}=ABIO    ${object_name}=RF1    ${lane_id}=LANE-1
    GnbDu.unlock_lane_from_sfp_via_gui    hw_name=${hw_name}
    ...                                   object_name=${object_name}
    ...                                   lane_id=${lane_id}

Verify SFP Status
    [Arguments]    ${status}    ${hw_name}=ABIO    ${connector}=RF1
    ${sfp_port_info}    GnbDu.get_hw_info    hw_name=${hw_name}
    ...                                      connector=${connector}
    ${sfp_status}    Set Variable    ${sfp_port_info}[Status][Operational state]
    Should Be Equal    ${sfp_status}    ${status}

Wait Until SFP Status Is Disabled
    Wait Until Keyword Succeeds    2 min    30 sec    Verify SFP Status    status=disabled

Wait Until SFP Status Is Enabled
    Wait Until Keyword Succeeds    2 min    30 sec    Verify SFP Status    status=enabled

Validate TCP Data Transfer
    Prepare Ue
    Run One Way TCP DL Data Transfer
    Run One Way TCP UL Data Transfer

Set Cell Info
    [Arguments]    ${class_name}=NRCELL_R    ${connection}=GNB_OAM
    Connect To BTS    connection=${connection}
    ${managed_objects}   coam.get_managed_objects    class_name=${class_name}
    ...                                              connection=${connection}
    ...                                              timeout=${300}
    Set Test Variable    ${NRCELL_R}    ${managed_objects[0]['distName']}
    ${cell_info}    coam.get_cell_specific_info    cell_id=${nrcell_r}
    ...                                            connection=${connection}
    ...                                            timeout=${60}
    Set Test Variable     ${NRARFCN}    ${cell_info['nrarfcn']}
    Set Test Variable     ${PHYSICAL_CELL_ID}    ${cell_info['physicalCellId']}
    [Teardown]    Disonnect From BTS    connection=${connection}

Reset To Test Dedicated
    [Arguments]    ${connection}=GNB_OAM
    Connect To BTS    connection=${connection}
    coam.reset_to_test_dedicated    connection=${connection}
    Sleep    3 min    reason=Waiting for reset
    [Teardown]    Disonnect From BTS    connection=${connection}

Start Uplink Prach Test
    [Arguments]    ${connection}=GNB_OAM
    coam.start_5g_uplink_ccm_test_prach    dist_name=${NRCELL_R}
    ...                                    nrarfcn_ul=${NRARFCN}
    ...                                    nrarfcn_dl=${NRARFCN}
    ...                                    interval=${REPORTING_TIME_INTERVAL}
    ...                                    receiving_slot=${RECEPTION_SLOT}
    ...                                    expectation_slot=${EXCEPTION_SLOT}
    ...                                    ru_mode=${RU_MODE}
    ...                                    prach_configuration_index=${PRACH_CONFIGURATION_INDEX}
    ...                                    prach_root_sequence_index=${PRACH_ROOT_SEQUENCE_INDEX}
    ...                                    delay_pattern_single_step_duration=${DELAY_PATTERN_DURATION}
    ...                                    beam_pattern_id=${BEAM_ID_PRACH}
    ...                                    phys_cell_id=${PHYSICAL_CELL_ID}
    ...                                    zero_correlation_zone_config=${ZERO_CORRELATION_ZONE_CONFIG}
    ...                                    constant_offset=${CONSTANT_OFFSET}
    ...                                    pfa_target_prach_id=${PFA_TARGET_PRACH_ID}
    ...                                    preamble_index=${PREAMBLE_INDEX}
    ...                                    accepted_timing_error=${ACCEPTED_TIMING_ERROR}
    ...                                    prach_sequence_type=${PRACH_SEQ_TYPE}
    ...                                    connection=${connection}
    ...                                    digital_output_enable=False
    ...                                    act_high_speed_cell=False
    Sleep    30s    reason=Waiting for 5G uplink CCM Prach test

Validate Prach Test Results
    [Arguments]    ${connection}=GNB_OAM
    ${result}    coam.watch_5g_uplink_ccm_test_results    nr_cell_rdn=${NRCELL_R}
    ...                                                   connection=${connection}
    ${missedCounter}    Get From Dictionary    ${result}    missedCounter
    ${idlePeriodCounter}    Get From Dictionary    ${result}    idlePeriodCounter
    Should Be Equal As Strings    ${missedCounter}    800
    Should Be Equal As Strings    ${idlePeriodCounter}    800


Start Uplink Pucch Test
    [Arguments]    ${connection}=GNB_OAM
    coam.start_5g_uplink_ccm_test_pucch    dist_name=${NRCELL_R}
    ...                                    nrarfcn_dl=${NRARFCN}
    ...                                    nrarfcn_ul=${NRARFCN}
    ...                                    interval=${REPORTING_TIME_INTERVAL}
    ...                                    receiving_slot=${RECEPTION_SLOT}
    ...                                    expectation_slot=${EXCEPTION_SLOT}
    ...                                    ru_mode=${RU_MODE}
    ...                                    pucch_format=${PUCCH_FORMAT}
    ...                                    num_pucch_symbol=${NUMBER_OF_PUCCH_SYMBOL}
    ...                                    beam_pattern_id=${BEAM_ID_PUCCH}
    ...                                    phys_cell_id=${PHYSICAL_CELL_ID}
    ...                                    prb_offset=${PRB_OFFSET}
    ...                                    largest_prb_index=${LARGEST_PRB_INDEX}
    ...                                    pucch_payload_content=${PUCCH_PAYLOAD_CONTENT}
    ...                                    format3_additional_dmrs=Disabled
    ...                                    num_pucch_symbol=${NUMPUCCHSYMBOL}
    ...                                    num_payload_bit=${NUM_PAYLOAD_BIT}
    ...                                    connection=${connection}
    ...                                    digital_output_enable=False
    ...                                    act_high_speed_cell=False
    Sleep    30s    reason=Waiting for 5G Uplink CCM Pucch test

Validate Pucch Test Results
    [Arguments]    ${connection}=GNB_OAM
    ${result}    coam.watch_5g_uplink_ccm_test_results    nr_cell_rdn=${NRCELL_R}
    ...                                                   connection=${connection}
    ${idlePeriodCounter}    Get From Dictionary    ${result}    idlePeriodCounter
    Should Be Equal As Strings    ${idlePeriodCounter}    800

Start Uplink Pusch Test
    [Arguments]    ${connection}=GNB_OAM
    coam.start_5g_uplink_ccm_test_pusch    dist_name=${NRCELL_R}
    ...                                    frc_index=${FRC_INDEX}
    ...                                    interval=${REPORTING_TIME_INTERVAL}
    ...                                    digital_out_rate=${DIGITAL_OUTPUT_RATE}
    ...                                    digital_out_type=${DIGITAL_OUT_TYPE}
    ...                                    beam_pattern_id=${BEAM_ID}
    ...                                    ru_mode=${RU_MODE}
    ...                                    phys_cell_id=${PHYSICAL_CELL_ID}
    ...                                    bb_selector=${BB_SELECTOR}
    ...                                    prb_offset=${PRB_OFFSET}
    ...                                    nrarfcn_ul=${NRARFCN}
    ...                                    ul_dmrs_mapping_type=${UL_DMRS_MAPPING_TYPE}
    ...                                    is_ptrs_fr2_enabled=false
    ...                                    connection=${connection}
    ...                                    digital_output_enable=True
    ...                                    nrarfcn_dl=${NRARFCN}
    ...                                    act_high_speed_cell=false
    Sleep    30s    reason=Waiting for 5G Uplink CCM Pusch test

Validate Pusch Test Results
    [Arguments]    ${connection}=GNB_OAM
    ${result}    coam.watch_5g_uplink_ccm_test_results    nr_cell_rdn=${NRCELL_R}
    ...                                                   connection=${connection}
    ${missedCounter1}    Get From Dictionary    ${result}    missedCounter1
    ${numberOfUnreceivedBits}    Get From Dictionary    ${result}    numberOfUnreceivedBits
    Should Be Equal As Strings    ${missedCounter1}    0
    Should Not Be Equal As Strings    ${numberOfUnreceivedBits}    0

Stop Performance Test
    [Arguments]    ${connection}=GNB_OAM
    coam.stop_5g_uplink_ccm_test
     ...                dist_name=${NRCELL_R}
     ...                connection=${connection}

Exit Test Dedicated
    [Arguments]    ${connection}=GNB_OAM
    Connect To BTS    connection=${connection}
    coam.reset_site    connection=${connection}
    Wait Until All Cells Are Operating Correctly
    [Teardown]    Disonnect From BTS    connection=${connection}

Set Allowed Alarms
    Set Suite Variable    @{allowed_alarms}    SSH enabled
    ...                                        R&D Service Port enabled
    ...                                        Service account root access is enabled
    ...                                        Ethernet port security is disabled
    ...                                        LMP access via port 443
    ...                                        Setup of X2 connectivity to gNB failed
    ...                                        LMP connectivity detected
    ...                                        Diagnostic Check Error
    ...                                        Sanity Check Error
    ...                                        Diagnostic Files collected
    ...                                        Diagnostic files collected
    ...                                        No X2 link available
    ...                                        No X2 link available for a specific LTEENB

Custom Test Setup
    [Arguments]    ${connection}=GNB_OAM
    Connect To BTS    connection=${connection}
    Set Allowed Alarms
    Common Preconditions
    coam.reset_site   timeout=600
    ...               connection=${connection}
    Sleep    2 min    reason=Waiting for reset
    Wait Until All Cells Are Operating Correctly

Suite Setup Custom
    Common Suite Setup With OnAir Test Line Preparation
    ...    swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
    ...    prefix_tag=TL151
    ...    list_of_additional_allowed_alarms=@{ALARMS_LIST}
