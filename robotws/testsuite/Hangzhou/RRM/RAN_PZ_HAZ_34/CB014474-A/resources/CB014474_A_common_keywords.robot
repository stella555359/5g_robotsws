*** Settings ***
Documentation     author: Chen Helen
...               contact: helen.1.chen@nokia-sbell.com
...               squad group: MMW_02

Library      taf.selenium.sbts    WITH NAME    selenium_coam
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB006915/resources/CB006915_common_keywords.robot
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB006915/resources/CB006915_TTI_Trace_Analysis.py
Library          ./CB014474_A_TTI_Trace_Analysis.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007113/resources/CB007113_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/traffic.robot

*** Variables ***
${DN_PREFIX}    MRBTS-11332/NRBTS-11332/
${mcs_type}    hbte
${mcs_index}   0

*** Keywords ***
Check Two UEs Pair with init-Tx Rat0
    ${specific_ttitrace_file}    Get_and_Unzip_Tti_Log
    ${result}    find_two_initTx_ues_paired_with_rat0
    ...    csv_file=${specific_ttitrace_file}[0]
    ...    filter_name1=muStatus
    ...    filter_name2=rat0Bitmap
    ...    filter_name3=txNumber
    ...    filter_name4=sfn
    ...    filter_name5=slot
    ...    filter_name6=rnti
    Should be True    ${result}

Check Two UEs Pair with re-Tx Rat0
    ${specific_ttitrace_file}    Get_and_Unzip_Tti_Log
    ${result}    find_two_reTx_ues_paired_with_rat0
    ...    csv_file=${specific_ttitrace_file}[0]
    ...    filter_name1=muStatus
    ...    filter_name2=rat0Bitmap
    ...    filter_name3=txNumber
    ...    filter_name4=sfn
    ...    filter_name5=slot
    ...    filter_name6=rnti
    Should be True    ${result}

Retry Check UEs Pair With Rat0
    [Arguments]    ${check_type}=init-Tx    ${cell_index}=1
    ${retry_times}    Set Variable    3
    FOR    ${times}    IN RANGE    ${retry_times}
        Catch_Logs_with_gnb_logs_14474    cell_index=${cell_index}
        Get_and_Unzip_Tti_Log
        ${check_result}    Run Keyword And Return Status
        ...    Run Keyword If    '${check_type}' == 'init-Tx'    Check Two UEs Pair with init-Tx Rat0
        ...    ELSE IF    '${check_type}' == 're-Tx'    Check Two UEs Pair with re-Tx Rat0
        ...    ELSE IF    '${check_type}' == 'both'
        ...    Run Keywords
        ...    Check Two UEs Pair with init-Tx Rat0
        ...    AND    Check Two UEs Pair with re-Tx Rat0
        Exit For Loop If    ${check_result}
    END
    Should Be True    ${check_result}

Enable or Disable 14861
    [Arguments]    ${status}    ${nrcell_index}=1
    [Documentation]    Enables or disables feature 14681 by modifying related parameters.
    ...    It sets 'actExhaustiveScheduling' to 'DL'/'disabled' and 'actPtpMetric' to 'true'/'false'.
    ...    :param status: 'enable' to turn on the feature, 'disable' to turn it off.
    ...    :param nrcell_index: The index of the NRCELL to be modified. Defaults to 1.

    ${dn}    Set Variable    ${DN_PREFIX}NRCELL-${nrcell_index}
    ${connection_alias}    Set Variable    GNB_OAM

    # Set values based on 'enable' or 'disable' status
    ${exhaustive_scheduling_val}    Set Variable If    '${status}' == 'enable'    DL    disabled
    ${ptp_metric_val}    Set Variable If    '${status}' == 'enable'    true    false

    Log    Setting parameters for feature 14681 to '${status}' on ${dn}
    ${param1}    Create Dictionary    dist_name=${dn}    parameter=actExhaustiveScheduling    value=${exhaustive_scheduling_val}
    ${param2}    Create Dictionary    dist_name=${dn}    parameter=actPtpMetric    value=${ptp_metric_val}
    ${params_to_update}    Create List    ${param1}    ${param2}
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${params_to_update}
    ...    connection=${connection_alias}

