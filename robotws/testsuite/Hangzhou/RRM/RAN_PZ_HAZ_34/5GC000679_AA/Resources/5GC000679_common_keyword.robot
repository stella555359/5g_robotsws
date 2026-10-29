*** Settings ***
Documentation     Auther: xiaodong.d.chen@nokia-sbell.com
...               Description: 679_common_keyword
Library           BuiltIn
Library           OperatingSystem
Library           Collections
Library           String
Library           taf.ue.tm500.asc    WITH NAME    asc
Library           679_DF_EF_modify_para.py
Library           TTI_trace_log_analysis.py
Library           TTI_trace_log_analysis.Event_trace_alaysis_679    WITH NAME    event_trace_analysis
Library           taf.rfrl.common_resources.python.SWConfig    WITH NAME    679swconfig
Resource          taf/rfrl/common_resources/robot/gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/tm500_hangzhou.robot
Resource          taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/alarm_checking.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Library           taf.analyzer.pcap        WITH NAME    pcap
Resource          ../../5GC001655/Resources/1347_common_keyword.robot
Resource          testsuite/Hangzhou/TRS/RAN_PZ_HAZ_34/CB005740/Resources/CB005740_common_keywords.robot


*** Variables ***
${TMA_SSH_ALIAS}    tma_ssh
${TMA_APP_ALIAS}    e500
${TAM_APP_PATH}    ${tl.ues[0].tma_path}
${E500_SCRIPTS_BASE}    ${CURDIR}/E500_scripts
${E500_IP}        ${tl.ues[0].tma_host.addr}
${E500_USER}      ${tl.ues[0].tma_host.username}
${E500_PW}        ${tl.ues[0].tma_host.password}
${TM500_PORT}    ${tl.ues[0].tma_command_port}
${E500_SSH_DOMAIN}    ${tl.ues[0].tma_host.private_key}
${iperf_path}    ${tl.ues[0].iperf_details.iperf_path}
@{ul_port_list}    5411  5412  5413  5414  5415  5416  5417  5418  5419  5420
${E500_upload_ip}    ${tl.ues[0].iperf_details.network_interface_address}
${E500_ASC_USER}    switch
${E500_ASC_PW}     switch
${E500_ASC_PORT}    10101
${TMA_ASC_ALIAS}    ASC
${tshark_path}    /usr/bin/tshark
${expression_cmas}    \"uldata_puschreceivereq\"
${command_template}    {tshark_path} -r {input_file} -X lua_script:{luashark_path} -Y ${expression_cmas} -T pdml > {output_file}
${rnti_2}    .//uldata_puschreceivereq[2]/UlData_PuschReceiveReq.grants_item_15.rnti
${rnti_4}    .//uldata_puschreceivereq[4]/UlData_PuschReceiveReq.grants_item_15.rnti
${rnti_5}    .//uldata_puschreceivereq[5]/UlData_PuschReceiveReq.grants_item_15.rnti

${numofPRB_1}    .//uldata_puschreceivereq[1]/UlData_PuschReceiveReq.grants_item_15.numOfPrb
${numofPRB_2}    .//uldata_puschreceivereq[2]/UlData_PuschReceiveReq.grants_item_15.numOfPrb
${numofPRB_3}    .//uldata_puschreceivereq[3]/UlData_PuschReceiveReq.grants_item_15.numOfPrb
${numofPRB_4}    .//uldata_puschreceivereq[4]/UlData_PuschReceiveReq.grants_item_15.numOfPrb

${pdsch_numofPrb}    DlData_PdschSendReq.grants_item_15.numOfPrb
${pdsch_slot}    DlData_PdschSendReq.PdschSendReq.slot
${pdsch_rnti}    DlData_PdschSendReq.PdschSendReq.rnti
${pdsch_sfn}     DlData_PdschSendReq.PdschSendReq.sfn

*** Keywords ***

679 Suite Setup
    [Arguments]    ${swconfig_modify}=${None}
    Backup and upload the new one based on default swconfig    swconfig_modify=${swconfig_modify}
    robot_common_operations.Common Suite Setup
    #Reset E500 via ASC

679 Suite TearDown
    Recover eNB swconfig file
    Kill tma process
    robot_common_operations.Common Suite Teardown

Backup and upload the new one based on default swconfig
    [Arguments]    ${swconfig_modify}    ${ASIK_MASTER_ALIAS}=ASIK Master    ${tmp_swconfig_path}=/home/ute/Downloads/TL218/swconfig.txt    
    Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
    Run keyword if    ${swconfig_modify}!=${None}
    ...    Run keywords    Log to console    Swconfig file modification is needed.    AND
    ...    679swconfig.modify_swConfig_file   parametersList=${swconfig_modify}    filePath=${tmp_swconfig_path}
    679swconfig.upload_swConfig_file_to_asik_and_crasign    localFilePath=${tmp_swconfig_path}    asik_alias=${ASIK_MASTER_ALIAS}
    csn.disconnect    connection=${ASIK_MASTER_ALIAS}

