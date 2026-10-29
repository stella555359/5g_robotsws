# *** Settings ***
# Documentation     author: Bijiajian
# ...               contact: Jiajian.bi@nokia-sbell.com
# ...               squad group: SG_02
# Suite Setup       Common Suite Setup for COAM
# Suite Teardown    Common Suite Teardown
# Force Tags        5G_RRM    QCD_MN_RAN    QCP_RAN_ST
# Library           OperatingSystem
# Library           Collections
# Library           BuiltIn
# Library           String
# Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/Resources/Resource_common_keywords.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource          Resources/1347_common_keyword.robot
# Variables         Resources/2537_variables.py
# 
# 
# *** Variables ***
# ${mcs_ip}    ${tl.mcses.ip_addr}
# ${mcs_model}    ${tl.mcses.model}
# ${TS_LOG_PATH_BASE}    ${OUTPUT DIR}/Case_Logs
# ${scf_path_23R4}       /home/ute/Downloads/SCF/23R4
# ${scf_path_23R1}       /home/ute/Downloads/SCF/23R1
# ${scf_path_23R2}       /home/ute/Downloads/SCF/23R2
# ${scf_path_23R3}       /home/ute/Downloads/SCF/23R3
# ${scf_path_common}     /home/ute/Downloads/SCF/common.xml
# @{beam_set_2_horizontal}    -19    -19    19    19    -19    -19    19    19    -19    -19    19    19    -19    -19    19    19
# @{beam_set_5_1_horizontal}    -33    -33    -16    -16    0    0    16    16    33    33    0    0    -33    -33    -16    -16
# @{beam_set_5_1_horizontal_re}    -29    -29    -29    -29    31    31    31    31   -29   -29   -29   -29   31   31   31   31
# @{beam_set_6_horizontal}    -35    -35    -20    -20    -7    -7    7    7    20    20    35    35    -35    -35    -20    -20
# @{beam_set_8_horizontal}    -37    -37    -26    -26    -15    -15    -5    -5    5    5    15    15    26    26    37    37
# @{Beamset3_1_horizontal}    -26    -26    0    0    26    26    0    0    -26    -26    0    0    26    26    0    0
# @{beam_set_2_vertical}    96    96    96    96    96    96    96    96    96    96    96    96    96    96    96    96
# @{beam_set_5_1_vertical}    96    96    96    96    96    96    96    96    96    96    102    102    96    96    96    96
# @{beam_set_5_1_vertical_re}    98    98    98    98    102    102    102    102    98    98    98    98   102   102   102   102
# @{beam_set_6_vertical}    96    96    96    96    96    96    96    96    96    96    96    96    96    96    96    96
# @{beam_set_8_vertical}    96    96    96    96    96    96    96    96    96    96    96    96    96    96    96    96
# @{Beamset3_1_vertical}    96    96    96    96    96    96    102    102    96    96    96    96    96    96    102    102
# ${tshark_path}    /usr/bin/tshark
# ${expression_cmas_ul}    \"uldata_puschreceivereq\"
# ${expression_cmas_dl}    \"dldata_pdschsendreq\"
# 
# *** Test Cases ***
# CB002537_100M_6UE _beamset6
#     [Tags]    CRT    5GC002537    ${QC_ID}[3]
#     [Setup]    Case Setup
#     Run Keyword And Ignore Error    MCS Set angle    horizontal_set=${beam_set_6_horizontal}
#     ...    vertical_set=${beam_set_6_vertical} 
#     Set Test Variable    ${ue_num}    ${6}
#     Reload Case SCF and Commission    scf_file=${scf_path}/common_100M_beam6.xml
#     Multi UE Attach And Send Traffic    num=${ue_num}
#     sleep    5s
#     Run Keyword And Continue On Failure    Check DL UL Throughput On Site
#     Common Capture BIP log and download
#     Run Keyword And Ignore Error    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=100    num=${ue_num}
#     Check Value for 2537-E
#     [Teardown]    Case Teardown
# 	
# [1.0] 5GC002537-F#2_DL_and_UL_scheduling_of_4_UEs_in_a_single_slot_with_FD_BF_when_refined_beam_enable
#     [Tags]    CRT    5GC002537    ${QC_ID}[1]
#     [Setup]    Case Setup
#     Run Keyword And Ignore Error    MCS Set PA common
#     Run Keyword And Ignore Error    MCS Set angle    horizontal_set=${beam_set_6_horizontal}
#     ...    vertical_set=${beam_set_6_vertical}
#     Set Test Variable    ${ue_num}    ${6}
#     Reload Case SCF and Commission    scf_file=${scf_path}/common_100M_beam6_ref.xml
#     Multi UE Attach And Send Traffic    num=${ue_num}
#     sleep    5s
#     Run Keyword And Continue On Failure    Check DL UL Throughput On Site
#     Common Capture BIP log and download
#     Run Keyword And Ignore Error    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=100    num=${ue_num}
#     Check Value for 2537-E    dl_ul=dl    pid_rate=0
#     Check Value for 2537-E    dl_ul=ul    pid_rate=0
#     [Teardown]    Case Teardown
#     
# CB002537_100M_8UE _beamset8_2subcell
#     [Tags]    CRT    5GC002537
#     [Setup]    Case Setup
#     Run Keyword And Ignore Error    MCS Set angle    horizontal_set=${beam_set_8_horizontal}
#     ...    vertical_set=${beam_set_8_vertical} 
#     Set Test Variable    ${ue_num}    ${8}
#     Reload Case SCF and Commission    scf_file=${scf_path}/common_beamset8_2subcell.xml
#     Multi UE Attach And Send Traffic    num=${ue_num}
#     sleep    5s
#     Common Capture BIP log and download
#     Run Keyword And Ignore Error    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=100    num=${ue_num}
#     Check Value for 2537-H
#     [Teardown]    Case Teardown
# 
# [1.0] 5GC000534_EA#B1_21_Verify transmission Of SSB on beam set #5#1 for differents beams on OTA mode
#     [Tags]    CRT    5GC002537    ${QC_ID}[0]
#     [Setup]    Case Setup
#     Run Keyword And Ignore Error    MCS Set PA common
#     Run Keyword And Ignore Error    MCS Set angle    horizontal_set=${beam_set_5_1_horizontal}
#     ...    vertical_set=${beam_set_5_1_vertical} 
#     Set Test Variable    ${ue_num}    ${6}
#     Reload Case SCF and Commission    scf_file=${scf_path}/common_5_1.xml
#     Multi UE Attach And Send Traffic    num=${ue_num}
#     sleep    5s
#     Run Keyword And Continue On Failure    Check DL UL Throughput On Site
#     Common Capture BIP log and download
#     Run Keyword And Ignore Error    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=100    num=${ue_num}
#     Check Value for 2537-E    pid_rate=0
#     [Teardown]    Case Teardown
# 
# CB002537_80M_6UE_beamset2
#     [Tags]    CRT    5GC002537
#     [Setup]    Case Setup
#     Run Keyword And Ignore Error    MCS Set angle    horizontal_set=${beam_set_2_horizontal}
#     ...    vertical_set=${beam_set_2_vertical} 
#     Set Test Variable    ${ue_num}    ${6}
#     Reload Case SCF and Commission    scf_file=${scf_path}/common_80M.xml
#     Multi UE Attach And Send Traffic    num=${ue_num}
#     sleep    5s
#     Run Keyword And Continue On Failure    Check DL UL Throughput On Site
#     Common Capture BIP log and download
#     Run Keyword And Ignore Error    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=100    num=${ue_num}
#     Check Value for 2537-F    pid_num=2
#     [Teardown]    Case Teardown
# 
# CB002537_100M_6UE_COUNTER
#     [Tags]    CRT    5GC002537
#     [Setup]    Case Setup
#     Run Keyword And Ignore Error    MCS Set PA common
#     Run Keyword And Ignore Error    MCS Set angle    horizontal_set=${beam_set_5_1_horizontal}
#     ...    vertical_set=${beam_set_5_1_vertical}
#     Set Test Variable    ${ue_num}    ${6}
#     Reload Case SCF and Commission    scf_file=${scf_path}/common_5_1.xml
#     Multi UE Attach And Send Traffic    num=${ue_num}
#     sleep    5s
#     Run keyword and ignore error    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=100    num=${ue_num}
#     sleep    15min
#     ${counter1}    Check BTS Counters via webUI    counter_id=M55308C20001
#     ${counter2}    Check BTS Counters via webUI    counter_id=M55308C20002
#     ${counter3}    Check BTS Counters via webUI    counter_id=M55308C21001
#     ${counter4}    Check BTS Counters via webUI    counter_id=M55308C21002
#     ${counter5}    Check BTS Counters via webUI    counter_id=M55308C21003
#     ${counter6}    Check BTS Counters via webUI    counter_id=M55308C21004
#     ${counter7}    Check BTS Counters via webUI    counter_id=M55308C17002
#     ${counter8}    Check BTS Counters via webUI    counter_id=M55308C18002
#     Should Contain    ${counter1}    273
#     Should Contain    ${counter2}    239
#     should be true    @{counter3}[-1]>=${1000000} or @{counter3}[-2]>=${1000000}
#     should be true    @{counter4}[-1]>=${4} or @{counter4}[-2]>=${4}
#     should be true    @{counter5}[-1]>=${100000} or @{counter5}[-2]>=${100000}
#     should be true    @{counter6}[-1]>=${4} or @{counter6}[-2]>=${4}
#     should be true    @{counter7}[-1]>=${4} or @{counter7}[-2]>=${4}
#     should be true    @{counter8}[-1]>=${4} or @{counter8}[-2]>=${4}
#     [Teardown]    Case Teardown
# 
# CB002537_20M_6UE
#     [Tags]    CRT    5GC002537
#     [Setup]    Case Setup
#     Run Keyword And Ignore Error    MCS Set angle    horizontal_set=${beam_set_5_1_horizontal}
#     ...    vertical_set=${beam_set_5_1_vertical} 
#     Set Test Variable    ${ue_num}    ${6}
#     Reload Case SCF and Commission    scf_file=${scf_path_common}
#     Multi UE Attach And Send Traffic    num=${ue_num}
#     sleep    5s
#     Run Keyword And Continue On Failure    Check DL UL Throughput On Site
#     Common Capture BIP log and download
#     Run Keyword And Ignore Error    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=20    num=${ue_num}
#     [Teardown]    Case Teardown
# 
# CB002537_40M_6UE
#     [Tags]    CRT    5GC002537
#     [Setup]    Case Setup
#     Run Keyword And Ignore Error    MCS Set angle    horizontal_set=${Beamset3_1_horizontal}
#     ...    vertical_set=${Beamset3_1_vertical} 
#     Set Test Variable    ${ue_num}    ${6}
#     Reload Case SCF and Commission    scf_file=${scf_path}/common_40M.xml
#     Multi UE Attach And Send Traffic    num=${ue_num}
#     sleep    5s
#     Run Keyword And Continue On Failure    Check DL UL Throughput On Site
#     Run Keyword And Ignore Error    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=50    num=${ue_num}
#     [Teardown]    Case Teardown
# 
# CB002537_100M_6UE_enable2200
#     [Tags]    CRT    5GC002537
#     [Setup]    Case Setup
#     Run Keyword And Ignore Error    MCS Set PA common
#     Run Keyword And Ignore Error    MCS Set angle    horizontal_set=${beam_set_6_horizontal}
#     ...    vertical_set=${beam_set_6_vertical} 
#     Set Test Variable    ${ue_num}    ${6}
#     Reload Case SCF and Commission    scf_file=${scf_path}/common_2200.xml
#     Multi UE Attach And Send Traffic    num=${ue_num}
#     sleep    5s
#     Run Keyword And Continue On Failure    Check DL UL Throughput On Site    dl_target=1400   ul_target=150 
#     Run Keyword And Ignore Error    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=100    num=${ue_num}
#     [Teardown]    Case Teardown
# 
# CB002537_60M_6UE_Beamset3_1
#     [Tags]    CRT    5GC002537
#     [Setup]    Case Setup
#     Run Keyword And Ignore Error    MCS Set angle    horizontal_set=${Beamset3_1_horizontal}
#     ...    vertical_set=${Beamset3_1_vertical}
#     Set Test Variable    ${ue_num}    ${6}
#     Reload Case SCF and Commission    scf_file=${scf_path}/common_60M.xml
#     Multi UE Attach And Send Traffic    num=${ue_num}
#     sleep    5s
#     Run Keyword And Continue On Failure    Check DL UL Throughput On Site
#     Run Keyword And Ignore Error    Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=100    num=${ue_num}
#     [Teardown]    Case Teardown
# 
# 5GC000524-D_11_USR#D11_C2_TDD_8_Ues_4x4_FDM - ECPRI - Static Ues - NeighbourCorrelation_case C_rrmMaxNumBeamsDlSubcell
#     [Tags]    CRT    5GC002056    ${QC_ID}[2]
#     [Setup]    Case Setup
#     Run Keyword And Ignore Error    MCS Set angle    horizontal_set=${beam_set_5_1_horizontal_re}
#     ...    vertical_set=${beam_set_5_1_vertical_re}
#     Reload Case SCF and Commission    scf_file=${scf_path}/common_2x2.xml
#     Common UE Attach    ue_index=0    power_reset=true
#     sleep    3s
#     Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=0    send_traffic=50MKbits/sec
#     ...    send_duration=1800
#     Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=0    send_traffic=1000MKbits/sec
#     ...    send_duration=1800
#     Common UE Attach    ue_index=5    power_reset=true
#     sleep    3s
#     Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=5    send_traffic=50MKbits/sec
#     ...    send_duration=1800
#     Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=5    send_traffic=1000MKbits/sec
#     ...    send_duration=1800
#     sleep    5s
#     Run Keyword And Continue On Failure    Check DL UL Throughput On Site    ul_target=100
#     Common Capture BIP log and download
#     Check Value for 2056 2x2
#     Run Keyword And Continue On Failure    Common Stop traffic    direction=dl    ue_index=0
#     Run Keyword And Continue On Failure    Common Stop traffic    direction=ul    ue_index=0
#     Run Keyword And Continue On Failure    Common Stop traffic    direction=dl    ue_index=5
#     Run Keyword And Continue On Failure    Common Stop traffic    direction=ul    ue_index=5
#     [Teardown]    Case Teardown
# 
# *** Keywords ***
# Common Suite Setup for COAM
#     Connect to gnb coam via ssl
#     ${build}    Coam Get Active SW Version
#     ${result}    String.split string    string=${build}    separator=_
#     @{QC_ID}    Run keyword if    'SBTS23R3' in ${result}    create list    QC_564369    QC_564368    QC_564367    QC_564316
#     ...    ELSE IF    'SBTS23R4' in ${result}    create list    QC_56863    QC_56923    QC_86628    QC_198512
#     ...    ELSE IF    'SBTS23R1' in ${result}    create list    QC_000000    QC_437841    QC_437842    QC_437845
#     ...    ELSE IF    'SBTS23R2' in ${result}    create list    QC_507056    QC_507055    QC_507052    QC_506976
#     ...    ELSE    create list    ${empty}
#     Set suite variable    @{QC_ID}    @{QC_ID}
#     robot_common_operations.Common Suite Setup
# 
# Common Suite Teardown
#     robot_common_operations.Common Suite Teardown
# 
# Case Setup
#     COAM Create log directory
#     Connect to gnb coam via ssl
#     ${build}    Coam Get Active SW Version
#     ${result}    String.split string    string=${build}    separator=_
#     Run keyword if    'SBTS23R3' in ${result}    set test variable    ${scf_path}    ${scf_path_23R3}
#     ...    ELSE IF    'SBTS23R4' in ${result}    set test variable    ${scf_path}    ${scf_path_23R4}
#     ...    ELSE IF    'SBTS23R1' in ${result}    set test variable    ${scf_path}    ${scf_path_23R1}
#     ...    ELSE IF    'SBTS23R2' in ${result}    set test variable    ${scf_path}    ${scf_path_23R2}
#     robot_common_operations.Common Case Setup
# 
# Case Teardown
#     Run keyword and ignore error    Multi UE Detach And Stop Traffic
#     Run keyword and ignore error    COAM Teardown gnb connections
#     #Run keyword and ignore error    CI_interface.Common Case Teardown
#     robot_common_operations.Common Case Teardown
# 	
# Reload Case SCF and Commission
#     [Arguments]    ${scf_file}
#     Connect to gnb coam via ssl
#     COAM Commission with scf file    scf_file_path=${scf_file}
#     COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='SA'
# 
# Multi UE Detach And Stop Traffic
#     : FOR    ${ue_no}    IN RANGE    ${ue_num}
#     \    Run Keyword And Continue On Failure    Common Stop traffic    direction=dl    ue_index=${ue_no}
#     \    Run Keyword And Continue On Failure    Common Stop traffic    direction=ul    ue_index=${ue_no}
#     \    Run Keyword And Continue On Failure    Common UE Detach    ue_index=${ue_no}    power_reset=true
# 
# Multi UE Attach And Send Traffic
#     [Arguments]    ${send_traffic_ul}=50MKbits/sec    ${send_traffic_dl}=300MKbits/sec    ${send_duration}=1800    ${num}=1
#     : FOR    ${ue_no}    IN RANGE    ${num}
#     \    Common UE Attach    ue_index=${ue_no}    power_reset=true
#     \    sleep    3s
#     \    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_ul}
#     \    ...    send_duration=${send_duration}
#     \    Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_dl}
#     \    ...    send_duration=${send_duration}
# 
# Check DL UL Throughput On Site
#     [Arguments]    ${dl_target}=1300    ${ul_target}=140
#     ${cells}    get_item_from_scf    scf_file_path=${scf_path_common}    ref=<p name="nrCellIdentity">([\\w\\W]*?)</p>
#     ${log_path}    power_ue.Collect Tput    ue_type=huawei    duration=1m    ignore_time=0min
#     power_ue.Check Tput    ue_type=huawei    direction=DL    log=${log_path}    cells=${cells}    target_throughput=${dl_target}
#     power_ue.Check Tput    ue_type=huawei    direction=UL    log=${log_path}    cells=${cells}    target_throughput=${ul_target}
# 
# Multi UE Check DL Tput
#     [Arguments]    ${check_traffic_dl}=100    ${num}=1
#     : FOR    ${ue_no}    IN RANGE    ${num}
#     \    Run Keyword And Continue On Failure    Common UE Check DL Tput    ue_index=${ue_no}    
#     \    ...    check_traffic=${check_traffic_dl}
# 
# Multi UE Check Tput
#     [Arguments]    ${check_traffic_ul}=5    ${check_traffic_dl}=50    ${num}=1
#     : FOR    ${ue_no}    IN RANGE    ${num}
#     \    Run Keyword And Continue On Failure    Common UE Check UL And DL Tput    ue_index=${ue_no}    
#     \    ...    check_traffic_ul=${check_traffic_ul}    check_traffic_dl=${check_traffic_dl}
# 
# Get dl pdml from bip
#     [Arguments]    ${pcap_file}=${bip_log_path}   ${output}=${TS_CASE_LOG_PATH}/2537.pdml
#     Set Test Variable    ${dl_command}    ${tshark_path} -r ${pcap_file} -Y ${expression_cmas_dl} -T pdml > ${output}
#     Run    ${dl_command}
# 
# Get ul pdml from bip
#     [Arguments]    ${pcap_file}=${bip_log_path}    ${output}=${TS_CASE_LOG_PATH}/2537.pdml
#     Set Test Variable    ${ul_command}    ${tshark_path} -r ${pcap_file} -Y ${expression_cmas_ul} -T pdml > ${output}
#     Run    ${ul_command}
# 
# Check Value for 2537-E
#     [Arguments]    ${dl_ul}=dl    ${output}=${TS_CASE_LOG_PATH}/2537.pdml    ${rnti_num}=4    ${pid_num}=4    ${pid_rate}=0.3
# 	Run keyword if    '${dl_ul}'=='dl'    Get dl pdml from bip
#     ...    ELSE IF   '${dl_ul}'=='ul'    Get ul pdml from bip
#     Get Item Num Per Slot    file_path=${output}    dl_or_ul=${dl_ul}    rnti_num=${rnti_num}    pid_num=${pid_num}    pid_rate=${pid_rate}
# 
# Check Value for 2537-F
#     [Arguments]    ${dl_ul}=ul    ${output}=${TS_CASE_LOG_PATH}/2537.pdml    ${rnti_num}=4    ${pid_num}=4    ${pid_rate}=0.3
#     Run keyword if    '${dl_ul}'=='dl'    Get dl pdml from bip
#     ...    ELSE IF   '${dl_ul}'=='ul'    Get ul pdml from bip
#     Get Item Num Per Slot    file_path=${output}    dl_or_ul=${dl_ul}    rnti_num=${rnti_num}    pid_num=${pid_num}    pid_rate=${pid_rate}
# 
# Check Value for 2537-H
#     [Arguments]    ${dl_ul}=dl    ${output}=${TS_CASE_LOG_PATH}/2537.pdml    ${rnti_num}=8    ${pid_num}=4    ${pid_rate}=0.3
#     Run keyword if    '${dl_ul}'=='dl'    Get dl pdml from bip
#     ...    ELSE IF   '${dl_ul}'=='ul'    Get ul pdml from bip
#     Get Item Num Per Slot    file_path=${output}    dl_or_ul=${dl_ul}    rnti_num=${rnti_num}    pid_num=${pid_num}    pid_rate=${pid_rate}
# 
# Check Value for 2056 2x2
#     [Arguments]    ${output}=${TS_CASE_LOG_PATH}/524.pdml
#     Get dl pdml from bip    output=${output}
#     ${pass_rate}    check_524_from_pdml    file_path=${output}
#     should be true    ${pass_rate}>=0.2
# 	
# evaluate value
#     [Arguments]    ${count}
#     ${count}    evaluate    ${count}+${1}
#     Set Test Variable    ${count}
# 
# MCS Set Odd Attenuations
#     [Arguments]    ${attenuation}    ${begin_input_port}    ${end_input_port}    ${output_port}
#     [Documentation]    for example:
#     ...    ${attenuation} =${90.0}
#     ...    ${begin_input_port}=${1}
#     ...    ${end_input_port}=${64}
#     ...    ${output_port}=${1}
#     mcs.set_odd_attenuations    attenuation=${attenuation}    begin_input_port=${begin_input_port}    
#     ...    end_input_port=${end_input_port}    output_port=${output_port}
# 
# MCS Set Even Attenuations
#     [Arguments]    ${attenuation}    ${begin_input_port}    ${end_input_port}    ${output_port}
#     mcs.set_even_attenuations    attenuation=${attenuation}    begin_input_port=${begin_input_port}    
#     ...    end_input_port=${end_input_port}    output_port=${output_port}
# 
# Set Odd By Output_port
#     [Arguments]    ${begin_output_port}    ${end_output_port}    ${attenuation}    ${B_Odd}=True
#     :FOR    ${num}    IN RANGE    ${${begin_output_port}}    ${${end_output_port}}+1
#     \    Run keyword if    ${num}%2 and '${B_Odd}'=='True'    MCS Set Odd Attenuations    attenuation=${${attenuation}}    
#     \    ...    begin_input_port=${1}    end_input_port=${64}    output_port=${${num}}
#     \    Run keyword if    ${num}%2==0 and '${B_Odd}'=='False'    MCS Set Odd Attenuations    attenuation=${${attenuation}}    
#     \    ...    begin_input_port=${1}    end_input_port=${64}    output_port=${${num}}
# 
# Set Even By Output_port
#     [Arguments]    ${begin_output_port}    ${end_output_port}    ${attenuation}    ${B_Odd}=True
#     :FOR    ${num}    IN RANGE    ${${begin_output_port}}    ${${end_output_port}}+1
#     \    Run keyword if    ${num}%2 and '${B_Odd}'=='True'    MCS Set Even Attenuations    attenuation=${${attenuation}}    
#     \    ...    begin_input_port=${1}    end_input_port=${64}    output_port=${${num}}
#     \    Run keyword if    ${num}%2==0 and '${B_Odd}'=='False'    MCS Set Even Attenuations    attenuation=${${attenuation}}    
#     \    ...    begin_input_port=${1}    end_input_port=${64}    output_port=${${num}}
# 
# MCS Set PA common
#     MCS Setup    ip=${mcs_ip}    model=${mcs_model}    vendor=hbte
#     Set Odd By Output_port    begin_output_port=1    end_output_port=16    attenuation=0    B_Odd=True
#     Set Odd By Output_port    begin_output_port=1    end_output_port=16    attenuation=90    B_Odd=False
#     Set Even By Output_port    begin_output_port=1    end_output_port=16    attenuation=90    B_Odd=True
#     Set Even By Output_port    begin_output_port=1    end_output_port=16    attenuation=0    B_Odd=False
#     MCS Teardown
