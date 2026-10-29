# @Time    : 2025/1/16 15:04
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @Group   : NSB MN RAN RD VRF HAZ3 5
# @File    : CB012192.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: NSB MN RAN RD VRF HAZ3 5
...    Feature CB012192 SSB to PRACH preamble mapping optimization - 5G FR1 TDD beamforming
Library       taf.ue.pioneer.client       WITH NAME           client
Force Tags    CRT_TRUNK
Resource      ${CURDIR}/CB012192_common_keywords.robot

Test Setup          MMW5 Common Case Setup    allowed_faults_ids=4569,8000
Test Teardown       MMW5 Common Case Teardown

*** Variables ***
${COMMON_SCF}    ${CURDIR}/COMMON_SCF.xml
${111_SCF}       ${CURDIR}/111_SCF.xml
${MODIFY_ONE_N56_DELTA}    ${CURDIR}/MODIFY_ONE_N56_DELTA.json
${MODIFY_TWO_N28_DELTA}    ${CURDIR}/MODIFY_TWO_N28_DELTA.json
${MODIFY_TWO_CELLS_DELTA}    ${CURDIR}/MODIFY_TWO_CELLS_DELTA.json
${CASE112_REPEAT_TIMES}    ${1}
${BTS_ID}    46484
${CELL0_PCI}    496