Recover eNB swconfig file
    Connect to Common Unit Master
    679swconfig.restore_swConfig_file_on_asik_and_crasign    asik_alias=ASIK Master
    csn.disconnect    connection=ASIK Master

Case Setup ready
    COAM Create log directory
    robot_common_operations.Common Case Setup

Recover test ENV
    [Arguments]    ${E500_Muti_UEs}=${E500_5892_phase2_Muti_UEs}    ${type}=NSA
    Stop DL traffic via iperf on Appserver to Multi UEs    ue_ip_list=${UE_IPs}
    Kill iperf process on E500 PC
    Cobham UE detach    e500_script_path=${E500_Muti_UEs}    type=${type}
    COAM Teardown gnb connections
    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot
    #csn.disconnect    connection=ASIK Master

Load Case SCF and Commission new
    [Arguments]    ${default_scf}
    Connect to gnb coam via ssl
    Run Keyword And Ignore Error    COAM Commission with scf file    scf_file_path=${default_scf}
    COAM Wait for gnb ready and cell setup    timeout=18 min    is_x2_check_from_gnb_needed=${False}

GNB is ready and UE attach new
    [Arguments]    ${ue_num}    ${679_default_scf}=${679_Korea_default_scf}    ${e500_script_path}=${E500_5892_phase2_Muti_UEs}
    ...    ${BW}=80    ${type}=NSA
    log to console      "load_SCFC"
    Load Case SCF and Commission new    default_scf=${679_default_scf}
    Synchron gNB and VIAVI
    log to console      "UE_attach_start"
    Cobham UE attach    ue_num=${ue_num}    e500_script_path=${e500_script_path}    BW=${BW}    type=${type}

GNB is ready and UE attach
    [Arguments]    ${ue_num}    ${679_default_scf}=${679_Korea_default_scf}    ${e500_script_path}=${E500_5892_phase2_Muti_UEs}
    ...    ${BW}=80    ${type}=NSA    ${PARAMS_TO_MODIFY_SCF}=${PARAMS_TO_MODIFY_Korea_conf_A}
    log to console      "load_SCFC"
    Modify SCF File and Commissioning    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_SCF}    679_default_scf=${679_default_scf}
    COAM Wait for gnb ready and cell setup    timeout=15 min
    Synchron gNB and VIAVI
    log to console      "UE_attach_start"
    Cobham UE attach    ue_num=${ue_num}    e500_script_path=${e500_script_path}    BW=${BW}    type=${type}    

Modify SCF File and Commissioning
    [Arguments]    ${PARAMS_TO_MODIFY_SCF}    ${679_default_scf}
    ${new_scf_file}    COAM Modify scf file    scf_file_path=${679_default_scf}    scf_parameters_list=${PARAMS_TO_MODIFY_SCF}
    Connect to gnb coam via ssl
    Run keyword and ignore error    COAM Commission with scf file    scf_file_path=${new_scf_file}

###E500 ralated process###
Synchron gNB and VIAVI
    [Arguments]    ${alias}=ASIK Master
    Connect to Common Unit Master
    ${cmd_export_pylib}    Evaluate    'export PYTHONPATH=/opt/hwmt/python:/opt/hwmt/lib/python2.7/site-packages'
    ${cmd_sync_clock}    Catenate    /opt/hwmt/python/sendommessage.sh -s 0x04dc -d HWASYNC-1/CLOCKOUTPUTS-1/SYNCOUT-1 --proto SYNC/sync_out
    ...                             -t execute --action setClock10MHz --args clock10MHz=1
    ${cmd_sync_frame_clock}    Catenate    /opt/hwmt/python/sendommessage.sh -s 0x04dc -d HWASYNC-1/CLOCKOUTPUTS-1/SYNCOUT-1 --proto SYNC/sync_out
    ...                    -t execute --action setFrameClock --args frameClock=1
    csn.send command    ${cmd_export_pylib}    connection=${alias}
    ${output_sync_clock}    csn.execute    ${cmd_sync_clock}    connection=${alias}
    sleep    2s
    Should Contain    ${output_sync_clock}    MitAaSysComFinalize ok
    ${output_sync_frame_clock}    csn.execute    ${cmd_sync_frame_clock}    connection=${alias}
    sleep    2s
    Should Contain    ${output_sync_frame_clock}    MitAaSysComFinalize ok
    csn.disconnect    connection=${alias}

Precondition_SSH_TMA
    [Documentation]  Connect to cobham control PC via SSH, and start TMA application.
    [Arguments]    ${TMA_PATH}    ${tma_alias}=tma
    ${TM500_PORT}=  Convert To Integer  ${TM500_PORT}
    Wait Until Keyword Succeeds    3x    30sec     csn.Connect to    hostname=${TM500_IP}    username=${TM500_USER}    
    ...                                                              password=${TM500_PW}    alias=${tma_alias}
    Run keyword and ignore error    csn.Execute  command=taskkill /F /IM TmaApplication.exe  connection=${tma_alias}
    sleep  3s
    csn.send_command   command="${TMA_PATH}" /u "Default User" /p ${TM500_PORT} /c y /a y &    connection=${tma_alias}
    sleep  60s
    ${tma_PID}  csn.Execute  command=ps -Wef |grep TmaApplication|awk '{{print $2}}'|head -n 1  connection=${tma_alias}
    Log    TMA is running with PID ${tma_PID}.
    Should not be empty    ${tma_PID.strip()}    msg=TMA app is not started
    sleep  10s
    csn.disconnect    connection=${tma_alias}
    [Return]    ${tma_PID}

