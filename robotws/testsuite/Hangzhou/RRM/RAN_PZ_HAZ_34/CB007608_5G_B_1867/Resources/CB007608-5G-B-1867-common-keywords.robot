*** Settings ***
Documentation
...               author: Na Li
...               contact: na.li@nokia-sbell.com
...               squad group: MMW_SG_04

Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           taf.config.scf    WITH NAME    cscf
Resource          ../../CB007608_B-573/Resources/5GC000573_common_keyword.robot
Library           taf.hw.rf_attenuator    WITH NAME    att

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
${CURDIR_path}            ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}
${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${att_ipaddr}                ${tl.attenuator.ip_addr}
${att_connection_port}       ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_api_port}              ${tl.attenuator.port}
${att_port_3}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_4}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${att_port_7}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[6].port_no}
${att_port_8}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[7].port_no}
${max_attenuation_value}     ${127}
${vendor}                    HBTE

*** Keywords ***
Get Version
    Log To Console    Get Version
    ${conn}    Connect to DU
    ${version}    coam.get_sw_version    connection=${conn}
    ${version_list}    split string    ${version}    _
    ${versiontitle}    set variable    ${version_list[0]}
    [Return]    ${versiontitle}
    [Teardown]    coam.Teardown  connection=${conn}

Connect to DU
    [Arguments]    ${alias}=cOAM_admin    ${DU_IP}=${DU_IP}
    Connect to gnb coam via ssl
    ...    bts_host=${DU_IP}
    ...    username=${WEBEM_USERNAME}
    ...    password=${WEBEM_PASSWORD}
    ...    connection=${alias}
    ${conn}    set variable    ${alias}
    [Return]    ${conn}

Disconnect from DU
    [Arguments]    ${alias}=cOAM_admin
    coam.teardown     connection=${alias}

COAM Commission with scf file ignore error
    [Arguments]  ${scf_file_path}=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_Trunk_gNB1.xml
    ...    ${connection}=GNB_OAM    ${timeout}=300    ${is_pdl_checking_needed}=${True}
    &{result}    coam.perform_commissioning    scf_file=${scf_file_path}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${True}    connection=${connection}

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

Adjust Enb
    [Arguments]    ${index}=true  ${alias}=enblte    ${dist_name}=MRBTS-${tl.enbs[0].global_bts_id}/LNBTS-${tl.enbs[0].global_bts_id}
    ...    ${parameter}=actMultiSCGSplitwoeLcId
    Connect and Modify the parameter on enblte  ${dist_name}    ${parameter}     ${index}

ssh connect to DU
    [Arguments]  ${ip_address}=${tl.gnbs[0].dus[0].f1_m_ip_addr}  ${alias}=cOAM_toor4nsn
    ...    ${ROOT_USERNAME}=toor4nsn    ${ROOT_PASSWORD}=oZPS0POrRieRtu
    ${connection}=  ssh.Connect to  ${ip_address}
    ...                             ${ROOT_USERNAME}
    ...                             ${ROOT_PASSWORD}
    ...                             alias=${alias}
    [Return]  ${connection}

start BBMOD tcpdump log
    [Arguments]   ${pcap}=enb_tcpdump_2.pcap    ${interface}=any
    ...    ${ip_address}=${tl.gnbs[0].dus[0].f1_m_ip_addr}  ${alias}=cOAM_toor4nsn
    ${connection}    ssh connect to DU    ip_address=${ip_address}  alias=${alias}
    ssh.send command    command=ps -ef |grep tcpdump |grep -v grep |grep ${interface} |awk '{print $2}' |xargs kill -2    connection=${connection}
    sleep    2s
    ssh.send command                    command=cd /ram && ls -l | grep CPRT | cut -d "_" -f 2|cut -d " " -f 1|head -1
    ...                                 connection=${connection}
    ${readOutput}=         ssh.readOutput    connection=${connection}
    ssh.send command
    ...    command=cd /ram && lxc-attach -n ${readOutput.split("\n")[0]} && nohup tcpdump -i any -w ${pcap} &>/dev/null &
    ...                                 connection=${connection}
    [Teardown]  ssh.disconnect          connection=${connection}

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

