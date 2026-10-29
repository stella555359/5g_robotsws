*** Settings ***
Force Tags    PY36
Documentation
...    Author: Xueqin Deng
...    Contact: xueqin.deng@nokia-sbell.com
...    Group: VRF_HAZ3_2
...    Feature: CB012464

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_cloud.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_Common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Cloud_VRAN40/common_setup_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

Test Setup    case_common_setup
Test Teardown    case_common_teardown

*** Variables ***
${actNrUlRipCounter_dist_name}    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRPMRNL-1/NRPMCCP-1
${actNrUlRipCounter_parameter}    actNrUlRipCounter
${MRBTS_ID}    37314
${counter_id_len}    5
${cell_dimension}    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3
${PMQAP_dimension}    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3/NRPMQAP-1
${SSBPM0_dimension}    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3/SSBPM-0
${SSBPM1_dimension}    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3/SSBPM-1
${PMQAP_prefix}    M55386C
${RIP_Sample_prefix}    M55388C
${RIP_Sched_prefix}    M55360C
${SSBPM_perfix}    M55202C
${5QI1_PMQAP_dimension}    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3/NRPMQAP-4
${5QI1_CQI_Prefix}    M55301C
${5QI1_CQI_dimension}    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3

*** Test Cases ***
[1]CB012464_CR_A_1_UL_PM_counters_rBLER_CP_OFDM_256QAM
    # Log to console    \n check ul bler counters
    # Basic_L3_call
    # ${PMQAP_counter_value}    get_last_counter_value_dict_for_vdu    counter_prefix=${PMQAP_prefix}
    # ...    counter_start=23    counter_end=65    counter_dimension=${PMQAP_dimension}
    # log to console    PMQAP_counter_value: ${PMQAP_counter_value}
    # set suite variable    ${PMQAP_counter_value}
    # Log to console    \n check ul bler counters
    # check_bler_counters    counter_value=${PMQAP_counter_value}    succ_drb_counter=29    fail_drb_counter=28
    Log to console    \n ul bler counters: M55386C00028 and M55386C00029 in FED status...

[1]CB012464_CR_A_2_UL_PM_counters_mcs_CP_OFDM_256QAM
    # Log to console    \n check ul mcs counters
    # ${sum}    get_counters_value_sum    counter_value=${PMQAP_counter_value}    counter_start=43    counter_end=47
    # should be true    ${sum}>0    ul mcs counters not update.
    Log to console    \n ul mcs counters: M55386C00043 to M55386C00047 in FED status...

[1]CB012464_CR_A_4_UL_PM_counters_rank2_CP_OFDM_256QAM
    Log to console    \n get radio quality counter per PMQAP: M55386C*
    Basic_L3_call
    ${PMQAP_counter_value_0}    get_last_counter_value_dict_for_vdu    counter_prefix=${PMQAP_prefix}
    ...    counter_start=23    counter_end=27    counter_dimension=${PMQAP_dimension}
    log to console    PMQAP_counter_value_0: ${PMQAP_counter_value_0}
    set suite variable    ${PMQAP_counter_value_0}
    ${PMQAP_counter_value_1}    get_last_counter_value_dict_for_vdu    counter_prefix=${PMQAP_prefix}
    ...    counter_start=30    counter_end=37    counter_dimension=${PMQAP_dimension}
    log to console    PMQAP_counter_value_1: ${PMQAP_counter_value_1}
    set suite variable    ${PMQAP_counter_value_1}
    ${PMQAP_counter_value_2}    get_last_counter_value_dict_for_vdu    counter_prefix=${PMQAP_prefix}
    ...    counter_start=53    counter_end=65    counter_dimension=${PMQAP_dimension}
    log to console    PMQAP_counter_value_2: ${PMQAP_counter_value_2}
    set suite variable    ${PMQAP_counter_value_2}
    Log to console    \n check ul rank2 counters
    ${sum}    get_counters_value_sum    counter_value=${PMQAP_counter_value_2}    counter_start=65    counter_end=65
	should be true    ${sum}>0    ul rank2 counters not update.