Cobham UE attach
    [Arguments]    ${BW}    ${e500_script_path}=${E500_SCRIPTS_BASE}    ${type}=NSA    ${tma_path}=${TAM_APP_PATH}    ${ue_num}=1
    [Timeout]    10 min
    Precondition_SSH_TMA    TMA_PATH=${tma_path}
    Kill iperf process on E500 PC
    wait until keyword succeeds    2 min    10 s    tm500_hangzhou.Connect    tm500_alias=${TMA_APP_ALIAS}
    tm500_hangzhou.Connect HW and Initialize    hw_connect_script_path=${e500_script_path}/Init_Config.txt    tm500_alias=${TMA_APP_ALIAS}
    tm500_hangzhou.Perform cell search    cell_search_script_path=${e500_script_path}/${type}_5G_Cell_Config_${BW}.txt   
    ...    tm500_alias=${TMA_APP_ALIAS}
    5GC000679_common_keyword.Retry ue attach if failed    type=${type}    attach_script_path=${e500_script_path}/${type}_5G_${ue_num}UEattach.txt
    ...    detach_script_path=${e500_script_path}/${type}_5G_UEdetach.txt    e500_alias=${TMA_APP_ALIAS}
    Sleep    5s

Retry ue attach if failed
    [Arguments]    ${type}    ${attach_script_path}    ${detach_script_path}    ${retry_time}=${2}    ${e500_alias}=${TMA_APP_ALIAS}
    ${detach_time}    Set variable    ${0}
    FOR    ${i}    IN RANGE    ${retry_time}
        ${attach_status}    run keyword and return status    E500 attach and verify    attach_script_path=${attach_script_path}    type=${type}
    ...    e500_alias=${e500_alias}
        Exit for loop if    ${attach_status}==${True}
        tm500_hangzhou.TM500 Detach    tm500_alias=${TMA_APP_ALIAS}    detach_script_path=${detach_script_path}
        ${detach_time}    Evaluate    ${detach_time}+1
        Log to console    Attached failed, retry detach time ${detach_time}
        ...    AND
    END
    Should be true    ${detach_time} < ${retry_time}    msg=Retry UE attach with ${retry_time} times and still failed

E500 attach and verify
    [Arguments]    ${attach_script_path}    ${type}    ${e500_alias}=${TMA_APP_ALIAS}
    Log to console    Sending attach_script from ${attach_script_path}
    ${response}=    tm500_remote.send script    ${attach_script_path}    alias=${e500_alias}
    #${response}=    tm500_remote.send command    command=\r\n    alias=${e500_alias}
    Sleep    5s
    Should contain    ${response}    Random Access Complete    msg=UE attach failed, string "Random Access Complete" is not found
    run keyword if    '${type}'=='NSA'    NSA L3 call Check    response=${response}
    ${e500_ue_ip}    Get ue ip address    attach_response=${response}
    Set test variable    ${UE_IP}    ${e500_ue_ip}

NSA L3 call Check
    [Arguments]    ${response}
    Should contain    ${response}    Attach Result: EPS Only    msg=UE attach failed, string "Attach Result: EPS Only" is not found
    ${response_verify_NR_attach}    tm500_remote.send command    command=forw mte Getstats [0] [0] [1]    alias=${TMA_APP_ALIAS}
    Should contain    ${response_verify_NR_attach}    L2 Random Access Complete
    ...    msg=UE attach failed, string "L2 Random Access Complete" is not found

Get ue ip address
    [Arguments]    ${attach_response}
    @{ue_ip_list}    Get regexp matches    ${attach_response}    IPv4 Address:(.*)    1
    ${ue_ip}    strip_string    ${ue_ip_list}[0]
    Set test variable    @{UE_IPs}    @{ue_ip_list}
    [Return]    ${ue_ip}

Kill iperf process on E500 PC
    [Arguments]    ${tma_alias}=tma
    Wait Until Keyword Succeeds    3x    30sec     csn.Connect to    hostname=${TM500_IP}    username=${TM500_USER}    
    ...                                                              password=${TM500_PW}    alias=${tma_alias}
    Run keyword and ignore error    csn.Execute  command=taskkill /F /IM iperf.exe  connection=${tma_alias}
    sleep    3s
    csn.disconnect    connection=tma