Check PM 1416 counter result
    [Arguments]    ${counter_id}    ${index}=${0}    ${enb}=${False}    ${BTS}=BTS    ${CELLS}=BTS
    ...    ${NRCELL}=NRBTS-1    ${counter_object}=NX2CB   ${alias}=cOAM_admin    ${DU_IP}=${DU_IP}
    ${connection}    Connect to DU    alias=${alias}    DU_IP=${DU_IP}
    ${counter_values}=    coam.get pm counters   couter_ids=${counter_id}    connection=${connection}
    ${result}    Get Dictionary Values   ${counter_values['${BTS}']['${CELLS}']['${NRCELL}']['${counter_object}']['${counter_id}']}
    [Return]    ${result}
    [Teardown]    Run Keyword And Ignore Error   Disconnect from DU    alias=${connection}

check counter phase1 increase
    [Arguments]    ${M55114C00501_1}=${M55114C00501}    ${counter_id}=${counter_id}    ${alias}=cOAM_admin    ${DU_IP}=${DU_IP}
    ...    ${NRCELL}=NRBTS-1
    ${M55601C00006_2}    Check PM 1416 counter result    counter_id=${counter_id}    alias=${alias}    DU_IP=${DU_IP}
    ...    NRCELL=${NRCELL}
    ${counter2}    set variable    0
    ${counter1}    set variable    0
    FOR    ${NUM}    IN    @{M55601C00006_2}
        ${counter2}    evaluate    ${NUM}+${counter2}
    END
    FOR    ${NUM}    IN    @{M55114C00501_1}
        ${counter1}    evaluate    ${NUM}+${counter1}
    END
    ${diff}    evaluate    ${counter2}-${counter1}
    should be true    '${diff}'=='4'

change the GNB1 parameter
    [Arguments]    ${value}=true  ${alias}=enblte    ${expect_cPlaneIpAddr}=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...    ${enb_index}=${0}    ${dist_name}=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}    ${conn}=GNB_OAM
    Connect to gnb coam via ssl
    ...    bts_host=${DU_IP}
    ...    username=${WEBEM_USERNAME}
    ...    password=${WEBEM_PASSWORD}
    ...    connection=${conn}
    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=actInterFreqInterGnbMobilityNSA
    ...    operation=update     value=${value}    connection=${conn}
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=actInterFreqIntraGnbMobilityNSA
    ...    operation=update     value=${value}    connection=${conn}
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=actIntraFreqIntraGnbMobilityNSA
    ...    operation=update     value=false    connection=${conn}
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    [Teardown]    Run Keyword And Ignore Error   Disconnect from DU    alias=${conn}

