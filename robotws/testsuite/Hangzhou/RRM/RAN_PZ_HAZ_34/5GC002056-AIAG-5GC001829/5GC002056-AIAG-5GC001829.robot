*** Settings ***
Suite Setup    robot_common_operations.Common Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown

Documentation
...   author: xiaofeng.1.zhu@nokia-sbell.com
...   contact: xiaofeng.1.zhu@nokia-sbell.com
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Variables         Resources/5GC002056_modify_para.py
Library           Resources/5GC002056_AIAG.py
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.hw.rf_attenuator    WITH NAME    att
Library           taf.ue  WITH NAME   ute_ue
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library    taf.analyzer.pcap    WITH NAME    check_cap
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library           ../CB007306_OTA/Resources/CB007306_common.py

*** Variables ***
${DU_OAM_IP_URL}            https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_WEBUI_IP}         ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_WEBUI_USER}        ${tl.gnbs[0].cu.oam_http_connection_details.username}
${DU_OAM_WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${DU_OAM_IP_TL}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_SSH_USERNAME_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${ENB_IP}                      ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${ENB_USERNAME}                ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${ENB_PASSWORD}                ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
${ru_alias}   RU
${test_ute}                   ${tl.test_pc.default_ssh_connection_details.addr}
${ute_name}                   ${tl.test_pc.default_ssh_connection_details.username}
${test_password}              ${tl.test_pc.default_ssh_connection_details.password}
${DU_OAM_IP}                  ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${IPERF_ADDR}                 ${tl.appserver.iperf_details.network_interface_address}
${IPERF_PORT}                 ${tl.appserver.iperf_details.port}
${att_ipaddr}                ${tl.attenuator.ip_addr}
${att_connection_port}       ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_api_port}              ${tl.attenuator.port}
${PA_port_3}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${PA_port_4}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${PA_port_7}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[6].port_no}
${PA_port_8}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[7].port_no}
#${att_port_8}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${appserver_addr}            ${tl.ues[1].iperf_details.ssh_connection_details.addr}
${connection}                GNB_OAM
${max_attenuation_value}     ${127}
${vendor}                    HBTE
${luashark_path}             /opt/ute/luashark/luashark_script/generated_luashark
${TS_CASE_LOG_PATH}          ${output_dir}
${epc_log_path}              /tmp
${target5}                   ${output_dir}/CELL_ID.txt
${filter1}                    nr-rrc.servCellIndex && nr-rrc.physCellId
${filter2}                    f1ap && f1ap.procedureCode == 12
${filter3}                    f1ap
${throughput}                100M
${direction1}                 ul
${direction2}                 dl
${default_scf_path}           ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}
${nrcellid1}                ${181825}
${nrcellid2}                ${181826}

*** Test Cases ***
[1]5GC002056-AIAG_5GC001829 spillover from 5GC001094_G_205_PSCell_change_A3_SSB_ RSRP_RSRQ_Combined_enable_with_SRB3
    [Documentation]    PSCell change A3 SSB  RSRP RSRQ Combined enable with SRB3
    [Tags]        CRT_TRUNK
    [Setup]      Case Setup
    ${CURDIR_path}    Prepare default scf
    Setup Commission SCF    CURDIR_path=${CURDIR_path}
    Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
    Modify Parameters for SRB3
    run keyword and ignore error    power_ue.UE Detach    ue_type=askey_sigspark    ue_index=${1}
    ${cell_ID_1}    ${cell_ID_2}    Get cell information
    Adjust the HBTE attenuation value    value_1=${20}    value_2=${20}    value_3=${40}
    Log and attach
    ${CELL1_ID}    Get phycellid from wireshark log    source=${output_dir}/gnb_tcpdump.pcap
    ...    target=${output_dir}/gnb_tcpdump.txt   filter=${filter1}
    ${CELL2_ID}    set variable if    '${CELL1_ID}'=='${cell_ID_1}'    ${cell_ID_2}    ${cell_ID_1}
    FOR   ${NUM}   IN RANGE    ${1}    ${3}
        start switch    NUM=${NUM}     cell1_ID=${CELL1_ID}    cell2_ID=${CELL2_ID}
    END
    check log and meesage    cell1_ID=${CELL1_ID}    cell2_ID=${CELL2_ID}
    [Teardown]  run keyword and ignore error    End attach and log