Enable or Disable 14474
    [Arguments]    ${status}    ${nrcell_index}=1
    [Documentation]    Enables or disables feature 14474 by modifying related parameters.
    ...    It sets 'actEnhDynSwitchRat0' and 'actPrbLimForVoNrRat1' to 'true'/'false'.
    ...    :param status: 'enable' to turn on the feature, 'disable' to turn it off.
    ...    :param nrcell_index: The index of the NRCELL to be modified. Defaults to 1.

    ${dn}    Set Variable    ${DN_PREFIX}NRCELL-${nrcell_index}
    ${connection_alias}    Set Variable    GNB_OAM

    # Set values based on 'enable' or 'disable' status
    ${param_val}    Set Variable If    '${status}' == 'enable'    true    false

    Log    Setting parameters for feature 14474 to '${status}' on ${dn}
    ${param1}    Create Dictionary    dist_name=${dn}    parameter=actEnhDynSwitchRat0    value=${param_val}
#    ${param2}    Create Dictionary    dist_name=${dn}    parameter=actPrbLimForVoNrRat1    value=${param_val}
    ${params_to_update}    Create List    ${param1}
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${params_to_update}
    ...    connection=${connection_alias}

Get Latest NR_5192e KPI Value
    [Arguments]    ${nrcell_index}=1
    [Documentation]    Get the latest value of KPI NR_5192e.
    ...    Formula: Sum([M55308C10010]) / Sum([M55308C00005] + [M55308C00015] + [M55308C00017])
    ...    :param nrcell_index: The index of the NRCELL. Defaults to 1.
    ...    :return: The calculated KPI value.

    ${dn}    Set Variable    ${DN_PREFIX}NRCELL-${nrcell_index}/NCELA
    ${connection_alias}    Set Variable    GNB_OAM

    ${counters}    Create List
    ...    M55308C10010
    ...    M55308C00005
    ...    M55308C00015
    ...    M55308C00017

    ${counter_values}    Get Latest Pm Counter Values By List
    ...    connection_alias=${connection_alias}
    ...    dic_path=${dn}
    ...    counter_id_list=${counters}

    ${numerator}    Set Variable    ${counter_values}[M55308C10010]
    ${denominator1}    Set Variable    ${counter_values}[M55308C00005]
    ${denominator2}    Set Variable    ${counter_values}[M55308C00015]
    ${denominator3}    Set Variable    ${counter_values}[M55308C00017]
    ${denominator}    Evaluate    ${denominator1} + ${denominator2} + ${denominator3}

    ${kpi_value}    Run Keyword If    ${denominator} > 0
    ...    Evaluate    ${numerator} / ${denominator}
    ...    ELSE
    ...    Set Variable    0

    [Return]    ${kpi_value}

Get Latest NR_5100c KPI Value
    [Arguments]    ${nrcell_index}=1
    [Documentation]    Get the latest value of KPI NR_5100c.
    ...    Formula: 8 * Sum([M55309C01001])/(Sum([M55308C02000] - [M55308C27001]) * Sum([M55308C00008]) / Sum([M55308C00005]))
    ...    :param nrcell_index: The index of the NRCELL. Defaults to 1.
    ...    :return: The calculated KPI value.

    ${M55309Cdn}    Set Variable    ${DN_PREFIX}NRCELL-${nrcell_index}/NMSDU
    ${M55308Cdn}    Set Variable    ${DN_PREFIX}NRCELL-${nrcell_index}/NCELA
    ${connection_alias}    Set Variable    GNB_OAM

    ${counters}    Create List
    ...    M55309C01001

    ${counter_values}    Get Latest Pm Counter Values By List
    ...    connection_alias=${connection_alias}
    ...    dic_path=${M55309Cdn}
    ...    counter_id_list=${counters}

    ${numerator}    Evaluate    8 * ${counter_values}[M55309C01001]

    ${counters}    Create List
    ...    M55308C02000
    ...    M55308C27001
    ...    M55308C00008
    ...    M55308C00005

    ${counter_values}    Get Latest Pm Counter Values By List
    ...    connection_alias=${connection_alias}
    ...    dic_path=${M55308Cdn}
    ...    counter_id_list=${counters}


    ${denominator_part1}    Evaluate    ${counter_values}[M55308C02000] - ${counter_values}[M55308C27001]
    ${denominator_part2}    Evaluate    ${counter_values}[M55308C00008] / ${counter_values}[M55308C00005]
    ${denominator}    Evaluate    ${denominator_part1} * ${denominator_part2}

    ${kpi_value}    Run Keyword If    ${denominator} > 0
    ...    Evaluate    ${numerator} / ${denominator}
    ...    ELSE
    ...    Set Variable    0

    [Return]    ${kpi_value}

