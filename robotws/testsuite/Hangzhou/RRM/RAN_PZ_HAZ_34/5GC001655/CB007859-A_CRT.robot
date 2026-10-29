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
# *** Variables ***
# ${TS_LOG_PATH_BASE}    ${OUTPUT DIR}/Case_Logs
# ${scf_path_23R1}       /home/ute/Downloads/SCF/23R1
# ${scf_path_23R2}       /home/ute/Downloads/SCF/23R2
# ${scf_path_23R3}       /home/ute/Downloads/SCF/23R3
# ${scf_path_23R4}       /home/ute/Downloads/SCF/23R4
# ${scf_path_common}     /home/ute/Downloads/SCF/common.xml
# @{beam_set_6_horizontal}    -35    -35    -20    -20    -7    -7    7    7    20    20    35    35    -35    -35    -20    -20
# @{Beamset3_1_horizontal}    -26    -26    0    0    26    26    0    0    -26    -26    0    0    26    26    0    0
# @{beam_set_5_1_horizontal}    -33    -33    -16    -16    0    0    16    16    33    33    0    0    -33    -33    -16    -16
# @{beam_set_6_vertical}    96    96    96    96    96    96    96    96    96    96    96    96    96    96    96    96
# @{Beamset3_1_vertical}    96    96    96    96    96    96    102    102    96    96    96    96    96    96    102    102
# @{beam_set_5_1_vertical}    96    96    96    96    96    96    96    96    96    96    102    102    96    96    96    96
# ${tshark_path}    /usr/bin/tshark
# ${expression_cmas_ul}    \"uldata_puschreceivereq\"
# ${expression_cmas_dl}    \"dldata_pdschsendreq\"
# 
# *** Test Cases ***
# [1.0] CB007114_5G_D_1_Supporting_L2subpool_on_22R1_TDD_cell_set_halfABIO_3cells_3RU_8DL4UL_BF
#     [Tags]    CRT    CB007114    ${QC_ID}[1]
#     [Setup]    Case Setup
#     Reload Case SCF and Commission    scf_file=${scf_path}/common.xml
#     ${status}    Run keyword and return status    Download and Get item from xzfile
#     Run keyword if    '${status}'=='False'    Download snap and search file
#     [Teardown]    Case Teardown
# 
# CB007114_5G_B_1_Cell_startup_with_L2subpool_TDD_halfABIO_3RU_3cells_4DL4UL_nonBF
#     [Tags]    CRT    CB007114
#     [Setup]    Case Setup
#     Reload Case SCF and Commission    scf_file=${scf_path}/common.xml
#     Set Test Variable    ${ue_num}    ${4}
#     Multi UE Attach And Send Traffic    num=${ue_num}
#     sleep    5s
#     Check DL UL Throughput On Site
#     [Teardown]    Case Teardown
# 
# [1.0] CB007859_D_02_DBF_eCPRI_NSA_TDD_FR1_DL_enhanced FDM_8UEs_per_Cell_longPucch_differentBandwidth
#     [Tags]    CRT    5GC007859    ${QC_ID}[0]
#     [Setup]    Case Setup
#     Run Keyword And Ignore Error    MCS Set angle    horizontal_set=${beam_set_5_1_horizontal}
#     ...    vertical_set=${beam_set_5_1_vertical}
#     Set Test Variable    ${ue_num}    ${8}
#     Reload Case SCF and Commission    scf_file=${scf_path}/common.xml
#     Multi UE Attach And Send Traffic    num=${ue_num}
#     sleep    5s
#     Common Capture BIP log and download
#     Check DL UL Throughput On Site
#     Multi UE Check Tput    check_traffic_ul=0    check_traffic_dl=100    num=${ue_num}
#     sleep    15min
#     ${counter1}    Check BTS Counters via webUI    counter_id=M55308C17002
#     ${counter2}    Check BTS Counters via webUI    counter_id=M55308C18002
#     Should Contain any    ${counter1}    7    8
#     Should Contain any    ${counter2}    7    8
#     Check Value for 7859-H    dl_ul=dl    pid_rate=0
#     Check Value for 7859-H    dl_ul=ul    pid_rate=0
#     [Teardown]    Case Teardown
# 
# CB007859_100M_3RU
#     [Tags]    CRT    5GC007859
#     [Setup]    Case Setup
#     Run Keyword And Ignore Error    MCS Set angle    horizontal_set=${beam_set_6_horizontal}
#     ...    vertical_set=${beam_set_6_vertical}
#     Set Test Variable    ${ue_num}    ${24}
#     Reload Case SCF and Commission    scf_file=${scf_path}/common.xml
#     Multi UE Attach And Send Traffic    num=${8}
#     Multi UE Attach And Send Traffic SA
#     sleep    5s
#     Common Capture BIP log and download
#     Check DL UL Throughput On Site
#     sleep    15min
#     ${counter11}    Check BTS Counters via webUI    counter_id=M55308C17002    count_path=CELLS/NRCELL-1/NCELA/MAX_SCHED_UE_PDSCH
#     ${counter12}    Check BTS Counters via webUI    counter_id=M55308C18002    count_path=CELLS/NRCELL-1/NCELA/MAX_SCHED_UE_PUSCH
#     ${counter21}    Check BTS Counters via webUI    counter_id=M55308C17002    count_path=CELLS/NRCELL-2/NCELA/MAX_SCHED_UE_PDSCH
#     ${counter22}    Check BTS Counters via webUI    counter_id=M55308C18002    count_path=CELLS/NRCELL-2/NCELA/MAX_SCHED_UE_PUSCH
#     ${counter31}    Check BTS Counters via webUI    counter_id=M55308C17002    count_path=CELLS/NRCELL-3/NCELA/MAX_SCHED_UE_PDSCH
#     ${counter32}    Check BTS Counters via webUI    counter_id=M55308C18002    count_path=CELLS/NRCELL-3/NCELA/MAX_SCHED_UE_PUSCH
#     Should Contain    ${counter11}    7
#     Should Contain    ${counter12}    7
#     Should Contain    ${counter21}    7
#     Should Contain    ${counter22}    7
#     Should Contain    ${counter31}    7
#     Should Contain    ${counter32}    7
#     Check Value for 7859-H    dl_ul=dl    rnti_num=21    pid_num=21
#     Check Value for 7859-H    dl_ul=ul    rnti_num=21    pid_num=21
#     [Teardown]    Case Teardown
# 
# *** Keywords ***
# Common Suite Setup for COAM
#     Connect to gnb coam via ssl
#     ${build}    Coam Get Active SW Version
#     ${result}    String.split string    string=${build}    separator=_
#     @{QC_ID}    Run keyword if    'SBTS23R3' in ${result}    create list    QC_564348    QC_564353
#     ...    ELSE IF    'SBTS23R2' in ${result}    create list    QC_507049    QC_507013
#     ...    ELSE IF    'SBTS23R1' in ${result}    create list    QC_437844   QC_437846
#     ...    ELSE IF    'SBTS23R4' in ${result}    create list    QC_173729    QC_198513
#     ...    ELSE    create list    ${empty}
# 	Set suite variable    @{QC_ID}    @{QC_ID}
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
#     #CI_interface.Common Case Teardown
#     robot_common_operations.Common Case Teardown
# 
# Case Teardown TCP
#     Run keyword and ignore error    Multi UE Detach And Stop Traffic
#     Run keyword and ignore error    COAM Teardown gnb connections
#     Run keyword and ignore error    Common close Iperf server on PC
#     #CI_interface.Common Case Teardown
#     robot_common_operations.Common Case Teardown
# 
# Download snap and search file
#     ${snap_path}    COAM Save snapshot via rest api
#     should not be empty    ${snap_path} 
#     run    unzip -o ${snap_path} -d ${log_path}
#     ${zip_name}    search_list_from_snap    file_name=${log_path}/snapshot_file_list.txt    cprt_name=BTS17_1515_runtime.zip
#     should not be empty    ${zip_name}
#     run    unzip -o ${log_path}/${zip_name} -d ${log_path}
#     run    unzip -o ${log_path}/BTS17_1515_runtime.zip -d ${log_path}
#     run    unxz -f ${log_path}/runtime_cp_rt.log.xz
#     ${ex1}    ${ex2}    get_item_from_xzfile    file_path=${log_path}/runtime_cp_rt.log
#     Should Contain    ${ex1}    0    1    2
#     Should Contain    ${ex2}    0    1    2
#     [Teardown]    run    rm -r ${log_path}/*
# 
# Download file From ASIK To TestPC
#     [Arguments]   ${log_prefix}    ${path}    ${log_path}=${TS_CASE_LOG_PATH}   ${connection}=ASIK Master
#     @{list_log_names}    ssh_common_commands.get_file_names_under_directory    directory=${path}    connection=${connection}
#     ...    file_indicator=${log_prefix}*
#     should not be empty  ${list_log_names}    msg=No file found with log prefix ${log_prefix} under asik tmp folder
#     @{list_log_path_local}    Create list
#     FOR  ${log_name}  IN  @{list_log_names}
#         Wait Until Keyword Succeeds   2 min  5 sec   csn.Download file
#         ...   remote_path=${path}/${log_name}
#         ...   local_path=${log_path}/${log_name}
#         ...   connection=${connection}
#         Append to list    ${list_log_path_local}    ${log_path}/${log_name}
#     END
#     [Return]    ${list_log_path_local}[0]
#     
# Download and Get item from xzfile
#     Connect to Common Unit Master
#     ${xz_file}    Download file From ASIK To TestPC    log_prefix=startup_cp_rt    path=/ffs/run/logs/CPRT00_aasyslog
#     should not be empty    ${xz_file}
#     Run    unxz -f ${xz_file}
#     ${ex1}    ${ex2}    get_item_from_xzfile    file_path=${TS_CASE_LOG_PATH}/startup_cp_rt.log
#     Should Contain    ${ex1}    0    1    2
#     Should Contain    ${ex2}    0    1    2
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
# Multi UE Attach And Send TCP Traffic
#     [Arguments]    ${send_traffic_ul}=20MKbits/sec    ${send_traffic_dl}=200MKbits/sec    ${send_duration}=1800    ${num}=1
#     Common open Iperf server on PC
#     : FOR    ${ue_no}    IN RANGE    ${num}
#     \    Common UE Attach    ue_index=${ue_no}    power_reset=true
#     \    sleep    3s
#     \    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_ul}
#     \    ...    send_duration=${send_duration}
#     \    Run Keyword And Continue On Failure    Common UE Send DL TCP Traffic    ue_index=${ue_no}    duration=${send_duration}
# 
# Multi UE Attach And Send Traffic
#     [Arguments]    ${send_traffic_ul}=20MKbits/sec    ${send_traffic_dl}=300MKbits/sec    ${send_duration}=3600    ${num}=1
#     : FOR    ${ue_no}    IN RANGE    ${num}
#     \    Common UE Attach    ue_index=${ue_no}    power_reset=true
#     \    sleep    3s
#     \    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_ul}
#     \    ...    send_duration=${send_duration}
#     \    Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_dl}
#     \    ...    send_duration=${send_duration}
# 
# Multi UE Attach And Send Traffic SA
#     [Arguments]    ${send_traffic_ul}=20MKbits/sec    ${send_traffic_dl}=200MKbits/sec    ${send_duration}=3600
#     : FOR    ${ue_no}    IN    8    9    10    11    12    13    14    15    16    17    18    19    20    21    22    23
#     \    Common UE Attach    ue_index=${ue_no}    attach_mode=5G_SA    power_reset=true
#     \    sleep    3s
#     \    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_ul}
#     \    ...    send_duration=${send_duration}
#     \    Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_dl}
#     \    ...    send_duration=${send_duration}
# 
# Check DL UL Throughput On Site
#     ${cells}    get_item_from_scf    scf_file_path=${scf_path}/common.xml    ref=<p name="nrCellIdentity">([\\w\\W]*?)</p>
#     ${log_path}    power_ue.Collect Tput    ue_type=huawei    duration=1m    ignore_time=0min
#     power_ue.Check Tput    ue_type=huawei    direction=DL    log=${log_path}    cells=${cells}    target_throughput=100
#     power_ue.Check Tput    ue_type=huawei    direction=UL    log=${log_path}    cells=${cells}    target_throughput=0
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
# 	Set Test Variable    ${dl_command}    ${tshark_path} -r ${pcap_file} -Y ${expression_cmas_dl} -T pdml > ${output}
#     Run    ${dl_command}
# 
# Get ul pdml from bip
#     [Arguments]    ${pcap_file}=${bip_log_path}    ${output}=${TS_CASE_LOG_PATH}/2537.pdml
# 	Set Test Variable    ${ul_command}    ${tshark_path} -r ${pcap_file} -Y ${expression_cmas_ul} -T pdml > ${output}
#     Run    ${ul_command}
# 	
# Check Value for 7859-H
#     [Arguments]    ${dl_ul}=dl    ${output}=${TS_CASE_LOG_PATH}/2537.pdml    ${rnti_num}=7    ${pid_num}=7    ${pid_rate}=0.5
# 	Run keyword if    '${dl_ul}'=='dl'    Get dl pdml from bip
#     ...    ELSE IF   '${dl_ul}'=='ul'    Get ul pdml from bip
#     Get Item Num Per Slot    file_path=${output}    dl_or_ul=${dl_ul}    rnti_num=${rnti_num}    pid_num=${pid_num}    pid_rate=${pid_rate}
# 
# Enable mirror port and start capture on ASIL
#     [Arguments]     ${asik_alias}=ASIK Master
#     csn.Execute     command=bcicmd -n 3msd -c '/dbg3ms/port 15 set state up'    connection=${asik_alias}
#     csn.Execute     command=dbgnac set port 2 speed 25000    connection=${asik_alias}
#     csn.Execute     command=dbgnac enable port 2    connection=${asik_alias}
#     csn.Execute     command=dbgnac set port 2 loop e t    connection=${asik_alias}
#     csn.Execute     command=dbgnac mirror sport 0 dport 2 e i    connection=${asik_alias}
#     csn.Execute     command=dbgnac mirror sport 2 dport 20 e i    connection=${asik_alias}
#     csn.Execute     command=/usr/bin/netd_uspace_lnk 2 1 25000 1    connection=${asik_alias}
#     csn.Execute     command=ifconfig nac_eth2 up    connection=${asik_alias}
#     csn.Send command    command=tcpdump -i nac_eth2 -w /tmp/tcpdump_L2L1.pcap    connection=${asik_alias}
# 
# Stop Bip Log Capture on ASIL and download BIP Logs to testPC
#     [Arguments]     ${interface}=nac_eth2    ${connection}=ASIK Master
#     ...             ${log_path}=${TS_CASE_LOG_PATH}    ${download_type}=Download
#     ...             ${log_prefix}=${None}
#     Stop BIP Capture On ASIK    interface=${interface}
#     ${list_log_path_local}    Download file From ASIK To TestPC    log_prefix=tcpdump_L2L1    path=/tmp/
#     [Return]    ${list_log_path_local}
# 
# Capture BIP log and download on ASIL
#     [Arguments]     ${duration}=2s
#     Connect to Common Unit Master
#     Enable mirror port and start capture on ASIL
#     Sleep    ${duration}
#     ${list_log_path_local}    Stop Bip Log Capture on ASIL and download BIP Logs to testPC
#     set test variable    ${bip_log_path}    ${list_log_path_local}
#     Csn.Disconnect    connection=ASIK Master