#[1]5GC002056-AIAG_5GC001829 spillover from 5GC001094_G_213_PSCell_change_A3_and_A5_with_SRB3
#    [Documentation]    PSCell change A3 and A5 with SRB3
#    [Tags]     CB002056-AIAG    CRT_21A
#    [Setup]
#    ${CURDIR_path}    Prepare default scf     common_load_scf=SCF_SBTS00_1.xml     other_scf=SCF_0.800_1.xml
#    Setup Commission SCF    CURDIR_path=${CURDIR_path}
#    run keyword and ignore error    power_ue.UE Detach    ue_type=askey_sigspark    ue_index=${4}
#    Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
#    ${cell_ID_1}    ${cell_ID_2}    Get cell information
#    Adjust the HBTE attenuation value    value_1=${35}    value_2=${35}    value_3=${20}    value_4=${20}
#    Log and attach
#    ${CELL_ID}    Check log cell ID
#    A3 switch    CELL_ID=${CELL_ID}    cell_ID_1=${cell_ID_1}    cell_ID_2=${cell_ID_2}
#    Check throughput and Stop traffic
#    log to console    A3 switch check successful,sleep 60s
#    sleep    60s
#    log to console    start A5  test
#    Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber0}
#    Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber1}
#    Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber2}
#    Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber3}
#    sleep    30s
#    Adjust the HBTE attenuation value    value_1=${35}    value_2=${35}    value_3=${20}    value_4=${20}
#    Log and attach
#    ${CELL_ID}    Check log cell ID
#    A5 switch    CELL_ID=${CELL_ID}    cell_ID_1=${cell_ID_1}    cell_ID_2=${cell_ID_2}
#    Check throughput and Stop traffic
#    [Teardown]  run keyword and ignore error    End attach and log

*** Keywords ***
Case Setup
    CI_interface.Common Case Setup
    robot_common_operations.Common case Setup


Prepare default scf
    [Arguments]  ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${DU_OAM_WEBUI_IP}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
    ${default_scf}    set variable if    ${if_common_load}    ${default_scf_path}/SCF_SBTS00_gNB1.xml
    ...    ${default_scf_path}/SCF_${version_list[0]}_gNB1.xml
    log to console   ${default_scf}
    [Return]     ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Get cell information
    [Arguments]    ${target}=${target5}
     coam.connect_to    bts_host=${DU_OAM_IP_TL}   name=${connection}
     ${INFO}    coam.get_cells_info    connection=${connection}
     coam.teardown       connection=${connection}
     text_save    ${target}    ${INFO}
     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
     csn.Send Command
     ...    command=cat ${target} |grep physicalCellId |cut -d ' ' -f 3|awk '{print}' |sort -n|head -1
     ...    connection=${connection}
     ${cell_1}  csn.Read Output    connection=${connection}
     ${cell_1}  strip_string    ${cell_1}
     csn.Send Command
     ...    command=cat ${target} |grep physicalCellId |cut -d ' ' -f 3|awk '{print}' |sort -n|tail -n 1
     ...    connection=${connection}
     ${cell_2}  csn.Read Output    connection=${connection}
     ${cell_2}  strip_string    ${cell_2}

     ${cell_1}    Evaluate    ${cell_1}*1
     ${cell_2}    Evaluate    ${cell_2}*1

     ${cell_ID_1}    set variable if    '${cell_1}'>'${cell_2}'    ${cell_2}    ${cell_1}
     ${cell_ID_2}    set variable if    '${cell_1}'>'${cell_2}'    ${cell_1}    ${cell_2}
     log to console    Cell_1:${cell_ID_1}----Cell_2:${cell_ID_2}
     [Return]    ${cell_ID_1}    ${cell_ID_2}
     [Teardown]    Delete file

Delete file
    [Arguments]    ${target}=${target5}
    run keyword and ignore error    coam.teardown       connection=${connection}
    csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}\
    csn.Send Command    command=rm ${target} -r    connection=${connection}
    [Teardown]    run keyword and ignore error    csn.Disconnect	connection=${connection}

Log and attach
    [Arguments]    ${UE_type}=samsung
    ${nrcellid2}     Create list    ${nrcellid2}
    start wireshark log    log_name=gnb_tcpdump
    power_ue.Prepare UE    ue_type=${UE_type}    ue_index=${1}
    log to console    UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_type=${UE_type}    ue_index=${1}
    sleep    5s
    log to console    Verify Attach
    power_ue.Verify attach    ue_type=${UE_type}    5Grach_ed=${5Grach_ed_0}    ue_index=${1}    4G_check=False    gnb_index=${0}
    sleep    5s
    end wireshark log    log_name=gnb_tcpdump