Get Latest NR_5114b KPI Value
    [Arguments]    ${nrcell_index}=1
    [Documentation]    Get the latest value of KPI NR_5114b.
    ...    Formula: (100*Sum([M55308C10001] + [M55308C10015] + [M55308C10011])/Sum([M55308C10003]))
    ...    :param nrcell_index: The index of the NRCELL. Defaults to 1.
    ...    :return: The calculated KPI value.

    ${M55308Cdn}    Set Variable    ${DN_PREFIX}NRCELL-${nrcell_index}/NCELA
    ${connection_alias}    Set Variable    GNB_OAM

    ${counters}    Create List
    ...    M55308C10001
    ...    M55308C10015
    ...    M55308C10011
    ...    M55308C10003

    ${counter_values}    Get Latest Pm Counter Values By List
    ...    connection_alias=${connection_alias}
    ...    dic_path=${M55308Cdn}
    ...    counter_id_list=${counters}

    ${numerator}    Evaluate    100 * (${counter_values}[M55308C10001] + ${counter_values}[M55308C10015] + ${counter_values}[M55308C10011])
    ${denominator}    Set Variable    ${counter_values}[M55308C10003]

    ${kpi_value}    Run Keyword If    ${denominator} > 0
    ...    Evaluate    ${numerator} / ${denominator}
    ...    ELSE
    ...    Set Variable    0

    [Return]    ${kpi_value}