Kill tma process
    [Arguments]    ${tma_alias}=tma
    Wait Until Keyword Succeeds    3x    30sec     csn.Connect to    hostname=${TM500_IP}    username=${TM500_USER}    
    ...                                                              password=${TM500_PW}    alias=${tma_alias}
    Run keyword and ignore error    csn.Execute  command=taskkill /F /IM TmaApplication.exe  connection=${tma_alias}
    sleep    3s
    csn.disconnect    connection=tma

Cobham UE detach
    [Arguments]    ${e500_script_path}=${E500_SCRIPTS_BASE}    ${type}=NSA
    [Timeout]    5 min
    ${log}=    tm500_remote.send script    ${e500_script_path}/${type}_5G_UEdetach.txt    alias=${TMA_APP_ALIAS}
    ${status}    run keyword and return status    Should contain    ${log}    DTRC
    Run Keyword If    '${status}'=='False'    tm500_remote.send command    command=#$$DISCONNECT    alias=${TMA_APP_ALIAS}
    tm500_hangzhou.Disconnect    tm500_alias=${TMA_APP_ALIAS}

Start DL traffic via iperf on Appserver to single UE
    [Arguments]    ${dl_throughput}    ${dl_time}=${99999}    ${dl_port}=${52300}    ${dl_length}=${1400}
    Start DL traffic via iperf on Appserver    ue_addr=${UE_IP}    dl_time=${dl_time}    dl_port=${dl_port}
    ...    dl_throughput=${dl_throughput}    dl_length=${dl_length}

Start DL traffic via iperf on Appserver for one UE
    [Arguments]     ${ue_addr}    ${dl_time}    ${dl_port}    ${dl_throughput}    ${dl_length}
    ...    ${appserver}=APPserver    ${protocol}=udp    ${ue_index}=${0}
    run keyword if    '${appserver}'=='APPserver'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}' |xargs kill -9    connection=APPserver
    run keyword if    '${protocol}'=='udp'    csn.send command
    ...    command=iperf -c ${ue_addr} -u -t ${dl_time} -i 1 -p ${dl_port} -P 1 -f m -b ${dl_throughput} -l ${dl_length} -T 64 &
    ...    connection=APPserver
    ...    ELSE IF    '${protocol}'=='tcp'    Start the tcp DL data via iperf    ue_index=${ue_index}
    ...    dl_time=${dl_time}    ue_addr=${ue_addr}    dl_port=${dl_port}
    sleep    3s
    [Teardown]    csn.disconnect    connection=APPserver

Start DL data on Appserver for one UE
    [Arguments]     ${ue_addr}    ${dl_time}    ${dl_port}    ${dl_throughput}    ${dl_length}
    ...    ${appserver}=APPserver    ${protocol}=udp    ${ue_index}=${0}
    run keyword if    '${protocol}'=='udp'    csn.send command
    ...    command=iperf -c ${ue_addr} -u -t ${dl_time} -i 1 -p ${dl_port} -P 1 -f m -b ${dl_throughput} -l ${dl_length} -T 64 &
    ...    connection=APPserver
    ...    ELSE IF    '${protocol}'=='tcp'    Start the tcp DL data via iperf    ue_index=${ue_index}
    ...    dl_time=${dl_time}    ue_addr=${ue_addr}    dl_port=${dl_port}
    sleep    3s

Start DL traffic via iperf on Appserver to Multi UEs
    [Arguments]    ${dl_throughput}    ${dl_time}=${99999}    ${dl_port}=${52300}    ${dl_length}=${1400}    ${appserver}=APPserver
    run keyword if    '${appserver}'=='APPserver'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}' |xargs kill -9    connection=APPserver
    FOR    ${UE_single_ip}    IN    @{UE_IPs}
        ${UE_single_ip}     strip_string    ${UE_single_ip}
        Start DL data on Appserver for one UE    ue_addr=${UE_single_ip}    dl_time=${dl_time}    dl_port=${dl_port}
    ...    dl_throughput=${dl_throughput}    dl_length=${dl_length}
    END
    [Teardown]    csn.disconnect    connection=APPserver

Start DL traffic to Multi UEs for diff Tput
    [Arguments]    ${dl_throughput}    ${ue_num}    ${dl_time}=${99999}    ${dl_port}=${52300}    ${dl_length}=${1400}    ${appserver}=APPserver
    run keyword if    '${appserver}'=='APPserver'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}' |xargs kill -9    connection=APPserver
    csn.disconnect    connection=APPserver
    FOR    ${i}    IN RANGE    ${ue_num}
        ${UE_single_ip}     strip_string    ${UE_IPs}[${i}]
        Start DL traffic via iperf on Appserver for one UE    ue_addr=${UE_single_ip}    dl_time=${dl_time}    dl_port=${dl_port}
    ...    dl_throughput=${dl_throughput}[${i}]    dl_length=${dl_length}
    END

Stop DL traffic via iperf on Appserver to Multi UEs
    [Arguments]    ${ue_ip_list}
    FOR    ${UE_single_ip}    IN    @{ue_ip_list}
        ${UE_single_ip}     strip_string    ${UE_single_ip}
        Close the iperf process on APPserver    port=${UE_single_ip}
    END