#    log to console    Start traffic
#    power_ue.Start traffic    ue_type=${UE_type}
#    ...    direction=${direction1}    throughput=5MKbits/sec    duration=6000    ue_index=${1}    iperf_type=via_command
#    power_ue.Start traffic    ue_type=${UE_type}
#    ...    direction=${direction2}    throughput=5MKbits/sec    duration=6000    ue_index=${1}
#    sleep    5s
#    ${log_path}    power_ue.Collect Tput    ue_type=${UE_type}    duration=30s    ignore_time=5s
#    Run Keyword And Ignore Error    power_ue.Check Tput    ue_type=samsung    direction=dl
#    ...    log=${log_path}     cells=${nrcellid2}    target_throughput=${5}
#    Run Keyword And Ignore Error    power_ue.Check Tput    ue_type=samsung    direction=ul
#    ...    log=${log_path}     cells=${nrcellid2}    target_throughput=${5}

Setup Commission SCF
    [Arguments]    ${CURDIR_path}
    Connect to gnb coam via ssl    bts_host=${DU_OAM_WEBUI_IP}
    log to console    connect successful
    COAM Commission with scf file    scf_file_path=${CURDIR_path}
    Run Keyword And Ignore Error    coam.teardown
    Wait Until Keyword Succeeds   16min   1min   Verify all cells should be onair
    sleep    60s
    [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=${connection}

Connect to gnb coam
    [Arguments]  ${connection}=GNB_OAM    ${bts_host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    coam.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
    ...   name=${connection}

Adjust the HBTE attenuation value
    [Arguments]      ${value_1}    ${value_2}    ${value_3}    ${att_port1}=${PA_port_3}
    ...    ${att_port2}=${PA_port_4}    ${att_port3}=${PA_port_7}    ${att_port4}=${PA_port_8}    ${model}=${tl.attenuator.model}
    #PA_port_3,4->PCI:86   PA_port_7,8->PCI:87
    Log to console    port3,4(pci:86)=${value_1},${value_2}___port7,8(pci:87)=${value_3}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    model=${model}
    ...    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    att.set_attenuation     port=${att_port1}    value=${value_1}
    att.set_attenuation     port=${att_port2}    value=${value_2}
    att.set_attenuation     port=${att_port3}    value=${value_3}
    att.set_attenuation     port=${att_port4}    value=${value_3}
    ${value_port1}    att.read_attenuation    port=${att_port1}
    should be equal    ${value_port1}    ${value_1}
    ${value_port2}    att.read_attenuation    port=${att_port2}
    should be equal    ${value_port2}    ${value_2}
    ${value_port3}    att.read_attenuation    port=${att_port3}
    should be equal    ${value_port3}    ${value_3}
    ${value_port4}    att.read_attenuation    port=${att_port4}
    should be equal    ${value_port4}    ${value_3}

Convert pcap to text
    [Arguments]    ${source}    ${target}    ${connection}    ${filter}
    ssh.send_command
    ...  command=nice tshark -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
    ssh.await execution end  connection=${connection}  timeout=30min
    sleep    1s

Get phycellid from wireshark log
    [Arguments]    ${source}   ${target}   ${filter}    ${connection}=TEST_PC
    csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
    sleep    1s
    Convert pcap to text    source=${source}    target=${target}    connection=${connection}    filter=${filter}
    csn.Send Command  command=cat ${target} |grep physCellId |head -2 |tail -n 1 |tr -cd "[0-9]"
    ...    connection=${connection}
    ${CELL_ID}  csn.Read Output    connection=${connection}
    ${CELL_ID}  strip_string    ${CELL_ID}
    log to console  physCellId=${CELL_ID}
    [Return]    ${CELL_ID}
    [Teardown]    run keyword and ignore error    csn.Disconnect	connection=${connection}

Get PID
    [Arguments]    ${connection}    ${command}
    Log To Console    Get PID
    ${PID}  csn.Execute  command=${command}   connection=${connection}
    ${PID}    strip_string    ${PID}
    should not be empty    ${PID}
    [Return]    ${PID}

start wireshark log
    [Arguments]    ${log_name}    ${alias}=VM
    csn.connect_to   hostname=${DU_OAM_IP_TL}
    ...    username=${DU_OAM_SSH_USERNAME_TL}    password=${DU_OAM_SSH_PASSWORD_TL}    alias=${alias}
    csn.send command    command=ps -ef |grep tcpdump |grep -v grep |grep any |awk '{print $2}' |xargs kill -2    connection=${alias}
    sleep    2s
    csn.send command    command=nohup tcpdump sctp -i any -w /tmp/${log_name}.pcap     connection=${alias}
    sleep    2s
    Trace capturing process should be triggered    log_prefix=${log_name}.pcap    connection_alias=${alias}
    sleep    3s
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}

end wireshark log
    [Arguments]    ${log_name}    ${alias}=VM    ${logpath}=${OUTPUT_DIR}
    csn.connect_to   hostname=${DU_OAM_IP_TL}
    ...    username=${DU_OAM_SSH_USERNAME_TL}    password=${DU_OAM_SSH_PASSWORD_TL}    alias=${alias}
    Stop trace capturing    log_prefix=${log_name}    connection_alias=${alias}
    ${log_full_path_ute}    set variable     ${logpath}/${log_name}.pcap
    csn.download_file   remote_path=/tmp/${log_name}.pcap   local_path=${log_full_path_ute}   connection=${alias}
    csn.execute    command=rm /tmp/${log_name}.pcap    connection=${alias}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}


