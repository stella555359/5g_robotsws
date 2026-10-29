*** Settings ***
Documentation
...               author: Na Li
...               contact: na.li@nokia-sbell.com
...               squad group: MMW_SG_04

Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           taf.config.scf    WITH NAME    cscf

*** Variables ***
${MRBTS_ID}               ${tl.gnbs[0].instance_id}
${NRBTS_ID}               ${tl.gnbs[0].global_bts_id}
${MRBTS_ID2}               ${tl.gnbs[1].instance_id}
${NRBTS_ID2}               ${tl.gnbs[1].global_bts_id}
${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
${target}                 ${OUTPUT_DIR}/btslog.log
${E500_SCRIPTS_BASE}      ${CURDIR}/E500_scripts
${LOG_PATH}               ${OUTPUT_DIR}
${DU_IP}                    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBEM_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${scf_file_path}            ${output_dir}
${ROOT_USERNAME}          toor4nsn
${ROOT_PASSWORD}          oZPS0POrRieRtu
${gNB2_ip}                ${tl.gnbs[1].dus[0].f1_m_ip_addr}

*** Keywords ***
Get Version
    Log To Console    Get Version
    ${conn}    Connect to DU
    ${version}    coam.get_sw_version    connection=${conn}
    ${version_list}    split string    ${version}    _
    ${versiontitle}    set variable    ${version_list[0]}
    [Return]    ${versiontitle}
    [Teardown]    coam.Teardown  connection=${conn}

Get Version gnb2
    Log To Console    Get Version
    ${conn}    Connect to DU    alias=cOAM_admin1    DU_IP=${gNB2_ip}
    ${version}    coam.get_sw_version    connection=${conn}
    ${version_list}    split string    ${version}    _
    ${versiontitle}    set variable    ${version_list[0]}
    [Return]    ${versiontitle}
    [Teardown]    coam.Teardown  connection=${conn}

Connect to DU
    [Arguments]    ${alias}=cOAM_admin    ${DU_IP}=${DU_IP}
    ${conn}=    coam.connect_to
    ...    bts_host=${DU_IP}
    ...    username=${WEBEM_USERNAME}
    ...    password=${WEBEM_PASSWORD}
    ...    name=${alias}
    [Return]    ${conn}

Connect to DU1
    [Arguments]    ${alias}=cOAM_admin1
    ${conn}=    coam.connect_to
    ...    bts_host=${gNB2_ip}
    ...    username=${WEBEM_USERNAME}
    ...    password=${WEBEM_PASSWORD}
    ...    name=${alias}
    [Return]    ${conn}

Disconnect from DU
    [Arguments]    ${alias}=cOAM_admin
    coam.teardown     connection=${alias}

Get Alarm Info
    [Arguments]   ${timeout}    ${connection}=cOAM_admin
    sleep    10s
    @{alarms}    coam.get_active_alarms    timeout=${timeout}    connection=${connection}
    sleep    1s
    log     ${alarms}
    ${fault_id_list}    create list
    ${fault_name_list}    create list
    FOR    ${item}    IN    @{alarms}
        ${fault_id}    get from dictionary    ${item}    faultId
        ${fault_name}    get from dictionary    ${item}    faultName
        append to list    ${fault_id_list}    ${fault_id}
        append to list    ${fault_name_list}    ${fault_name}
    END
    [Return]    ${fault_name_list}    ${fault_id_list}

COAM Commission with scf file ignore error
    [Arguments]  ${scf_file_path}=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/scf_1416.xml
    ...    ${connection}=GNB_OAM    ${timeout}=300    ${is_pdl_checking_needed}=${True}
    &{result}    coam.perform_commissioning    scf_file=${scf_file_path}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${True}    connection=${connection}

COAM Commission with 4G scf file ignore error
    [Arguments]  ${scf_file_path}=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS22R1_enb.xml
    ...    ${timeout}=300    ${is_pdl_checking_needed}=${True}
    ${connection}    Connect to eNB via ssl
    &{result}    coam.perform_commissioning    scf_file=${scf_file_path}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${True}    connection=${connection}
    enblte.teardown    connection=enblte

check 4G onair
    ${connection}    Connect to eNB via ssl
    ADMIN Wait Until BTS OnAir    alias=${connection}
    enblte.teardown    connection=enblte

ADMIN Check onair
    [Arguments]        ${admin_alias}=${LOGGING_ADMIN_ALIAS}
    ${dict_info}=   coam.Get Bts Info    connection=${admin_alias}
    ${state}=    Get From Dictionary    dictionary=${dict_info['status']}    key=proceduralState
    Should be equal    ${state}    OnAir

ADMIN Wait Until BTS OnAir
    [Arguments]    ${timeout}=15 min
    ...            ${interval}=30 sec
    ...            ${alias}=cOAM_admin
    Wait Until Keyword Succeeds    ${timeout}
    ...                            ${interval}
    ...                            ADMIN Check onair
    ...                            admin_alias=${alias}

check cell band
    [Arguments]    ${conn}    ${expect}=n257, n261    ${cell_id}=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ${cell_status}    coam.get_cell_specific_info   cell_id=${cell_id}
    ...    connection=${conn}
    ${band}    get from dictionary    ${cell_status}    band
    should be equal as strings    ${band}    ${expect}

Adjust Enb
    [Arguments]    ${index}=locked  ${alias}=enblte    ${dist_name}=MRBTS-${tl.enbs[0].global_bts_id}/LNBTS-${tl.enbs[0].global_bts_id}/LNADJGNB-2
    ...    ${parameter}=administrativeState
    Connect and Modify the parameter on enblte  ${dist_name}    ${parameter}     ${index}

Trigger A3 measurement report for 1874 case
    [Arguments]    ${a2_meas_id}=1    ${report_interval}=0    ${serving_cell_pci}=50    ${serving_cell_rsrp}=50
    ...    ${serving_cell_rsrq}=55    ${serving_cell_sinr}=30    ${neigh_cell_pci}=51    ${neigh_cell_rsrp}=71    ${neigh_cell_rsrq}=77
    ...    ${neigh_cell_sinr}=30    ${tm500_alias}=e500
    log to console  Start to trigger A2 measurement report
    ${cmd_a3_mr}    catenate
    ...    forw mte NrRrcAptTriggerMeasReport ${a2_meas_id} 0 0 ${report_interval} 1
    ...    {8 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[50] [55] [30]]}] []] [] []}
    ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[71] [77] [30]]}] [] ] })]
    ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
    ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
    sleep    5s
    Wait until keyword succeeds    10s    200ms    5GC000573_common_keyword.match pattern in response    response=${response}
    ...    e500_alias=${tm500_alias}    pattern=Random Access Complete