[1]CB012464_CR_A_14_DL_PM_counters_wbcqi_CP_OFDM_256QAM
    Log to console    \n check dl cqi counters
    ${sum}    get_counters_value_sum    counter_value=${PMQAP_counter_value_0}    counter_start=23    counter_end=27
    should be true    ${sum}>0    ul cqi counters not update.
    sleep    5s
    Perform_UE_Attach
    sleep    10s
    Perform and Check Vonr Call
    sleep    6min
    ${5QI1_PMQAP_counter_value}    get_last_counter_value_dict_for_vdu    counter_prefix=${PMQAP_prefix}
    ...    counter_start=23    counter_end=27    counter_dimension=${5QI1_PMQAP_dimension}
    log to console    5QI1_PMQAP_counter_value: ${5QI1_PMQAP_counter_value}
    ${5QI1_CQI_counter_value}    get_last_counter_value_dict_for_vdu    counter_prefix=${5QI1_CQI_Prefix}
    ...    counter_start=22000    counter_end=22015    counter_dimension=${5QI1_CQI_dimension}
    log to console    5QI1_CQI_counter_value: ${5QI1_CQI_counter_value}
    ${PMQAP_bins}    Create List    23    24    25    26    27
    ${CQI_bins}      Create List    22000-22002    22003-22005    22006-22009    22010-22013    22014-22015
    ${5QI1_PMQAP_sum}    get_counters_value_sum    counter_value=${5QI1_PMQAP_counter_value}    counter_start=23    counter_end=27
    FOR    ${index}    IN RANGE    0    5
        ${bin_start}    Set Variable    ${PMQAP_bins}[${index}]
        ${bin_end}      Set Variable    ${PMQAP_bins}[${index}]
        ${cqi_range}    Set Variable    ${CQI_bins}[${index}]
        ${cqi_start}    Evaluate    int('${cqi_range}'.split('-')[0])
        ${cqi_end}      Evaluate    int('${cqi_range}'.split('-')[1])
        ${pmqap_bin}    get_counters_value_sum    counter_value=${5QI1_PMQAP_counter_value}
        ...    counter_start=${bin_start}    counter_end=${bin_end}
        ${cqi_bin_sum}  get_counters_value_sum    counter_value=${5QI1_CQI_counter_value}
        ...    counter_prefix=${5QI1_CQI_Prefix}    counter_start=${cqi_start}    counter_end=${cqi_end}
        should be true    ${pmqap_bin}==${cqi_bin_sum}
    END
    should be true    ${5QI1_PMQAP_sum}>0    5QI1 cqi counters not update.

[1]CB012464_CR_A_15_DL_PM_counters_rbler_CP_OFDM_256QAM
    Log to console    \n check dl bler counters
    check_bler_counters    counter_value=${PMQAP_counter_value_1}    succ_drb_counter=31    fail_drb_counter=30

[1]CB012464_CR_A_17_DL_PM_counters_rank4_CP_OFDM_256QAM
    Log to console    \n check dl rank4 counters
    ${sum}    get_counters_value_sum    counter_value=${PMQAP_counter_value_1}    counter_start=37    counter_end=37
	should be true    ${sum}>0    dl rank4 counters not update.

[1]CB012464_CR_A_18_DL_PM_counters_mcs_CP_OFDM_256QAM
    Log to console    \n check dl mcs counters
    ${sum}    get_counters_value_sum    counter_value=${PMQAP_counter_value_2}    counter_start=58    counter_end=62
	should be true    ${sum}>0    dl mcs counters not update.

[1]CB012464_CR_A_21_RIP_counter_update_with_all_UL_channel_enable_pusch_pucch_same_bandwidth_interference
    Log to console    \n check RIP pusch and pucch counters
    Perform_UE_Attach
	sleep    10min    reason=wait generate counter.
	${mo_dn}    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3
	${pucchSize_para_name}     Set Variable     pucchConfig/0/pucchSize
    ${pucchSize}    Get Parameter For vDU    mo_dn=${mo_dn}    para_name=${pucchSize_para_name}
	${half_pucch_number}    Evaluate    int(${pucchSize}/2)
	${pucch_low_end}    set variable    ${half_pucch_number}
	${pucch_high_start}    Evaluate    273-${half_pucch_number}+1
	${pusch_start}    Evaluate    ${pucch_low_end}+1
	${pusch_end}    Evaluate    ${pucch_high_start}-1
    ${rip_pucch_counter_low}    get_last_counter_value_dict_for_vdu    counter_prefix=${RIP_Sample_prefix}
    ...    counter_start=1    counter_end=${pucch_low_end}    counter_dimension=${cell_dimension}
    ${rip_pucch_counter_high}    get_last_counter_value_dict_for_vdu    counter_prefix=${RIP_Sample_prefix}
    ...    counter_start=${pucch_high_start}    counter_end=273    counter_dimension=${cell_dimension}
	${sum1}    get_all_counters_values_sum    counter_value=${rip_pucch_counter_low}
	${sum2}    get_all_counters_values_sum    counter_value=${rip_pucch_counter_high}
    ${rip_pucch_counter_value}    Evaluate    	${sum1}+${sum2}
	${rip_pusch_counter_value}    get_last_counter_value_dict_for_vdu    counter_prefix=${RIP_Sample_prefix}
    ...    counter_start=${pusch_start}    counter_end=${pusch_end}    counter_dimension=${cell_dimension}
	should be true    ${rip_pucch_counter_value}>0    rip pucch counters not update.
	check_every_counter_not_zero    counter_value=${rip_pusch_counter_value}