Reboot UE
    [Arguments]    ${serial}=${serial}    ${connection}=cpc_0    ${timeout}=${10}
    _Excute ADB Command On UE PC     command=adb -s ${serial} reboot    connection=${connection}    timeout=${timeout}
    wait until keyword succeeds    3 min    10s    _UE_Exist    connection=${connection}

start switch
    [Arguments]   ${NUM}    ${cell1_ID}    ${cell2_ID}
    ${nrcellid1}     Create list    ${nrcellid1}
    ${nrcellid2}     Create list    ${nrcellid2}
    start wireshark log    log_name=${cell1_ID}_${cell2_ID}_${NUM}
    sleep    5s
    FOR   ${step}  IN RANGE    ${20}    ${41}    ${5}
        #log to console  NUM:${step}/
        Adjust the HBTE attenuation value    value_1=${step}    value_2=${step}    value_3=${20}
        sleep    2s
    END
    sleep    5s
    end wireshark log    log_name=${cell1_ID}_${cell2_ID}_${NUM}

#    ${log_path}    power_ue.Collect Tput    ue_type=samsung    duration=30s    ignore_time=5s
#    Run Keyword And Ignore Error    power_ue.Check Tput    ue_type=samsung    direction=dl
#    ...    log=${log_path}     cells=${nrcellid1}    target_throughput=${5}
#    Run Keyword And Ignore Error    power_ue.Check Tput    ue_type=samsung    direction=ul
#    ...    log=${log_path}     cells=${nrcellid1}    target_throughput=${5}

    start wireshark log    log_name=${cell2_ID}_${cell1_ID}_${NUM}
    sleep    5s
    FOR   ${step}  IN RANGE    ${20}    ${41}    ${5}
#        log to console  NUM:${step}/
        Adjust the HBTE attenuation value    value_1=${20}    value_2=${20}    value_3=${step}
        sleep    2s
    END
    sleep    5s
    end wireshark log    log_name=${cell2_ID}_${cell1_ID}_${NUM}

#    ${log_path}    power_ue.Collect Tput    ue_type=samsung    duration=30s    ignore_time=5s
#    Run Keyword And Ignore Error    power_ue.Check Tput    ue_type=samsung    direction=dl
#    ...    log=${log_path}     cells=${nrcellid2}    target_throughput=${5}
#    Run Keyword And Ignore Error    power_ue.Check Tput    ue_type=samsung    direction=ul
#    ...    log=${log_path}     cells=${nrcellid2}    target_throughput=${5}