Get Latest NR_5244e KPI Value
    [Arguments]    ${nrcell_index}=1
    [Documentation]    Get the latest value of KPI NR_5244e.
    ...    :param nrcell_index: The index of the NRCELL. Defaults to 1.
    ...    :return: The calculated KPI value.

    ${M55304Cdn}    Set Variable    ${DN_PREFIX}NRCELL-${nrcell_index}/NMPDU
    ${M55308Cdn}    Set Variable    ${DN_PREFIX}NRCELL-${nrcell_index}/NCELA
    ${M55366Cdn}    Set Variable    ${DN_PREFIX}NRCELL-${nrcell_index}/DHQLSE
    ${dn}    Set Variable    ${DN_PREFIX}NRCELL-${nrcell_index}
    ${connection_alias}    Set Variable    GNB_OAM

    ${counters1}    Create List
    ...    M55304C01000    M55304C01001    M55304C01002    M55304C01003    M55304C01004
    ...    M55304C01005    M55304C01006    M55304C01007    M55304C01008    M55304C01009
    ...    M55304C01010    M55304C01011    M55304C01012    M55304C01013    M55304C01014
    ...    M55304C01015    M55304C01016    M55304C01017    M55304C01018    M55304C01019
    ...    M55304C01020    M55304C01021    M55304C01022    M55304C01023    M55304C01024
    ...    M55304C01025    M55304C01026    M55304C01027    M55304C01028
    ${counters2}    Create List
    ...    M55304C05000    M55304C05001    M55304C05002    M55304C05003    M55304C05004
    ...    M55304C05005    M55304C05006    M55304C05007    M55304C05008    M55304C05009
    ...    M55304C05010    M55304C05011    M55304C05012    M55304C05013    M55304C05014
    ...    M55304C05015    M55304C05016    M55304C05017    M55304C05018    M55304C05019
    ...    M55304C05020    M55304C05021    M55304C05022    M55304C05023    M55304C05024
    ...    M55304C05025    M55304C05026    M55304C05027
    ${counters3}    Create List
    ...    M55366C05000    M55366C05001    M55366C05002    M55366C05003    M55366C05004
    ...    M55366C05005    M55366C05006    M55366C05007    M55366C05008    M55366C05009
    ...    M55366C05010    M55366C05011    M55366C05012    M55366C05013    M55366C05014
    ...    M55366C05015    M55366C05016    M55366C05017    M55366C05018    M55366C05019
    ...    M55366C05020    M55366C05021    M55366C05022    M55366C05023    M55366C05024
    ...    M55366C05025    M55366C05026    M55366C05027    M55366C05028
    ${counters4}    Create List
    ...    M55304C00001
    ${other_counters}    Create List
    ...    M55308C10001    M55308C10003    M55308C10010
    ...    M55308C00005    M55308C00015    M55308C00017
    ${all_counters}    Catenate    ${counters1}    ${counters2}    ${counters3}    ${other_counters}

    ${counter1_values}    Get Latest Pm Counter Values By List
    ...    connection_alias=${connection_alias}
    ...    dic_path=${M55304Cdn}
    ...    counter_id_list=${counters1}

    ${counter2_values}    Get Latest Pm Counter Values By List
    ...    connection_alias=${connection_alias}
    ...    dic_path=${M55304Cdn}
    ...    counter_id_list=${counters2}

    ${counter3_values}    Get Latest Pm Counter Values By List
    ...    connection_alias=${connection_alias}
    ...    dic_path=${M55366Cdn}
    ...    counter_id_list=${counters3}

    ${counter4_values}    Get Latest Pm Counter Values By List
    ...    connection_alias=${connection_alias}
    ...    dic_path=${M55304Cdn}
    ...    counter_id_list=${counters4}

    ${other_counters_values}    Get Latest Pm Counter Values By List
    ...    connection_alias=${connection_alias}
    ...    dic_path=${M55308Cdn}
    ...    counter_id_list=${other_counters}

    ${sum1}    Evaluate    sum($counter1_values.values())
    ${sum2}    Evaluate    sum($counter2_values.values())
    ${sum3}    Evaluate    sum($counter3_values.values())

    ${part1_num}    Evaluate    8 * (${sum1} + ${sum2} + ${sum3})
    ${part1_den}    Set Variable    ${counter4_values}[M55304C00001]
    ${part1}    Run Keyword If    ${part1_den} > 0    Evaluate    ${part1_num} / ${part1_den}    ELSE    Set Variable    0

    ${part2_num}    Set Variable    ${other_counters_values}[M55308C10001]
    ${part2_den}    Set Variable    ${other_counters_values}[M55308C10003]
    ${part2}    Run Keyword If    ${part2_den} > 0    Evaluate    ${part2_num} / ${part2_den}    ELSE    Set Variable    0

    ${part3_num}    Set Variable    ${other_counters_values}[M55308C10010]
    ${part3_den}    Evaluate
    ...    ${other_counters_values}[M55308C00005] + ${other_counters_values}[M55308C00015] + ${other_counters_values}[M55308C00017]
    ${part3}    Run Keyword If    ${part3_den} > 0    Evaluate    ${part3_num} / ${part3_den}    ELSE    Set Variable    0

    ${denominator}    Run Keyword If    ${part2} != 0 and ${part3} != 0    Evaluate    ${part2} * ${part3}    ELSE    Set Variable    0
    ${kpi_value}    Run Keyword If    ${denominator} > 0    Evaluate    ${part1} / ${denominator}    ELSE    Set Variable    0

    [Return]    ${kpi_value}

Get Latest Pm Counter Values By List
    [Arguments]    ${connection_alias}    ${dic_path}    ${counter_id_list}
    ${counters_dict}    COAM get pm counters dict via admin    connection_alias=${connection_alias}    counter_id_list=${counter_id_list}
    ${latest_values}=    Create Dictionary
    FOR    ${counter}    IN    @{counter_id_list}
        ${full_path}    Set Variable    ${dic_path}/${counter}
        ${value}    Get counter latest value from dict
        ...    counters_dict=${counters_dict}    BTS_or_TRS=BTS    full_path=${full_path}
        Set To Dictionary    ${latest_values}    ${counter}=${value}
    END
    [Return]    ${latest_values}

COAM get pm counters dict via admin
    [Arguments]   ${connection_alias}   ${counter_id_list}   ${timeout}=${900}
    ${counter_ids}   Set Variable   ,
    ${counter_ids}   Set Variable   ${counter_ids.join(${counter_id_list})}
    ${counters_dict}   coam.get_pm_counters
    ...   counter_ids=${counter_ids}
    ...   timeout=${timeout}
    ...   connection=${connection_alias}
    [Return]   ${counters_dict}