Start UL traffic via iperf on VIAVI to single UE
    [Arguments]     ${traffic_time}    ${throughput}    ${E500_upload_ip}    ${port}=5411
    Connect to cobham control pc via ssh
    ${cmd_start_iperf_client}    Catenate    ${iperf_path}/iperf -c ${E500_upload_ip} -u -b ${throughput}
    ...    -i 1 -l 1024  -t ${traffic_time} -p ${port}
    csn.send command     ${cmd_start_iperf_client}    connection=${tma_ssh_alias}
    [Teardown]    csn.disconnect    connection=tma_ssh

Start UL traffic via iperf to Multi UEs
    [Arguments]     ${ue_num}    ${ul_time}    ${ul_throughput}    ${E500_upload_ip}
    FOR    ${i}    IN RANGE    ${ue_num}
        Start UL traffic via iperf on VIAVI to single UE    traffic_time=${ul_time}    throughput=${ul_throughput}
    ...    E500_upload_ip=${E500_upload_ip}    port=${ul_port_list}[${i}]
    END

Start UL traffic to Multi UEs for diff Tput
    [Arguments]     ${ue_num}    ${ul_time}    ${ul_throughput}    ${E500_upload_ip}
    FOR    ${i}    IN RANGE    ${ue_num}
        Start UL traffic via iperf on VIAVI to single UE    traffic_time=${ul_time}    throughput=${ul_throughput}[${i}]
    ...    E500_upload_ip=${E500_upload_ip}    port=${ul_port_list}[${i}]
    END

Start DL and UL data for Muti UEs
    [Arguments]    ${ue_num}    ${ul_throughput}    ${dl_throughput}    ${ul_time}=${700}
    Start DL traffic via iperf on Appserver to Multi UEs    dl_throughput=${dl_throughput}
    Start UL traffic via iperf to Multi UEs    ue_num=${ue_num}    ul_time=${ul_time}    ul_throughput=${ul_throughput}
    ...     E500_upload_ip=${E500_upload_ip}

Close the iperf process on VIAVI
    wait until keyword succeeds    1 min    10 sec    Connect to cobham control pc via ssh
    ${output}=    csn.execute    ps -ef |grep iperf    connection=${tma_ssh_alias}
    ${len}=    Get length    ${output}
    ${iperf_pid_list}=    Run Keyword If     ${len}>0
    ...                csn.execute    ps -ef |grep iperf |awk '{print $2}'    connection=${tma_ssh_alias}
    @{iperf_pid_list}=    Split To Lines	   ${iperf_pid_list}
    FOR    ${iperf_pid}    IN    @{iperf_pid_list}
        csn.execute   kill -9 ${iperf_pid}    connection=${tma_ssh_alias}
    END
    [Teardown]    csn.disconnect    connection=tma_ssh

Check L1 throughput on VIAVI
    [Arguments]    ${e500_script_path}=${E500_SCRIPTS_BASE}    ${e500_alias}=e500
    ${response}=  tm500_remote.send script  ${e500_script_path}/L1_tput_check.txt  alias=${e500_alias}
    @{l1_tput_list}    Get regexp matches    ${response}    Average:(.*)Min:    1
    FOR    ${l1_tput}    IN    @{l1_tput_list}
        ${tput}=    Strip String    ${l1_tput}    mode=left    characters=${SPACE}0
        ${value}    Evaluate    float(${tput})/1048576
        Log to console    ${value}
    END

Check MAC throughput on VIAVI
    [Arguments]    ${e500_script_path}=${E500_SCRIPTS_BASE}    ${e500_alias}=e500
    sleep    10s
    ${response}=  tm500_remote.send script  ${e500_script_path}/MAC_tput_check.txt  alias=${e500_alias}
    @{mac_tput_list}    Get regexp matches    ${response}    Average:(.*)Min:    1
    FOR    ${mac_tput}    IN    @{mac_tput_list}
        ${tput}=    Strip String    ${mac_tput}    mode=left    characters=${SPACE}0
        ${value}    Evaluate    float(${tput})/1048576
        Log to console    ${value}
    END

Check throughput on gNB
    [Arguments]    ${direction}    ${throughput}    ${ue_index}=${0}    ${gnb_index}=${0}    ${du_index}=${0}    ${hw_slot}=${1}
    ...    ${sample}=${10}    ${start_offset}=${3}    ${sleep_time}=${8}    ${cellid}=${EMPTY}    ${log_type}=Aasyslog    &{kwargs}
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2Lo   log_name=data_${direction}.txt
    ${DL_tput_cell}    run keyword if    '${direction}' == 'dl'    Caculate DL throughput on gnb L2Lo with re   dl_expect=${throughput}
    ...                                                                                       gnb_index=${gnb_index}
    ...                                                                                       du_index=${du_index}
    ...                                                                                       hw_slot=${hw_slot}
    ...                                                                                       sample=${sample}
    ...                                                                                       start_offset=${start_offset}
    ...                                                                                       sleep_time=${sleep_time}
    ...                                                                                       cellid=${cellid}
    ...                                                                                       log_type=${log_type}
    ...    ELSE IF    '${direction}' == 'ul'    Caculate UL throughput on gnb L2Lo with re    ul_expect=${throughput}
    ...                                                                                       gnb_index=${gnb_index}
    ...                                                                                       du_index=${du_index}
    ...                                                                                       hw_slot=${hw_slot}
    ...                                                                                       sample=${sample}
    ...                                                                                       start_offset=${start_offset}
    ...                                                                                       sleep_time=${sleep_time}
    ...                                                                                       cellid=${cellid}
    ...                                                                                       log_type=${log_type}
    [Return]    ${DL_tput_cell}
    [Teardown]    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}