check log and meesage
    [Arguments]      ${cell1_ID}    ${cell2_ID}    ${connection}=TEST_PC
    FOR   ${NUM}   IN RANGE    ${1}    ${3}
        Check log cell ID    source=${cell1_ID}_${cell2_ID}_${NUM}.pcap    target=${cell1_ID}_${cell2_ID}_${NUM}.txt
        ...    filter=${filter2}    data=${cell2_ID}
        Check log cell ID    source=${cell2_ID}_${cell1_ID}_${NUM}.pcap    target=${cell2_ID}_${cell1_ID}_${NUM}.txt
        ...    filter=${filter2}    data=${cell1_ID}
        csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
        sleep    1s
        Convert pcap to text    source=${output_dir}/${cell1_ID}_${cell2_ID}_${NUM}.pcap
        ...    target=${output_dir}/${cell1_ID}_${cell2_ID}_${NUM}_flow.txt    connection=${connection}    filter=${filter3}
        Convert pcap to text    source=${output_dir}/${cell2_ID}_${cell1_ID}_${NUM}.pcap
        ...    target=${output_dir}/${cell2_ID}_${cell1_ID}_${NUM}_flow.txt    connection=${connection}    filter=${filter3}
        ${val_result1}    Check Wireshark Message Flow From Txt
        ...    txt_file_path=${output_dir}/${cell2_ID}_${cell1_ID}_${NUM}_flow.txt    message_dict=${message_flow}
        ${val_result2}    Check Wireshark Message Flow From Txt
        ...    txt_file_path=${output_dir}/${cell1_ID}_${cell2_ID}_${NUM}_flow.txt    message_dict=${message_flow}
        Run Keyword And Continue On Failure    should be equal    ${val_result1}    ${True}
        Run Keyword And Continue On Failure    should be equal    ${val_result2}    ${True}
    END

Check log cell ID
    [Arguments]    ${source}  ${target}    ${filter}    ${data}
    ${CELL_ID}    Get phycellid from wireshark log    source=${output_dir}/${source}    target=${output_dir}/${target}   filter=${filter}
    log to console  Check log cell ID:${CELL_ID}
    run keyword and continue on failure    should be equal as strings    ${data}    ${CELL_ID}
    [Return]    ${CELL_ID}

End attach and log
    [Arguments]    ${UE_type}=samsung
    power_ue.Stop traffic    ue_type=${UE_type}    direction=${direction1}    ue_index=${1}    ue_mode=NSA    iperf_type=via_command
    power_ue.Stop traffic    ue_type=${UE_type}    direction=${direction2}    ue_index=${1}    ue_mode=NSA
    run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_type}    ue_index=${1}
    csn.connect_to   hostname=${DU_OAM_IP_TL}
    ...    username=${DU_OAM_SSH_USERNAME_TL}    password=${DU_OAM_SSH_PASSWORD_TL}    alias=VM
    run keyword and ignore error    csn.execute    ps -ef | grep tcpdump | grep -v grep | awk '{print $2}' | xargs kill -2
    ...    connection=VM
    run keyword and ignore error    csn.Disconnect	connection=VM
    CI_interface.Common Case Teardown
    robot_common_operations.Common case Teardown
    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Save Snapshot    bts_host=${DU_OAM_IP_TL}

Save Snapshot
    [Arguments]    ${bts_host}=${DU_OAM_IP_TL}    ${connection}=cOAM    ${timeout}=10min
    log to console    Save Snapshot...
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    ${snapshot_path}    coam.get_snapshot    target_file_name=${output_dir}/${timestamp}_snapshot.zip    connection=${connection}
    ...    timeout=${timeout}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${snapshot_path}


A3 switch
    [Arguments]    ${CELL_ID}    ${cell_ID_1}    ${cell_ID_2}    ${NUM1}=${25}    ${NUM2}=${20}
    ${CRNTI_cell1}    Check x2ap    CELL_ID=${CELL_ID}
    ${ID}    set variable if    '${CELL_ID}'=='${cell_ID_1}'    ${cell_ID_2}    ${cell_ID_1}
    start extract log
    sleep    2s
    log to console  NUM:${25}/
    Adjust the HBTE attenuation value    value_1=${25}    value_2=${25}    value_3=${20}    value_4=${20}
    sleep    5s
    log to console  NUM:${20}/
    Adjust the HBTE attenuation value    value_1=${20}    value_2=${15}    value_3=${20}    value_4=${20}
    sleep    5s
    log to console  NUM:${15}/
    Adjust the HBTE attenuation value    value_1=${15}    value_2=${5}    value_3=${20}    value_4=${20}
    sleep    5s
    log to console  NUM:${10}/
    Adjust the HBTE attenuation value    value_1=${10}    value_2=${0}    value_3=${20}    value_4=${20}
    sleep    5s
    log to console  NUM:${5}/
    Adjust the HBTE attenuation value    value_1=${5}    value_2=${0}    value_3=${20}    value_4=${20}
    sleep    5s
    log to console  NUM:${0}/
    Adjust the HBTE attenuation value    value_1=${0}    value_2=${0}    value_3=${20}    value_4=${20}
    sleep    5s
    end extract log
    event check    event_ID=${event_1}
    log to console    A3 check successful
    ${CELL_ID}    Check log cell ID
    Analysis capture log for Case213
    should be true    '${CELL_ID}'=='${ID}'
    sleep    10s
    ${CRNTI_cell2}    SRB3 check    CELL_ID=${CELL_ID}
    should not be equal    ${CRNTI_cell1}    ${CRNTI_cell2}
    log to console    switch cell successful