Get counter latest value from dict
    [Arguments]    ${counters_dict}    ${BTS_or_TRS}    ${full_path}
    ${keys}=    Split String    ${full_path}    /
    ${keys}=    Create List    ${BTS_or_TRS}    @{keys}
    ${value}=    Set Variable    ${counters_dict}
    FOR    ${key}    IN    @{keys}
        ${value}=    Get From Dictionary    ${value}    ${key}
    END
    ${all_keys}=    Get Dictionary Keys    ${value}
    ${last_key}=    Get From List    ${all_keys}    -1
    ${last_value}=    Get From Dictionary    ${value}    ${last_key}
    [Return]    ${last_value}

MCS_Add_Att_Value
    MCS_Setup    mcs_type=${mcs_type}    mcs_index=${mcs_index}
    Set Even And Odd ATT For Output Port   att_value=${20}    end_output_port={8}
    mcs_common.Teardown MCS    mcs_type=${mcs_type}    mcs_index=0    mcs_alias=MCS_${mcs_index}

MCS_Recover_Att_Value
    MCS_Setup    mcs_type=${mcs_type}    mcs_index=${mcs_index}
    Set Even And Odd ATT For Output Port   att_value=${10}    end_output_port={8}
    mcs_common.Teardown MCS    mcs_type=${mcs_type}    mcs_index=0    mcs_alias=MCS_${mcs_index}

Set Even And Odd ATT For Output Port
    [Arguments]    ${att_value}    ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
    ...    ${begin_output_port}=${1}    ${end_output_port}=${4}
    ...    ${begin_input_port}=${1}    ${end_input_port}=${32}    &{kwargs}
    hbte.Set Odd Attenuations For Output Port    begin_output_port=${begin_output_port}    end_output_port=${end_output_port}
    ...    attenuation=${att_value}    B_Odd=False    mcs_alias=${mcs_alias}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
    hbte.Set Even Attenuations For Output Port    begin_output_port=${begin_output_port}    end_output_port=${end_output_port}
    ...    attenuation=90    B_Odd=False    mcs_alias=${mcs_alias}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
    hbte.Set Odd Attenuations For Output Port    begin_output_port=${begin_output_port}    end_output_port=${end_output_port}
    ...    attenuation=90    B_Odd=True    mcs_alias=${mcs_alias}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
    hbte.Set Even Attenuations For Output Port    begin_output_port=${begin_output_port}    end_output_port=${end_output_port}
    ...    attenuation=${att_value}    B_Odd=True    mcs_alias=${mcs_alias}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}

Retry Check BWP1 BWP3 UE Switched To Rat0
    [Arguments]    ${check_type}=init-Tx    ${cell_index}=1
    ${retry_times}    Set Variable    3
    FOR    ${times}    IN RANGE    ${retry_times}
        Catch_Logs_with_gnb_logs_14474    cell_index=${cell_index}
        Get_and_Unzip_Tti_Log
        ${check_result}    Run Keyword And Return Status
        ...    Run Keyword If    '${check_type}' == 'init-Tx'    Check BWP13 UE with init-Tx Rat0
        ...    ELSE IF    '${check_type}' == 're-Tx'    Check BWP13 UE with re-Tx Rat0
        ...    ELSE IF    '${check_type}' == 'both'
        ...    Run Keywords
        ...    Check BWP13 UE with init-Tx Rat0
        ...    AND    Check BWP13 UE with re-Tx Rat0
        Exit For Loop If    ${check_result}
    END
    Should Be True    ${check_result}

Check BWP13 UE with init-Tx Rat0
    ${specific_ttitrace_file}    Get_and_Unzip_Tti_Log
    ${result}    find_BWP13_initTx_ue_with_rat0
    ...    csv_file=${specific_ttitrace_file}[0]
    ...    filter_name1=cellBwpId
    ...    filter_name2=rat0Bitmap
    ...    filter_name3=txNumber
    ...    filter_name4=rnti
    Should be True    ${result}

Check BWP13 UE with re-Tx Rat0
    ${specific_ttitrace_file}    Get_and_Unzip_Tti_Log
    ${result}    find_BWP13_reTx_ue_with_rat0
    ...    csv_file=${specific_ttitrace_file}[0]
    ...    filter_name1=cellBwpId
    ...    filter_name2=rat0Bitmap
    ...    filter_name3=txNumber
    ...    filter_name4=rnti
    Should be True    ${result}