Get MAC DL UL throughput on VIAVI
    [Arguments]    ${e500_script_path}=${E500_SCRIPTS_BASE}    ${e500_alias}=e500
    ${mac_dl_tput_Value}    Create List
    ${mac_ul_tput_Value}    Create List
    ${response}=  tm500_remote.send script  ${e500_script_path}/MAC_tput_check.txt  alias=${e500_alias}
    ${dl_average}    Run    echo '${response}' |grep -A 1 "DL LogCh"
    ${ul_average}    Run    echo '${response}' |grep -A 1 "UL LogCh"
    @{mac_dl_tput_list}    Get regexp matches    ${dl_average}    Average:(.*)Min:    1
    @{mac_ul_tput_list}    Get regexp matches    ${ul_average}    Average:(.*)Min:    1
    FOR    ${mac_dl_tput}    IN    @{mac_dl_tput_list}
        ${tput}=    Strip String    ${mac_dl_tput}    mode=left    characters=${SPACE}0
        ${value}    Evaluate    float(${tput})/1048576
        Append To List    ${mac_dl_tput_Value}    ${value}
        Log to console    ${value}
    END
    FOR    ${mac_ul_tput}    IN    @{mac_ul_tput_list}
        ${tput}=    Strip String    ${mac_ul_tput}    mode=left    characters=${SPACE}0
        ${value}    Evaluate    float(${tput})/1048576
        Append To List    ${mac_ul_tput_Value}    ${value}
        Log to console    ${value}
    END
    [Return]    ${mac_dl_tput_Value}    ${mac_ul_tput_Value}

###PowerCycle Viavi###
Connect to E500 ASC via ssh
    [Arguments]  ${tma_asc_alias}=${TMA_ASC_ALIAS}
    csn.Connect to    hostname=${E500_IP}    username=${E500_ASC_USER}    password=${E500_ASC_PW}    port=${E500_ASC_PORT}
    ...            alias=${tma_asc_alias}

Disconnect from E500 ASC via ssh
    [Arguments]    ${tma_asc_alias}=${TMA_ASC_ALIAS}
    csn.disconnect    connection=${tma_asc_alias}

Reset E500 via ASC
    [Documentation]
    ...    The purpose of this keyword to powercycle VIAVI when the E500 crashed
    ...    need to run CMD on the E500 control PC:
    ...    netsh interface portproxy add v4tov4 listenaddress=10.57.130.173 listenport=10101 connectaddress=192.168.10.9 connectport=22
    [Arguments]    ${username}=tm500    ${group}=Units-1    ${tma_asc_alias}=${TMA_ASC_ALIAS}
    Connect to E500 ASC via ssh
    asc.set username    name=${username}    connection=${tma_asc_alias}
    asc.set power off    group_name=${group}    connection=${tma_asc_alias}
    sleep    10s
    asc.set power on    group_name=${group}    connection=${tma_asc_alias}
    sleep    120s
    wait until keyword succeeds    4min    20sec    Ping E500 asc ip
    sleep    10s
    Disconnect from E500 ASC via ssh

Ping E500 asc ip
    [Arguments]    ${cobham_asc_ip}=192.168.10.9        ${tma_ssh_alias}=${TMA_SSH_ALIAS}
    Connect to cobham control pc via ssh    tma_ssh_alias=${tma_ssh_alias}
    ${response}    csn.execute    command=ping ${cobham_asc_ip}    connection=${tma_ssh_alias}
    Should Contain    ${response}    Reply from ${cobham_asc_ip}: bytes=32
    Disconnect from E500 control pc via ssh

Disconnect from E500 control pc via ssh
    [Arguments]    ${tma_ssh_alias}=${TMA_SSH_ALIAS}
    csn.disconnect    connection=${tma_ssh_alias}