Check btslog
    [Arguments]    ${command}=grep 'Free cfPreamble48 for ssbIndex'   ${target}=${target}    ${connection}=ute
    log to console    Check btslog meassage...
    csn.Connect to     hostname=${TEST_PC_IP}     username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    csn.Send Command    command=cat ${target} |${command}
    ...    connection=${connection}
    ${free}  csn.Read Output    connection=${connection}
    should not be empty    ${free}
    log to console    Check btslog meassage successful
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}


Check wireshark log data contain messages
    [Arguments]    ${message}     ${txt_filename}=attach_message.txt     ${connection}=ute
    csn.Send Command  command=cat ${LOG_PATH}/${txt_filename} | grep ${message}    connection=${connection}
    ${data}    csn.Read Output    connection=${connection}
    ${data}    strip_string    ${data}
    should not be empty    ${data}
    log to console    data:${data}

change parameter gnb1
    [Arguments]   ${dst}=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}    ${para}=actIntraFreqIntraGnbMobilityNSA    ${val}=true
     ${connection}    Connect to DU
     coam.Perform Parameter Recommissioning    dist_name=${dst}   parameter=${para}   value=${val}
     ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
     [Teardown]    Disconnect from DU

ssh connect to DU
    [Arguments]  ${ip_address}=${tl.gnbs[0].dus[0].f1_m_ip_addr}  ${alias}=cOAM_toor4nsn
    ...    ${ROOT_USERNAME}=toor4nsn    ${ROOT_PASSWORD}=oZPS0POrRieRtu
    ${connection}=  ssh.Connect to  ${ip_address}
    ...                             ${ROOT_USERNAME}
    ...                             ${ROOT_PASSWORD}
    ...                             alias=${alias}
    [Return]  ${connection}

