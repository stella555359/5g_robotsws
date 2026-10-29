*** Settings ***
Documentation     author: piao
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: yongji.piao@nokia-sbell.com

Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    taf.selenium.gnb.oam.coam.cu    WITH NAME   coam_cu
Library    OperatingSystem
Library    taf.transport.ssh    WITH NAME    csn

Library    taf.ul.selenium.netact    WITH NAME    selenetact
Library    taf.rfrl.common_resources.python.ssh_common_commands    WITH NAME    ssh_common_commands
Resource    ./5GC001937_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot

*** Variables ***
${UE_TYPE}    samsung
${dltp}    100
${ultp}    20
${pcapfileCU}    5GC001581_PCMD.pcap
${pcapfileDU}    5GC001912_PCMD.pcap
${luashark_path}    /opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
${TSHARK_traceId}    ${TSHARK_5GC001581_COMMON} -T fields -e nsetapx.traceId
${TSHARK_traceId_pdml}    ${TSHARK_5GC001581_pdml} -T fields -e nsetapx.traceId
${TSHARK_plmn_Identity}    ${TSHARK_5GC001581_COMMON} -T fields -e nsetapx.plmn_Identity
${TSHARK_plmn_Identity_pdml}    ${TSHARK_5GC001581_pdml} -T fields -e nsetapx.plmn_Identity
${TSHARK_cellIdentity}    ${TSHARK_5GC001581_COMMON} -T fields -e nsetapx.cellIdentity
${TSHARK_cellIdentity_pdml}    ${TSHARK_5GC001581_pdml} -T fields -e nsetapx.cellIdentity
${TSHARK_setupSCells}    ${TSHARK_5GC001581_COMMON} -T fields -e nsetapx.setupSCells
${TSHARK_setupSCells_pdml}    ${TSHARK_5GC001581_pdml} -T fields -e nsetapx.setupSCells
${TSHARK_5GC001581_COMMON}    /usr/bin/tshark -r {pcap_file} -X lua_script:{luashark_path} -Y  \"nsetapx.TraceMessage\"
${TSHARK_5GC001581_pdml}    /usr/bin/tshark -r ${output_dir}/${pcapfileCU} -X lua_script:${luashark_path} -Y  \"nsetapx.TraceMessage\"
${CU_OAM_IP}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${mrbts_id}    MRBTS-${tl.gnbs[0].instance_id}
${nrbts_id}    NRBTS-${tl.gnbs[0].global_bts_id}
${mrbts_instance_id}    ${tl.gnbs[0].instance_id}
${TSHARK_timeOfUePduRx}    ${TSHARK_5GC001912_COMMON} -T fields -e nsetapx.timeOfUePduRx
${TSHARK_timeOfUePduRx_pdml}    ${TSHARK_5GC001912_pdml} -T fields -e nsetapx.timeOfUePduRx
${TSHARK_timeOfUeSched}    ${TSHARK_5GC001912_COMMON} -T fields -e nsetapx.timeOfUeSched
${TSHARK_timeOfUeSched_pdml}    ${TSHARK_5GC001912_pdml} -T fields -e nsetapx.timeOfUeSched
${TSHARK_timeOfUePduTx}    ${TSHARK_5GC001912_COMMON} -T fields -e nsetapx.timeOfUePduTx
${TSHARK_timeOfUePduTx_pdml}    ${TSHARK_5GC001912_pdml} -T fields -e nsetapx.timeOfUePduTx
${TSHARK_numOfBad1stMacPduTx}    ${TSHARK_5GC001912_COMMON} -T fields -e nsetapx.numOfBad1stMacPduTx
${TSHARK_numOfBad1stMacPduTx_pdml}    ${TSHARK_5GC001912_pdml} -T fields -e nsetapx.numOfBad1stMacPduTx
${TSHARK_numOfBadLastMacPduTx}    ${TSHARK_5GC001912_COMMON} -T fields -e nsetapx.numOfBadLastMacPduTx
${TSHARK_numOfBadLastMacPduTx_pdml}    ${TSHARK_5GC001912_pdml} -T fields -e nsetapx.numOfBadLastMacPduTx
${TSHARK_numOf1stMacPduTx}    ${TSHARK_5GC001912_COMMON} -T fields -e nsetapx.numOf1stMacPduTx
${TSHARK_numOf1stMacPduTx_pdml}    ${TSHARK_5GC001912_pdml} -T fields -e nsetapx.numOf1stMacPduTx
${TSHARK_sumOfRlcPduRxBytes}    ${TSHARK_5GC001912_COMMON} -T fields -e nsetapx.sumOfRlcPduRxBytes
${TSHARK_sumOfRlcPduRxBytes_pdml}    ${TSHARK_5GC001912_pdml} -T fields -e nsetapx.sumOfRlcPduRxBytes
${TSHARK_sumOfRlcPduTxBytes}    ${TSHARK_5GC001912_COMMON} -T fields -e nsetapx.sumOfRlcPduTxBytes
${TSHARK_sumOfRlcPduTxBytes_pdml}    ${TSHARK_5GC001912_pdml} -T fields -e nsetapx.sumOfRlcPduTxBytes
${TSHARK_sumOfWbCqi}    ${TSHARK_5GC001912_COMMON} -T fields -e nsetapx.sumOfWbCqi
${TSHARK_sumOfWbCqi_pdml}    ${TSHARK_5GC001912_pdml} -T fields -e nsetapx.sumOfWbCqi
${TSHARK_numOfWbCqiSamples}    ${TSHARK_5GC001912_COMMON} -T fields -e nsetapx.numOfWbCqiSamples
${TSHARK_numOfWbCqiSamples_pdml}    ${TSHARK_5GC001912_pdml} -T fields -e nsetapx.numOfWbCqiSamples
${TSHARK_sumOfSinrSamples}    ${TSHARK_5GC001912_COMMON} -T fields -e nsetapx.sumOfSinrSamples
${TSHARK_sumOfSinrSamples_pdml}    ${TSHARK_5GC001912_pdml} -T fields -e nsetapx.sumOfSinrSamples
${TSHARK_numOfSinrSamples}    ${TSHARK_5GC001912_COMMON} -T fields -e nsetapx.numOfSinrSamples
${TSHARK_numOfSinrSamples_pdml}    ${TSHARK_5GC001912_pdml} -T fields -e nsetapx.numOfSinrSamples
${TSHARK_taData}    ${TSHARK_5GC001912_COMMON} -T fields -e nsetapx.taData
${TSHARK_taData_pdml}    ${TSHARK_5GC001912_pdml} -T fields -e nsetapx.taData
${TSHARK_5GC001912_COMMON}    /usr/bin/tshark -r {pcap_file} -X lua_script:{luashark_path} -Y  \"nsetapx.TraceMessage\"
${TSHARK_5GC001912_pdml}    /usr/bin/tshark -r ${output_dir}/${pcapfileDU} -X lua_script:${luashark_path} -Y  \"nsetapx.TraceMessage\"
*** Keywords ***

