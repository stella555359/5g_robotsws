# # 
# # *** Settings ***
# # Resource    ../../5GC001911-CA/resource/5GC001911-CA_keywords.robot
# # Resource    ../Resources/FGCR-7660_keywords.robot
# # Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# # 
# # 
# # Documentation
# # ...   author: Fang Ludan
# # ...   contact: ludan.fang@nokia-sbell.com
# # ...   squad group: MMW_SG1
# # ...   feature : FGCR-7660
# # 
# # 
# # Force Tags    5G_RRM        
# # ...    PY36
# # Suite Setup     Suite preparation for 7660
# # Suite Teardown  run keyword and ignore error   Common suite recovery   swconfig_template_path=${SWCONFIG_DEFAULT_FILE_PATH_7660}
# # 
# # 
# # *** Variables ***
# # 
# # *** Test Cases ***
# # [1]FGCR-7660-5GC001726-GA-002-5G19B_default_value_situation_of_mmW 8CC_4CC_2CC_1CC_UE_balancing
# #     [Documentation]    author: Fang ludan
# #     ...   The purpose of this test case is to validate a more balanced admission control in default value situation.
# #     ...   A values of “0” for each NRCELL-tmpParam threshold to ensure the threshold is ignored when this special (default) value is used.
# #     [Tags]    CRT_20B   CRT_TRUNK
# #     [Timeout]    1 hour
# #     [Setup]    Case Preparation for 7660
# #     Modify SCF on ENB for 7660      online_modify_parameters=${MODIFY_ENB_VIA_API_P2}
# #     ${5Grach_ed_list}    create list
# # 
# # ##UE1##
# #     Start X2 log capture from eNB    log_name=X2_tcpdump_1_0    interface=br1
# #     ${5Grach_ed_0}    attach multi power ue    ue_index=${0}
# #     Sleep  1min
# #     ${X2tcpdump_log}    Stop X2 log capture from eNB    log_name=X2_tcpdump_1_0
# #     start multi power ue traffic ul and dl    ue_index=${0}   ul_throughput=100M    dl_throughput=1000M
# #     Check CC number_0 in X2log    x2ap_log=${X2tcpdump_log}
# #     Verify peak tput of each cell   dl_cell=${dl_cell}    ul_cell=${ul_cell}   expected_dl_tput_max=${expected_dl_tput_max}
# #     ...     expected_dl_tput_min=${expected_dl_tput_min}      expected_ul_tput=${expected_ul_tput}
# #     ...      dl_num_exp=${1}    ul_num_exp=${1}
# #     stop multi power ue traffic ul and dl   ue_index=${0}
# #     Append to list    ${5Grach_ed_list}    ${5Grach_ed_0}
# # ##UE1##
# # 
# # 
# # ##UE2##
# #     Verify UE attach by UE Index    ue_num=${1}    5Grach_ed_list=${5Grach_ed_list}
# #     Start X2 log capture from eNB    log_name=X2_tcpdump_1_1    interface=br1
# #     ${5Grach_ed_1}    attach multi power ue    ue_index=${1}
# #     Sleep  1min
# #     ${X2tcpdump_log}    Stop X2 log capture from eNB    log_name=X2_tcpdump_1_1
# #     start multi power ue traffic ul and dl    ue_index=${1}   ul_throughput=100M    dl_throughput=1000M
# #     Check CC number_0 in X2log    x2ap_log=${X2tcpdump_log}
# #     Verify peak tput of each cell   dl_cell=${dl_cell}    ul_cell=${ul_cell}   expected_dl_tput_max=${expected_dl_tput_max}
# #         ...     expected_dl_tput_min=${expected_dl_tput_min}      expected_ul_tput=${expected_ul_tput}
# #         ...     dl_num_exp=${1}   ul_num_exp=${1}
# #     stop multi power ue traffic ul and dl   ue_index=${1}
# #     Append to list    ${5Grach_ed_list}    ${5Grach_ed_1}
# # ##UE2##
# # #
# # ###UE3##
# #     Verify UE attach by UE Index    ue_num=${2}    5Grach_ed_list=${5Grach_ed_list}
# #     Start X2 log capture from eNB    log_name=X2_tcpdump_1_2    interface=br1
# #     ${5Grach_ed_2}    attach multi power ue    ue_index=${2}
# #     Sleep  1min
# #     ${X2tcpdump_log}    Stop X2 log capture from eNB    log_name=X2_tcpdump_1_2
# #     start multi power ue traffic ul and dl    ue_index=${2}   ul_throughput=100M    dl_throughput=1000M
# #     Check CC number_0 in X2log    x2ap_log=${X2tcpdump_log}
# #     Verify peak tput of each cell   dl_cell=${dl_cell}    ul_cell=${ul_cell}   expected_dl_tput_max=${expected_dl_tput_max}
# #     ...     expected_dl_tput_min=${expected_dl_tput_min}      expected_ul_tput=${expected_ul_tput}
# #     ...     dl_num_exp=${1}    ul_num_exp=${1}
# #     stop multi power ue traffic ul and dl   ue_index=${2}
# #     Append to list    ${5Grach_ed_list}    ${5Grach_ed_2}
# # ###UE3##
# # 
# # ###UE4##
# #     Verify UE attach by UE Index    ue_num=${3}    5Grach_ed_list=${5Grach_ed_list}
# #     Start X2 log capture from eNB    log_name=X2_tcpdump_1_3    interface=br1
# #     ${5Grach_ed_3}    attach multi power ue    ue_index=${3}
# #     Sleep  1min
# #     ${X2tcpdump_log}    Stop X2 log capture from eNB    log_name=X2_tcpdump_1_3
# #     start multi power ue traffic ul and dl    ue_index=${3}   ul_throughput=100M    dl_throughput=1000M
# #     Check CC number_0 in X2log    x2ap_log=${X2tcpdump_log}
# #     Verify peak tput of each cell   dl_cell=${dl_cell}    ul_cell=${ul_cell}   expected_dl_tput_max=${expected_dl_tput_max}
# #     ...     expected_dl_tput_min=${expected_dl_tput_min}      expected_ul_tput=${expected_ul_tput}
# #     ...     dl_num_exp=${1}    ul_num_exp=${1}
# #     stop multi power ue traffic ul and dl   ue_index=${3}
# # ##UE4##
# #     [Teardown]    run keyword and ignore error     case teardown for 7660
# # 
# # 
# # 
# # [1]FGCR-7660-5GC001726-GA-001-5G19B mmW 8CC_4CC_2CC_1CC UE balancing
# #     [Documentation]    author: Fang ludan
# #     ...   The purpose of this test case is to validate a more balanced admission control in default value situation.
# #     ...   A values of “0” for each NRCELL-tmpParam threshold to ensure the threshold is ignored when this special (default) value is used.
# #     [Tags]    CRT_20B   CRT_TRUNK
# #     [Timeout]    1 hour
# #     [Setup]    Case Preparation for 7660
# #     Modify SCF on ENB for 7660      online_modify_parameters=${MODIFY_ENB_VIA_API_P1}
# #     ${5Grach_ed_list}    create list
# # 
# # ##UE1##
# #     Start X2 log capture from eNB    log_name=X2_tcpdump_2_0    interface=br1
# #     ${5Grach_ed_0}    attach multi power ue    ue_index=${0}
# #     Sleep  1min
# #     ${X2tcpdump_log}    Stop X2 log capture from eNB    log_name=X2_tcpdump_2_0
# #     start multi power ue traffic ul and dl    ue_index=${0}   ul_throughput=100M    dl_throughput=1000M
# #     Check CC number in X2log    x2ap_log=${X2tcpdump_log}     cell_num_exp=${8CC_num}
# #     Verify peak tput of each cell   dl_cell=${dl_cell}    ul_cell=${ul_cell}   expected_dl_tput_max=${expected_dl_tput_max}
# #     ...     expected_dl_tput_min=${expected_dl_tput_min}      expected_ul_tput=${expected_ul_tput}
# #     ...     dl_num_exp=${8CC_num_for_Tput}    ul_num_exp=${1}
# #     stop multi power ue traffic ul and dl   ue_index=${0}
# #     Append to list    ${5Grach_ed_list}    ${5Grach_ed_0}
# # ###UE1##
# # 
# # ###UE2##
# #     Verify UE attach by UE Index    ue_num=${1}    5Grach_ed_list=${5Grach_ed_list}
# #     Start X2 log capture from eNB    log_name=X2_tcpdump_2_1    interface=br1
# #     ${5Grach_ed_1}    attach multi power ue    ue_index=${1}
# #     Sleep  1min
# #     ${X2tcpdump_log}    Stop X2 log capture from eNB    log_name=X2_tcpdump_2_1
# #     start multi power ue traffic ul and dl    ue_index=${1}   ul_throughput=100M    dl_throughput=1000M
# #     Check CC number in X2log    x2ap_log=${X2tcpdump_log}   cell_num_exp=${4CC_num}
# #     Verify peak tput of each cell   dl_cell=${dl_cell}    ul_cell=${ul_cell}   expected_dl_tput_max=${expected_dl_tput_max}
# #         ...     expected_dl_tput_min=${expected_dl_tput_min}      expected_ul_tput=${expected_ul_tput}
# #         ...     dl_num_exp=${4CC_num_for_Tput}   ul_num_exp=${1}
# #     stop multi power ue traffic ul and dl   ue_index=${1}
# #     Append to list    ${5Grach_ed_list}    ${5Grach_ed_1}
# # ###UE2##
# # 
# # ##UE3##
# #     Verify UE attach by UE Index    ue_num=${2}    5Grach_ed_list=${5Grach_ed_list}
# #     Start X2 log capture from eNB    log_name=X2_tcpdump_2_2    interface=br1
# #     ${5Grach_ed_2}    attach multi power ue    ue_index=${2}
# #     Sleep  1min
# #     ${X2tcpdump_log}    Stop X2 log capture from eNB    log_name=X2_tcpdump_2_2
# #     start multi power ue traffic ul and dl    ue_index=${2}   ul_throughput=100M    dl_throughput=1000M
# #     Check CC number in X2log    x2ap_log=${X2tcpdump_log}   cell_num_exp=${2CC_num}
# #     Verify peak tput of each cell   dl_cell=${dl_cell}    ul_cell=${ul_cell}   expected_dl_tput_max=${expected_dl_tput_max}
# #     ...     expected_dl_tput_min=${expected_dl_tput_min}      expected_ul_tput=${expected_ul_tput}
# #     ...     dl_num_exp=${2CC_num_for_Tput}   ul_num_exp=${1}
# #     stop multi power ue traffic ul and dl   ue_index=${2}
# #     Append to list    ${5Grach_ed_list}    ${5Grach_ed_2}
# # ##UE3##
# # 
# # #UE4##
# #     Verify UE attach by UE Index    ue_num=${3}    5Grach_ed_list=${5Grach_ed_list}
# #     Start X2 log capture from eNB    log_name=X2_tcpdump_2_3    interface=br1
# #     ${5Grach_ed_3}    attach multi power ue    ue_index=${3}
# #     Sleep  1min
# #     ${X2tcpdump_log}    Stop X2 log capture from eNB    log_name=X2_tcpdump_2_3
# #     start multi power ue traffic ul and dl    ue_index=${3}   ul_throughput=100M    dl_throughput=1000M
# #     Check CC number_0 in X2log    x2ap_log=${X2tcpdump_log}
# #     Verify peak tput of each cell   dl_cell=${dl_cell}    ul_cell=${ul_cell}   expected_dl_tput_max=${expected_dl_tput_max}
# #     ...     expected_dl_tput_min=${expected_dl_tput_min}      expected_ul_tput=${expected_ul_tput}
# #     ...     dl_num_exp=${1CC_num_for_Tput}    ul_num_exp=${1}
# #     stop multi power ue traffic ul and dl   ue_index=${3}
# # #UE4##
# #      [Teardown]   run keyword and ignore error     case teardown for 7660
# # 
# # 
# # 
# # 
# # 
# # 
