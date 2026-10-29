# *** Settings ***
# Suite Setup       Qualcomm Common Suite Setup
# Suite Teardown    Qualcomm Common Suite Teardown
# Test Setup        Qualcomm Common Test Setup
# Test Teardown     Qualcomm Common Test Teardown
# Force Tags        qualcomm    owner_l3gao    SBTS00   SBTS22R4   CRT
# Resource          ../../resources/KISS/robot/common_resource.robot
# Resource          ../../resources/sg10/internal_resource/internal_resource.robot
# Library           taf.sbts.oam.coam.admin
# Library           taf.pdu
# 
# Documentation     gNB10692
# ...    PMcounter 0x340000:15
# ...    cell bandwith 100mhz
# ...    M55308C10001~M55308C10006
# ...    PRB_USED_PDSCH   PRB_USED_PUSCH  PRB_AVAIL_PDSCH  PRB_AVAIL_PUSCH   PRB_AVAIL_PDSCH_BB_POOL   PRB_AVAIL_PUSCH_BB_POOL
# ...    M55308C35001~M55308C35009
# ...    PRB_UL_SU_MIMO_1LAYER  PRB_UL_SU_MIMO_2LAYER  PRB_UL_MU_MIMO_2LAYER    PRB_UL_MU_MIMO_3LAYER    PRB_UL_MU_MIMO_4LAYER
# ...    PRB_UL_MU_MIMO_NOPAIR_UE    PRB_UL_MU_MIMO_2PAIR_UE    PRB_UL_MU_MIMO_3PAIR_UE    PRB_UL_MU_MIMO_4PAIR_UE
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# @{LOG_NAME_LIST}    gnb_snapshot     sosreport
# ${UE1_ID}         c2d07079    #8450  1 2 3 4
# ${UE2_ID}         2cdcf49b    #8450  5 6 7 8
# ${UE3_ID}         733cc94b    #8550   9 10 11 12
# ${UE4_ID}         95fe0e6e    #8350   13 14
# ${UE_DL_PORT1}    5001
# ${UE_DL_PORT2}    5002
# ${UE_DL_PORT3}    5003
# ${UE_DL_PORT4}    5004
# ${UE_UL_PORT1}    5001
# ${UE_UL_PORT2}    5002
# ${UE_UL_PORT3}    5003
# ${UE_UL_PORT4}    5004
# ${DL_LOG}    /tmp/iperf_server_on_ue_log.txt
# ${UL_LOG}    /tmp/iperf_server_on_pc_log.txt
# ${DL_SEND_DATA_CMD}    -u -t 8000 -i 1 -P 1 -f m -b 1100.00M -l 1400B -T 64
# ${UL_SEND_DATA_CMD}    -u -c 10.108.183.187 -p 5182 -P 1 -i 1 -f m -b 200M -t 99999
# ${EXPORT_GRID_TP}    Common Displays;Events and Debug Msgs vs. Time
# ${EXPORT_GRID}    ${None}
# &{GNBMIRRORINGCONFIGS}     L2HI_MIRRORING='false'   L2RT_MIRRORING='true'     NUMBER_OF_FILES=10    FILE_SIZE_MBYTES=300
# ${SCFC_NAME}     CB007113_case01.xml
# ${GNB_SWCONFIG_QUAL_NAME}     gnb_swconfig.txt
# ${4G_S1_local_IP}    10.108.175.74
# ${FIX_RANK4}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x04
# ${FIX_RANK3}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x03
# ${FIX_RANK2}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x02
# ${FIX_RANK1}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x01
# ${FIX_RANK0}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x04
# ${dmc_file}    ${CONFIG_DIR_PATH}/qualcomm_config/NR5G_Debugging_TP.dmc
# ${UE_NUM}   4
# ${iperfpc_ip}   10.108.183.187  #10.106.164.21
# @{VENDOR_PARAMETER_C32}	maxNumLayerPrbL1Sp:273	   maxNumStreamPrbL1Sp:546	  maxNumWbStreamPrbL1Sp:546
# @{VENDOR_PARAMETER_C64}	maxNumLayerPrbL1Sp:1092	   maxNumStreamPrbL1Sp:2184	  maxNumWbStreamPrbL1Sp:2184
# ${DL_peak_TP}   1000
# ${UL_peak_TP}   135  #140
# ${GNB_SW_BUILD}    SBTS00_ENB_9999_230303_000004
# 
# *** Test Cases ***
# CB007113_I_1_case1_MUMIMO_4layers_with_UL_PRB_pooling_activated_2rank2ue
#     step1：commission gNB with WebUI
#     step2：attach UE1_UE2 and check counters and ULmimo
#     step3：attach UE3_UE4 and check counters and ULmimo
# 
# *** Keywords ***
# UE3_UE4 attach to right cell
#     Block Cell   313   gnb10692
#     Qualcomm attach ue hardly    ${UE3_ID}
#     Qualcomm detach ue    ${UE3_ID}
#     Unblock Cell    313    gnb10692
#     Block Cell   312   gnb10692
#     Qualcomm attach ue hardly    ${UE4_ID}
#     Qualcomm detach ue    ${UE4_ID}
#     Unblock Cell    312    gnb10692
# 
# Block Cell
#     [Arguments]    ${phy_cell_id}    ${alias}
#     log to console   block Cell${phy_cell_id}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
#     ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.administrativeState}'=='Unlocked'
#          ...    Run Keywords    TAF_ADMIN.lock    ${nrcel.id}    timeout=60    connection=${alias}  AND    sleep    60
#     TAF_ADMIN.teardown    connection=${alias}
# 
# Unblock Cell
#     [Arguments]    ${phy_cell_id}    ${alias}
#     log to console   unblock Cell${phy_cell_id}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
#     ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.administrativeState}'=='Locked'
#          ...    Run Keywords    TAF_ADMIN.unlock    ${nrcel.id}    timeout=60    connection=${alias}  AND    sleep    60
#     TAF_ADMIN.teardown    connection=${alias}
# 
# step1：commission gNB with WebUI
#     Modify Qualcomm gNB Swconfig
#     detach all UEs
#     UE3_UE4 attach to right cell
# #    upgrade gnb and check status    ${GNB_SW_BUILD}
# #    Set Mcs Channel Phase And Attenuation same time    ${PHASE_att_FILE_PATH}
# #    Modify Vendor and Qualcomm prepare gnb onair
#     Attach qualcomm ue and make call stable
# 
# step2：attach UE1_UE2 and check counters and ULmimo
#     Start capture only gnb syslog in 'step2' file
#     attach UE1_UE2 and check rrc logs    ${dmc_file}
#     Start UE1_UE2 full buffer
#     Wait '10s' for stable
#     log to console  check ULmimo UE1_2
#     Start QXDM trace    ${dmc_file}
# #    Get TDD 7113 counters
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'step2_tti'
#     check UE1_UE2 DL TP and bler with ttitrace    ${DL_peak_TP}    1    step2_tti    tti_7113_case01_pair_dl
#     Check UE1_UE2 UL TP and bler with ttitrace    ${UL_peak_TP}    1    step2_tti    tti_7113_case01_pair_ul
#     Stop QXDM trace    ${dmc_file}
#     Stop capture only gnb syslog in 'step2' file
# 
# step3：attach UE3_UE4 and check counters and ULmimo
#     Start capture only gnb syslog in 'step3' file
#     attach UE3_UE4 and check rrc logs    ${dmc_file}
#     Start UE3_UE4 full buffer
#     Wait '10s' for stable
#     log to console  check ULmimo UE1_2_3_4
#     Start QXDM trace    ${dmc_file}
# #    Get TDD 7113 counters
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'step3_tti'
#     check UE1_UE2_UE3_UE4 DL TP and bler with ttitrace    ${DL_peak_TP}    1    step3_tti    tti_7113_case01_pair_dl
#     Check UE1_UE2_UE3_UE4 UL TP and bler with ttitrace    ${UL_peak_TP}    1    step3_tti    tti_7113_case01_pair_ul
#     Stop QXDM trace    ${dmc_file}
#     Stop capture only gnb syslog in 'step3' file
# 
# Start UE1_UE2 full buffer
#     csn.connect to  ${iperfpc_ip}    username=ute  password=%EjvHVvvkQD6  alias=serve
#     ${ret}   csn.execute  ps -ef | grep iperf   connection=serve
#     ${ret}   csn.send command   pkill -9 iperf    connection=serve
#     ${ret}   csn.execute  ps -ef | grep iperf   connection=serve
#     : for    ${num}   IN RANGE  1   3
#     \     Qualcomm Start DL Data    ${UE${num}_ID}    ${UE_DL_PORT${num}}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
#     \     Qualcomm Start UL Data    ${UE${num}_ID}    ${UE_UL_PORT${num}}    ${UL_LOG}    ${UL_SEND_DATA_CMD}
# 
# Start UE3_UE4 full buffer
#     : for    ${num}   IN RANGE  3   5
# #    \     Qualcomm Start DL Data    ${UE${num}_ID}    ${UE_DL_PORT${num}}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
#     \     Qualcomm Start UL Data    ${UE${num}_ID}    ${UE_UL_PORT${num}}    ${UL_LOG}    ${UL_SEND_DATA_CMD}
# 
# attach 4 UES and check RRC with full buffer
#     [Arguments]    ${step_tag}
#     Start capture only gnb syslog in 'rrc_logs${step_tag}' file
#     Capture Qualcomm SA UE RRC logs and analysis   ${dmc_file}
#     Start UE full buffer
#     Wait '10s' for stable
#     Stop capture only gnb syslog in 'rrc_logs${step_tag}' file
# 
# 
# Attach qualcomm ue and make call stable
#     : for    ${num}   IN RANGE  1   ${UE_NUM}+1
#     \     Qualcomm detach ue    ${UE${num}_ID}
#     \     Qualcomm attach ue hardly    ${UE${num}_ID}
#     Start UE1_UE2 full buffer
#     Start UE3_UE4 full buffer
#     Wait '20s' for stable
#     Stop UE data
#     detach all UEs
# 
# attach UE '${attach_time}' times
#     : for    ${num_x}   IN RANGE  1   ${attach_time}+1
#     \     Start capture only gnb syslog in 'attach_multi_time_${num_x}' file
#     \     Attach qualcomm ue and make call stable     ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}
#     \     Stop capture only gnb syslog in 'attach_multi_time_${num_x}' file
# 
# detach all UEs
#     : for    ${num}   IN RANGE  1   ${UE_NUM}+1
#     \     Qualcomm detach ue    ${UE${num}_ID}
# 
# attach UE1_UE2 and check rrc logs
#     [Arguments]    ${dmc}
#     ${rnti_list}   create list
#     : for    ${num}   IN RANGE  1   3
#     \     Qualcomm Start Qxdm Trace    ${UE${num}_ID}    dmc_file=${dmc}
#     \     Qualcomm detach ue    ${UE${num}_ID}
#     \     Qualcomm attach ue hardly    ${UE${num}_ID}
#     \     ${ue_absolutely_path}    Qualcomm Stop Qxdm Trace    ${UE${num}_ID}    ${log_path}
#     \     Download qualcomm log    ${ue_absolutely_path}.hdf     ${EXPORT_GRID}    ${UE${num}_ID}_rrc_raw.txt
#     \     ${ret}    Get_Rach_Msg4_Crnti   ${test_log_directory()}${/}${UE${num}_ID}_rrc_raw.txt
#     \     set suite variable     ${rnti}     ${ret}
#     \     append to list    ${rnti_list}    ${rnti}
#     \     run keyword and continue on failure    filter_qcat_message
#           ...       ${test_log_directory()}${/}${UE${num}_ID}_rrc_raw.txt      ::=    ${test_log_directory()}${/}RRC_UE${num}.txt
#     \     set global variable  ${num}
#     set suite variable   ${rnti_list_suite}    ${rnti_list}
# 
# attach UE3_UE4 and check rrc logs
#     [Arguments]    ${dmc}
#     : for    ${num}   IN RANGE  3  5
#     \     Qualcomm Start Qxdm Trace    ${UE${num}_ID}    dmc_file=${dmc}
#     \     Qualcomm detach ue    ${UE${num}_ID}
#     \     Qualcomm attach ue hardly    ${UE${num}_ID}
#     \     ${ue_absolutely_path}    Qualcomm Stop Qxdm Trace    ${UE${num}_ID}    ${log_path}
#     \     Download qualcomm log    ${ue_absolutely_path}.hdf     ${EXPORT_GRID}    ${UE${num}_ID}_rrc_raw.txt
#     \     ${ret}    Get_Rach_Msg4_Crnti   ${test_log_directory()}${/}${UE${num}_ID}_rrc_raw.txt
#     \     set suite variable     ${rnti}     ${ret}
#     \     append to list    ${rnti_list_suite}    ${rnti}
#     \     run keyword and continue on failure    filter_qcat_message
#           ...       ${test_log_directory()}${/}${UE${num}_ID}_rrc_raw.txt      ::=    ${test_log_directory()}${/}RRC_UE${num}.txt
#     \     set global variable  ${num}
# 
# Stop UE data
#     : for    ${num}   IN RANGE  1   ${UE_NUM}+1
#     \     Qualcomm Stop DL Data    ${UE${num}_ID}    ${UE_DL_PORT${num}}
#     \     Qualcomm Stop UL Data    ${UE${num}_ID}    ${UE_UL_PORT${num}}
# 
# Download QC logs and check rrc
#     : for    ${num}   IN RANGE  1   ${NUM}+1
#     \     Download qualcomm log    ${ue${num}_logs_path}.hdf     ${EXPORT_GRID}    ${UE${num}_ID}_rrc_raw.txt
#     \     Qualcomm Start DL Data    ${UE${num}_ID}    ${UE_DL_PORT}+${num}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
#     \     Qualcomm Start UL Data    ${UE${num}_ID}    ${UE_UL_PORT}+${num}    ${UL_LOG}    ${UL_SEND_DATA_CMD}
#     \     log to console     comment  check RRC logs
#     \     run keyword and continue on failure    filter_qcat_message
#           ...       ${test_log_directory()}${/}${UE${num}_ID}_rrc_raw.txt      ::=    ${test_log_directory()}${/}RRC_UE${num}.txt
#     \     run keyword and continue on failure    check_log_with_au2anlysis
#     ...        ${CURDIR}/ini/8701_case15_rrclog_UE${num}.ini    p    save_log_directory=${test_log_directory()}
# 
# 
# check UE1_UE2 DL TP and bler with ttitrace
#     [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}
#     ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}_tti/tti_dl.csv
#     ...    ${test_log_directory()}/All/${tti_file}_tti/tti_dl_new.csv
#     ...    ${time_avg}   ratio=0.2    filter=dlFdSchedData.ackNack\=ACK
#     @{keys}  Get Dictionary Keys   ${a}
#     : FOR    ${T_rnti}   IN    @{rnti_list_suite}     #check bler
#     \    ${ackNack}    read_csv_columns    ${test_log_directory()}/All/${tti_file}_tti/tti_dl.csv
#     ...   dlFdSchedData.ackNack    rnti={T_rnti}
#     \    ${ret1}    evaluate  ${ackNack}.count('ACK')/len(${ackNack})
#     \    should be true  ${ret1}>0.98
#     : FOR      ${key}     IN     @{keys}    #check TP
#     \    ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
#     \    should be true  ${result}>${throughput}
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}_tti/
# 
# Check UE1_UE2 UL TP and bler with ttitrace
#     [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}
#     ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}_tti/tti_ul.csv
#     ...    ${test_log_directory()}/All/${tti_file}_tti/tti_ul_new.csv
#     ...    ${time_avg}    ratio=0.2    filter=ulHarqRxData.crcResult\=OK   cared_title=ulFdSchedData.tbSize
#     @{keys}  Get Dictionary Keys   ${a}
#     : FOR   ${num}   IN RANGE   1   3     #check tp based on given crnti
#     \    ${result1}  evaluate   ${a[${rnti_list_suite[${num}-1]}]}/${time_avg}/1024/1000
#     \    should be true  ${result1}>${throughput}
#     : FOR    ${T_rnti}   IN    @{rnti_list_suite}     #check bler
#     \    ${crcResult}    read_csv_columns    ${test_log_directory()}/All/${tti_file}_tti/tti_ul.csv
#     ...   ulHarqRxData.crcResult    rnti={T_rnti}
#     \    ${ret1}    evaluate  ${crcResult}.count('OK')/len(${crcResult})
#     \    should be true  ${ret1}>0.98
#     7113_check_file.Check 7113 Cell Rachslot     ${test_log_directory()}/All/${tti_file}_tti/tti_ul.csv      311      19
# #    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case15_pair_power_layer9.ini    log_need_to_check=i
# #    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}_tti/
# 
# check UE1_UE2_UE3_UE4 DL TP and bler with ttitrace
#     [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}
#     ${4UE_DL_TP_list}   create list
#     ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}_tti/tti_dl.csv
#     ...    ${test_log_directory()}/All/${tti_file}_tti/tti_dl_new.csv
#     ...    ${time_avg}   ratio=0.2    filter=dlFdSchedData.ackNack\=ACK
#     @{keys}  Get Dictionary Keys   ${a}
#     : FOR    ${T_rnti}   IN    @{rnti_list_suite}     #check bler
#     \    ${ackNack}    read_csv_columns    ${test_log_directory()}/All/${tti_file}_tti/tti_dl.csv
#     ...   dlFdSchedData.ackNack    rnti={T_rnti}
#     \    ${ret1}    evaluate  ${ackNack}.count('ACK')/len(${ackNack})
#     \    should be true  ${ret1}>0.98
#     : FOR      ${key}     IN     @{keys}    #check TP
#     \    ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
#     \    append to list    ${4UE_DL_TP_list}    ${result}
#     \    log to console    ${4UE_DL_TP_list}
#     ${4UE_DL_TP_list_sum}    evaluate    sum(${4UE_DL_TP_list})
#     log to console    UE DL TP ${4UE_DL_TP_list}
#     log to console    UE DL TP sum ${4UE_DL_TP_list_sum}
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/
#     run keyword and continue on failure    should be true    ${4UE_DL_TP_list_sum}>(${throughput}*3)
# 
# Check UE1_UE2_UE3_UE4 UL TP and bler with ttitrace
#     [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}
#     ${4UE_UL_TP_list}   create list
#     ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}_tti/tti_ul.csv
#     ...    ${test_log_directory()}/All/${tti_file}_tti/tti_ul_new.csv
#     ...    ${time_avg}    ratio=0.2    filter=ulHarqRxData.crcResult\=OK   cared_title=ulFdSchedData.tbSize
#     @{keys}  Get Dictionary Keys   ${a}
#     : FOR   ${num}   IN RANGE   1   3     #check tp based on given crnti
#     \    ${result1}  evaluate   ${a[${rnti_list_suite[${num}-1]}]}/${time_avg}/1024/1000
#     \    should be true  ${result1}>${throughput}
#     \    append to list    ${4UE_UL_TP_list}    ${result1}
#     \    log to console    ${4UE_UL_TP_list}
#     : FOR    ${T_rnti}   IN    @{rnti_list_suite}     #check bler
#     \    ${crcResult}    read_csv_columns    ${test_log_directory()}/All/${tti_file}_tti/tti_ul.csv
#     ...   ulHarqRxData.crcResult    rnti={T_rnti}
#     \    ${ret1}    evaluate  ${crcResult}.count('OK')/len(${crcResult})
#     \    should be true  ${ret1}>0.98
#     7113_check_file.Check 7113 Cell Rachslot     ${test_log_directory()}/All/${tti_file}_tti/tti_ul.csv      311      19
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case15_pair_power_layer9.ini    log_need_to_check=i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}_tti/
#     ${4UE_UL_TP_list_sum}    evaluate    sum(${4UE_UL_TP_list})
#     log to console    UE UL TP ${4UE_UL_TP_list}
#     log to console    UE UL TP sum ${4UE_UL_TP_list_sum}
#     run keyword and continue on failure    should be true    ${4UE_UL_TP_list_sum}>(${throughput}*3)
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}_tti/tti
# 
# Qualcomm attach ue hardly
#     [Arguments]    ${ue_id}
#     : FOR    ${reboot_count}    IN RANGE    1    5
#     \    ${out}    ${attach_status}     Run Keyword And Ignore Error   Qualcomm Attach With Adb    ${ue_id}
#     \    Run Keyword if    '${attach_status}'=='True'    Exit For Loop
#     \    Qualcomm Execute Adb Cmd     ${ue_id}    reboot
#     \    Wait '60s' for stable
#     \    ${reboot_count}    Set Variable    ${reboot_count}+1
#     \    Qualcomm Detach With Adb      ${ue_id}
# 
# Start QXDM trace
#     [Arguments]    ${dmc}
#     : for    ${num}   IN RANGE  1   ${UE_NUM}+1
#     \     Qualcomm Start Qxdm Trace    ${UE${num}_ID}    dmc_file=${dmc}
# 
# Stop QXDM trace
#     [Arguments]    ${dmc}
#     : for    ${num}   IN RANGE  1   ${UE_NUM}
#     \     ${ue_absolutely_path}    Qualcomm Stop Qxdm Trace    ${UE${num}_ID}    ${log_path}    quit_app=false
#     \     sftp_download    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${ue_absolutely_path}.hdf    ${test_log_directory()}/
#     ${ue_absolutely_path}    Qualcomm Stop Qxdm Trace    ${UE4_ID}    ${log_path}
#     sftp_download    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${ue_absolutely_path}.hdf    ${test_log_directory()}/
# 
# Download qualcomm log
#     [Arguments]    ${UE_trace_file}    ${export_grid}    ${name}    ${txt_file_path}=${TXT_DEF_PATH}
#     ${qc_log}    qualcomm export to txt with qcat    ${UE_trace_file}    ${txt_file_path}    filter=${export_grid}
#     sftp_download    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${UE_trace_file}    ${test_log_directory()}/
#     sftp_download    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${qc_log}
#     ...              ${test_log_directory()}/${name}
# 
# Modify Qualcomm gNB Swconfig
# 	Add GNB swconfig	 0x420068:6   #act inter subpool
# 	Add GNB swconfig	 0x580612:1   #enable ADMIN developer
# 	Add GNB swconfig	 0x450027:1   # Admin developement account
# 	Add GNB swconfig     0x340000:15   #PM counter 1mim
# 
# Prepare for nsa env
#     unlock one 4G cell    289    ${4G_S1_local_IP}
#     Set ue to NSA    ${UE1_ID}
#     Wait '5s' for stable
#     Set ue to NSA    ${UE2_ID}
#     Wait '5s' for stable
#     Set ue to NSA    ${UE3_ID}
#     Wait '5s' for stable
#     Set ue to NSA    ${UE4_ID}
#     Wait '35s' for stable
# 
# 
# Prepare for sa env
#     run keyword and ignore error    lock one 4G cell    289     ${4G_S1_local_IP}
#     Set ue to SA simple    ${UE1_ID}
#     Wait '5s' for stable
#     Set ue to SA simple    ${UE2_ID}
#     Wait '5s' for stable
#     Set ue to SA simple    ${UE3_ID}
#     Wait '5s' for stable
#     Set ue to SA simple    ${UE4_ID}
#     Wait '5s' for stable
# 
# 
# Set ue to NSA simple
#     [Arguments]    ${ue_id}
#     ${value1}    Qualcomm Read Nvitem     ${ue_id}    80000
#     Wait '10s' for stable
#     Qualcomm Write Nvitem    ${ue_id}    80000    80
#     Wait '5s' for stable
#     Qualcomm Write Nvitem    ${ue_id}    74213    0,8192
#     Qualcomm Write Nvitem    ${ue_id}    74087    0
#     ${value1}    Qualcomm Read Nvitem     ${ue_id}    80000
#     Wait '10s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    reboot
# 
# Set ue to SA simple
#     [Arguments]    ${ue_id}
#     ${value1}    Qualcomm Read Nvitem     ${ue_id}    80000
#     Wait '15s' for stable
#     Qualcomm Write Nvitem    ${ue_id}    80000    64
#     Wait '5s' for stable
#     Qualcomm Write Nvitem    ${ue_id}    74213    0    #NSA
#     Qualcomm Write Nvitem    ${ue_id}    74087    0,8192    #SA
#     Wait '10s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    reboot
# 
# 
# Unlock one 4G cell
#     [Arguments]    ${phy_cell_id}    ${bts_id}=192.168.255.129    ${alias}=block
#     TAF_ADMIN.connect to    bts_host=${bts_id}    bts_port=443    use_ssl=True    name=${alias}
#     ${nrcel_list}    TAF_ADMIN.Get Parameters For All    LNCEL    timeout=30    connection=${alias}
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Run Keyword If    '${nrcel.phyCellId}'=='${phy_cell_id}' and '${nrcel.blockingState}'=='Blocked'
#     ...  TAF_ADMIN.unblock cell    ${nrcel.id}    timeout=60    connection=${alias}
#     TAF_ADMIN.teardown    connection=${alias}
# 
# lock one 4G cell
#     [Arguments]    ${phy_cell_id}    ${bts_id}=192.168.255.129    ${alias}=block
#     TAF_ADMIN.connect to    bts_host=${bts_id}    bts_port=443    use_ssl=True    name=${alias}
#     ${nrcel_list}    TAF_ADMIN.Get Parameters For All    LNCEL    timeout=30    connection=${alias}
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Run Keyword If    '${nrcel.phyCellId}'=='${phy_cell_id}' and '${nrcel.blockingState}'=='Unblocked'
#     ...   TAF_ADMIN.block cell    ${nrcel.id}    timeout=60    connection=${alias}
#     TAF_ADMIN.teardown    connection=${alias}
# 
# 
# Get TDD 7113 counters
#     Wait '40s' for stable
#     ${PRB_UL_PUSCH__cell1}   create list
#     ${PRB_UL_PUSCH__cell2}   create list
#     ${PRB_UL_PUSCH__cell3}   create list
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     log to console    ${remaining_time}
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
#     : FOR    ${num}    IN RANGE    1    10
# 	\    ${M55308C3500_cell1_res}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C3500${num}    cell_id=1
#     \    set suite variable     ${M55308C3500${num}_cell1}     ${M55308C3500_cell1_res}
#     \    append to list    ${PRB_UL_PUSCH__cell1}    ${M55308C3500${num}_cell1}
#     \    ${M55308C3500_cell2_res}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C3500${num}    cell_id=2
#     \    set suite variable     ${M55308C3500${num}_cell2}     ${M55308C3500_cell2_res}
#     \    append to list    ${PRB_UL_PUSCH__cell2}    ${M55308C3500${num}_cell2}
#     \    ${M55308C3500_cell3_res}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C3500${num}    cell_id=3
#     \    set suite variable     ${M55308C3500${num}_cell3}     ${M55308C3500_cell3_res}
#     \    append to list    ${PRB_UL_PUSCH__cell3}    ${M55308C3500${num}_cell3}
#     : FOR    ${num}    IN RANGE    1    7
# 	\    ${M55308C1000_cell1_res}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C1000${num}    cell_id=1
#     \    set suite variable     ${M55308C1000${num}_cell1}     ${M55308C1000_cell1_res}
#     \    append to list    ${PRB_UL_PUSCH_cell1}    ${M55308C1000${num}_cell1}
#     \    ${M55308C1000_cell2_res}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C1000${num}    cell_id=2
#     \    set suite variable     ${M55308C1000${num}_cell2}     ${M55308C1000_cell2_res}
#     \    append to list    ${PRB_UL_PUSCH_cell2}    ${M55308C1000${num}_cell2}
#     \    ${M55308C1000_cell3_res}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C1000${num}    cell_id=3
#     \    set suite variable     ${M55308C1000${num}_cell3}     ${M55308C1000_cell3_res}
#     \    append to list    ${PRB_UL_PUSCH_cell3}    ${M55308C1000${num}_cell3}
# 
#     set suite variable   ${PRB_UL_PUSCH__cell1_suite}    ${PRB_UL_PUSCH__cell1}
#     set suite variable   ${PRB_UL_PUSCH__cell2_suite}    ${PRB_UL_PUSCH__cell2}
#     set suite variable   ${PRB_UL_PUSCH__cell3_suite}    ${PRB_UL_PUSCH__cell2}