start BBMOD tcpdump log
    [Arguments]   ${pcap}=enb_tcpdump_2.pcap
    ...    ${ip_address}=${tl.gnbs[0].dus[0].f1_m_ip_addr}  ${alias}=cOAM_toor4nsn
    ${connection}    ssh connect to DU    ip_address=${ip_address}  alias=${alias}
    ssh.send command                    command=cd /ram && ls -l | grep CPRT | cut -d "_" -f 2|cut -d " " -f 1|head -1
    ...                                 connection=${connection}
    ${readOutput}=         ssh.readOutput    connection=${connection}
    ssh.send command
    ...    command=cd /ram && lxc-attach -n ${readOutput.split("\n")[0]} && nohup tcpdump -i any -w ${pcap} &>/dev/null &
    ...                                 connection=${connection}
    [Teardown]  ssh.disconnect          connection=${connection}

stop BBMOD tcpdump log
    [Arguments]    ${pacp_filename}=enb_tcpdump_2.pcap
    ...    ${ip_address}=${tl.gnbs[0].dus[0].f1_m_ip_addr}  ${alias}=cOAM_toor4nsn
    ${connection}    ssh connect to DU    ip_address=${ip_address}  alias=${alias}
    ${PID}    wait until keyword succeeds    1min    2s    Get PID    connection=${connection}
    ...    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'
    ssh.send_command    command=kill -9 ${PID}    connection=${connection}
    ssh.download_file                   remote_path=/ram/${pacp_filename}
    ...                                 local_path=${LOG_PATH}/${pacp_filename}
    ...                                 connection=${connection}
    [Teardown]  ssh.disconnect          connection=${connection}

Get PID
    [Arguments]    ${connection}    ${command}
    Log To Console    Get PID
    ssh.send_command    command=${command}   connection=${connection}
    ${PID}    ssh.read output    connection=${connection}
    ${PID}    strip_string    ${PID}
    should not be empty    ${PID}
    [Return]    ${PID}

Check PM 1416 counter result
    [Arguments]    ${counter_id}    ${index}=${0}    ${enb}=${False}    ${BTS}=BTS    ${CELLS}=CELLS
    ...    ${NRCELL}=NRCELL-1    ${counter_object}=RACCU    ${alias}=cOAM_admin    ${DU_IP}=${DU_IP}
    ${connection}    Connect to DU    alias=${alias}    DU_IP=${DU_IP}
    ${counter_values}=    coam.get pm counters   couter_ids=${counter_id}    connection=${connection}
    ${result}    Get Dictionary Values   ${counter_values['${BTS}']['${CELLS}']['${NRCELL}']['${counter_object}']['${counter_id}']}
    [Return]    ${result}
    [Teardown]    Run Keyword And Ignore Error   Disconnect from DU    alias=${connection}

change the GNB2 parameter
    [Arguments]    ${index}=locked  ${alias}=enblte    ${expect_cPlaneIpAddr}=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...    ${enb_index}=${0}    ${dist_name}=MRBTS-${MRBTS_ID2}/NRBTS-${NRBTS_ID2}/NRCONNECTMODE_PROFILE-0
    ...    ${parameter}=multiFreqBandIndicatorNR
   ${conn}=    coam.connect_to
    ...    bts_host=${gNB2_ip}
    ...    username=${WEBEM_USERNAME}
    ...    password=${WEBEM_PASSWORD}
    ...    name=${alias}
    ${value_list}    create list    ${261}
    ${dict}    create dictionary    parameterName=${parameter}    operation=update    value=${value_list}
    ${list}    create list   ${dict}
    coam.perform_object_recommissioning    dist_name=${dist_name}
    ...    parameter=${list}    operation=create     skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    connection=${conn}
    coam.perform_parameter_recommissioning    dist_name=MRBTS-${MRBTS_ID2}/NRBTS-${NRBTS_ID2}/NRCELL-1    parameter=nrConnectModeProfileDN
    ...    operation=update     value=${dist_name}
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    connection=${conn}
    coam.perform_parameter_recommissioning    dist_name=MRBTS-${MRBTS_ID2}/NRBTS-${NRBTS_ID2}/NRPMRNL-1    parameter=miNrRacCu
    ...    operation=update     value=5min
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    connection=${conn}
    [Teardown]    Run Keyword And Ignore Error   Disconnect from DU    alias=${conn}

