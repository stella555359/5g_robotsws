# @Time    : 2023/11/16 15:34
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB009855_common_keywords.robot
# @Software: PyCharm
*** Settings ***
Documentation    This is common robot keywords template
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/logs.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

*** Variables ***
${5CC_COUNTERS}    M55138C00048,M55138C00049,M55118C02016,M55118C07510,M55139C00023,M55139C00024,M55118C02015,M55118C02014
${SCF_W102_103}    ${CURDIR}/CB009855W_Resources/SCF_W102_103.xml

*** Keywords ***
Verify 5CC Counters Update Normal
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/11/16 15:38
    [Arguments]    ${timeout}=300    ${connection}=GNB_OAM
    ${5cc_counters}    coam.get_pm_counters    counter_ids=${5CC_COUNTERS}    timeout=${timeout}    connection=${connection}
    ${gnb_scell_req}    Set Variable    ${5cc_counters['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-6']['RSACU']['M55138C00048']}
    ${gnb_scell_req_value}    Get Latest Average Counter Value    ${gnb_scell_req}
    Should Be True    ${gnb_scell_req_value}>0
    ${gnb_scell_succ}    Set Variable    ${5cc_counters['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-6']['RSACU']['M55138C00049']}
    ${gnb_scell_succ_value}    Get Latest Average Counter Value    ${gnb_scell_succ}
    Should Be True    ${gnb_scell_succ_value}>0
    ${ue_pcell}    Set Variable    ${5cc_counters['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-6']['NCAC']['M55118C02016']}
    ${ue_pcell_value}    Get Latest Average Counter Value    ${ue_pcell}
    Should Be True    ${ue_pcell_value}>0
    ${ue_scell_cell6}    Set Variable    ${5cc_counters['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-6']['NCAC']['M55118C07510']}
    ${ue_scell_cell6_value}    Get Latest Average Counter Value    ${ue_scell_cell6}
    Should Be True    ${ue_scell_cell6_value}==0
    ${ue_scell_cell1}    Set Variable    ${5cc_counters['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-1']['NCAC']['M55118C07510']}
    ${ue_scell_cell1_value}    Get Latest Average Counter Value    ${ue_scell_cell1}
    Should Be True    ${ue_scell_cell1_value}>0
    ${ue_scell_cell2}    Set Variable    ${5cc_counters['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-2']['NCAC']['M55118C07510']}
    ${ue_scell_cell2_value}    Get Latest Average Counter Value    ${ue_scell_cell2}
    Should Be True    ${ue_scell_cell2_value}>0
    ${ue_scell_cell5}    Set Variable    ${5cc_counters['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-5']['NCAC']['M55118C07510']}
    ${ue_scell_cell5_value}    Get Latest Average Counter Value    ${ue_scell_cell5}
    Should Be True    ${ue_scell_cell5_value}>0
    ${ue_scell_cell4}    Set Variable    ${5cc_counters['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-4']['NCAC']['M55118C07510']}
    ${ue_scell_cell4_value}    Get Latest Average Counter Value    ${ue_scell_cell4}
    Should Be True    ${ue_scell_cell4_value}>0
    ${gnb_du_scell_req}    Set Variable    ${5cc_counters['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-6']['RSADU']['M55139C00023']}
    ${gnb_du_scell_req_value}    Get Latest Average Counter Value    ${gnb_du_scell_req}
    Should Be True    ${gnb_du_scell_req_value}>0
    ${gnb_du_scell_succ}    Set Variable    ${5cc_counters['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-6']['RSADU']['M55139C00024']}
    ${gnb_du_scell_succ_value}    Get Latest Average Counter Value    ${gnb_du_scell_succ}
    Should Be True    ${gnb_du_scell_succ_value}>0
    ${rrc_reconf_att}    Set Variable    ${5cc_counters['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-6']['NCAC']['M55118C02015']}
    ${rrc_reconf_att_value}    Get Latest Average Counter Value    ${rrc_reconf_att}
    Should Be True    ${rrc_reconf_att_value}>0
    ${rrc_reconf_succ}    Set Variable    ${5cc_counters['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-6']['NCAC']['M55118C02014']}
    ${rrc_reconf_succ_value}    Get Latest Average Counter Value    ${rrc_reconf_succ}
    Should Be True    ${rrc_reconf_succ_value}>0

Verify M55118C02016 M55118C07510 Update Normal
    [Documentation]    Author: xiaofei.zhao@nokia-sbell.com
    ...    Init Define: 2023/12/16 15:38
    [Arguments]    ${timeout}=300    ${connection}=GNB_OAM
    ${5cc_counters}    coam.get_pm_counters    counter_ids=${5CC_COUNTERS}    timeout=${timeout}    connection=${connection}
    ${ue_pcell}    Set Variable    ${5cc_counters['BTS']['MRBTS-2040']['NRBTS-37148']['NRCELL-1']['NCAC']['M55118C02016']}
    ${counter_list}    Get Dictionary Values    ${ue_pcell}
    ${count}    Get Length    ${counter_list}
    ${ue_pcell_value}    Get Latest Average Counter Value    ${ue_pcell}    ${count}
    Should Be True    ${ue_pcell_value}>0
    ${ue_scell_cell6}    Set Variable    ${5cc_counters['BTS']['MRBTS-2040']['NRBTS-37148']['NRCELL-6']['NCAC']['M55118C02016']}
    ${ue_scell_cell6_value}    Get Latest Average Counter Value    ${ue_scell_cell6}    ${count}
    Should Be True    ${ue_scell_cell6_value}==0
    ${ue_scell_cell6}    Set Variable    ${5cc_counters['BTS']['MRBTS-2040']['NRBTS-37148']['NRCELL-6']['NCAC']['M55118C07510']}
    ${ue_scell_cell6_value}   Get Latest Average Counter Value    ${ue_scell_cell6}     ${count}
    Should Be True    ${ue_scell_cell6_value}>0
    ${ue_scell_cell2}    Set Variable    ${5cc_counters['BTS']['MRBTS-2040']['NRBTS-37148']['NRCELL-2']['NCAC']['M55118C07510']}
    ${ue_scell_cell2_value}   Get Latest Average Counter Value    ${ue_scell_cell2}     ${count}
    Should Be True    ${ue_scell_cell2_value}>0
    ${ue_scell_cell5}    Set Variable    ${5cc_counters['BTS']['MRBTS-2040']['NRBTS-37148']['NRCELL-5']['NCAC']['M55118C07510']}
    ${ue_scell_cell5_value}   Get Latest Average Counter Value    ${ue_scell_cell5}     ${count}
    Should Be True    ${ue_scell_cell5_value}>0
    ${ue_scell_cell4}    Set Variable    ${5cc_counters['BTS']['MRBTS-2040']['NRBTS-37148']['NRCELL-4']['NCAC']['M55118C07510']}
    ${ue_scell_cell4_value}   Get Latest Average Counter Value    ${ue_scell_cell4}     ${count}
    Should Be True    ${ue_scell_cell4_value}>0

