# *** Settings ***
# Suite Setup       common suite setup
# Suite Teardown    common suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Resource          ../../resources/KISS/robot/4g_common_resource.robot
# Force Tags       owner_l3gao   Qualcomm    CRT    SBTS00    CB009919
# 
# Documentation
# ...     case1 tm3 8271 has 2scell ,8272 has 1 scell
# ...     8273 +8274 non-ca
# ...     when ue flymode scell TP abnormal
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/Config_file/
# ${UE_CONFIG}      ${CURDIR}/Config_file/qualcomm_config/10.101.0.8.yml
# ${UE1_ID}    72d1d395     # qualcomm8350
# ${UE1_DL_PORT}    5003
# ${UE1_UL_PORT}    5005
# ${UE1_IP}         20.1.1.213
# ${UE1_DL_SERVER_LOG}    /tmp/iperf_server_on_ue_log1.txt
# ${UE1_UL_SERVER_LOG}    /tmp/iperf_server_on_pc_log1.txt
# ${UE1_DL_CLIENT_EXTRA_CMD}    -u -t 3600 -i 1 -P 1 -f m -b 400.00M -l 1400B -T 64
# ${UE1_UL_CLIENT_EXTRA_CMD}    -u -P 1 -i 1 -f m -w 4M -b 60M -t 999
# ${UE_PC_IP}       10.69.5.189
# ${UE_PC_USER}     SG-tester
# ${UE_PC_PASS}     Nokia123!
# ${export_grid}    LTE;Time Grids;Physical Grid;LTE L1 Tput and BLER vs. Time
# ${USE_SSL}        True
# ${BTS_PORT}       443
# ${BTS_ADDRESS}    192.168.255.129
# ${epc_server}     10.108.231.40
# ${CB009919_scfc_case10}    ${CURDIR}/Config_file/CB009919_SCFC_case10.xml
# ${swconfig_file}    ${CURDIR}/Config_file/swconfig.txt
# ${ATT_FILE_PATH}    ${CURDIR}/Config_file/LTE5228_new_good_Gting_10db_AEHC_att.csv
# ${PHASE_FILE_PATH}    ${CURDIR}/Config_file/LTE5228_new_good_Gting_10db_AEHC_phase.csv
# ${Qualcomm_DMC_file}    ${CURDIR}/Config_file/8350.dmc
# ${cellid}    8271
# ${tm3}    Dynamic Open Loop MIMO
# ${tm7}    Single Stream Beamforming
# ${tm8}    Dual Stream Beamforming
# 
# *** Test Cases ***
# CB009919_B_B3_case10_TM8_TDD_4CC_ULCA_DL_ULpeak_throughput
#     [Tags]    case10    CB009919_l3gao  tm8_frame1_7_1cc_2cc_3cc_4CC_ulca
#     [Setup]    test setup
#     Load and sent SCFC    ${CB009919_scfc_case10}
# 
#     online change parameters    9919_case10    ${tm8}    7    6   256QAM    true    -44    -90    -44    -44
#     attach UE twice and send full DLUL data
#     UE attach    ${UE1_ID}
#     collect qualcomm logs and cell peak and bler    3    88   22   3CC   false
# #    get counter file
#     Ue Detach    ${UE1_ID}
# 
# #    online change parameters    9919_case10    ${tm8}    7    6   256QAM    true    -90    -44    -44    -44
# #    UE attach    ${UE1_ID}
# #    collect qualcomm logs and cell peak and bler    4    87   22   4CC   false
# #    Ue Detach    ${UE1_ID}
# 
#     online change parameters    9919_case10    ${tm8}    7    6   64QAM    false    -44    -44    -90    -44    UL_CA_with_smartSched
#     sleep   60s
#     UE attach    ${UE1_ID}
#     collect qualcomm logs and cell peak and bler    2    64   22   2CC   true
#     Ue Detach    ${UE1_ID}
# 
#     online change parameters    9919_case10    ${tm8}    7    6   64QAM    false    -90    -44    -44    -44    UL_CA_with_smartSched
#     UE attach    ${UE1_ID}
#     send data again
#     collect qualcomm logs and cell peak and bler    4    64   22   4CC_ULCA   true
#     Ue Detach    ${UE1_ID}
#     stop UE dl and ul data
#     [Teardown]    Test Teardown
# 
# *** Keyword ***
# send data again
#     Send DL Data    ${UE1_ID}    ${UE1_DL_PORT}    ${UE1_IP}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Send UL Data    ${UE1_ID}    ${UE1_UL_PORT}    ${epc_server}    ${UE1_UL_SERVER_LOG}   ${UE1_UL_CLIENT_EXTRA_CMD}
# 
# get counter file
#     [Arguments]    ${PM_tage}
#     ${remaining_time}    ta_kiss_bts.get_counter_file_remaining_time    counter_refresh_period=1min
#     log to console   PM counter remaind time is --------------${remaining_time}
#     Sleep    ${remaining_time}
#     ta_kiss_bts.Download Latest Pmcounter
#     ...    local_path=${SUITE_LOG_DIRECTORY}/${PM_tage}/PMcounter.xml.gz    source_path=/ram/    host=192.168.255.129    suffix=gz
# #    ${TP_cell}    Check cellTP PM Counter    ${SUITE_LOG_DIRECTORY}/PMcounter.xml    M8012C22    M8012C23    M8012C25    M8012C26    8271
# #    ${DL_peak_target}    evaluate    ${DL_peak}*${ccNUm}
# #    Run Keyword And Ignore Error    should be true   ${TP_cell1[3]}>(${DL_peak_target}-2000)
# #    Ue Detach    ${UE1_ID}
#     ${passed}=  Run Keyword And Return Status  Download Latest Pmcounter  local_path=${TEST_LOG_DIR}${/}    source_path=/tmp/
#     Run Keyword If  not ${passed}  Download Latest Pmcounter  local_path=${TEST_LOG_DIR}${/}  source_path=/tmp/  suffix=gz
#     Stop and collect enb syslog
#     ${pattern}=    Run Keyword If    '${passed}'=='True'    remove_file    ${TEST_LOG_DIR}/*.xz
#     ...    ELSE    remove_file    ${TEST_LOG_DIR}/*.gz
#     ${counter_file}    list files in directory    ${TEST_LOG_DIR}/    pattern=*.ANY.*
#     set test variable    ${counter_file}
#     ${Count_M8012C26}    get_counter_value_from_counter_file    ${TEST_LOG_DIR}/${counter_file[0]}    M8012C26    1
#     ${Count_M8012C23}    get_counter_value_from_counter_file    ${TEST_LOG_DIR}/${counter_file[0]}    M8012C23    1
# 
# 
# Get cell UL_DL TP
#     [Arguments]    ${counter_file}    ${PDCP_DATA_RATE_MEAN_UL}    ${PDCP_DATA_RATE_MEAN_DL}    ${cell_id}
#     ${counter_value1}    Get Counter Value From Counter File    ${counter_file}    ${PDCP_DATA_RATE_MEAN_UL}    ${cell_id}
#     ${counter_value2}    Get Counter Value From Counter File    ${counter_file}    ${PDCP_DATA_RATE_MEAN_DL}    ${cell_id}
#     ${counter_list}    Create List      ${counter_value1}    ${counter_value2}    ${counter_value3}    ${counter_value4}
#     log to console    \n cell${CellID}'s DL mean tp is ${counter_value2}
#     log to console    \n cell${CellID}'s UL mean tp is ${counter_value1}
#     [Return]    ${counter_value2}    ${counter_value1}
# 
# collect qualcomm logs and cell peak and bler
#     [Arguments]    ${ccNUm}     ${DL_peak}    ${UL_peak}    ${tag_logs}    ${ULCA}=false
#     log to console   load qxdm to capture logs
#     Qualcomm Start Qxdm Trace    ${UE1_ID}    dmc_file=${CURDIR}/Config_file/8350.dmc
#     Sleep    6
#     ${path1}  Qualcomm Stop Qxdm Trace   ${UE1_ID}  C:\\tmp\\Qualcomm\\
#     log to console  qualcomm log path name is ${path1}
#     collect_qualcomm_log    ${path1}.hdf    ${export_grid}    Throughput_${UE1_IP}_${tag_logs}.txt
#      : FOR    ${num}    IN RANGE    0    ${ccNUm}
#     \    ${rt_1}    get_dl_cell_tput    ${SUITE_LOG_DIRECTORY}${/}Throughput_${UE1_IP}_${tag_logs}.txt    ${num}
#     \    ${UE1_cell_dl_tput}    evaluate    ${rt_1}/1024
#     \    ${rt_2}    get_ul_cell_tput    ${SUITE_LOG_DIRECTORY}${/}Throughput_${UE1_IP}_${tag_logs}.txt    ${num}
#     \    ${UE1_cell_ul_tput}    evaluate    ${rt_2}/1024
#     \    set suite variable    ${UE1_cell${num}_dl_tput}    ${UE1_cell_dl_tput}
#     \    set suite variable    ${UE1_cell${num}_ul_tput}    ${UE1_cell_ul_tput}
#     \    ${UE1_cell_dl_bler}    get_dl_cell_bler    ${SUITE_LOG_DIRECTORY}${/}Throughput_${UE1_IP}_${tag_logs}.txt    ${num}
#     \    set suite variable    ${UE1_cell${num}_dl_bler}    ${UE1_cell_dl_bler}
#     \    ${UE1_cell_ul_bler}    get_ul_cell_bler    ${SUITE_LOG_DIRECTORY}${/}Throughput_${UE1_IP}_${tag_logs}.txt    ${num}
#     \    set suite variable    ${UE1_cell${num}_ul_bler}    ${UE1_cell_ul_bler}
#     \    log to console  \n ${tag_logs} cc${num} dl_tp is ${UE1_cell${num}_dl_tput} target is ${DL_peak}
#     \    log to console  ${tag_logs} cc${num} dl_bler is ${UE1_cell${num}_dl_bler} target is 2
#     \    run keyword and continue on failure  should be true    ${UE1_cell${num}_dl_tput}>${DL_peak}
#     \    run keyword and continue on failure  should be true    ${UE1_cell${num}_dl_bler}<2
# 
#     log to console  ${tag_logs} Pcell ul_bler is ${UE1_cell0_ul_bler}
#     log to console  ${tag_logs} Pcell ul_tp is ${UE1_cell0_ul_tput} target is ${UL_peak}
#     should be true    ${UE1_cell0_ul_tput}>${UL_peak}
#     should be true    ${UE1_cell0_ul_bler}<2
# 
#     run keyword if    '${ULCA}'=='true'    log to console  ${tag_logs} Scell ul_bler is ${UE1_cell1_ul_bler}
#     run keyword if    '${ULCA}'=='true'    log to console  ${tag_logs} Scell ul_tp is ${UE1_cell1_ul_tput} target is (${UL_peak}-2)mbps
#     run keyword if    '${ULCA}'=='true'    should be true    ${UE1_cell1_ul_tput}>(${UL_peak}-3)   #kbps
#     run keyword if    '${ULCA}'=='true'    should be true    ${UE1_cell1_ul_bler}<2
# 
# online change parameters
#     [Arguments]    ${case_json_file}    ${dlMimoMode}    ${tddSpecSubfConf}    ${maxNumUeDlDwPTS}    ${actModulationSchemeDl}
#     ...    ${actDl256QamChQualEst}    ${qrxlevmin_8271}    ${qrxlevmin_8272}    ${qrxlevmin_8273}    ${qrxlevmin_8274}    ${actULCAggr}=false
#     log to console   start commission eNB by ${case_json_file}.json
#     taf.sbts.oam.coam.admin.Setup Admin    bts_host=192.168.255.129    bts_port=443    use_ssl=True
#     ${template}    OperatingSystem.Get File    ${CURDIR}/Config_file/${case_json_file}.json
# #    log to console    ${template}
#     ${message} =    Replace Variables    ${template}
#     Create File    ${CURDIR}/Config_file/${case_json_file}_modified.json    ${message}
#     perform_delta_recommissioning
#     ...    ${CURDIR}/Config_file/${case_json_file}_modified.json    skip_parameter_relation_errors=${True}    should_activate=${True}
#     teardown_admin
#     log to console   wait for eNB on air
#     ${cell_onair}    Cell Should Be Onair    timeout=3000
#     log to console   online change done and sleep 10s for all cell stable
#     Sleep    10
# 
# attach UE twice and send full DLUL data
#     log to console    attach UE for stable
#     Qualcomm attach ue hardly    ${UE1_ID}
#     Send DL Data    ${UE1_ID}    ${UE1_DL_PORT}    ${UE1_IP}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Send UL Data    ${UE1_ID}    ${UE1_UL_PORT}    ${epc_server}    ${UE1_UL_SERVER_LOG}   ${UE1_UL_CLIENT_EXTRA_CMD}
#     Sleep    25
#     Ue detach    ${UE1_ID}   #for UE stable
#     Qualcomm attach ue hardly    ${UE1_ID}
#     Sleep    25
#     Ue detach    ${UE1_ID}   #for UE stable
# #    stop UE dl and ul data
# 
# Check cellTP PM Counter
#     [Arguments]    ${counter_file}    ${PDCP_DATA_RATE_MAX_UL}    ${PDCP_DATA_RATE_MEAN_UL}
#     ...    ${PDCP_DATA_RATE_MAX_DL}      ${PDCP_DATA_RATE_MEAN_DL}    ${cell_id}
#     ${counter_value1}    Get Counter Value From Counter File    ${counter_file}    ${PDCP_DATA_RATE_MAX_UL}    ${cell_id}
#     ${counter_value2}    Get Counter Value From Counter File    ${counter_file}    ${PDCP_DATA_RATE_MEAN_UL}    ${cell_id}
#     ${counter_value3}    Get Counter Value From Counter File    ${counter_file}    ${PDCP_DATA_RATE_MAX_DL}    ${cell_id}
#     ${counter_value4}    Get Counter Value From Counter File    ${counter_file}    ${PDCP_DATA_RATE_MEAN_DL}    ${cell_id}
#     ${counter_list}    Create List      ${counter_value1}    ${counter_value2}    ${counter_value3}    ${counter_value4}
#     log to console    \n cell${CellID}'s UL_TP_MAX UL_TP_MEAN DL_TP_MAX DL_TP_MEAN are ---${counter_list}
#     [Return]    ${counter_list}
# 
# 
# 
# 
# UE Attach
#     [Arguments]    ${UE1_ID}
#     Qualcomm attach ue hardly    ${UE1_ID}
#     log to console   sleep for 10s for scell rank2 report
#     Sleep    5
# 
# start UE dl and ul full data
#     Send DL Data    ${UE1_ID}    ${UE1_DL_PORT}    ${UE1_IP}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
#     Send UL Data    ${UE1_ID}    ${UE1_UL_PORT}    ${epc_server}    ${UE1_UL_SERVER_LOG}   ${UE1_UL_CLIENT_EXTRA_CMD}
# #    Send DL Data    ${UE1_ID}    ${UE1_DL_PORT}    ${UE1_IP}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
# 
# stop UE dl and ul data
#     stop DL Data    ${UE1_ID}    ${UE1_DL_PORT}    ${UE1_IP}
#     stop UL Data    ${UE1_ID}    ${UE1_DL_PORT}
# 
# Send DL Data
#     [Arguments]    ${device_id}    ${port}    ${ue_ip}    ${server_log_path}    ${extra_cmd}
#     Qualcomm Start Iperf Server On Ue    ${device_id}    ${port}    log_path=${server_log_path}
#     Qualcomm Start Iperf Client On Pc    ${port}    ${ue_ip}    extra_cmd=${extra_cmd}
# 
# Stop DL Data
#     [Arguments]    ${device_id}    ${port}    ${UE1_IP}
#     Qualcomm Stop Iperf Server On Ue    ${device_id}    ${port}
#     Qualcomm Stop Iperf Client On Pc    ${port}
# 
# Send UL Data
#     [Arguments]    ${device_id}    ${port}    ${pc_ip}    ${server_log_path}    ${extra_cmd}
#     Qualcomm Start Iperf Server On Pc    ${port}    log_path=${server_log_path}
#     Qualcomm Start Iperf Client On Ue    ${device_id}    ${port}    ${pc_ip}    extra_cmd=${extra_cmd}
# 
# Stop UL Data
#     [Arguments]    ${device_id}    ${port}
#     Qualcomm Stop Iperf Server On Pc    ${port}
#     Qualcomm Stop Iperf Client On Ue    ${device_id}    ${port}
# 
# Block Cell
#     [Arguments]    ${phy_cell_id}    ${alias}
#     ${lncel_list}=    Get parameters for all    LNCEL    timeout=10    alias=${alias}
#     : FOR    ${lncel}    IN    @{lncel_list}
#     \    Log to console    \n physical cell ${lncel.phyCellId} is ${lncel.blockingState}
#     \    Run Keyword If    '${lncel.phyCellId}'=='${phy_cell_id}' and '${lncel.blockingState}'=='Unblocked'
#     \    ...    Run Keywords    block    ${lncel.id}    timeout=30
#     \    ...    alias=${alias}
#     \    ...    AND    sleep    5
# 
# Unblock Cell
#     ${lncel_list}=    Get parameters for all    LNCEL    timeout=10    alias=enb1
#     : FOR    ${lncel}    IN    @{lncel_list}
#     \    Run Keyword If    '${lncel.blockingState}'=='Blocked'    Run Keywords    unblock    ${lncel.id}    timeout=30
#         ...    alias=enb1
#         ...    AND    sleep    60
#     \    Log to console    \n physical cell ${lncel.phyCellId} is ${lncel.blockingState}
#     \    sleep    2
# 
# Block All Cell
#     [Arguments]    ${alias}
#     ${lncel_list}=    Get parameters for all    LNCEL    timeout=10    alias=${alias}
#     : FOR    ${lncel}    IN    @{lncel_list}
#     \    Log to console    \n block all cell
#     \    Run Keyword If    '${lncel.blockingState}'=='Unblocked'    Run Keywords    block    ${lncel.id}    timeout=30
#         ...    alias=${alias}
# #        ...    AND    sleep    10
# 
# Qualcomm attach ue hardly
#     [Arguments]    ${ue_id}
#     Ue Detach    ${UE1_ID}
#     Sleep    2
#     : FOR    ${reboot_count}    IN RANGE    1    3
#     \    ${out}    ${attach_status}     Run Keyword And Ignore Error   Qualcomm Attach With Adb    ${ue_id}
#     \    Run Keyword if    '${attach_status}'=='True'    Exit For Loop
#     \    Qualcomm Execute Adb Cmd    ${ue_id}    reboot
#     \    Sleep    70
#     \    ${reboot_count}    Set Variable    ${reboot_count}+1
#     \    Qualcomm Detach With Adb      ${ue_id}
# 
# Ue Detach
#     [Arguments]    ${device_id}
#     Qualcomm Detach With Adb    ${device_id}
# 
# collect_qualcomm_log
#     [Arguments]    ${UE_trace_file}    ${export_grid}    ${txt_file_name}    ${txt_file_path}=C:\\tmp\\Qualcomm\\
#     ${qualcomm_log_path}    qualcomm export to txt with qcat    ${UE_trace_file}    ${txt_file_path}    ${None}
#     sftp_download    10.69.5.189    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${UE_trace_file}    ${SUITE_LOG_DIRECTORY}${/}
#     sftp_download    10.69.5.189    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${qualcomm_log_path}    ${SUITE_LOG_DIRECTORY}${/}${txt_file_name}
# 
# 
# clean the process
#     connect to host    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    conn_type=SSH
#     run keyword and continue on failure    execute shell command    taskkill /f /im adb.exe
#     sleep    5
#     run keyword and continue on failure    execute shell command    taskkill /f /im QXDM.exe
#     disconnect from host
# 
# Unblock 1 Cell
#     [Arguments]    ${phy_cell_id}    ${alias}
#     ${lncel_list}=    Get parameters for all    LNCEL    timeout=10    alias=${alias}
#     : FOR    ${lncel}    IN    @{lncel_list}
#     Log to console    \n physical cell ${lncel.phyCellId} is ${lncel.blockingState}
#     Run Keyword If    '${lncel.phyCellId}'=='${phy_cell_id}' and '${lncel.blockingState}'=='Blocked'
#     ...    Run Keywords    unblock    ${lncel.id}    timeout=120    alias=enb1
#     ...    AND    sleep    60
# 
# 
# Load SCFC
#     [Arguments]    ${build}
#     Setup admin    bts_host=192.168.255.129    bts_port=443    use_ssl=True    alias=enb1
#     Run Keyword If    '${build}'=='SBTS23R3'    perform_commissioning    827    ${CB009919_scfc}
#     ...    skip_parameter_relation_errors=False    should_activate=True
#     ...    timeout=600     alias=enb1
#     teardown_admin    alias=enb1
# 
# Load and sent SCFC
#     [Arguments]    ${scfc_file}
#     Ue Detach    ${UE1_ID}
#     log to console   load ${scfc_file}
#     log to console   wait on air
#     Setup admin    bts_host=192.168.255.129    bts_port=443    use_ssl=True    alias=enb827
#     perform_commissioning    827    ${scfc_file}    skip_parameter_relation_errors=False    should_activate=True
#     ...    timeout=600     alias=enb827
#     teardown_admin    alias=enb827
#     ${cell_onair}    Cell Should Be Onair    timeout=3000
# 
# Download and update eNB build
#     [Arguments]    ${build}
#     Run Keyword If    '${build}'=='SBTS23R3'    download_latest_file    10.69.80.93    22    SG-tester    Nokia123!
#     ...    ${93_path_trunk}    /tmp/1.zip    filter=.*.zip
#     Setup admin    bts_host=192.168.255.129    bts_port=443    use_ssl=True    alias=enb1
#     Update Software    ${downloaded_latest_build}    should_activate=True    timeout=1800    alias=enb1
#     teardown_admin    alias=enb1
# 
# Set Mcs Channel Phase And Attenuation
#     [Arguments]    ${att_csv}    ${phase_csv}
#     Obtain MCS Info
#     MCS Setup    host_ip=${host_ip}    device_ip=${device_ip}    db_path=${db_path}    username=${USER}    password=${PASS}
#     MCS Set Frequency    frequency=2550
#     Mcs Set Attenuation    att=${att_csv}
#     Mcs Set Phase    phase=${phase_csv}
#     ${all_channel_info}=    MCS Query Channel Phase And Attenuation    channel=ALL
#     Log    ${all_channel_info}
#     MCS Teardown
# 
# power on 827
#     taf.pdu.setup pdu  FACOM   host=10.69.80.43  alias=gnb
#     taf.pdu.get port status   6   gnb    #827 leftrack
#     taf.pdu.power off   port=6   pdu_device=gnb
#     taf.pdu.get port status   6   gnb
#     sleep  5s
#     taf.pdu.power on   port=6   pdu_device=gnb
#     taf.pdu.get port status   6   gnb
# 
#     taf.pdu.setup pdu  FACOM   host=10.69.80.42  alias=enb
#     taf.pdu.get port status   5   gnb    #827 rightrack
#     taf.pdu.power off   port=5   pdu_device=enb
#     taf.pdu.get port status   5   gnb
#     sleep  5s
#     taf.pdu.power on   port=5   pdu_device=enb
#     taf.pdu.get port status   5   gnb
# 
# 
# suite setup
#     log to console    suite setup start
#     ${connection}    connect_to_host    ${epc_server}    port=22    username=ute    password=%EjvHVvvkQD6    conn_type=SSH
#     ${con}    get_current_connection
#     switch_host_connection    ${con}
#     execute shell command    pkill iperf -9
#     Disconnect From Host    ${con}
# #    power on 827
#     Setup Enb Fsm Access    alias=enb2
#     Run Keyword And Ignore Error    get_enb_swconfig_file    ${CURDIR}${/}swconfig_back.txt    alias=enb2
#     Run Keyword And Ignore Error    put_enb_swconfig_file    ${swconfig_file}    partition=active    alias=enb2
#     ${swversion}=    Get eNB SW Version    alias=enb2
#     log    activeBuildVersion=${swversion}
#     Teardown Enb Fsm Access    alias=enb2
#     ${build_SWDL}    Fetch From Left    ${swversion}    _
#     Comment   before load scfc detach all UE
#     Qualcomm Setup
#     sleep    1
#     Ue Detach    ${UE1_ID}
#     sleep    1
#     Setup Enb Fsm Access    alias=enb2
#     Run Keyword And Ignore Error    get_enb_swconfig_file    ${CURDIR}${/}swconfig_back.txt    alias=enb2
#     Run Keyword And Ignore Error    put_enb_swconfig_file    ${swconfig_file}    partition=active    alias=enb2
#     Teardown Enb Fsm Access    alias=enb2
#     log to console   get info for MCS
#     Obtain Env Info
#     qualcomm teardown
# #    Set Mcs Channel Phase And Attenuation    ${ATT_FILE_PATH}    ${PHASE_FILE_PATH}
# 
# test setup
#     log to console    \n test setup
#     ${timestamp}    Evaluate    time.strftime('%Y%m%d%H%M')    time
#     ${FILE_NAME} =    Replace String Using Regexp    ${SUITE_NAME[:50]}    \\s+$    ${EMPTY}
#     ${SUITE_LOG_DIRECTORY} =    Catenate    SEPARATOR=${/}    ${OUTPUT_DIR}    ev_logs    ${FILE_NAME}_${timestamp}
#     ${SUITE_LOG_DIRECTORY}    Replace String    ${SUITE_LOG_DIRECTORY}    ${SPACE}    _
#     Set Suite Variable    ${SUITE_LOG_DIRECTORY}
#     Create Directory    ${SUITE_LOG_DIRECTORY}
#     log to console    save log dir:${SUITE_LOG_DIRECTORY}
#     taf.sbts.oam.coam.admin.Setup Admin  bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=enb1
#     Setup Enb Fsm Access    alias=enb2
#     ${swversion}=    Get eNB SW Version    alias=enb2
#     log to console    ${swversion}
#     get_enb_swconfig_file    ${SUITE_LOG_DIRECTORY}${/}swconfig_back.txt    alias=enb2
#     put_enb_swconfig_file    ${swconfig_file}    partition=active    alias=enb2
#     Teardown Enb Fsm Access    alias=enb2
#     set_case_qc_id     ${TEST_NAME}     ${swversion}
#     Qualcomm Setup
# 
# Test Teardown
# #    Run Keyword And Ignore Error    teardown_admin    alias=enb1
#     Run Keyword And Ignore Error    taf.sbts.oam.coam.admin.teardown Admin    alias=enb1
#     Run Keyword And Ignore Error    Ue Detach    ${UE1_ID}
#     Run Keyword And Ignore Error    Ue Detach    ${UE2_ID}
#     Run Keyword And Ignore Error    Ue Detach    ${UE3_ID}
# #    Run Keyword And Ignore Error    disconnect from host
#     Run Keyword And Ignore Error    collect_syslog_results    alias=enb1_startup_syslog
#     Run Keyword And Ignore Error    collect_syslog_results    alias=enb1_startup_syslog
#     Run Keyword And Ignore Error    stop DL Data    ${UE1_ID}    ${UE1_DL_PORT}    ${UE1_IP}
#     Run Keyword And Ignore Error    stop UL Data    ${UE1_ID}    ${UE1_DL_PORT}
#     Run Keyword And Ignore Error    Qualcomm Teardown
#     Comment    Run Keyword And Ignore Error    check_err_wrn_in_btslog    ${SUITE_LOG_DIRECTORY}    all
#     Comment    Run Keyword And Ignore Error    get_active_alarm_via_admin    alias=enb1
#     Comment    Run Keyword And Ignore Error    collect_snapshot_and_im_via_admin    alias=enb1
#     Comment    Run Keyword And Ignore Error    collect_enb_parameter_file
# 
# check pm counter
#     ${remaining_time}    ta_kiss_bts.get_counter_file_remaining_time    counter_refresh_period=1min
#     log to console   PM counter remaind time is --------------${remaining_time}
#     Sleep    ${remaining_time}
#     ta_kiss_bts.Download Latest Pmcounter
#     ...    local_path=${SUITE_LOG_DIRECTORY}/PMcounter.xml.gz    source_path=/ram/    host=192.168.255.129    suffix=gz
#     ${TP_cell}    Check cellTP PM Counter    ${SUITE_LOG_DIRECTORY}/PMcounter.xml    M8012C22    M8012C23    M8012C25    M8012C26    8271
#     ${DL_peak_target}    evaluate    ${DL_peak}*${ccNUm}
#     Run Keyword And Ignore Error    should be true   ${TP_cell1[3]}>(${DL_peak_target}-2000)
#     Ue Detach    ${UE1_ID}
# 
# Step3:PM counter check
#     Start enb syslog'8'
#     ${remian_time}    get_counter_file_remaining_time
#     ${remian_time}    evaluate    ${remian_time}+900
#     Wait Throughput Timer  ${remian_time}
#     # start_capture_ttitrace'8'
#     Wait Throughput Timer    5
#     # Save_and_Decode_ttitrace_'8'
#     ${passed}=  Run Keyword And Return Status  Download Latest Pmcounter  local_path=${TEST_LOG_DIR}${/}    source_path=/tmp/
#     Run Keyword If  not ${passed}  Download Latest Pmcounter  local_path=${TEST_LOG_DIR}${/}  source_path=/tmp/  suffix=gz
#     Stop and collect enb syslog
#     ${pattern}=    Run Keyword If    '${passed}'=='True'    remove_file    ${TEST_LOG_DIR}/*.xz
#     ...    ELSE    remove_file    ${TEST_LOG_DIR}/*.gz
#     ${counter_file}    list files in directory    ${TEST_LOG_DIR}/    pattern=*.ANY.*
#     set test variable    ${counter_file}
#     ${Count_M8012C26}    get_counter_value_from_counter_file    ${TEST_LOG_DIR}/${counter_file[0]}    M8012C26    1
#     ${Count_M8012C23}    get_counter_value_from_counter_file    ${TEST_LOG_DIR}/${counter_file[0]}    M8012C23    1
#     set_test_variable    ${Count_M8012C26}
#     set_test_variable    ${Count_M8012C23}
#     log    4UE\_OTA\_total\_pm\_counter\_dl\_CA\_throughput\_open\_ulmumimo ${Count_M8012C26}    console=${True}
#     log    4UE\_OTA\_total\_pm\_counter\_ul\_CA\_throughput\_open\_ulmumimo ${Count_M8012C23}    console=${True}
#     Should Be True    ${Count_M8012C23}>45000
#     Should Be True    ${Count_M8012C26}>85000