[1]CB012464_CR_A_19_RIP_counter_update_with_all_UL_channel_enable_preamble_interference
    Log to console    \n check RIP preamble counters
	${value2}    create list    PRACH without Preamble
    online_modify_nidd_parameters_vdu
    ...    dist_name=${actNrUlRipCounter_dist_name}    parameter=${actNrUlRipCounter_parameter}    value=${value2}
	sleep    1min
    ${actNrUlRipCounter_value}    Get Parameter For vDU
    ...    mo_dn=${actNrUlRipCounter_dist_name}    para_name=${actNrUlRipCounter_parameter}
	should be equal    ${value2}    ${actNrUlRipCounter_value}    parameter actNrUlRipCounter update failure
    sleep    10min    reason=wait generate counter.
	${preamble_sample_counter_value}    get_last_counter_value_dict_for_vdu    counter_prefix=${RIP_Sample_prefix}
    ...    counter_start=126    counter_end=137    counter_dimension=${cell_dimension}
	${preamble_max_counter_value}    get_last_counter_value_dict_for_vdu    counter_prefix=${RIP_Sched_prefix}
    ...    counter_start=1125    counter_end=1136    counter_dimension=${cell_dimension}
	${preamble_avg_counter_value}    get_last_counter_value_dict_for_vdu    counter_prefix=${RIP_Sched_prefix}
    ...    counter_start=125    counter_end=136    counter_dimension=${cell_dimension}
	check_all_counters_equal_and_not_zero    counter_value=${preamble_sample_counter_value}
	check_all_counters_update_and_equal    counter_value=${preamble_max_counter_value}
	check_all_counters_update_and_equal    counter_value=${preamble_avg_counter_value}

[1]CB012464_CR_A_22_RIP_counter_update_with_all_UL_channel_disable
    Log to console    \n check RIP preamble counters with ul channel disable
	${value2}    create list    disabled
    online_modify_nidd_parameters_vdu
    ...    dist_name=${actNrUlRipCounter_dist_name}    parameter=${actNrUlRipCounter_parameter}    value=${value2}
	sleep    6min
    ${actNrUlRipCounter_value}    Get Parameter For vDU
    ...    mo_dn=${actNrUlRipCounter_dist_name}    para_name=${actNrUlRipCounter_parameter}
	should be equal    ${value2}    ${actNrUlRipCounter_value}    parameter actNrUlRipCounter update failure
	Basic_L3_call
    ${rip_sample_counter_value}    get_last_counter_value_dict_for_vdu    counter_prefix=${RIP_Sample_prefix}
    ...    counter_start=1    counter_end=273    counter_dimension=${cell_dimension}
	${sum}    get_all_counters_values_sum    counter_value=${rip_sample_counter_value}
	should be true    ${sum}==0    RIP counters update with all ul channel disabled.