*** Test Cases ***
CB012192-5G-A_102_A1_2_SSBs_map_to_one_RACH_Occasion_with_one_UE_Nokia_Radios_SA_8UL_made2
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/23 10:58
    [Tags]    102
    COAM Commission with scf file    ${COMMON_SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=administrativeState    value=Locked
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-0
    ...    parameter=qRxLevMin    value=-30
    Sleep    300s

    Case102 UE Multi Attach Detach
    wait_until_next_5_min    extra_sleep_time=60
    Dcap Stop Trace Via Trace ID

    ${ue_log_xml_list}    Export UE DDIB Log to L1 XML
    ${beam_result}    Set Variable    &{EMPTY}
    FOR    ${ue_log_xml}    IN    @{ue_log_xml_list}
        ${beam_result}    get_ue_beam_id_and_rach_result    ${ue_log_xml}    ${beam_result}
    END
    Log To Console    ${beam_result}
    ${counter_ids}    Create Counter IDS From M55306C00001 To M55306C00064
    ${counter_values}    Get Counters Recent Values    counter_ids=${counter_ids}
    Log To Console    ${counter_values}
    Check SSB Counters Update Normally    ${counter_values}    ${beam_result}
    Check KPI NR_5013a Update Normally    ${counter_values}
    Check All attach Are Success in UElog    ${beam_result}
    Connect to gnb coam via ssl
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=administrativeState    value=Unlocked


CB012192-5G-C_112_Robustness_Online_recommissioning_during_RU_reset
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/26 11:10
    [Tags]    112
    COAM Commission with scf file    ${COMMON_SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=administrativeState    value=Locked
    Sleep    120s

    FOR    ${index}    IN RANGE    ${CASE112_REPEAT_TIMES}
        Case112 Reset RU And Recommissioning    ru_dist=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
        ...    cell_dist=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-0    delta_file=${MODIFY_ONE_N56_DELTA}
        Case112 Reset RU And Recommissioning    ru_dist=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
        ...    cell_dist=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-0    delta_file=${MODIFY_TWO_N28_DELTA}
    END

CB012192-5G-W_111_W_SSB_to_PRACH_preamble_mapping_optimization_SA_8UL_made2
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/23 10:59
    [Tags]    111
    COAM Commission with scf file    ${111_SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State
    Sleep    300s

    Case111 Multi UE Attch And Keep Traffic
    wait_until_next_5_min    extra_sleep_time=60

    ${ue_log_xml_list}    Export UE DDIB Log to L1 XML
    ${beam_result}    Set Variable    &{EMPTY}
    FOR    ${ue_log_xml}    IN    @{ue_log_xml_list}
        ${beam_result}    get_ue_beam_id_and_rach_result    ${ue_log_xml}    ${beam_result}
    END
    Log To Console    ${beam_result}

    ${counter_ids_one}    Create Counter IDS From M55306C00001 To M55306C00064
    ${feature_off_cell1_values}    Get Counters Recent Values    counter_ids=${counter_ids_one}    nrcell=NRCELL-0
    ${feature_off_cell2_values}    Get Counters Recent Values    counter_ids=${counter_ids_one}    nrcell=NRCELL-1
    ${feature_off_cell2_sum_value}    Set Variable    0
    FOR    ${i}    IN RANGE    1    7
        ${feature_off_cell2_sum_value}    Evaluate    ${feature_off_cell2_sum_value}+${feature_off_cell2_values["M55306C0000${i}"]}
    END
    Run Keyword And Ignore Error    Check KPI NR_5013a Update Normally    ${feature_off_cell1_values}

    Connect to gnb coam via ssl
    coam.perform_delta_recommissioning    delta_file=${MODIFY_TWO_CELLS_DELTA}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Sleep    30s
    Wait Until Keyword Succeeds    5min    30s    Verify BTS 5G Cells Status Is Normal State
    Sleep    300s

    Case111 Multi UE Attch And Keep Traffic
    wait_until_next_5_min    extra_sleep_time=60

    ${ue_log_xml_list}    Export UE DDIB Log to L1 XML
    ${beam_result}    Set Variable    &{EMPTY}
    FOR    ${ue_log_xml}    IN    @{ue_log_xml_list}
        ${beam_result}    get_ue_beam_id_and_rach_result    ${ue_log_xml}    ${beam_result}
    END
    Log To Console    ${beam_result}

    ${counter_ids_two}    Create Counter IDS From M55306C00001 To M55306C00064
    ${feature_on_cell1_values}    Get Counters Recent Values    counter_ids=${counter_ids_two}    nrcell=NRCELL-0
    ${feature_on_cell2_values}    Get Counters Recent Values    counter_ids=${counter_ids_two}    nrcell=NRCELL-1
    ${feature_on_cell2_sum_value}    Set Variable    0
    FOR    ${i}    IN RANGE    1    7
        ${feature_on_cell2_sum_value}    Evaluate    ${feature_on_cell2_sum_value}+${feature_on_cell2_values["M55306C0000${i}"]}
    END

    Run Keyword And Ignore Error    Check KPI NR_5013a Update Normally    ${feature_on_cell1_values}
    Should Be True    ${feature_off_cell2_sum_value}>=${feature_on_cell2_sum_value}

*** Keywords ***
Case102 UE Multi Attach Detach
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/23 15:19
    [Arguments]    ${need_bip_log}=True    ${bip_log}=bip_interface_mirroring    ${nr_cells}=NRCELL_R-0
    IF    ${need_bip_log}==True
        @{custom_profile_list}    Create List    ${bip_log}
        Dcap Start Trace Via Custom Profile    custom_profile_list=${custom_profile_list}
        ...    nr_cells=${nr_cells}
    END
    Pioneer Multi UE Require
    Run Keyword And Ignore Error    Pioneer Multi UE Poweroff
    Run Keyword And Ignore Error    Pioneer Multi UE Poweron
    Pioneer Multi UE Detach
    Pioneer Multi UE Attach
    Pioneer Multi UE Detach
    Pioneer Multi UE Poweroff
    [Teardown]    Pioneer Multi UE Teardown

Case112 Multi UE Attch And Keep Traffic
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/24 15:08
    Pioneer Multi UE Require    start_log=False
    Run Keyword And Ignore Error    Pioneer Multi UE Poweroff
    Run Keyword And Ignore Error    Pioneer Multi UE Poweron
    Pioneer Multi UE Verify Attach    bts_id=${BTS_ID}    pci=${CELL0_PCI}
    Pioneer Multi UE Start Traffic
    Sleep    10s
    ${tp_results}    Pioneer Multi UE Check Traffic
    Pioneer Multi UE Stop Traffic
    Pioneer Multi UE Poweroff
    [Return]    ${tp_results}
    [Teardown]    Pioneer Multi UE Teardown

Case111 Multi UE Attch And Keep Traffic
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/02/05 11:30
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=qRxLevMin    value=-22
    Pioneer Multi UE Require
    Run Keyword And Ignore Error    Pioneer Multi UE Poweroff
    Run Keyword And Ignore Error    Pioneer Multi UE Poweron
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=qRxLevMin    value=-60
    Pioneer Multi UE Start Traffic
    Sleep    10s
    ${tp_results}    Pioneer Multi UE Check Traffic
    Pioneer Multi UE Stop Traffic
    Pioneer Multi UE Poweroff
    [Return]    ${tp_results}
    [Teardown]    Pioneer Multi UE Teardown

Case112 Reset RU And Recommissioning
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/26 10:39
    [Arguments]    ${ru_dist}    ${cell_dist}    ${delta_file}    ${connection}=GNB_OAM
    Run Keyword And Ignore Error    coam.reset_unit    dist_name=${ru_dist}    connection=${connection}
    Wait Until Keyword Succeeds    3min    10s    Verify BTS Single RU Status Is Reset State    dist_name=${ru_dist}
    coam.perform_delta_recommissioning    delta_file=${delta_file}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=${connection}
    Wait Until Keyword Succeeds    10min    30s    Verify BTS Single Cell Status Is Normal State    ${cell_dist}
    ${tp_results}    Case112 Multi UE Attch And Keep Traffic
    [Return]    ${tp_results}