MTP Attach And Start Traffic
    [Arguments]    ${MTP_ue_index}    ${MTP_ul_tp}    ${MTP_dl_tp}
    power_ue.Prepare UE    ue_index=${MTP_ue_index}    ue_type=qualcomm
	  sleep    2s
    log to console   UE Attach
	  power_ue.UE Attach    ue_index=${MTP_ue_index}    ue_type=qualcomm
  	sleep    2s
    UE Start UL&DL UDP Traffic    ue_index=${MTP_ue_index}    ul_tp=${MTP_ul_tp}    dl_tp=${MTP_dl_tp}

MTP Detach
    [Arguments]    ${MTP_ue_index}
    power_ue.UE Detach   ue_index=${MTP_ue_index}    ue_type=qualcomm

#TL2025 Keywords
MTK UE Click on airplane mode
    [Documentation]   click AIRPLANE
    ...    :param  ue_mode: Attach  or  Dettach
    [Arguments]   ${ue_mode}    ${ue_index}=${3}
    Connect to control pc via cygwin    ue_index=${ue_index}
    Run Keyword If    '${ue_mode}'=='Dettach'    Dettach UE By Adb Command    ue_index=${ue_index}
    Run Keyword If    '${ue_mode}'=='Attach'    Run Keywords    Dettach UE By Adb Command    ue_index=${ue_index}    AND
    ...    Attach UE By Adb Command    ue_index=${ue_index}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect      connection=cygwin

Dettach UE By Adb Command
    [Arguments]    ${ue_index}=${0}
    ${serial_number}    Set Variable    ${tl.ues[${ue_index}].serial_number}
    Run Keyword and Ignore Error   csn.send_command    command=adb -s ${serial_number} root    connection=cygwin
    sleep   4s
    Run Keyword and Ignore Error   csn.send_command    command=adb -s ${serial_number} shell settings put global airplane_mode_on 1
    ...    connection=cygwin
    sleep   4s
    Run Keyword and Ignore Error   csn.send_command
    ...    command=adb -s ${serial_number} shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true    connection=cygwin
    sleep   4s

Attach UE By Adb Command
    [Arguments]    ${ue_index}=${0}
    ${serial_number}    Set Variable    ${tl.ues[${ue_index}].serial_number}
    Run Keyword and Ignore Error   csn.send_command    command=adb -s ${serial_number} root    connection=cygwin
    sleep   4s
    Run Keyword and Ignore Error   csn.send_command    command=adb -s ${serial_number} shell settings put global airplane_mode_on 0
    ...    connection=cygwin
    sleep   4s
    Run Keyword and Ignore Error   csn.send_command
    ...    command=adb -s ${serial_number} shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state false    connection=cygwin
    sleep   4s

Check DL Throught From Asslog
    [Arguments]    ${dl_list}=${cell_list}    ${dl_tp}=500
    ...    ${target_avg_percent}=0.98   ${log_time}=60s    ${min_percent}=0.85    ${ignore_time}=10s
    ${log_path}    power_ue.Collect Tput   ue_type=samsung    duration=${log_time}    ignore_time=${ignore_time}
    ${dl_result}    run keyword and continue on failure    power_ue.Check Tput    ue_type=samsung
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${dl_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${True}    min_percent=${min_percent}
    Log to console    ${dl_result}

Multi M90 Dyn UE L3 Call and Start Traffic
    [Arguments]    ${dl_tput}=100Mbits/sec    ${ue_index}=${m90_dynamic_ue_index}    ${iperf_port}=${iperf_port_list[0]}
    Log to console    \nM90 Dyn 10M UE Attach
    MTK UE Click on airplane mode    ue_mode=Attach   ue_index=${ue_index}
    Log to console    M90 Dyn 10M UE Start Traffic ${dl_tput}
    power_ue.Start traffic    ue_type=samsung    direction=dl    throughput=${dl_tput}    ue_index=${ue_index}
    ...   protocol=udp    duration=1200    iperf_port=${iperf_port}
    log to console    M90 10M dynamic UE start dl traffic

Multi M90 UE Stop traffic and detach with UEindex
    [Arguments]    ${ue_index}=${m90_dynamic_ue_index}    ${iperf_port}=${iperf_port_list[0]}
    Log to console    M90 dyn UE Stop traffic and detach
    Run Keyword And Ignore Error    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}
    ...    ue_type=samsung    iperf_port=${iperf_port}
    Run Keyword And Ignore Error    MTK UE Click on airplane mode    ue_mode=Dettach    ue_index=${ue_index}