Precondition
    [Documentation]    Check status on CU and DU
    Check LTE Status
    wait until keyword succeeds    15Min    150s    COAM Check GNB_DU cell is on air
    COAM Check GNB_CU cell on air
Check LTE Status
    ${status}    run keyword and return status     Connect to LTE
    Run Keyword If    ${status}==False    Perform Enb Site Power Off

    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=LTE
Connect to LTE
    [Arguments]
    ...    ${host}=${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
    csn.Connect To     hostname=${host}    username=${username}    password=${password}   alias=LTE

Perform Enb Site Power Off
    [Arguments]    ${enb_index}=${0}    ${du_index}=${0}
    ...    ${model}=${tl.enbs[${enb_index}].airscale.common_units[0].pdu_port.pdu.__class__.__name__}
    ${enb_index}    Convert to integer    ${enb_index}
    ${enb_pdu_ip}=  set variable  ${tl.enbs[${enb_index}].airscale.common_units[0].pdu_port.pdu.addr}
    ${enb_pdu_port}=  set variable  ${tl.enbs[${enb_index}].airscale.common_units[0].pdu_port.port_no}
    #log to console    ${model} \n ${enb_pdu_ip} \n ${enb_pdu_port}
    pdu.setup_pdu    model=${model}   host=${enb_pdu_ip}    alias=enb_pdu_${enb_index}
    pdu.power_off    port=${enb_pdu_port}    pdu_device=enb_pdu_${enb_index}
    pdu.power_on    port=${enb_pdu_port}    pdu_device=enb_pdu_${enb_index}

COAM Check GNB_DU cell is on air
    [Documentation]  Author: Shenrao
    ...              Description: Check if GNB is in cell on air status
    [Arguments]    ${connection}=COAM
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=${connection}
    COAM Check All Cells Onair

Get version based on stream version
    Connect to Common Unit Master
    ${cmd_get_sw_file_name}    Set variable    ls /ffs/run |grep TargetBD.*.xml |grep -v .xml.
    ${sw_file_name}    ssh.execute    command=${cmd_get_sw_file_name}    connection=ASIK Master
    @{sw_version_list}    Get regexp matches    ${sw_file_name}    TargetBD_(.*?)_    1
    ${sw_version}    Strip string    ${sw_version_list[0]}
    #${program_version}    Replace string using regexp    string=${sw_version}    pattern=SBTS|5G    replace_with=${EMPTY}
    ssh.disconnect  connection=ASIK Master
    [Return]    ${sw_version}

COAM Check GNB_CU cell on air
    log to console  \n***** COAM Check GNB_CU Cell on air*****
    Connect to CU admin
    ${result_cell_status}=     cu.get_cells_statuses
    ${operability_state}=     set variable    ${result_cell_status[0]['operational_state']}
    should be equal       ${operability_state}     enabled
    [Teardown]  cu.disconnect

Connect to CU admin
    cu.connect to     host=${CU_OAM_IP}
    ...               username=Nemuadmin
    ...               password=nemuuser
    ...               port=${EMPTY}
    ...               cu_version=cuoam_19b
    ...               secure=${True}

Set actPCMDReport_DU to True
    [Arguments]
    COAM Update Parameter    dist_name=${mrbts_id}/${nrbts_id}    parameter=actPCMDReport     value=True
    sleep    5s

Set actPCMDReport_DU to False
    [Arguments]
    COAM Update Parameter    dist_name=${mrbts_id}/${nrbts_id}    parameter=actPCMDReport     value=True
    sleep    5s

Set actPCMDReport_CU to true
    [Arguments]    ${value}=true
    coam_cu.set_parameter_value   object_name=${mrbts_id}/${nrbts_id}    filter_param=Activate PCMD report
    ...    new_value=${value}    abbr=actPCMDReport
    sleep    5s
    log to console    validate plan
    coam_cu.validate_plan
    sleep   5s
    log to console    activate plan
    coam_cu.activate_plan     activate_plan_despite_reset=true    activate_plan_despite_cell_locking=true    timeout=600
    sleep   600s
Set actPCMDReport_CU to false
    [Arguments]    ${value}=true
    coam_cu.set_parameter_value   object_name=${mrbts_id}/${nrbts_id}    filter_param=Activate PCMD report
    ...    new_value=${value}    abbr=actPCMDReport
    sleep    5s
    log to console    validate plan
    coam_cu.validate_plan
    sleep   5s
    log to console    activate plan
    coam_cu.activate_plan     activate_plan_despite_reset=true    activate_plan_despite_cell_locking=true    timeout=600
    sleep   600s
L3 call setup and check
    [Arguments]    ${UE_TYPE}=samsung    ${ue_index}=0    ${ultp}=${18}    ${cell_id}=${14925825}    ${ul_throughput}=${0}    ${direction}=ul
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_index=0    ue_type=samsung
    Log To Console    \n ### Start Capture 5GC001581 wireshark ###
    Start Capture wireshark log for 5GC001581
    Log To Console    \n ### Start Capture 5GC001912 wireshark ###
    Start Capture wireshark log for 5GC001912
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=0    ue_type=samsung    log_type=Aasyslog
    power_ue.Verify attach    ue_index=0    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False
    Log To Console    \n ### UE Start traffic and check TP DL###
    power_ue.Start traffic    ue_index=0    ue_type=samsung    direction=dl    throughput=4000M    duration=120s
    Log To Console    \n ### UE Start traffic and check TP UL###
    #power_ue.Start traffic    ue_index=0    ue_type=samsung    direction=ul    throughput=300M    duration=120s
    power_ue.Start traffic   ue_type=samsung   direction=ul   throughput=300M    duration=120s
    ...    iperf_type=via_command    ue_index=0    protocol=udp
    #Log To Console    \n ### check throughput ###
    #run keyword if    'ul'=='ul'    check throughput for ul    ultp=${ul_tp}
    #run keyword if    'dl'=='dl'    check throughput for dl    dltp=${dl_tp}
    Log To Console    \n ### Stop traffic ###
    power_ue.Stop traffic    direction=ul    ue_index=0    ue_type=samsung
    power_ue.Stop traffic    direction=dl    ue_index=0    ue_type=samsung
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=0    ue_type=samsung
    Log To Console    \n ### Stop Capture 5GC001581 wireshark and download ###
    sleep    1m
    Stop Capture wireshark log for 5GC001581
    Download 5GC001581_PCMD wireshark Log To TestPC
    Log To Console    \n ### Stop Capture 5GC001912 wireshark and download ###
    Stop Capture wireshark log for 5GC001912
    Download 5GC001912_PCMD wireshark Log To TestPC
    [Teardown]   Run Keyword And Ignore Error    Stop Capture wireshark log for 5GC001581
    ...    AND    Run Keyword And Ignore Error    Stop Capture wireshark log for 5GC001912
check throughput for ul
    [Arguments]    ${ultp}=${100}    ${cell_id}=${14925825}    ${ul_throughput}=${0}
    Teardown the Aasyslog save progress    gnb_index=${0}    du_index=${0}
    Aasyslog precondition    gnb_index=${0}    du_index=${0}
    Start the Aasyslog save progress    gnb_index=${0}    du_index=${0}    filter=L2Lo   log_name=data_ul.txt

    FOR    ${index}    IN RANGE    0    2
        ${ul_throughput_tmp}    Caculate UL throughput on gnb L2Lo with re    log_type=Aasyslog    cellid=${${cell_id}+${index}}
        ${ul_throughput}=    Evaluate    ${ul_throughput}+${ul_throughput_tmp}
    END

    Log to console    ul_throughput = ${ul_throughput}
    Run keyword and continue on failure    should be true    ${ul_throughput} > ${ultp}

check throughput for dl
    [Arguments]    ${dltp}=${2000}    ${cell_id}=${14925825}    ${dl_throughput}=${0}
    Teardown the Aasyslog save progress    gnb_index=${0}    du_index=${0}
    Aasyslog precondition    gnb_index=${0}    du_index=${0}
    Start the Aasyslog save progress    gnb_index=${0}    du_index=${0}    filter=L2Lo   log_name=data_dl.txt

    FOR    ${index}    IN RANGE    0    8
        ${dl_throughput_tmp}    Caculate DL throughput on gnb L2Lo with re    log_type=Aasyslog    cellid=${${cell_id}+${index}}
        ${dl_throughput}=    Evaluate    ${dl_throughput}+${dl_throughput_tmp}
    END

    Log to console    dl_throughput = ${dl_throughput}
    Run keyword and continue on failure    should be true    ${dl_throughput} > ${dltp}
Start Capture wireshark log for 5GC001581
    [Documentation]    Start Capture wireshark log for 5GC001581
    ...                Author: xinzhu
    ...                Contact: xinran.zhu@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA.
    ...                :param file_name: file name

    [Arguments]    ${gnb_index}=0    ${du_index}=0
    ...    ${host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${file_name1}=5GC001581_PCMD.pcap
    csn.Connect To     hostname=${host}    username=robot    password=rastre1   alias=ASIK_Master
    csn.Execute    command=sudo rm -rf /tmp/${file_name1}    connection=ASIK_Master
    ${output}    csn.Execute    command=sudo ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'    connection=ASIK_Master
    ${output}    csn.Execute    command=sudo kill -9 ${output.split('\r\n')[0]}    connection=ASIK_Master
    ${cmd}=    catenate    sudo tcpdump -i oam -w /tmp/${file_name1} &>/dev/null &
    csn.send command    command=${cmd}    connection=ASIK_Master
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'    connection=ASIK_Master
    Should not be empty    ${output}
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=ASIK_Master

Stop Capture wireshark log for 5GC001581
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${connection}=ASIK_Master
    ...    ${host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    csn.Connect To     hostname=${host}    username=robot    password=rastre1    alias=ASIK_Master
    sleep    1s
    ${output}    csn.Execute    command=sudo ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'    connection=ASIK_Master
    ${output}    csn.Execute    command=sudo kill -9 ${output.split('\r\n')[0]}    connection=ASIK_Master
    ${output}    csn.Execute    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'
    ...    connection=ASIK_Master
    Should be empty    ${output}
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=ASIK_Master

Download 5GC001581_PCMD wireshark Log To TestPC
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${connection}=ASIK_Master    ${log_path}=${output_dir}
    ...    ${host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${file_name1}=5GC001581_PCMD.pcap
    csn.Connect To     hostname=${host}    username=robot    password=rastre1    alias=ASIK_Master
    csn.Download file    remote_path=/tmp/${file_name1}    local_path=${log_path}/${file_name1}   connection=ASIK_Master
    csn.execute    command=sudo rm -rf /tmp/${file_name1}     connection=ASIK_Master
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=ASIK_Master
PCMD value check from pdml
    [Arguments]    ${output_value}    ${traffic_direction}=dl
    FOR    ${item}    IN    @{output_value}
        ${dl_data}    Evaluate    ${item.split(",")[0]}
        ${ul_data}    Evaluate    ${item.split(",")[0]}
        run keyword if    "${traffic_direction}"=="dl" and "${dl_data}"!="${EMPTY}"    Exit For Loop
        run keyword if    "${traffic_direction}"=="dl" and "${dl_data}"!="${EMPTY}"    Exit For Loop
    END
Start Capture wireshark log for 5GC001912
    [Documentation]    Start Capture wireshark log for 5GC001912.
    ...                Author: shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA.
    ...                :param file_name: file name

    [Arguments]    ${gnb_index}=0    ${du_index}=0
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    #...    ${host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${file_name2}=5GC001912_PCMD.pcap
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=ASIK_Master
    csn.Execute    command=rm -rf /tmp/${file_name2}    connection=ASIK_Master
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep |awk '{print $2}' |xargs kill -9    connection=ASIK_Master
    #Should be empty    ${output}
    ${cmd}=    catenate    tcpdump -i fp0 -w /tmp/${file_name2} &>/dev/null &
    csn.send command    command=${cmd}    connection=ASIK_Master
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'    connection=ASIK_Master
    Should not be empty    ${output}
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=ASIK_Master

Stop Capture wireshark log for 5GC001912
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${connection}=ASIK_Master
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    #...    ${host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=ASIK_Master
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep |awk '{print $2}'    connection=ASIK_Master
    #Should not be empty    ${output}
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'|xargs kill -9    connection=ASIK_Master
    Should be empty    ${output}
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=ASIK_Master
Download 5GC001912_PCMD wireshark Log To TestPC
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${connection}=ASIK_Master    ${log_path}=${output_dir}
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    #...    ${host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${file_name2}=5GC001912_PCMD.pcap
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=ASIK_Master
    csn.Download file    remote_path=/tmp/${file_name2}    local_path=${log_path}/${file_name2}   connection=ASIK_Master
    csn.execute    command=rm -rf /tmp/${file_name2}     connection=ASIK_Master
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=ASIK_Master
_Generating Delta Plan Operation Should Be Successful
    [Arguments]   ${action_id}
    [Documentation]   _Generating Delta Plan Operation Should Be Successful
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | action_id | yes | Generating delta plan's action id|
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _Generating Delta Plan Operation Should Be Successful | action_id=xxx |
	${res}   cu.get_action_state_of_generating_delta_plan   ${action_id}
	should be equal as strings  ${res['status']}  success
_Get CU Specifical MO UUID
    [Arguments]   ${plan_id}  ${mo_dn}
    [Documentation]   _Get CU Specifical MO UUID
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id|
    ...    | mo_dn | yes | needed modify parameters's modn |
    ...    *RETURN VALUE*  ${mouuid}
    ...    Example
    ...    |  ${mouuid} | _Get CU Specifical MO UUID | plan_id=${delta_plan_id} | mo_dn=MRBTS-1/NRBTS-1|

    @{name_list}=   split_string    ${mo_dn}   /
    set test variable  ${parent_mouuid}    ${EMPTY}
    FOR  ${name}  IN  @{name_list}
        ${mouuid}  _Get CU Specifical MO UUID via DN Name   ${plan_id}  ${name}
    END
    [Return]   ${mouuid}
_Get CU Specifical MO UUID via DN Name
    [Arguments]   ${plan_id}  ${name}
    [Documentation]  _Get CU Specifical MO UUID via DN Name
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | modify parameters list |
    ...    | name | yes | needed modify parameters modn's name  |
    ...    *RETURN VALUE*   ${parent_mouuid}
    ...    Example
    ...    |  ${parent_mouuid} | _Get CU Specifical MO UUID via DN Name | plan_id=${delta_plan_id} | name=${name}|

    &{delta_plan_tree}   cu.get_delta_plan_tree_diff   plan_id=${plan_id}
    @{plan_tree}=  set variable  ${delta_plan_tree["created"]}
    FOR  ${mo_info}  IN  @{plan_tree}
      run keyword if  '${mo_info["parent_mo_uuid"]}'=='${parent_mouuid}' and '${mo_info["name"]}'=='${name}'  run keywords
    ...  set test variable  ${parent_mouuid}  ${mo_info["mo_uuid"]}  AND  exit for loop
    END
    [Return]   ${parent_mouuid}

_Update Parameters Operation Should Be Successful
    [Arguments]   ${plan_id}  ${action_id}
    [Documentation]   CU Online Parameter Change By Rest
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | action_id | yes | Update parameter operation feedback action id |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _Update Parameters Operation Should Be Successful  | plan_id=xxx | action_id=xxx |
	${res}=  cu.get_action_state_of_updating_parameters_of_delta_plan  plan_id=${plan_id}  action_id=${action_id}
	should be equal as strings  ${res['status']}  success
_Validating Delta Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    [Documentation]   _Validating Delta Plan Operation Should Be Successful
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | action_id | yes | Update parameter operation feedback action id |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _Validating Delta Plan Operation Should Be Successful  | plan_id=xxx | action_id=xxx |
    ${res}=    cu.get_action_state_of_validating_delta_plan   ${plan_id}  ${action_id}
	should be equal as strings  ${res['status']}  success

_Activating Delta Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${operation_id}
    [Documentation]   _Activating Delta Plan Operation Should Be Successful
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | operation_id | yes | active delta plan feedback id |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _Activating Delta Plan Operation Should Be Successful | plan_id=xxx | operation_id=xxx |
	${res}=  cu.get_operation_state_of_activating_delta_plan   ${plan_id}  ${operation_id}
	should be equal as strings  ${res['status']}  success
