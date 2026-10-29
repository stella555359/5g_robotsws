# *** Settings ***
# Library           ../Resources/check_counter_value.py
# Variables           ../TestData/2056_scf_modify.py
# Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
# Resource           ../../5GC002157/Resources/5GC002157_keywords.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_setup_teardown.robot
# 
# Documentation    Suite description
# ...   author: Ren Biyao
# ...   contact: biyao.ren@nokia-sbell.com
# ...   squad group: MMW_SG1
# 
# Force Tags    5G_RAN_TDD
# ...    PY36
# Suite Setup     Suite common setup preparation   is_pdl_checking_needed=${False}     scf_template_path=${SCF_DEFAULT_FILE_PATH}
# ...             enb_default_scf_file=${ENB_SCF_DEFAULT_FILE_PATH}    prepare_ue=${True}    ue_index=${1}
# Suite Teardown  Run keyword and ignore error    Suite teardown common
# 
# *** Variables ***
# ${PDML_CONVERT_X2AP_TEMPLATE}        {tshark_path} -r {pcap_file} -Y  \"x2ap\"  -T pdml
# ${MRBTS_ID}                          ${tl.gnbs[0].instance_id}
# ${SCF_DEFAULT_FILE_PATH}        /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${MRBTS_ID}.xml
# ${SWCONFIG_DEFAULT_FILE_PATH}    /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${MRBTS_ID}.txt
# ${RECOVERY_TIMEOUT}                  10 min
# ${ENB_SCF_DEFAULT_FILE_PATH}      /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${tl.gnbs[0].instance_id}_ENB.xml
# 
# *** Test Cases ***
# [1]5GC002056-AIAJ_003_SgNB_release_based_on_A2_without_SRB3
#    [Documentation]    author: Ren Biyao
#    ...    This case verify SgNB release based on A2 without SRB3
#    [Tags]    CRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R3    CRT_22R4    CRT_23R1
#    [Setup]    Common case setup    is_log_required=${True}
#    Connect to gnb coam via ssl
#    Make SgNBAddition on specific cell     gnb_ps_cell_index=${1}
#    Start X2 log capture from eNB    log_name=TC003    interface=br1
#    @{local_counter_file_path}    Ue attach and collect pm counter logs
#    ${TC003_pcap}    Stop X2 log capture from eNB     log_name=TC003
#    Load pcap with filter    filter_expression=x2ap    command_template=${PDML_CONVERT_X2AP_TEMPLATE}
#    ...    pcap_file=${TC003_pcap}
#    ${TC003_pdml}    Get pdml log    tcpdump_log=${TC003_pcap}
#    check_tcpdump_msg    msg_file=${CURDIR}/../Resources/a2_meas_release.txt   tcpdump_pdml=${TC003_pdml}
# 
#    &{EXPECTED_COUNTER_WITH_VALUE}   create dictionary    M55112C05001=1   M55112C05002=1
#    ${list_expected_counters}    get dictionary keys     ${EXPECTED_COUNTER_WITH_VALUE}
#    @{check_counter_value_status}    create list
#    ${cell_id}    create list     1
#    FOR    ${cur_counter_file}   IN    @{local_counter_file_path}
#           ${act_counters_dict}    get_cell_counters_from_file    file_path=${cur_counter_file}
#           ...    list_cell=${cell_id}    list_measurement_ids=${list_expected_counters}
#           ${cur_check_value_status}    run keyword and return status    check_counter_with_expected_value
#           ...    expected_counter_with_value=${EXPECTED_COUNTER_WITH_VALUE}
#           ...    given_counter_dict=${act_counters_dict}
#           append to list    ${check_counter_value_status}     ${cur_check_value_status}
#    END
#    list should contain value     ${check_counter_value_status}    ${True}
#    [Teardown]    Run keyword and ignore error    Common case teardown    ue_index=${1}
# 
# *** Keywords ***
# Ue attach and collect pm counter logs
#     [Documentation]    Author: Ren Biyao
#     Connect to Common Unit Master
#     Connect to gnb coam via ssl
#     &{pre_case_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=5
#     Sleep    ${pre_case_time_info['wait_time']} min
#     Wait until PM counter file is genereated    timeout=2min
#     ...    log_generate_timestamp=${pre_case_time_info['log_generator_timestamp']}
#     &{case_start_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=5
#     Retry commercial ue attach if failed    retry_time=${3}    ue_type=${UE_TYPE}    prepare_ue_needed=${False}
#     ...    ue_index=${1}
#     Connect to Capacity Unit Master
#     &{case_stop_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=5
#     sleep    ${case_stop_time_info['wait_time']} min
#     @{remote_file_path}    Wait until PM counter file is genereated    timeout=2min
#     ...    log_generate_timestamp=${case_start_time_info['log_generator_timestamp']}
#     @{local_counter_file_path}    counter.download_pm_counter_files_to_test_pc    remote_file_path=${remote_file_path}
#     ...    local_file_folder=${TS_CASE_LOG_PATH}
#     [Return]    @{local_counter_file_path}