TL2025_Case_Setup
    Log To Console    \n *** Case setup
    robot_common_operations.Common Case Setup
    ${connection}=    Set Variable If    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}

TL2025Case_Teardown
    Log To Console    \n *** Case teardown
    Run Keyword And Ignore Error    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    CI interface.Common Case Teardown
    TL2025Case_Teardown_Ssh_Copy_TTI_to_Log
    Run Keyword If Test Failed    TL2025Case_Teardown_Ssh_Copy_TTI_to_Log
    Run Keyword And Ignore Error    TL2025Case_Teardown_Ssh_Remove_TTI

TL2025Case_Teardown_Ssh_Copy_TTI_to_Log
    [Arguments]
    ...    ${tti_script_path}=/home/ute/gnb_logs
    Log To Console    Copy TTI under ${tti_script_path} to ${OUTPUT_DIR}/${TEST NAME}/
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    Run Keyword And Ignore Error    ssh.send command    command=cp -r ${tti_script_path}/BTS-37050_${gnb_ip}_*_TTI* "${OUTPUT_DIR}/${TEST NAME}/"
    ...    connection=ute
    Run Keyword And Ignore Error    ssh.disconnect    connection=ute

TL2025Case_Teardown_Ssh_Remove_TTI
    [Arguments]
    ...    ${tti_script_path}=/home/ute/gnb_logs
    ...    ${new_dir}=/home/ute/output_log/
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    Run Keyword And Ignore Error    ssh.send command    command=rm -rf ${tti_script_path}/BTS-37050_${gnb_ip}_*_TTI
    ...    connection=ute
    Run Keyword And Ignore Error    ssh.send command    command=rm -rf ${new_dir}/BTS-37050_${gnb_ip}_*_TTI
    ...    connection=ute
    Run Keyword And Ignore Error    ssh.disconnect    connection=ute

Topyoung_MCS_Add_Att_Value
    ${mcs_type}    Set Variable    topyoung
    MCS_Setup    mcs_type=${mcs_type}    mcs_index=${mcs_index}
    topyoung.Set Odd And Even ATT For Output Port    att_value=${45}
    ...    begin_output_port=${1}    end_output_port=${8}    begin_input_port=${1}    end_input_port=${64}
    mcs_common.Teardown MCS    mcs_type=${mcs_type}    mcs_index=0    mcs_alias=MCS_${mcs_index}

Topyoung_MCS_Recover_Att_Value
    ${mcs_type}    Set Variable    topyoung
    MCS_Setup    mcs_type=${mcs_type}    mcs_index=${mcs_index}
    topyoung.Set Odd And Even ATT For Output Port    att_value=${15}
    ...    begin_output_port=${1}    end_output_port=${8}    begin_input_port=${1}    end_input_port=${64}
    mcs_common.Teardown MCS    mcs_type=${mcs_type}    mcs_index=0    mcs_alias=MCS_${mcs_index}

Catch_Logs_with_gnb_logs_14474
    [Arguments]
    ...            ${duration}=3
    ...            ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${log_type}=TTI
    ...            ${cell_index}=1
    log to console    --- start gnb_logs collection---
    ${log_type_to_command_mapping}    Create Dictionary    TTI=t    BIP=b   m=m
    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    ssh.send command    command=cd ${gnb_logs_script_path}&&sudo rm *${log_type}.zip   connection=ute
    ${start_capture_command}     Catenate
    ...    sudo ./gnb_logs ${gnb_ip} -C ${cell_index} -${log_type_to_command_mapping['${log_type}']} ${duration}
    ...    tti_Raw_logs_only = no
    ssh.send command    command=cd ${gnb_logs_script_path}&&${start_capture_command}   connection=ute
    ${stop_capture}    ssh.read output until    finished    timeout=6000   connection=ute
    Run Keyword And Ignore Error    ssh.disconnect    connection=ute