###check point###
Check FDM schedlue two UEs in one slot on DL traffic
    [Arguments]    ${filename}=${bip_log_path}    ${crnti_expression}=${pdsch_rnti}    
    Read BIP Wireshark Log    cap_file=${filename}    filter=dldata_pdschsendreq
    ${PdschSendReq_sfn_list}=   cap.Get element value    element_expression=${pdsch_sfn}
    ${PdschSendReq_sfn_list}    Remove_repetition_list    ${PdschSendReq_sfn_list}
    ${length}=    get length     ${PdschSendReq_sfn_list}
    should be true    ${length}>0
    FOR    ${sfn}    IN    @{PdschSendReq_sfn_list}
        Read BIP Wireshark Log    cap_file=${filename}    filter=dldata_pdschsendreq
        ${pdsch_slotlist}=   cap.Get Element Value    element_expression=${pdsch_slot}    condition_expression=${pdsch_sfn}==0x${sfn[2:]}${sfn[:2]}
        ${result}=    Get rnti based on sfn and slot    filename=${filename}    sfnn=${sfn[2:]}${sfn[:2]}
        ...    PdschSendReq_slot_list=@{pdsch_slotlist}    rnti_expression=${crnti_expression}
        Exit for loop if    ${result}>=2
    END

Get rnti based on sfn and slot
    [Arguments]    ${filename}    ${sfnn}    ${PdschSendReq_slot_list}    ${rnti_expression}
    FOR    ${slot}    IN    @{PdschSendReq_slot_list}
        Read BIP Wireshark Log    cap_file=${filename}    filter=dldata_pdschsendreq
        ${PdschSendReq_rnti_list}=   cap.Get Element Value    element_expression=${rnti_expression}
        ...    condition_expression=${pdsch_slot}==0x${slot} and ${pdsch_sfn}==0x${sfnn}
        ${num_UE}=      get length     ${PdschSendReq_rnti_list}
        Exit for loop if    ${num_UE}>=2
    END
    [Return]    ${num_UE}

Check FDM schedlue two UEs in one slot on UL traffic
    [Arguments]    ${filename}=${bip_log_path}    ${item}=${rnti_2}
    ${packets}    Load BIP Log with Template Command    pcap_file=${filename}    command_template=${command_template}
    ${value}    Get value from Bip Log by xpath    packets=${packets}    field_name=${item}
    ${length}=    get length    ${value}
    Should be true    ${length}>=1

Get ul rnti based on sfn and slot
    [Arguments]    ${filename}    ${sfnn}    ${PuschReceiveReq_slot_list}
    FOR    ${slot}    IN    @{PuschReceiveReq_slot_list}
        Read BIP Wireshark Log    cap_file=${filename}    filter=uldata_puschreceivereq
        ${PuschReceiveReq_rnti_list}=   cap.Get Element Value    element_idx=${1}    element_expression=${pusch_rnti}
        ...    condition_expression=${pusch_slot}==0x${slot} and ${pusch_sfn}==0x${sfnn}
        ${num_UE}=      get length     ${PuschReceiveReq_rnti_list}
        Exit for loop if    ${num_UE}==1
    END
    [Return]    ${num_UE}

Check ALL PRBs were schedlued in one slot on UL traffic
    [Arguments]    ${filename}=${bip_log_path}    ${allofPrb}=${217}
    ${packets}    Load BIP Log with Template Command    pcap_file=${filename}    command_template=${command_template}
    ${value1}    Get value from Bip Log by xpath    packets=${packets}    field_name=${numofPRB_1}
    ${value2}    Get value from Bip Log by xpath    packets=${packets}    field_name=${numofPRB_2}
    ${value3}    Get value from Bip Log by xpath    packets=${packets}    field_name=${numofPRB_3}
    ${value4}    Get value from Bip Log by xpath    packets=${packets}    field_name=${numofPRB_4}
    Run keyword if     '${value1}[0]' == '0x000000d9'
    ...     Run keyword and continue on failure    Get all PRBs of schedlued    a=${value1}[0]
    ...     ELSE    Get all PRBs of schedlued   a=${value1}[0]    b=${value2}[0]    c=${value3}[0]    d=${value4}[0]
    Should be True    ${sumofPrb} == ${allofPrb}

Get all PRBs of schedlued
    [Arguments]    ${a}    ${b}=${0}    ${c}=${0}    ${d}=${0}
    ${sumofPrb}    Evaluate    ${a}+${b}+${c}+${d}
    set test variable     ${sumofPrb}

Check ALL PRBs were schedlued in one slot on DL traffic
    [Arguments]    ${filename}=${bip_log_path}    ${prb_expression}=${pdsch_numofPrb}    ${allofPrb}=${217}
    Read BIP Wireshark Log    cap_file=${filename}    filter=dldata_pdschsendreq
    ${PdschSendReq_sfn_list}=   cap.Get element value    element_expression=${pdsch_sfn}
    ${PdschSendReq_sfn_list}    Remove_repetition_list    ${PdschSendReq_sfn_list}
    ${length}=    get length     ${PdschSendReq_sfn_list}
    should be true    ${length}>0
    FOR    ${sfn}    IN    @{PdschSendReq_sfn_list}
        Read BIP Wireshark Log    cap_file=${filename}    filter=dldata_pdschsendreq
        ${pdsch_slotlist}=   cap.Get Element Value    element_expression=${pdsch_slot}    condition_expression=${pdsch_sfn}==0x${sfn[2:]}${sfn[:2]}
        ${result}=    Get Prbs based on sfn and slot on DL    filename=${filename}    sfnn=${sfn[2:]}${sfn[:2]}
        ...    PdschSendReq_slot_list=@{pdsch_slotlist}    prb_expression=${prb_expression}
        Get schedlued prb for one UE    prb_list=${result}
        Get all PRBs of schedlued   a=0x${prb_1[2:]}${prb_1[:2]}    b=0x${prb_2[2:]}${prb_2[:2]}
        ...    c=0x${prb_3[2:]}${prb_3[:2]}    d=0x${prb_4[2:]}${prb_4[:2]}
        Exit for loop if    ${sumofPrb} == ${allofPrb}
    END