[1]CB012464_CR_A_24_DL_radio_quality_measurement_oneSSB
    Log to console    \n check dl counters per SSB beam
    ${start_time}    get_last_counter_time_for_vcu    counter_id=M55202C39820    counter_dimension=${SSBPM0_dimension}
    Perform_UE_Attach
    sleep    10min    reason=wait generate counter.
	${rsrp_list}    get_counter_id_list    counter_prefix=${SSBPM_perfix}    counter_start=39806    counter_end=39825
    ${is_update_rsrp_pm0}    Check if counters update after start time
    ...    counter_ids=${rsrp_list}    counter_dimension=${SSBPM0_dimension}    start_time=${start_time}
    ${is_update_rsrp_pm1}    Check if counters update after start time
    ...    counter_ids=${rsrp_list}    counter_dimension=${SSBPM1_dimension}    start_time=${start_time}
	${rsrq_list}    get_counter_id_list    counter_prefix=${SSBPM_perfix}    counter_start=39826    counter_end=39845
    ${is_update_rsrq_pm0}    Check if counters update after start time
    ...    counter_ids=${rsrq_list}    counter_dimension=${SSBPM0_dimension}    start_time=${start_time}
    ${is_update_rsrq_pm1}    Check if counters update after start time
    ...    counter_ids=${rsrq_list}    counter_dimension=${SSBPM1_dimension}    start_time=${start_time}
	${sinr_list}    get_counter_id_list    counter_prefix=${SSBPM_perfix}    counter_start=39846    counter_end=39865
    ${is_update_sinr_pm0}    Check if counters update after start time
    ...    counter_ids=${sinr_list}    counter_dimension=${SSBPM0_dimension}    start_time=${start_time}
    ${is_update_sinr_pm1}    Check if counters update after start time
    ...    counter_ids=${sinr_list}    counter_dimension=${SSBPM1_dimension}    start_time=${start_time}
    ${all_update_pm0}    run keyword and return status
    ...    should be true    ${is_update_rsrp_pm0} and ${is_update_rsrq_pm0} and ${is_update_sinr_pm0}
    ${all_update_pm1}    run keyword and return status
    ...    should be true    ${is_update_rsrp_pm1} and ${is_update_rsrq_pm1} and ${is_update_sinr_pm1}
    should be true    ${all_update_pm0} or ${all_update_pm1}

*** Keywords ***
Basic_L3_call
    [Arguments]    ${ue_index}=${0}    ${dl_tp}=1637    ${ul_tp}=228    ${dl_exp}=0    ${ul_exp}=0    ${duration}=3600
    log to console    \n***Prepare UE***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    sleep    3s
    log to console    \n***UE Attach***
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}     log_type=aasyslog
    sleep    3s
    log to console    \n***start traffic***
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}Mbits/sec
    ...    duration=${duration}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}Mbits/sec
    ...    duration=${duration}    ue_index=${ue_index}
    log to console    \n***collect tput***
    ${Tput_logs}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m
    log to console    \n***Stop traffic ***
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    log to console    \n***check tput ***
    ${cells}    create list    ${611352579}
	${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${Tput_logs}    cells=${cells}
    ...    ultarget_throughput=${ul_exp}    dltarget_throughput=${dl_exp}    actCarrierAggregation=${False}

Perform_UE_Attach
    [Arguments]    ${ue_index}=${0}
    log to console    \n***Prepare UE***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    sleep    3s
    log to console    \n***UE Attach***
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}     log_type=aasyslog
    sleep    3s

get_last_counter_value_dict_for_vdu
    [Arguments]    ${counter_prefix}    ${counter_start}    ${counter_end}    ${counter_dimension}
    ${counter_value}        Create Dictionary
    FOR    ${counter}    IN RANGE    ${counter_start}    ${counter_end}+1
	    ${counterid}     evaluate     "${counter}".zfill(${counter_id_len})
        ${counter_string}    Set Variable    ${counter_prefix}${counterid}
        ${counter_value_dict}    Get Pointed Counter For vDU    counter_id=${counter_string}    dimension_dn=${counter_dimension}
        ${value}    Get From Dictionary    ${counter_value_dict}[-1]    value
        Set To Dictionary       ${counter_value}     ${counter_string}    ${value}
    END
    [Return]    ${counter_value}

check_bler_counters
    [Arguments]    ${counter_value}    ${succ_drb_counter}    ${fail_drb_counter}    ${counter_prefix}=${PMQAP_prefix}    ${exp_bler}=0.1
	${succ_drb_counter_id}     evaluate     "${succ_drb_counter}".zfill(${counter_id_len})
	${fail_drb_counter_id}     evaluate     "${fail_drb_counter}".zfill(${counter_id_len})
	${succ_counter_string}    set variable    ${counter_prefix}${succ_drb_counter_id}
	${fail_counter_string}    set variable    ${counter_prefix}${fail_drb_counter_id}
    ${succ_drb_counter_value}    set variable     ${counter_value['${succ_counter_string}']}
	${fail_drb_counter_value}    set variable     ${counter_value['${fail_counter_string}']}
	${bler_calculate}    Evaluate    ${fail_drb_counter_value}/(${succ_drb_counter_value}+${fail_drb_counter_value})
	log to console    bler calculate from counters: ${bler_calculate}
	should be true    0<=${bler_calculate}<=${exp_bler}