Get Latest Average Counter Value
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${counters}    ${count}=3
    ${time_list}    Get Dictionary Keys    ${counters}
    ${counter_values}    Set Variable    0
    FOR    ${i}    IN RANGE    1    ${count}+1
        ${counter_values}    Evaluate    ${counter_values}+${counters['${time_list[-${i}]}']}
    END
    ${average_counter_value}    Evaluate    ${counter_values}/3
    [Return]    ${average_counter_value}

Stop_Collect_Trace_and_Get_Result
    [Arguments]   ${timeout}=5min
    [Documentation]  Stop tracing, delete to traces to save server space, then remove the bts from the dcapserver.
    ...     return: path of downloaded trace file in zip format, and the content in the zip file.
    Log to console   Stop collecting dcap log.
    rd.stop_trace
    sleep    ${timeout}
    ${trace_file_path}    rd.get_results
    ${trace_result_content}    rd.get_result_file_contents
    ${PATHONLY}   ${SNAPSHOTNAME}   Split String From Right    string=${trace_file_path}   separator=/     max_split=1
#    ${PATHONLY}   ${SNAPSHOTNAMEContent}   Split String From Right    string=${trace_result_content}   separator=/     max_split=1
    run    mv ${trace_file_path} ${LOG_PATH}/.
#    run    mv ${trace_result_content} ${LOG_PATH}/.
    set test variable   ${trace_file_path}    ${LOG_PATH}/${SNAPSHOTNAME}
#    set test variable   ${trace_result_content}    ${LOG_PATH}/${SNAPSHOTNAMEContent}
    rd.delete_trace
    rd.delete_bts
    [Return]  ${trace_file_path}  ${trace_result_content}

Get_Theory_CA_Dl_Ul_Tput
    [Documentation]  use NRDIM tool get the theory DL and UL tput.
    &{modified_parameters}    Create Dictionary    UElayersDL=${3}    UEDLmodulation256QAM=${1}    UEULmodulation256QAM=${1}
    ${theoretical_dl_pcell}    ${theoretical_ul_pcell}    Get Theoretical Throughput    scf_path=${SCF_W102_103}
    ...    cell_id=4    ue_ul_layer=${1}    UEmaxData=1    mod_params=${modified_parameters}
    ${theoretical_dl_scell1}    ${theoretical_ul_scell1}    Get Theoretical Throughput    scf_path=${SCF_W102_103}
    ...    cell_id=1    UEmaxData=1    mod_params=${modified_parameters}
    ${theoretical_dl_scell2}    ${theoretical_ul_scell2}    Get Theoretical Throughput    scf_path=${SCF_W102_103}
    ...    cell_id=2    ue_ul_layer=${1}
    ${theoretical_dl_scell3}    ${theoretical_ul_scell3}    Get Theoretical Throughput    scf_path=${SCF_W102_103}
    ...    cell_id=5
    ${theoretical_dl_scell4}    ${theoretical_ul_scell4}    Get Theoretical Throughput    scf_path=${SCF_W102_103}
    ...    cell_id=6
    ${theoretical_dl_5CC_sum}    Evaluate
    ...    ${theoretical_dl_pcell}+${theoretical_dl_scell1}+${theoretical_dl_scell2}+${theoretical_dl_scell3}+${theoretical_dl_scell4}
    # NOTE:for T+F UL 2CC,Uplink peak throughput on FDD SCell is reduced to 80%(1116_0ms/3ms) or 60%(1070) due to scheduling restriction for single UE
    ${theoretical_ul_2CC_sum}    Evaluate    ${theoretical_ul_pcell}+${theoretical_ul_scell2}*0.6
    Set Suite Variable    ${theoretical_dl_5CC_sum}
    Set Suite Variable    ${theoretical_ul_2CC_sum}
    [Return]  ${theoretical_dl_5CC_sum}  ${theoretical_ul_2CC_sum}

Check_CA_Throught_From_Asslog
    [Arguments]  ${ul_tp}    ${dl_tp}    ${duration}=1m    ${ul_list}=${ul_cell_list}    ${dl_list}=${dl_cell_list}
    ...    ${target_avg_percent}=0.98    ${min_percent}=0.85    ${ue_index}=0    ${ue_type}=${tl.ues[${ue_index}].capabilities[-1]}
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}    ignore_time=60s    check_source=aasyslog
    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${ul_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${True}    min_percent=${min_percent}    check_source=aasyslog
    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${dl_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${True}    min_percent=${min_percent}    check_source=aasyslog

