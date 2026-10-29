# @Time    : 2024/4/22 11:02
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @Group   : NSB MN RAN RD VRF HAZ3 5
# @File    : CB011080_common_keywords.robot
# @Software: PyCharm
# @Doc     : This is common robot keywords template
*** Settings ***
Documentation    This is common robot keywords for feature CB011080
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py

*** Keywords ***
Get_Theory_CA_Dl_Ul_Tput
    [Documentation]  use NRDIM tool get the theory DL and UL tput.
    # use fixed Tput value due to local API NRDIM tool issue: https://jiradc.ext.net.nokia.com/browse/REX-25792
    # NRDIM tool should be used after ticket closed
    # Pcell/NRCELL-4: http://5gtables.eecloud.dynamic.nsn-net.net/?code=
    #  ISSFBOYvewE6aVIEHxBgDAAIAAAAAAPp9B9PoAAJDgJKAQBAAAAAACYSBIABkUwAAJ0AAAAJAAAAAAAAAkgAAEAAAABoAAAAAAAAAABAggAAABAAUYBRv4AAgAAAAAAAAAAA
    #  ...    ZBw-wFAABAAAAAAEAAO4IAAAAAAAAAABjCABgQAMCEAAAAAAAAAAAAAAEAHDAAAAAAIEAAAACA
#    Set Test Variable    ${dl_pcell}    1637
#    Set Test Variable    ${ul_pcell}    109.9
    # Pcell/NRCELL-4 offical scf: ISSBBOYvewE6aUoENRBgDAAIAAAAAAPp9B9PoAAJDgJJEQBAAAAAACYaZIAFkUwAgJ0AAAAJAAgEMAEBlkkgAEAAAAxoAAAAAAwAAA
    # ...   BAggAAAhAAUYBRu4AAgAAAAICAIAIAZBy-wFAIBAAAAAAEAAO4IAAAAAAAAAABjCABgQAMKAAAIAAAAAAAUAYAQAHDAEAAELoEKAIASA
    Set Test Variable    ${dl_pcell}    1654
    Set Test Variable    ${ul_pcell}    112
    # Scell1/NRCELL-1: KCSBBpmvekk6WVIEKxBgDIIIAAAAAAD6qghlEAAIAoAKAQBAAAAAACYKBIgFkQQAkJwAQAAJAAAAAAAAAkkgAAAAgAAAAAAAAAQAAABAgoAAAAAATQDR
    # ...    g4AAgAAAAAAAAAAAYBwYAFAAAAABAAAAAgO9JAAAAAAAAAABjAAAgIAMCEAAAAAAAAAAAAAAEAHDAA
    Set Test Variable    ${dl_scell1}    219
    Set Test Variable    ${ul_scell1}    220
    # Scell2/NRCELL-2: KCSBBgAvesk6SVIEJxBgDIIIAAAAAANH2BVcwAAIAoAIAQBAAAAAACYGBAgFkQQAkJwAQAAJAAAAAAAAAkgAAAAAgAAAAAAAAAAAAABAggMgAAAATQBR
    # ...    g4AAgAAAAAAAAAAAYBwDwFAAAAABAAAAAAO9JAAAAAAAAAABjAAAAAAMCEAAAAAAAAAAAAAAEAHDAA
    Set Test Variable    ${dl_scell2}    91.8
    Set Test Variable    ${ul_scell2}    42.9
    # Scell3/NRCELL-3: KCSBBgivekE6QVIEKxBgDAAIAAAAAAD07Ag3IAAIAoAIAQBAAAAAACYKBIAFkQQAkIwAAAAJAAAAAAAAAkgAAAAAgAAAAAAAAAAAAABAgoAAAAAATQBR
    # ...    g4AAgAAAAAAAAAAAYBwKgFAAAAABAAAAAgO4JAAAAAAAAAABjAAAAAAMCEAAAAAAAAAAAAAAEAHDAA
    Set Test Variable    ${dl_scell3}    104.9
    Set Test Variable    ${ul_scell3}    47.7
    # Scell5/NRCELL-5: ICCFMSqvewE6aVIEMxBgDAAIAAAAAATU-yan2AAJCQJKAQBAAAAAACYIBIABkUwAAJ0AAAAJAAAAAAAAAkgAAEAAAABoAAAAAAAAAABAggAAABAAUYBR
    # ...    v4AAgAAAAAAAAAAAZBwQgFAABAAAAAAEAAO4IAAAAAAAAAABjCAAAAAMCEAAAAAAAAAAAAAAEAHDAA
    Set Test Variable    ${dl_scell5}    441.8
    Set Test Variable    ${ul_scell5}    28.8
    # Scell6/NRCELL-6: ICCBMWYvewE6aUoENRBgDAAIAAAAAAT8CifgUAAJDgJJEQBAAAAAACYaZIAFkUwAgJ0AAAAJAAgEMAEBlkkgAEAAAAxoAAAAAAwAAABAggAAAhAAUYBR
    # ...    u4AAgAAAAICAIAIAZBy-wFAIBAAAAAAEAAO4IAAAAAAAAAABjCABgQAMKAAAYAAAAAAAMAEAIAHDAEAAEToEGAAAGA
    Set Test Variable    ${dl_scell6}    1610
    Set Test Variable    ${ul_scell6}    115.1