A5 switch
    [Arguments]    ${CELL_ID}    ${cell_ID_1}    ${cell_ID_2}    ${NUM1}=${25}    ${NUM2}=${20}
    ${CRNTI_cell3}    Check x2ap    CELL_ID=${CELL_ID}
    ${ID}    set variable if    '${CELL_ID}'=='${cell_ID_1}'    ${cell_ID_2}    ${cell_ID_1}
    Get ENB LOG
    start extract log
    sleep    2s
    log to console  NUM:${25}/
    Adjust the HBTE attenuation value    value_1=${25}    value_2=${25}    value_3=${20}    value_4=${20}
    sleep    5s
    log to console  NUM:${20}/
    Adjust the HBTE attenuation value    value_1=${20}    value_2=${15}    value_3=${20}    value_4=${20}
    sleep    5s
    log to console  NUM:${15}/
    Adjust the HBTE attenuation value    value_1=${15}    value_2=${5}    value_3=${20}    value_4=${20}
    sleep    5s
    log to console  NUM:${10}/
    Adjust the HBTE attenuation value    value_1=${10}    value_2=${0}    value_3=${20}    value_4=${20}
    sleep    5s
    log to console  NUM:${5}/
    Adjust the HBTE attenuation value    value_1=${5}    value_2=${0}    value_3=${20}    value_4=${20}
    sleep    5s
    log to console  NUM:${0}/
    Adjust the HBTE attenuation value    value_1=${0}    value_2=${0}    value_3=${20}    value_4=${20}
    sleep    5s
    end extract log
    end ENB LOG
    Analysis capture log for Case213
    event check    event_ID=${event_2}
    log to console    A5 check successful
    ${CELL_ID}    Check log cell ID
    should be true    '${CELL_ID}'=='${ID}'
    ${CRNTI_cell4}    SRB3 check    CELL_ID=${CELL_ID}
    should not be equal    ${CRNTI_cell3}    ${CRNTI_cell4}