change the GNB1 parameter
    [Arguments]    ${value}=true  ${alias}=enblte    ${expect_cPlaneIpAddr}=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...    ${enb_index}=${0}    ${dist_name}=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ${conn}=    coam.connect_to
    ...    bts_host=${DU_IP}
    ...    username=${WEBEM_USERNAME}
    ...    password=${WEBEM_PASSWORD}
    ...    name=${alias}
    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=actInterFreqInterGnbMobilityNSA
    ...    operation=update     value=${value}    connection=${conn}
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=actInterFreqIntraGnbMobilityNSA
    ...    operation=update     value=${value}    connection=${conn}
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=actIntraFreqIntraGnbMobilityNSA
    ...    operation=update     value=false    connection=${conn}
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    coam.perform_parameter_recommissioning    dist_name=${dist_name}/NRADJNRCELL-1    parameter=nrarfcn
    ...    operation=update     value=2073799    connection=${conn}
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    [Teardown]    Run Keyword And Ignore Error   Disconnect from DU    alias=${conn}

Modify scf GNB2 file
    [Timeout]  20 min
    [Arguments]    ${value1}=true    ${value2}=22454
    ...    ${MRBTS_ID}=${tl.gnbs[0].instance_id}    ${timeout}=10 min    ${scf_mame}=SCF_C.xml
    ...    ${value3}=2073799    ${value4}=n32
    ...    ${alias}=cOAM_admin1    ${DU_IP}=${gNB2_ip}    ${cell_id}=NRCELL-1
    ${connection}    Connect to DU    alias=${alias}    DU_IP=${DU_IP}
    coam.get_current_scf_file    local_dir_path=${output_dir}    file_name=${scf_mame}    connection=${connection}    timeout=60
    Run Keyword And Ignore Error   Disconnect from DU    alias=${connection}
    ${scf_path}     set vari able    ${output_dir}/${scf_mame}
    cscf.load_scf    ${scf_path}
    cscf.modify_scf_element    value=${value2}    dist_name=MRBTS-${MRBTS_ID2}/NRBTS-${NRBTS_ID2}/${cell_id}    p_name=gscnOrSsPbchArfcn
    cscf.modify_scf_element    value=${value3}    dist_name=MRBTS-${MRBTS_ID2}/NRBTS-${NRBTS_ID2}/${cell_id}   p_name=nrarfcn
    cscf.modify_scf_element    value=2073399    dist_name=MRBTS-${MRBTS_ID2}/NRBTS-${NRBTS_ID2}/NRADJNRCELL-1    p_name=nrarfcn
    cscf.modify_scf_element    value=${value1}    dist_name=MRBTS-${MRBTS_ID2}/NRBTS-${NRBTS_ID2}   p_name=actMultiFrequencyBandIndicatorNRSupport
    cscf.save_scf    ${output_dir}/scf.xml
    ${conn}    Connect to DU    alias=${alias}    DU_IP=${gNB2_ip}
    COAM Commission with scf file ignore error    scf_file_path=${output_dir}/scf.xml     connection=${conn}
    RUN KEYWORD AND IGNORE ERROR    Disconnect from DU    alias=${connection}
    [Teardown]    Remove File    ${scf_path}

Modify scf GNB1 file
    [Timeout]  20 min
    [Arguments]    ${value1}=n48    ${value2}=22454
    ...    ${MRBTS_ID}=${tl.gnbs[0].instance_id}    ${timeout}=10 min    ${scf_mame}=SCF_C.xml
    ...    ${value3}=2073799    ${value4}=rsrp
    ...    ${alias}=cOAM_admin    ${DU_IP}=${DU_IP}   ${cell_id}=NRCELL-2
    ${connection}    Connect to DU    alias=${alias}    DU_IP=${DU_IP}
    coam.get_current_scf_file    local_dir_path=${output_dir}    file_name=${scf_mame}    connection=${connection}    timeout=60
    Run Keyword And Ignore Error   Disconnect from DU    alias=${connection}
    ${scf_path}     set vari able    ${output_dir}/${scf_mame}
    cscf.load_scf    ${scf_path}
    cscf.modify_scf_element    value=${value2}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${cell_id}    p_name=gscnOrSsPbchArfcn
    cscf.modify_scf_element    value=${value3}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${cell_id}   p_name=nrarfcn
    cscf.modify_scf_element    value=${value4}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1    p_name=a5MeasEnabled
    cscf.modify_scf_element    value=${value1}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1  p_name=cbraPreamblesPerSsb
    cscf.modify_scf_element    value=none    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1    p_name=a3MeasEnabled
    cscf.modify_scf_element    value=true    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...     p_name=actInterFreqInterGnbMobilityNSA
    cscf.modify_scf_element    value=true    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...     p_name=actInterFreqIntraGnbMobilityNSA
    cscf.modify_scf_element    value=false    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...     p_name=actIntraFreqIntraGnbMobilityNSA
    cscf.modify_scf_element    value=${value4}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRHOIF-2     p_name=a5MeasEnabled
    cscf.save_scf    ${output_dir}/scf.xml
    ${conn}    Connect to DU    alias=${alias}    DU_IP=${DU_IP}
    COAM Commission with scf file ignore error    scf_file_path=${output_dir}/scf.xml     connection=${conn}
    RUN KEYWORD AND IGNORE ERROR    Disconnect from DU    alias=${connection}
    [Teardown]    Remove File    ${scf_path}