#    ${dl_pcell}    ${ul_pcell}    Get Theoretical Throughput    scf_path=${SCF_A27}
#    ...    cell_id=4    mod_params=${CELL456_MODIFY_PARAMS}
#    ${dl_scell1}    ${ul_scell1}    Get Theoretical Throughput    scf_path=${SCF_A27}
#    ...    cell_id=1    mod_params=${CELL1_MODIFY_PARAMS}
#    ${dl_scell2}    ${ul_scell2}    Get Theoretical Throughput    scf_path=${SCF_A27}
#    ...    cell_id=2    mod_params=${CELL2_MODIFY_PARAMS}
#    ${dl_scell3}    ${ul_scell3}    Get Theoretical Throughput    scf_path=${SCF_A27}
#    ...    cell_id=3    mod_params=${CELL3_MODIFY_PARAMS}
#    ${dl_scell5}    ${ul_scell5}    Get Theoretical Throughput    scf_path=${SCF_A27}
#    ...    cell_id=5    mod_params=${CELL456_MODIFY_PARAMS}
#    ${dl_scell6}    ${ul_scell6}    Get Theoretical Throughput    scf_path=${SCF_A27}
#    ...    cell_id=6    mod_params=${CELL456_MODIFY_PARAMS}
    ${theoretical_dl_6CC_sum}    Evaluate
    ...    ${dl_pcell}+${dl_scell1}+${dl_scell2}+${dl_scell3}+${dl_scell5}+${dl_scell6}
    ${theoretical_ul_2CC_sum}    Evaluate
    ...    ${ul_pcell}+${ul_scell1}/2*0.8
    Set Suite Variable    ${theoretical_dl_6CC_sum}
    Set Suite Variable    ${theoretical_ul_2CC_sum}
    ${exp_dl_indiv}    Create List    ${dl_scell1}    ${dl_scell2}    ${dl_scell3}    ${dl_pcell}    ${dl_scell5}    ${dl_scell6}
    ${ul_scell1_ca}    Evaluate    ${ul_scell1}/2*0.8
    ${exp_ul_indiv}    Create List    ${ul_scell1_ca}    ${ul_pcell}
    Set Suite Variable    ${exp_dl_indiv}
    Set Suite Variable    ${exp_ul_indiv}
    [Return]  ${theoretical_dl_6CC_sum}  ${theoretical_ul_2CC_sum}

Convert expected tput value for checking
    [Documentation]  Author: Ding Binmei
    ...    Notes for input expected tput:
    ...       -1: Means not to check tput, will return as ${None}
    ...        0: Means tput should < 2M,  will return as -2
    ...       Negative value: Means tput should < exp_value, will keep the original value
    ...       Positive value: Means tput should >= exp_value, will keep the original value
    [Arguments]  ${exp_tput_value}
    ${exp_tput_value_convert}    Set variable if    '${exp_tput_value}'=='-1'    ${None}
    ...    '${exp_tput_value}'=='0'    ${-2}
    ...    ${exp_tput_value}
    [Return]  ${exp_tput_value_convert}

Get individual expected tput value for cells
    [Documentation]  Author: Ding Binmei
    ...    Return a dict value like: {nrcellIdentity1: exp_tput1, nrcellIdentity2: exp_tput2}
    [Arguments]     ${list_nrCellIdentity}     ${list_exp_tput}
    ${len_nrCellIdentity}    Get length    ${list_nrCellIdentity}
    ${len_exp_tput}    Get length    ${list_exp_tput}
    Should be True    ${len_nrCellIdentity}==${len_exp_tput}
    ...    msg=Invalid input for ${list_exp_tput}, if need to check tput for individual cells, then expeted tput value should be set to each cell
    &{dict_cell_indiv_tput}    Create dictionary
    FOR    ${index}    ${nrCellIdentity}    IN ENUMERATE    @{list_nrCellIdentity}
        ${exp_tput}    Convert expected tput value for checking    exp_tput_value=${list_exp_tput[${index}]}
        Run keyword if    ${exp_tput}!=${None}
        ...     Set to dictionary    ${dict_cell_indiv_tput}    ${nrCellIdentity}=${exp_tput}
    END
    [Return]    ${dict_cell_indiv_tput}