Get Prbs based on sfn and slot on DL
    [Arguments]    ${filename}    ${sfnn}    ${PdschSendReq_slot_list}    ${prb_expression}
    FOR    ${slot}    IN    @{PdschSendReq_slot_list}
        Read BIP Wireshark Log    cap_file=${filename}    filter=dldata_pdschsendreq
        ${PdschSendReq_prb_list}=   cap.Get Element Value    element_expression=${prb_expression}
        ...    condition_expression=${pdsch_slot}==0x${slot} and ${pdsch_sfn}==0x${sfnn}
        ${num_UE}=      get length     ${PdschSendReq_prb_list}
        Exit for loop if    ${num_UE}>=2
    END
    [Return]    ${PdschSendReq_prb_list}

Get schedlued prb for one UE
    [Arguments]    ${prb_list}
    set test variable     ${prb_1}    ${prb_list}[0]
    set test variable     ${prb_2}    ${prb_list}[1]
    set test variable     ${prb_3}    ${prb_list}[2]
    set test variable     ${prb_4}    ${prb_list}[3]

Capturing TTI logs and verify throughput and get MCS
    [Arguments]    ${direction}    ${Expected_Dl_Tput}=80    ${Expected_Ul_Tput}=10
    Start TTI trace log capturing
    Sleep    5s
    Stop TTI trace log capturing
    &{dict_csv_file_path}    Convert TTI trace log and download combined csv logs to test pc
    Check throughput on gNB    direction=dl    throughput=${Expected_Dl_Tput}
    Check throughput on gNB    direction=ul    throughput=${Expected_Ul_Tput}
    Run keyword if    '${direction}'=='dl'
    ...    Run keyword and continue on failure    Get DL MCS based on event trace log    dict_event_trace_log=${dict_csv_file_path}
    ...    ELSE    Run keyword and continue on failure    Get UL MCS based on event trace log    dict_event_trace_log=${dict_csv_file_path}

Get DL MCS based on event trace log
    [Arguments]    ${dict_event_trace_log}    ${direction}=dl    ${program}=None
    @{get_usedMcs}    event_trace_analysis.get_average_used_mcs_for_ues    file_path=${dict_event_trace_log['DL']}    direction=${direction}
    ...    program=${program}
    Set test variable    @{rrmUsedMcs}    @{get_usedMcs}
    @{get_proposedMcs}    event_trace_analysis.get_average_proposed_mcs_for_ues    file_path=${dict_event_trace_log['DL']}    direction=${direction}
    ...    program=${program}
    Set test variable    @{rrmProposedMcs}    @{get_proposedMcs}

Get UL MCS based on event trace log
    [Arguments]    ${dict_event_trace_log}    ${direction}=ul    ${program}=None
    @{get_usedMcs}    event_trace_analysis.get_average_used_mcs_for_ues    file_path=${dict_event_trace_log['UL']}    direction=${direction}
    ...    program=${program}
    Set test variable    @{rrmUsedMcs}    @{get_usedMcs}
    @{get_proposedMcs}    event_trace_analysis.get_average_proposed_mcs_for_ues    file_path=${dict_event_trace_log['UL']}    direction=${direction}
    ...    program=${program}
    Set test variable    @{rrmProposedMcs}    @{get_proposedMcs}

Verify used MCS is ok than Proposed MCS
    [Arguments]    ${numofues}
    FOR    ${i}    IN RANGE    ${numofues}
        Should be True    ${rrmUsedMcs}[${i}] <= ${rrmProposedMcs}[${i}]
    END

Load BIP Log with Template Command
    [Arguments]    ${pcap_file}    ${command_template}    ${tshark_path}=${TSHARK_PATH}    ${luashark_path}=${tmp_lua_dir}
    ${packets}=   pcap.load_pcap_file   pcap_file=${pcap_file}
    ...                                 tshark_path=${tshark_path}
    ...                                 luashark_path=${luashark_path}
    ...                                 command_template=${command_template}
    [Return]    ${packets}
	
Get value from Bip Log by xpath
    [Arguments]    ${packets}    ${field_name}
    ${value}    pcap.get_field_value_by_xpath    pdml_list=${packets}    xpath=${field_name}
    [Return]    ${value}

Get BTS Counters from webUI
    [Arguments]    ${counter_id}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${counters}    selenium_coam.get_bts_counters_info    counter_id=${counter_id}
    COAM selenium logout
    ${counters}    Get Dictionary Values    ${counters}
    [Return]    ${counters}
