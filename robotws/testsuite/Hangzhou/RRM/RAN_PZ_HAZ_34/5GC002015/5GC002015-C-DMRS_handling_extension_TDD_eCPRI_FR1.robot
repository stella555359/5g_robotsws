# *** Settings ***
# Documentation      author: Ji Jian
# ...                contact: jian.ji@nokia-sbell.com
# ...                Group: HGZ_SG2
# Force Tags         5G_RRM
# ...    PY36
# 
# Suite Setup        Common Suite Setup for COAM
# Suite Teardown     Common Suite Teardown for COAM
# 
# Resource           Resources/5GC001655_common_keyword.robot
# Variables          Resources/2015_variables.py
# 
# *** Variables ***
# ${scf_file}                 common_2x2.xml
# ${tmp_swconfig_dir}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/swconfig.txt
# @{swconfig_rank}            0x580017=1
# ${ue_index}                 0
# @{DmrsMappingType}          DlData_PdschGrant.dlDmrsMappingType               0    0
# @{DmrsTypeAPos}             DlData_PdschGrant.dlDmrsTypeAPos                  3    3
# @{DmrsAddPos}               DlData_PdschGrant.dlDmrsAddPos                    0    0
# @{PtrsFlag}                 DlData_PdschGrant.dlPtrsFlag                      0    0
# @{PtrsTimeDensity}          DlData_PdschGrant.dlPtrsTimeDensity               1    1
# @{PtrsFrequencyDensity}     DlData_PdschGrant.dlPtrsFrequencyDensity          2    2
# @{numofLaysers}             DlData_PdschGrant.numOfLayers                     2    4
# @{numOfDmrs}                DlData_PdschGrant.numOfDmrsCdmGroupWithoutData    2    2 
# @{checkpoint_list}      ${DmrsMappingType}    ${DmrsTypeAPos}    ${DmrsAddPos}    ${PtrsFlag}    ${PtrsTimeDensity}    ${PtrsFrequencyDensity}
#     ...                     ${numofLaysers}       ${numOfDmrs}
# @{MODIFY_SCF_2015_C_1116_01_list}     ${MODIFY_SCF_2015_C_1116_01_Step3}
#                               ...     ${MODIFY_SCF_2015_C_1116_01_Step5}
#                               ...     ${MODIFY_SCF_2015_C_1116_01_Step6}
#                               ...     ${MODIFY_SCF_2015_C_1116_01_Step7}
# 							  
# @{MODIFY_SCF_2015_C_1116_04_list}     ${MODIFY_SCF_2015_C_1116_01_Step3}
#                               ...     ${MODIFY_SCF_2015_C_1116_04_Step5}
#                               ...     ${MODIFY_SCF_2015_C_1116_01_Step6}
#                               ...     ${MODIFY_SCF_2015_C_1116_01_Step7}
# &{5GC002015_C_01}           SBTS22R2=QC_203071    SBTS22R3=QC_402749    SBTS22R4=QC_361905    SBTS23R1=QC_56877
# 
# *** Test Cases ***
# [1][2.0] 5GC002015_C_01_Verify frame structure of 1116 and DMRS FDM 64QAM with 2x2MIMO and PTRS OFF on SA mode
#     [Tags]     5GC002015     CRT_22R3    ${5GC002015_C_01['${program}']}
#     [Setup]     Case Setup
#     Modify Case SCF and Commission
#     ...    PARAMS_TO_MODIFY_SCF=${MODIFY_SCF_2015_C_1116_01_pre_condition}
#     ...    scf_file=${_scf_file_path_2x2}
#     UE Attach and Start Original Traffic
#     ...    direction=dl
#     ...    throughput=1200M
#     ...    duration=900
#     Check Traffic Throughput with Multiple parameter
#     ...    MODIFY_SCF_list=${MODIFY_SCF_2015_C_1116_01_list}
#     Run Keyword And Continue On Failure    Check Result in BIP in a loop
#     ...    index=${1}
#     ...    checkpoint_list=${checkpoint_list}
#     [Teardown]     Case Teardown
# 
# [1][2.0] 5GC002015_C_04_Verify frame structure of 1116 and DMRS FDM 256QAM with 2x2MIMO and PTRS off on SA mode
#     [Tags]     5GC002015     CRT_22R3
#     [Setup]     Case Setup
#     Modify Case SCF and Commission
#     ...    PARAMS_TO_MODIFY_SCF=${MODIFY_SCF_2015_C_1116_04_pre_condition}
#     ...    scf_file=${_scf_file_path_2x2}
#     UE Attach and Start Original Traffic
#     ...    direction=dl
#     ...    throughput=1200M
#     ...    duration=900
#     Check Traffic Throughput with Multiple parameter
#     ...    MODIFY_SCF_list=${MODIFY_SCF_2015_C_1116_04_list}
#     Run Keyword And Continue On Failure    Check Result in BIP in a loop
#     ...    index=${1}
#     ...    checkpoint_list=${checkpoint_list}
#     [Teardown]     Case Teardown
# 
# [1][2.0] 5GC002015_C_15_Verify frame structure of 1116 and DMRS FDM 256QAM with 4x4MIMO and PTRS OFF
#     [Tags]     5GC002015     CRT_22R3
#     [Setup]     Case Setup
#     Modify Case SCF and Commission
#     ...    PARAMS_TO_MODIFY_SCF=${MODIFY_SCF_2015_C_1116_15_pre_condition}
#     ...    scf_file=${_scf_file_path_4x4}
#     UE Attach and Start Original Traffic
#     ...    direction=dl
#     ...    throughput=1200M
#     ...    duration=900
#     Run Keyword And Continue On Failure    Check Result in BIP in a loop
#     ...    index=${2}
#     ...    checkpoint_list=${checkpoint_list}
#     [Teardown]     Case Teardown
# 
# [1][2.0] 5GC002015_C_18_Verify frame structure of 1116 and DMRS FDM 64QAM with 2x2MIMO and PTRS OFF on NSA mode
#     [Tags]     5GC002015     CRT_22R3
#     [Setup]     Case Setup
#     Modify Case SCF and Commission
#     ...    PARAMS_TO_MODIFY_SCF=${MODIFY_SCF_2015_C_1116_18_pre_condition}
#     ...    scf_file=${_scf_file_path_2x2}
#     UE Attach and Start Original Traffic
#     ...    direction=dl
#     ...    throughput=1200M
#     ...    duration=900
#     Check Traffic Throughput with Multiple parameter
#     ...    MODIFY_SCF_list=${MODIFY_SCF_2015_C_1116_04_list}
#     Run Keyword And Continue On Failure    Check Result in BIP in a loop
#     ...    index=${1}
#     ...    checkpoint_list=${checkpoint_list}
#     [Teardown]     Case Teardown
# 
# *** Keywords ***
# 
# UE Attach and Start Original Traffic
#     [Arguments]     ${direction}     ${throughput}     ${duration}
#     wait until keyword succeeds    15min    10s    Common UE Attach
#     power_ue.Start traffic     ue_type=${ue_type}     direction=${direction}     throughput=${throughput}     duration=${duration}
#     sleep    10s
#     Get original Mcs and Throughput
#     [Teardown]     Run Keyword And Continue On Failure     Run keywords
#     ...    Common Capture BIP log and download to testPC
#     ...    AND    Check MCS Value    bip_log=${bip_log_path}
#     ...    AND    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl     iperf_port=${dl_port}
#     ...    AND    power_ue.UE Detach     ue_type=${ue_type}
# 
# Start Traffic and Check Throughput
#     [Arguments]     ${throughput}    ${direction}=dl     ${duration}=900    ${Expected_Throughput_DL}=100
#     wait until keyword succeeds    15min    10s    Common UE Attach
#     power_ue.Start traffic     ue_type=${ue_type}     direction=${direction}     throughput=${throughput}     duration=${duration}
#     sleep    10s
# 	${tput_log}    Run Keyword And Continue On Failure    power_ue.Collect Tput    ue_type=${ue_type}    duration=2m
# 	${real_dl_tput}    Run Keyword And Continue On Failure    power_ue.Check Tput
#     ...    ue_type=${ue_type}    direction=DL    cells=${list_of_cell_ids}    log=${tput_log}    target_throughput=${Expected_Throughput_DL}
#     Log To Console    \nreal_dl_tput=${real_dl_tput}\n
#     Log To Console    \naverage_dl_tput=${real_dl_tput[0]['average']}\n
#     [Teardown]     Run Keyword And Continue On Failure     Run keywords
#     ...    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl     iperf_port=${dl_port}
#     ...    AND    power_ue.UE Detach     ue_type=${ue_type}
# 	
# Check Traffic Throughput with Multiple parameter
#     [Arguments]    ${MODIFY_SCF_list}    ${is_gnb_restrat_after_online_modify}=True
#     FOR     ${PARAMS_TO_MODIFY_SCF}    IN ZIP    ${MODIFY_SCF_list}
#         COAM Update several parameters via webUI
#         ...    parameters_to_update_via_webui=${PARAMS_TO_MODIFY_SCF}
#         ...    download_dir=${TS_CASE_LOG_PATH}
#         ...    is_gnb_restrat_after_online_modify=${is_gnb_restrat_after_online_modify}
#         Start Traffic and Check Throughput     throughput=1200M
#     END
# 
# 
# Check MCS Value
#     [Arguments]     ${bip_log}     ${check_mcs}=DlData_PdschGrant.mcs
#     Load pcap file    pcap_file=${bip_log}    field_name=dldata_pdschsendreq
#     ${values}    pcap.get_field_value_by_xpath     xpath=.//${check_mcs}
#     ${values}    Remove Duplicates    ${values}
#     log to console    ${values}
# #    FOR     ${flag}     IN     @{values}
# #        Run Keyword And Continue On Failure    should be true     0<=${flag}<=28
# #    END
# 
# Check Result in BIP in a loop
#     [Arguments]    ${index}     ${checkpoint_list}    ${field_name}=dldata_pdschsendreq
#     Load pcap file with filter    pcap_file=${bip_log_path}    field_name=${field_name}
#     FOR     ${checkpoint}    IN ZIP   ${checkpoint_list}
#         log to console     \n*** check if ${checkpoint[0].split('.')[-1]} is equal to ${checkpoint}[${index}] ***
#         ${values}    pcap.get_field_value_by_xpath     xpath=.//${checkpoint[0]}
#         ${values}    Remove Duplicates    ${values}
#         Run Keyword And Continue On Failure     should be true    '${values[0][-1]}'=='${checkpoint}[${index}]'
#         Run Keyword And Continue On Failure     log to console   ${checkpoint[0].split('.')[-1]}==${values[0][-1]}
#     END
# 
# Check and Modify dmrsTypeAPosition parameter
#     [Arguments]     ${expected_result}
#     COAM Navigate to login page via webUI     download_dir=${TS_CASE_LOG_PATH}
#     ${current_value_dlDmrsTypeAPos}     selenium_coam.get_parameter_value     dist_name=${MR_NR_CELL_NAME}     filter_param=Dmrs-TypeA position
#     ...     abbr=dmrsTypeAPosition     timeout=${120}
#     Run Keyword And Continue On Failure     Run keywords     selenium_coam.logout
#     ...     AND     selenium_coam.disable_virtual_display
#     run keyword if      '${current_value_dlDmrsTypeAPos}'=='pos2'     set list value     ${expected_result}     1     02
#     ...     ELSE IF     '${current_value_dlDmrsTypeAPos}'=='pos3'     set list value     ${expected_result}     1     03
#     [Return]     ${expected_result}
# 
# Get Mcs value in WebUI
#     COAM Navigate to login page via webUI     download_dir=${TS_CASE_LOG_PATH}
#     ${mcs_value}     selenium_coam.get_parameter_value     dist_name=${MR_NR_CELL_NAME}     filter_param=Initial MCS for DL transmission
#     ...     abbr=dllaIniMcs     timeout=${120}
#     [Teardown]     Run Keyword And Continue On Failure     Run keywords     selenium_coam.logout
#     ...     AND     selenium_coam.disable_virtual_display
#     [Return]     ${mcs_value}
# 
# Get original Mcs and Throughput
#     Wait until keyword succeeds    2 min    5 s    Teardown the Aasyslog save progress     gnb_index=${0}     du_index=${0}
#     ${origin_throughput}=     Caculate DL throughput from L2lo
#     ${origin_mcs}=     Run Keyword And Continue On Failure     Get Mcs value in WebUI
#     set test variable    ${origin_throughput}
#     set test variable    ${origin_mcs}
#     log to console    \n origin_throughput=${origin_throughput}Mbps
#     log to console    \n origin_mcs=${origin_mcs}
#     [Return]     ${origin_throughput}     ${origin_mcs}
# 
# Caculate DL throughput from L2lo
#     Teardown the Aasyslog save progress     gnb_index=${0}     du_index=${0}
#     Aasyslog precondition     gnb_index=${0}     du_index=${0}
#     Start the Aasyslog save progress     gnb_index=${0}     du_index=${0}     filter=L2Lo     log_name=data_dl.txt
#     ${throughput}=     Caculate DL throughput on gnb L2Lo with re     log_type=Aasyslog     sample=${50}
#     [Return]     ${throughput}