Check RSRP and RSRQ
    [Arguments]    ${filter2}=${filter2}
    csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
    Convert pcap to text    source=${source}    target=${target2}    connection=${connection}    filter=${filter2}
    csn.Send Command
    ...    command=cat ${target2} |grep '<= SS-RSRQ <' |grep rsrq: |cut -d '(' -f 2|awk '{print}' |head -2 |tail -n 1|tr -cd "[0-9]"
    ...    connection=${connection}
    ${RSRQ1}  csn.Read Output    connection=${connection}
    ${RSRQ1}  strip_string    ${RSRQ1}
    csn.Send Command
    ...    command=cat ${target2} |grep '<= SS-RSRQ <' |grep rsrq: |cut -d '(' -f 2|awk '{print}' |head -1 |tail -n 1|tr -cd "[0-9]"
    ...    connection=${connection}
    ${RSRQ2}  csn.Read Output    connection=${connection}
    ${RSRQ2}  strip_string    ${RSRQ2}

    csn.Send Command
    ...    command=cat ${target2} |grep '<= SS-RSRP <' |grep rsrp: |cut -d '(' -f 2|awk '{print}' |head -3 |tail -n 1|tr -cd "[0-9]"
    ...    connection=${connection}
    ${RSRP1}  csn.Read Output    connection=${connection}
    ${RSRP1}  strip_string    ${RSRP1}
    csn.Send Command
    ...    command=cat ${target2} |grep '<= SS-RSRP <' |grep rsrp: |cut -d '(' -f 2|awk '{print}' |head -1 |tail -n 1|tr -cd "[0-9]"
    ...    connection=${connection}
    ${RSRP2}  csn.Read Output    connection=${connection}
    ${RSRP2}  strip_string    ${RSRP2}
    log to console    RSRQ_1 is :${RSRQ1}
    log to console    RSRQ_2 is :${RSRQ2}
    log to console    RSRP_1 is :${RSRP1}
    log to console    RSRP_2 is :${RSRP2}
    ${RSRQ1}    set variable if    '${RSRQ1}'=='${EMPTY}'   ${0}    ${RSRQ1}
    ${RSRQ2}    set variable if    '${RSRQ2}'=='${EMPTY}'   ${0}    ${RSRQ2}
    ${RSRP1}    set variable if    '${RSRP1}'=='${EMPTY}'   ${0}    ${RSRP1}
    ${RSRP2}    set variable if    '${RSRP2}'=='${EMPTY}'   ${0}    ${RSRP2}
    ${RSRQ}    evaluate   ${RSRQ1}-${RSRQ2}
    ${RSRP}    evaluate   ${RSRP1}-${RSRP2}
    log to console    RSRQ is :${RSRQ}
    log to console    RSRP is :${RSRP}
    [Return]    ${RSRQ}  ${RSRP}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Modify Common parameter via Coam
    [Arguments]  ${input_list}    ${connection}=GNB_connection    ${bts_ip}=${DU_OAM_IP_TL}
    log to console  Modify parameter
    Connect to gnb coam via ssl    bts_host=${DU_OAM_WEBUI_IP}    connection=${connection}
    FOR    ${item}   IN    @{input_list}
         ${dict_value}    Get Content From Input Dict    input_dict=${item}
         coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]   value=${dict_value}[2]
         ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
    END
    log to console  sleep 1min
    sleep  1min
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Get Content From Input Dict
    [Arguments]  ${input_dict}
    ${dist_name}    get from dictionary     ${input_dict}    dist_name
    ${parammeter}    get from dictionary    ${input_dict}    parameter
    ${new_value}     get from dictionary    ${input_dict}    value
    ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
    [Return]  ${value_list}

Analysis capture log for Case213
    [Arguments]    ${filter4}=${filter4}    ${filter5}=${filter5}    ${filter6}=${filter6}    ${filter7}=${filter7}
    ...    ${filter8}=${filter8}    ${target6}=${target6}
    csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#    Convert pcap to text    source=${source}    target=${target6}    connection=${connection}    filter=${filter4}
#    csn.Send Command    command=cat ${target6}    connection=${connection}
#    ${re1}  csn.Read Output    connection=${connection}
#    should be empty    ${re1}
    Convert pcap to text    source=${source}    target=${target6}    connection=${connection}    filter=${filter5}
    csn.Send Command    command=cat ${target6}    connection=${connection}
    ${re2}  csn.Read Output    connection=${connection}
    should be empty    ${re2}
#    Convert pcap to text    source=${source}    target=${target6}    connection=${connection}    filter=${filter6}
#    csn.Send Command    command=cat ${target6}    connection=${connection}
#    ${re3}  csn.Read Output    connection=${connection}
#    should be empty    ${re3}
    Convert pcap to text    source=${source}    target=${target6}    connection=${connection}    filter=${filter7}
    csn.Send Command    command=cat ${target6}    connection=${connection}
    ${re4}  csn.Read Output    connection=${connection}
    should be empty    ${re4}
    Convert pcap to text    source=${source}    target=${target6}    connection=${connection}    filter=${filter8}
    csn.Send Command    command=cat ${target6}    connection=${connection}
    ${re5}  csn.Read Output    connection=${connection}
    should be empty    ${re5}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

SRB3 check
    [Arguments]     ${CELL_ID}
    cap.read_cap    cap_file=${source}    display_filter=f1ap
    ${srb3_ho_rrc_reconfig} =  Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7 and nr-rrc.srb_Identity == 3
    ...    and nr-rrc.physCellId == ${CELL_ID}
    ${status}    ${value} =    run keyword and ignore error    cap.Check Expression    condition_expression=${srb3_ho_rrc_reconfig}
    log to console    ${status}
    should be equal    '${status}'    'PASS'
    ${CRNTI_cell} =    cap.get_element_value    element_expression=nr-rrc.newUE_Identity
    ...    condition_expression=f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    log to console    ${CRNTI_cell}
    [Return]    ${CRNTI_cell}