check counter phase1 increase
    [Arguments]    ${M55114C00501_1}=${M55114C00501}    ${counter_id}=${counter_id}    ${alias}=cOAM_admin    ${DU_IP}=${DU_IP}
    ...    ${NRCELL}=NRCELL-1
    ${M55601C00006_2}    Check PM 1416 counter result    counter_id=${counter_id}    alias=${alias}    DU_IP=${DU_IP}
    ...    NRCELL=${NRCELL}
    should be true   ${M55601C00006_2[-1]}-${M55114C00501_1[-1]}==${1}

Stop 1416 trace capturing
    [Arguments]        ${log_prefix}=enb_tcpdump_2.pcap    ${alias}=ASIK Slave    ${retry_time}=10
    ...    ${ip_address}=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ${connection_alias}    ssh connect to DU    ip_address=${ip_address}  alias=${alias}
    FOR    ${i}    IN RANGE    ${retry_time}
        ssh.execute    ps -ef | grep tcpdump | grep -v grep | grep ${log_prefix} | awk '{print $2}' | xargs kill -2
        ...    connection=${connection_alias}
        ${is_trace_capture_stopped}    run keyword and return status    wait until keyword succeeds    5s    200ms
        ...    Trace capturing process should be stopped    log_prefix=${log_prefix}    connection_alias=${connection_alias}
        exit for loop if    ${is_trace_capture_stopped}==${True}
    END
    should be true    ${is_trace_capture_stopped}
    ssh.download_file                   remote_path=/ram/${log_prefix}
    ...                                 local_path=${LOG_PATH}/${log_prefix}
    ...                                 connection=${connection_alias}
    [Teardown]  ssh.disconnect          connection=${connection_alias}

1095 Check_TP_And_Bler
    [Arguments]  ${dir_path}    ${ul_min_tp}    ${ul_max_tp}    ${dl_min_tp}    ${dl_max_tp}    ${bler_value}
    ${ul_tp_result}   Viavi_Log_analysis.Check_One_UE_TP_Stable    dir_path=${dir_path}    direction=ul    check_value=${ul_max_tp}
    ...    expect_num=${5}    UE_ID=0
    ${dl_tp_result}   Viavi_Log_analysis.Check_One_UE_TP_Stable    dir_path=${dir_path}    direction=dl    check_value=${dl_max_tp}
    ...    expect_num=${5}    UE_ID=0
    ${ul_bler_result}    Viavi_Log_analysis.Check_One_UE_Bler_Stable    dir_path=${dir_path}    direction=ul    check_value=${bler_value}
    ...    expect_num=${5}    UE_ID=0
    ${dl_bler_result}    Viavi_Log_analysis.Check_One_UE_Bler_Stable    dir_path=${dir_path}    direction=dl    check_value=${bler_value}
    ...    expect_num=${5}    UE_ID=0
    Run Keyword And Continue On Failure    Should Be Equal    ${ul_tp_result}    ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${dl_tp_result}    ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${ul_bler_result}    ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${dl_bler_result}    ${True}

1095 Download Viavi Log
    [Documentation]
    [Arguments]  ${logs_path}    ${connect}=Control_PC
    log to console    ${logs_path}
    ssh.Connect to    hostname=${E500_IP}    username=${E500_USER}    password=${E500_PW}    alias=${connect}
    ${new_path}    set variable    /cygdrive/c/Users/nokia5G/Documents/CSV/${logs_path}[1]
    ssh.send command    command=mkdir ${new_path}    connection=${connect}
    ssh.send command    command=cd '${logs_path}[0]';scp *.csv ${new_path}     connection=${connect}
    sleep    40s
    ${buffer}=         ssh.readOutput    connection=${connect}
    5GC000573_common_keyword.Copy Viavi Log    logs_path=${new_path}
#    ssh.send command    command=rm -rf ${new_path}    connection=${connect}
    ${ute_path}    set variable    ${output_dir}/${logs_path}[1]
    [Return]  ${ute_path}
    [Teardown]    Run Keyword And Ignore error    ssh.disconnect    connection=${connect}