get_counters_value_sum
    [Arguments]    ${counter_value}    ${counter_start}    ${counter_end}    ${counter_prefix}=${PMQAP_prefix}
	${sum}    set variable    0
    FOR    ${counter}    IN RANGE    ${counter_start}    ${counter_end}+1
	    ${counterid}     evaluate     "${counter}".zfill(${counter_id_len})
        ${counter_string}    Set Variable    ${counter_prefix}${counterid}
        ${value}    set variable     ${counter_value['${counter_string}']}
        ${sum}     Evaluate    ${sum} + ${value}
    END
    log to console    sum of counters from ${counter_prefix}${counter_start} to ${counter_prefix}${counter_end}: ${sum}
	[Return]    ${sum}

check_all_counters_equal_and_not_zero
    [Arguments]    ${counter_value}
    ${counter_values}    Get Dictionary Values    ${counter_value}
	should be true    ${counter_values}[0]>0    The counter value is: ${counter_values}[0]
	${number}   Count Values In List   ${counter_values}    ${counter_values}[0]
	${counter_length}    Get length    ${counter_values}
    should be equal    ${number}    ${counter_length}    counters not all equal.

check_all_counters_update_and_equal
    [Arguments]    ${counter_value}
    ${counter_values}    Get Dictionary Values    ${counter_value}
	Should Not Be Empty    ${counter_values}[0]    The counter value is: ${counter_values}[0]
	${number}   Count Values In List   ${counter_values}    ${counter_values}[0]
	${counter_length}    Get length    ${counter_values}
    should be equal    ${number}    ${counter_length}    counters not all equal.

check_every_counter_not_zero
    [Arguments]    ${counter_value}
    FOR    ${counter_id}    IN    @{counter_value.keys()}
	    ${value}    set variable     ${counter_value['${counter_id}']}
        should be true    ${value}!=0    value of counter ${counter_id} is zero.
    END

get_all_counters_values_sum
    [Arguments]    ${counter_value}
    ${counter_values}    Get Dictionary Values    ${counter_value}
	${sum}    Evaluate    sum([int(x) for x in ${counter_values}])
	[Return]    ${sum}

Get Parameter For vDU
    [Arguments]    ${mo_dn}    ${para_name}
    vDU Login    vdu_index=0
    ${value}    Online Get VDU Parameter Value     ${mo_dn}    ${para_name}
    Log To Console    \n*** Get the value of ${para_name} is ${value} from vDU***
    [Teardown]    run keyword and ignore error    vDU Logout
	[Return]    ${value}

VCU Get PM Counter Value
    [Arguments]    ${counter_id}    ${dimension_dn}    ${measurement_id}=None    ${connection}=CU
    Connect to vcu via rest api    gnb_index=0    connection=${connection}
    ${res}    cu.Get Counter
    ...    measurement_id=${measurement_id}    dimension_dist_name=${dimension_dn}    counter_id=${counter_id}    connection=${connection}
    [Teardown]   Teardown vcu connection    connection=${connection}
    [Return]    ${res}

get_last_counter_value_dict_for_vcu
    [Arguments]    ${counter_prefix}    ${counter_start}    ${counter_end}    ${counter_dimension}    ${measurement_id}=None    ${connection}=CU
    ${counter_value}        Create Dictionary
    FOR    ${counter}    IN RANGE    ${counter_start}    ${counter_end}+1
	    ${counterid}     evaluate     "${counter}".zfill(${counter_id_len})
        ${counter_string}    Set Variable    ${counter_prefix}${counterid}
		${counter_value_dict}    VCU Get PM Counter Value    counter_id=${counter_string}    dimension_dn=${counter_dimension}
        ...		measurement_id=${measurement_id}    connection=${connection}
		${value}    Get From Dictionary    ${counter_value_dict}[values][-1]    value
        Set To Dictionary       ${counter_value}     ${counter_string}    ${value}
    END
    [Return]    ${counter_value}