Modify scf file
    [Timeout]  20 min
    [Arguments]    ${value}=28    ${value1}=300    ${value3}=true    ${value4}=false    ${value5}=5min    ${value6}=300ms
    ...    ${MRBTS_ID}=${tl.gnbs[0].instance_id}    ${timeout}=10 min    ${scf_mame}=SCF_C.xml
    ...    ${alias}=cOAM_admin    ${DU_IP}=${DU_IP}   ${cell_id}=NRCELL-1
    ${versiontitle}    Get Version
    ${scf_path}    Run keyword if    '${versiontitle}'=='SBTS22R1'    set variable
    ...    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS22R1_gNB1.xml
    ...    ELSE    set variable
    ...    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_Trunk_gNB1.xml
    cscf.load_scf    ${scf_path}
    cscf.modify_scf_element    value=${value}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${cell_id}    p_name=dllaIniMcs
    cscf.modify_scf_element    value=${value}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${cell_id}    p_name=ullaIniMcs
    cscf.modify_scf_element    value=${value1}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}    p_name=periodicalDataUsageReportTimer
    cscf.modify_scf_element    value=${value3}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}  p_name=actSecDataUsageRep
    cscf.modify_scf_element    value=${value5}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1  p_name=miNrS1UInterface
    cscf.modify_scf_element    value=${value4}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}  p_name=actDlDataForwardingX2
    cscf.modify_scf_element    value=${value4}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}  p_name=actDlDataForwardingX2Limit
    cscf.modify_scf_element    value=${value3}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}  p_name=actMultiDrbNSA
    cscf.modify_scf_element    value=${value4}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}  p_name=actUeInitRlf
    cscf.modify_scf_element    value=${value3}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}  p_name=actGnbInitRlf
    cscf.modify_scf_element    value=${value6}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}  p_name=tWaitingRlRecover
    cscf.modify_scf_element    value=${value4}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}  p_name=actA2SgnbRelease
    cscf.modify_scf_element    value=${EMPTY}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}  p_name=timerX2DataFwdGuard
    cscf.save_scf    ${output_dir}/scf.xml
    ${conn}    Connect to DU    alias=${alias}    DU_IP=${DU_IP}
    COAM Commission with scf file ignore error    scf_file_path=${output_dir}/scf.xml     connection=${conn}
    RUN KEYWORD AND IGNORE ERROR    Disconnect from DU    alias=${connection}
    [Teardown]    Remove File    ${output_dir}/scf.xml

Convert 1876 pcap to text
    [Arguments]    ${source}    ${target}    ${filter}   ${connection}=ute
    csn.send_command
    ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
    csn.await execution end  connection=${connection}  timeout=30min
    sleep    5s

Check 1876 wireshark log data common
    [Arguments]    ${command}    ${pacp_filename}   ${txt_filename}    ${filter}    ${connection}=ute
    Connect to ENB with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}    alias=${connection}
    sleep    1s
    log to console    ${LOG_PATH}
    log to console    ${pacp_filename}
    Convert 1876 pcap to text   source=${LOG_PATH}/${pacp_filename}
    ...  target=${LOG_PATH}/${txt_filename}   connection=${connection}    filter=${filter}
    csn.Send Command  command=cat ${LOG_PATH}/${txt_filename} |${command}    connection=${connection}
    ${data}    csn.Read Output    connection=${connection}
    ${data}    strip_string    ${data}
    [Return]   ${data}
    [Teardown]    run keyword and ignore error    csn.Disconnect  	connection=${connection}

1876 kill IPSL process
    Connect to cobham control pc via ssh
    csn.send command    command=taskkill /f /im "ips32.exe"       connection=tma_ssh
    Disconnect from cobham control pc via ssh

Adjust the HBTE attenuation value
    [Arguments]      ${value_1}    ${value_2}    ${value_3}    ${value_4}     ${port1}=${att_port_3}
    ...    ${port2}=${att_port_4}    ${port3}=${att_port_7}    ${port4}=${att_port_8}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    att.set_attenuation     port=${port1}    value=${value_1}
    att.set_attenuation     port=${port2}    value=${value_2}
    att.set_attenuation     port=${port3}    value=${value_3}
    att.set_attenuation     port=${port4}    value=${value_4}
    ${value_port1}    att.read_attenuation    port=${port1}
    should be equal    '${value_port1}'    '${value_1}.0'
    ${value_port2}    att.read_attenuation    port=${port2}
    should be equal    '${value_port2}'    '${value_2}.0'
    ${value_port3}    att.read_attenuation    port=${port3}
    should be equal    '${value_port3}'    '${value_3}.0'
    ${value_port4}    att.read_attenuation    port=${port4}
    should be equal    '${value_port4}'    '${value_4}.0'

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
    ${ute_path}    set variable    ${output_dir}/${logs_path}[1]
    [Return]  ${ute_path}
    [Teardown]    Run Keyword And Ignore error    ssh.disconnect    connection=${connect}