Check_CA_Throught_From_Asslog
    [Arguments]  ${ul_tp}    ${dl_tp}    ${duration}=1m    ${ul_list}=${ul_cell_list}    ${dl_list}=${dl_cell_list}
    ...    ${target_avg_percent}=0.98    ${min_percent}=0.85    ${ue_index}=0    ${ue_type}=${tl.ues[${ue_index}].capabilities[-1]}
    ...    ${cell_indiv_tput_dl}=${None}    ${cell_indiv_tput_ul}=${None}    ${log_dir}=${OUTPUT_DIR}
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}    ignore_time=60s    check_source=aasyslog
    ...    log_dir=${log_dir}
    ${ul_syslog_tp}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${ul_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${True}    min_percent=${min_percent}    check_source=aasyslog    cell_indiv_tput=${cell_indiv_tput_ul}
    ${dl_syslog_tp}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${dl_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${True}    min_percent=${min_percent}    check_source=aasyslog    cell_indiv_tput=${cell_indiv_tput_dl}
    [Return]  ${ul_syslog_tp[0]["average"]}    ${dl_syslog_tp[0]["average"]}


Init PA For Peak Throughput
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/11/15 16:55
    gnb_classical_hangzhou.Get Initial Attenuation Values For RU
    ${channels_to_modify}    create dictionary    1=24    2=24    14=24    15=24
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=0
    ${channels_to_modify}    create dictionary    3=34    4=34    13=34
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=1
    ${channels_to_modify}    create dictionary    5=12    6=3   7=3    8=3
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=2
    ${channels_to_modify}    create dictionary    9=28    10=24    11=28   12=24
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=3

Set Test Variables
    [Documentation]    Author: chun.li@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM
    ${stream}    coam.get_sw_release_name    connection=${connection}
    Set Test Variable    ${stream}
    ${sanitized_test_name}    Replace String    ${TEST NAME}    ${SPACE}    _
    ${TS_CASE_LOG_PATH}    Join Path    ${OUTPUT_DIR}    ${sanitized_test_name}
    Create Directory    ${TS_CASE_LOG_PATH}
    Set Test Variable    ${TS_CASE_LOG_PATH}
    Set Test Variable    ${A7_WIRESHARK_LOG}    ${TS_CASE_LOG_PATH}/11080_A7.pcap
    Set Test Variable    ${A7_WIRESHARK_RRC}    ${TS_CASE_LOG_PATH}/11080_A7_rrc.pcap
    Set Test Variable    ${A9_WIRESHARK_LOG}    ${TS_CASE_LOG_PATH}/11080_A9.pcap
    Set Test Variable    ${A9_WIRESHARK_RRC}    ${TS_CASE_LOG_PATH}/11080_A9_rrc.pcap
    Set Test Variable    ${A13_WIRESHARK_LOG}    ${TS_CASE_LOG_PATH}/11080_A13.pcap
    Set Test Variable    ${A13_WIRESHARK_RRC}    ${TS_CASE_LOG_PATH}/11080_A13_rrc.pcap
    Set Test Variable    ${A19_WIRESHARK_LOG}    ${TS_CASE_LOG_PATH}/11080_A19.pcap
    Set Test Variable    ${A19_WIRESHARK_RRC}    ${TS_CASE_LOG_PATH}/11080_A19_rrc.pcap
    Set Test Variable    ${B28_WIRESHARK_LOG}    ${TS_CASE_LOG_PATH}/11080_B28.pcap
    Set Test Variable    ${B28_WIRESHARK_RRC}    ${TS_CASE_LOG_PATH}/11080_B28_rrc.pcap
    Set Test Variable    ${C42_WIRESHARK_LOG}    ${TS_CASE_LOG_PATH}/11080_C42.pcap
    Set Test Variable    ${C42_WIRESHARK_RRC}    ${TS_CASE_LOG_PATH}/11080_C42_rrc.pcap