online_modify_nidd_parameters_vdu
    [Arguments]    ${dist_name}    ${parameter}    ${value}    ${timeout}=300    ${connection}=DU
	log to console    modify parameter ${parameter} to ${value}
	${list_parameter_update}    create list
    ${dict_parameter}    create dictionary    dist_name=${dist_name}   parameter=${parameter}    value=${value}
    append to list  ${list_parameter_update}   ${dict_parameter}
    ${dict_du_parameters}    create dictionary      param_to_upd=${list_parameter_update}
    wait until keyword succeeds    1min    2sec    vDU.Connect to vdu via rest api   gnb_index=0   du_index=0    connection=${connection}
    online_nidd_process.online_modify_nidd_parameters_via_restapi    params_modify_dict=${dict_du_parameters}
        ...    connection=${connection}    timeout=${timeout}    bts_type=du
    [Teardown]    Run keyword and ignore error    Teardown vdu connection    connection=${connection}

get_last_counter_time_for_vcu
    [Arguments]    ${counter_id}    ${counter_dimension}    ${measurement_id}=None    ${connection}=CU
    ${counter_time_value}    VCU Get PM Counter Value    counter_id=${counter_id}    dimension_dn=${counter_dimension}
    ...    measurement_id=${measurement_id}    connection=${connection}
    ${time}    Get From Dictionary    ${counter_time_value}[values][-1]    start_time
    Log To Console    \n*** latest counter update time: ${time}***
	[Return]    ${time}

Get counter values after start time
    [Arguments]    ${counter_id}    ${counter_dimension}    ${start_time}    ${measurement_id}=None    ${connection}=CU
    ${counter_time_value}    VCU Get PM Counter Value    counter_id=${counter_id}    dimension_dn=${counter_dimension}
    ...    measurement_id=${measurement_id}    connection=${connection}
	${dict_list}    set variable    ${counter_time_value}[values]
    ${result}=    Create List
    FOR    ${item}    IN    @{dict_list}
        ${item_time}=    Set Variable    ${item['start_time']}
        ${cmp}=    Evaluate    '${item_time}' > '${start_time}'
        Run Keyword If    ${cmp}    Append To List    ${result}    ${item['value']}
    END
    [Return]    ${result}

Check if counters update after start time
    [Arguments]    ${counter_ids}    ${counter_dimension}    ${start_time}    ${measurement_id}=None    ${connection}=CU
    FOR    ${counter_id}    IN    @{counter_ids}
	    ${values}    Get counter values after start time
        ...    counter_id=${counter_id}    counter_dimension=${counter_dimension}    start_time=${start_time}
        ...    measurement_id=${measurement_id}    connection=${connection}
		${sum}    Evaluate    sum([int(x) for x in ${values}])
		${is_update}    Run Keyword And Return Status    should be true    ${sum}>0
        Exit For Loop If    ${is_update}
	END
	[Return]    ${is_update}

get_counter_id_list
    [Arguments]    ${counter_prefix}    ${counter_start}    ${counter_end}
    ${counter_id_list}        Create List
    FOR    ${counter}    IN RANGE    ${counter_start}    ${counter_end}+1
	    ${counterid}     evaluate     "${counter}".zfill(${counter_id_len})
        ${counter_string}    Set Variable    ${counter_prefix}${counterid}
        Append To List    ${counter_id_list}    ${counter_string}
    END
    [Return]    ${counter_id_list}

Perform and Check Vonr Call
    [Arguments]    ${mo_ueindex}=0    ${duration}=600
    spark.Update_test_plan    ue_alias=UE_${mo_ueindex}    call_type=0
    ...    Duration=${duration}
    sleep    3s
    spark.Start_test_plan  ue_alias=UE_${mo_ueindex}    task_name=CallMO
    sleep    10s
    ${Vonr_call_status}    Run Keyword And Continue On Failure   spark.get_Vonr_call_status_on_ue
    ...      ue_alias=UE_${mo_ueindex}   param={"LastEventIndex":0}
    run keyword if    '${Vonr_call_status}'=='True'    Log To Console    \n*** vonr call status check passed
    ...    ELSE    Log To Console    \n*** vonr call status check failed

case_common_setup
    robot_common_operations.Common Case Setup

case_common_teardown
    robot_common_operations.Common Case Teardown
	CI interface.Common Case Teardown