change the BC2 GNB2 parameter
    [Arguments]    ${index}=locked  ${alias}=enblte    ${expect_cPlaneIpAddr}=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...    ${enb_index}=${0}    ${dist_name}=MRBTS-${MRBTS_ID2}/NRBTS-${NRBTS_ID2}/NRCONNECTMODE_PROFILE-1
    ...    ${parameter}=multiFreqBandIndicatorNR    ${value1}=n48    ${cell_id}=NRCELL-1
   ${conn}=    coam.connect_to
    ...    bts_host=${gNB2_ip}
    ...    username=${WEBEM_USERNAME}
    ...    password=${WEBEM_PASSWORD}
    ...    name=${alias}
    ${conn1}=    coam.connect_to
    ...    bts_host=${DU_IP}
    ...    username=${WEBEM_USERNAME}
    ...    password=${WEBEM_PASSWORD}
    ...    name=cOAM_admin
    ${value_list}    create list    ${258}
    ${dict}    create dictionary    parameterName=${parameter}    operation=update    value=${value_list}
    ${list}    create list   ${dict}
    ${dict2}    create dictionary    parameterName=ssbFrequency   operation=update    value=2058715
    ${list2}    create list   ${dict2}
    ${dict3}    create dictionary    parameterName=nrarfcn   operation=update    value=2073399
    ${list3}    create list   ${dict3}
    ${dict4}    create dictionary    parameterName=nrarfcn   operation=update    value=2058799
    ${list4}    create list   ${dict4}
    coam.perform_object_recommissioning    dist_name=${dist_name}
    ...    parameter=${list}    operation=create     skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    connection=${conn}
    coam.perform_object_recommissioning    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRHOIF-2    parameter=${list2}
    ...    operation=update
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    connection=${conn1}
    coam.perform_object_recommissioning    dist_name=MRBTS-${MRBTS_ID2}/NRBTS-${NRBTS_ID2}/NRADJNRCELL-1    parameter=${list3}
    ...    operation=update
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    connection=${conn}
    coam.perform_object_recommissioning    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRADJNRCELL-1    parameter=${list4}
    ...    operation=update
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    connection=${conn1}
    coam.perform_parameter_recommissioning    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRADJNRCELL-1    parameter=freqBandIndicatorNR
    ...    operation=update     value=258
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    connection=${conn1}
    coam.perform_parameter_recommissioning    dist_name=MRBTS-${MRBTS_ID2}/NRBTS-${NRBTS_ID2}/NRCELLGRP-0   parameter=numberOfTransmittedSsBlocks
    ...    operation=update     value=1 beam
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    connection=${conn}
    coam.perform_parameter_recommissioning    dist_name=MRBTS-${MRBTS_ID2}/NRBTS-${NRBTS_ID2}/NRCELL-1    parameter=nrConnectModeProfileDN
    ...    operation=update     value=${dist_name}
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    connection=${conn}
    coam.perform_parameter_recommissioning    dist_name=MRBTS-${MRBTS_ID2}/NRBTS-${NRBTS_ID2}/${cell_id}   parameter=cbraPreamblesPerSsb
    ...    operation=update     value=${value1}
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    connection=${conn}
    coam.perform_parameter_recommissioning    dist_name=MRBTS-${MRBTS_ID2}/NRBTS-${NRBTS_ID2}/NRPMRNL-1    parameter=miNrRacCu
    ...    operation=update     value=5min
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    connection=${conn}
    coam.perform_parameter_recommissioning    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRHOIF-2   parameter=freqBandIndicatorNR
    ...    operation=update     value=258
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    connection=${conn1}
    coam.perform_parameter_recommissioning    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRHOIF-1    parameter=freqBandIndicatorNR
    ...    operation=update     value=258
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    connection=${conn1}
    coam.perform_parameter_recommissioning    dist_name=MRBTS-${MRBTS_ID2}/NRBTS-${NRBTS_ID2}    parameter=srb3SupportEnabled
    ...    operation=update     value=false
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    connection=${conn}
    coam.perform_parameter_recommissioning    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}    parameter=srb3SupportEnabled
    ...    operation=update     value=false
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    connection=${conn1}
    Run Keyword And Ignore Error   Disconnect from DU    alias=${conn1}
    [Teardown]    Run Keyword And Ignore Error   Disconnect from DU    alias=${conn}