Check x2ap
    [Arguments]     ${CELL_ID}
    ${CELL_ID}    Evaluate    ${CELL_ID}*1
    cap.read_cap    cap_file=${source}    display_filter=x2ap
    ${SgNBAdditionRequestACK_srb3} =  Catenate    x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27
    ...    and nr-rrc.srb_Identity == 3    and     nr-rrc.physCellId == ${CELL_ID}
    ${status}    ${value} =    run keyword and ignore error    cap.Check Expression    condition_expression=${SgNBAdditionRequestACK_srb3}
    log to console    ${status}
    should be equal    '${status}'    'PASS'
    ${CRNTI_cell} =    cap.get_element_value    element_expression=nr-rrc.newUE_Identity
    ...    condition_expression=x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27
    [Return]    ${CRNTI_cell}

event check
    [Arguments]    ${event_ID}    ${filter}=${filter}
    log to console    start event check...
    csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
    Convert pcap to text    source=${source}    target=${target3}    connection=${connection}    filter=${filter}
    csn.Send Command
    ...    command=cat ${target3} |grep ${event_ID}    connection=${connection}
    ${event}  csn.Read Output    connection=${connection}
    ${event}  strip_string    ${event}
    should not be empty    ${event}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Get ENB LOG
    ${connection_1}    csn.connect_to   hostname=${ENB_IP}
    ...    username=${ENB_USERNAME}    password=${ENB_PASSWORD}    alias=VM
    csn.Send Command   command=tcpdump -n -i br1 -w /tmp/enb_tcpdump.pcap    connection=${connection_1}
    log to console  start ENB log successful
    sleep    3s
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection_1}

end ENB LOG
    ${connection_1}    csn.connect_to   hostname=${ENB_IP}
    ...    username=${ENB_USERNAME}    password=${ENB_PASSWORD}    alias=VM
    csn.Send Command  command=ps -ef | grep tcpdump | grep -v grep | grep enb_tcpdump.pcap |tail -n 1 |awk '{print $2}'
    ...    connection=${connection_1}
    ${PID}  csn.Read Output    connection=${connection_1}
    ${PID}  strip_string    ${PID}
    log to console  End ENB log successful
    log to console  PID output: ${PID}
    csn.Send Command  command=kill ${PID}    connection=${connection_1}
    Download ENB Log
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection_1}

Download ENB Log
    [Arguments]    ${connection_2}=Download
    csn.connect_to   hostname=${ENB_IP}    username=${ENB_USERNAME}    password=${ENB_PASSWORD}
    ...    alias=${connection_2}
    csn.download_file   local_path=${LOG_PATH}/enb_tcpdump.pcap    remote_path=${epc_log_path}/enb_tcpdump.pcap
    ...    connection=${connection_2}
    sleep    5s
    log to console  Download Log successful
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection_2}

Modify Parameters for SRB3
    Connect to gnb coam via ssl    bts_host=${DU_OAM_WEBUI_IP}    connection=${connection}
    Modify Parameters with coam     input_list=${GNB_MODIFY_Parameter_srb3}    connection=${connection}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}

Modify Parameters with coam
    [Arguments]    ${input_list}    ${delta_id}=modify_parameter    ${connection}=GNB_OAM
    coam.create_delta    delta_id=${delta_id}
    FOR    ${item}  IN    @{input_list}
        ${operation}    get from dictionary    ${item}    operation
        Run keyword if    '${operation}'=='update'
        ...    coam.append_parameter_update_to_delta    dist_name=${item['dist_name']}    parameter=${item['parameter']}
        ...    value=${item['value']}    delta_id=${delta_id}
        Run keyword if    '${operation}'=='delete'
        ...    coam.append_parameter_delete_to_delta    dist_name=${item['dist_name']}    parameter=${item['parameter']}
        ...    delta_id=${delta_id}
        Log to console    Add task - ${operation}: ${item['dist_name']}.${item['parameter']}
    END
    ${delta_file}    coam.get_delta    delta_id=${delta_id}
    ${timeout}    set variable    300
    Log to console    Perform parameters via delta_id:${delta_id} is ongoing, timeout ${timeout}s.
    coam.perform_delta_recommissioning
    ...    delta_file=${delta_file}
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${timeout}
    ...    connection=${connection}
    Log to console    Perform parameters done.
    [Teardown]    run keyword and ignore error    coam.remove_delta    delta_id=${delta_id}
