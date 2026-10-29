*** Settings ***

Documentation    author：Pengliang Wu
...              contact: pengliang.wu@nokia-sbell.com
...              squad group: mmw_SG_04

Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot

*** Variables ***
${CURDIR_path}                  ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}
${gNB_ip}                       ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_username}                 ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}                 ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ul_power_port_list}           ${tl.ues[0].iperf_details.ports[0:3]}
${dl_power_port_list}           ${tl.ues[0].iperf_details.ports[3:6]}
${MRBTS_ID}                     ${tl.gnbs[0].instance_id}
${NRBTS_ID}                     ${tl.gnbs[0].global_bts_id}



*** Keywords ***

Get sw build version for scf name
    [Arguments]     ${combine_mode}=${EMPTY}
    Connect to Common Unit Master
    ssh.force_reconnect    connection=ASIK Master
    ${cmd_get_sw_file_name}    Set variable    ls /ffs/run |grep TargetBD.*.xml |grep -v .xml.
    ${sw_file_name}    ssh.execute    command=${cmd_get_sw_file_name}    connection=ASIK Master
    @{sw_version_list}    Get regexp matches    ${sw_file_name}    TargetBD_(.*?)_    1
    Run keyword and ignore error    Remove values From List     ${sw_version_list}    BSR
    ${sw_version_list}    Strip string    ${sw_version_list[0]}
    ${if_SBTS}    run keyword and return status    should contain    ${sw_file_name}     9999
    ${sw_version}    set variable if    ${if_SBTS}    SBTS00    ${sw_version_list}
    ${default_scf_name}    Catenate    TL702_SCF_${combine_mode}gNB_${sw_version}.xml
    log to console    Selected SCF name: ${default_scf_name}
    ${default_scf}    set variable    ${CURDIR_path}/${default_scf_name}
    set suite variable    ${default_scf}
    [Return]  ${default_scf}

Setup Commission SCF
    [Arguments]     ${BTS_Host}=${gNB_ip}    ${combine_mode}=${EMPTY}
     ${default_scf}    Get sw build version for scf name    combine_mode=${combine_mode}
     Connect to gnb coam via ssl    bts_host=${BTS_Host}    username=${gNB_username}    password=${gNB_password}
     log to console    Start commission with SCF
     COAM Commission with scf file      scf_file_path=${default_scf}
     Wait Until Keyword Succeeds   20min   2min     COAM Check GNB cell on air
     [Teardown]    Run keyword and ignore error     COAM Teardown gnb connections

Check BTS Should Be Normal
    [Arguments]  ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    Wait Until Keyword Succeeds    1200s    10s    Verify all cells should be onair
    [Teardown]   Run Keyword And Ignore Error   COAM Teardown gnb connections    connection=${connection}

Get Content From Input Dict
    [Arguments]  ${input_dict}
    ${dist_name}    get from dictionary     ${input_dict}    dist_name
    ${parammeter}    get from dictionary    ${input_dict}    parameter
    ${new_value}     get from dictionary    ${input_dict}    value
    ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
    [Return]  ${value_list}

Modify Common parameter via Coam
    [Arguments]  ${input_list}    ${gNB_ip}=${gNB_ip}    ${connection}=GNB_connection
    log to console    Modify parameter
    Connect to gnb coam via ssl     bts_host=${gNB_ip}      connection=${connection}
    FOR    ${item}  IN    @{input_list}
        ${dict_value}    Get Content From Input Dict    input_dict=${item}
        coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]   value=${dict_value}[2]
        ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
    END
    log to console  change parameter successful,sleep 30s
    sleep  30s
    [Teardown]    run keyword and ignore error    coam.teardown    connection=${connection}

Get nrCellIdentity form BTS by NRCELL id
    [Arguments]     ${nrcell_id}=NRCELL-2
    Connect to gnb coam via ssl    connection=GNB_OAM    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ${subcells_info}    coam.get_subcells_info    connection=GNB_OAM
    ${cell_group}    Get All Cell Group Id    connection=GNB_OAM
    FOR    ${group_id}  IN    @{cell_group}
        ${nrcell_dict}    set variable    ${subcells_info['NRCELLGRP-${group_id}']}
        ${nrcell_id_list}    get dictionary keys    ${nrcell_dict}
        ${cell_id}    set variable    ${nrcell_dict['${nrcell_id_list}[0]']['NRCELL_L']['parameters']['nrCellIdentity']}
        EXIT FOR LOOP IF    '${nrcell_id}'=='${nrcell_id_list}[0]'
    END
    [Return]     ${cell_id}
    [Teardown]    Run keyword and ignore error     COAM Teardown gnb connections

L3 Call
    [Arguments]    ${nrcell_index_list}    ${ul_throughput}    ${dl_throughput}    ${expected_ul}    ${expected_dl}    ${time}
    ${cellid_list}    create list
    FOR  ${each_cellid}  IN  @{nrcell_index_list}
        ${cellid}    Get nrCellIdentity form BTS by NRCELL id    nrcell_id=${each_cellid}
        append to list    ${cellid_list}    ${cellid}
    END
    attach power ue
    start power ue traffic ul and dl      ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}
    Check power ue Tput    ul_throughput=${expected_ul}    dl_throughput=${expected_dl}    time=${time}    cells=${cellid_list}
    stop multi power ue traffic ul and dl
    detach multi power ue

attach power ue
    [Arguments]    ${gnb_index}=${0}
    log to console       Prepare UE
    power_ue.Prepare UE    ue_index=${gnb_index}    ue_type=samsung
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${gnb_index}    ue_type=samsung    log_type=Aasyslog
    power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False    gnb_index=${gnb_index}


start power ue traffic ul and dl
    [Arguments]     ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000
    ...    ${protocol}=udp
    log to console      Start traffic    console=yes
    run keyword and continue on failure      power_ue.Start traffic    ue_index=${0}    direction=ul
    ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=samsung    iperf_type=via_command    protocol=${protocol}
    ...    iperf_port=${ul_power_port_list}[${0}]
    sleep    1s
    run keyword and continue on failure     power_ue.Start traffic    ue_index=${0}    direction=dl
    ...    throughput=${dl_throughput}    duration=${dl_duration}    ue_type=samsung    protocol=${protocol}
    ...    iperf_port=${dl_power_port_list}[${0}]

Check power ue Tput
    [Arguments]     ${time}=3m    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${target_avg_percent}=0.95    ${min_percent}=0.85
    ...    ${cells}=${EMPTY}
    ${log_path}    power_ue.Collect Tput     ue_type=samsung    duration=${time}    log_dir=${OUTPUT_DIR}/${TEST NAME}/
    run keyword and continue on failure    power_ue.Check Tput    ue_type=samsung    direction=ul    target_throughput=${ul_throughput}
    ...     target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    cells=${cells}    log=${log_path}
    ...     actCarrierAggregation=${True}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=samsung    direction=dl    target_throughput=${dl_throughput}
    ...     target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    cells=${cells}    log=${log_path}
    ...     actCarrierAggregation=${True}

stop multi power ue traffic ul and dl
    [Arguments]    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console     Stop traffic    console=yes
    run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=samsung    iperf_type=${protocol}
    ...    protocol=${protocol}    iperf_port=${ul_power_port_list}[${0}]
    run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=samsung    protocol=${protocol}
    ...    iperf_port=${dl_power_port_list}[${0}]

detach multi power ue
    log to console      UE Detach    console=yes
    power_ue.UE Detach    ue_index=${0}    ue_type=samsung

Power Off pDU
    [Arguments]    ${pdu_ip}    ${pdu_port}    ${model}=HBTE
    Log To Console    Power Off pDU
    pdu.Setup Pdu    model=${model}    host=${pdu_ip}    alias=pdu_alias
    pdu.Power Off    port=${pdu_port}    pdu_device=pdu_alias
    ${pdu_status}    pdu.Get Port Status    port=${pdu_port}    pdu_device=pdu_alias
    Should Be Equal     ${pdu_status}    off
    Sleep    15s

Power On pDU
    [Arguments]    ${pdu_ip}    ${pdu_port}    ${model}=HBTE
    Log To Console    Power On pDU
    pdu.Setup Pdu    model=${model}    host=${pdu_ip}    alias=pdu_alias
    pdu.Power On    port=${pdu_port}    pdu_device=pdu_alias
    ${pdu_status}    pdu.Get Port Status    port=${pdu_port}    pdu_device=pdu_alias
    Should Be Equal     ${pdu_status}    on

Lock and Unlock BBMOD
    [Arguments]    ${file_path}    ${BBMOD_index}=BBMOD-1
    Connect to gnb coam via ssl    connection=GNB_OAM    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}    file_path=${file_path}
    log to console    lock bbmod ${BBMOD_index}
    coam.lock    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/${BBMOD_index}    timeout=600s    connection=GNB_OAM
    sleep    20s
    ${output}=    coam.get_fbb_info    connection=GNB_OAM
    FOR    ${bbmod}    IN    @{output}
        ${result}    Run Keyword And Return Status    Dictionary should contain key    ${bbmod['id']}    configuration
        ${bbmod_name}    set variable if    ${result}==${True}    ${bbmod['id']['configuration']}    ${None}
        ${status}    set variableif    ${result}==${True}    ${bbmod['status']['administrativeState']}    ${None}
        run keyword if    '${bbmod_name}'=='MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/${BBMOD_index}'    Should be equal
        ...    ${status}    Locked
        Exit For Loop If    '${bbmod_name}'=='MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/${BBMOD_index}'
    END
    log to console    ulock bbmod ${BBMOD_index}
    coam.unlock    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/${BBMOD_index}    timeout=600s    connection=GNB_OAM
    Wait Until Keyword Succeeds    800s    10s    Verify all cells should be onair
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}    file_path=${file_path}
    [Teardown]    Run keyword and ignore error     COAM Teardown gnb connections

NRCELL Deletion and Addition
    [Arguments]     ${nrcell_id}=2    ${lcelnr_id}=2    ${nrcell_grp_id}=1    ${nrdu_id}=1
    Connect to gnb coam via ssl    connection=GNB_OAM    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${OUTPUT_DIR}
    Selenium Login And Disable Screen Lock    download_dir=${OUTPUT_DIR}
    log to console    Delete NRCELL-${nrcell_id} and related object
    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcelnr_id}
    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${nrcell_id}
    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${nrcell_grp_id}
    ${cell_list}    Get Cell From Cell Group    cellgrp_id=${nrcell_grp_id}
    ${cell_grp}     Get All Cell Group Id
    ${cell_grp_list_len}    get length    ${cell_grp}
    FOR    ${index}    IN RANGE    ${cell_grp_list_len}
        ${value}    selenium_coam.get_parameter_value     dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-${nrdu_id}
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
        run keyword if    '${value}'=='${nrcell_grp_id}'    selenium_coam.remove_element
        ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-${nrdu_id}
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
        Exit For Loop If    '${value}'=='${nrcell_grp_id}'
    END
    ${error}    selenium_coam.validate_plan
    log to console    error infomation: ${error}
    log to console    Deleted Object and Activate plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}    timeout=${300}
    Wait Until Keyword Succeeds    1200s    10s    Verify all cells should be onair
    ${fault_id_list_1}    Get BTS Alarm FaultID
    ${cell_grp_after_delete}     Get All Cell Group Id
    Should Not Contain    ${cell_grp_after_delete}    ${${nrcell_grp_id}}
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_path}
    selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${nrcell_grp_id}
    ...    include_subobject=${True}   id_value=${nrcell_grp_id}    timeout=15

    selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcelnr_id}
    ...    include_subobject=${True}   id_value=${lcelnr_id}    timeout=15

    selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    object_class_name=NRCELL    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${nrcell_id}
    ...    include_subobject=${True}   id_value=${nrcell_id}    timeout=15

    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${nrcell_id}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${lcelnr_id}

    selenium_coam.add_element    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-${nrdu_id}
    ...    abbr=refNrCellGroup    filter_param=Reference to cell group
    ...    timeout=15

    FOR  ${i}  IN  @{cell_grp}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-${nrdu_id}
        ...    filter_param=Reference to cell group     new_value=${i}
        ...    node_index=${i}
    END
    ${error}    selenium_coam.validate_plan
    log to console    error infomation: ${error}
    log to console    Added Object and Activate plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${False}
    Wait Until Keyword Succeeds    1200s    10s    Verify all cells should be onair
    ${cell_list_add}    Get Cell From Cell Group    cellgrp_id=${nrcell_grp_id}
    lists should be equal     ${cell_list_add}    ${cell_list}
    ${fault_id_list_2}    Get BTS Alarm FaultID
    run keyword and continue on failure    lists should be equal    ${fault_id_list_1}    ${fault_id_list_2}
    [Teardown]    Run keywords    Run Keyword And Ignore Error    selenium logout and close browser    AND
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections

Get BTS Alarm FaultID
    [Arguments]  ${connection}=Fault_GNB_OAM
    Connect to gnb coam via ssl    connection=GNB_OAM    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    Log To Console    get active alarm
    ${alarm_info}    coam.get_active_alarms    connection=${connection}
    ${fault_id_list}    create list
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        append to list    ${fault_id_list}    ${fault_id_dic}
    END
    sort list    ${fault_id_list}
    [Return]    ${fault_id_list}
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

#Connect to GNB
#    [Arguments]    ${du_index}=${0}    ${alias}=ASIK Master    ${gnb_index}=${0}
#    csn.Connect to    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
#    ...               ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
#    ...               ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
#    ...               alias=${alias}
#
#Start wireshark capture from gNB or Enb
#    [Documentation]    Description: Start X2 log capture on gNB or Enb
#    [Arguments]     ${filename}    ${interface}=any    ${index}=${0}    ${alias}=ASIK Master
#    Connect to GNB   gnb_index=${index}    alias=${alias}
#    ${log_name}    Set variable    ${filename}.pcap
#    ${log_full_path_gnb}    join path    /tmp    ${log_name}
#    csn.send command    command=ps -ef |grep tcpdump |grep -v grep |grep ${interface} |awk '{print $2}' |xargs kill -2    connection=${alias}
#    sleep    2s
#    csn.send command    command=nohup tcpdump sctp -i ${interface} -w ${log_full_path_gnb}     connection=${alias}
#    sleep    2s
#    Trace capturing process should be triggered    log_prefix=${log_name}    connection_alias=${alias}
#    [Return]    ${alias}
#    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}
#
#
#Stop wireshark capture from gNB or Enb
#    [Documentation]    Description: Stop X2 log capture on gNB or Enb, and download x2 log to testpc
#    [Arguments]     ${filename}    ${logpath}=${OUTPUT_DIR}/${TEST NAME}    ${index}=${0}    ${alias}=ASIK Master
#    Connect to GNB       gnb_index=${index}    alias=${alias}
#    Stop trace capturing    log_prefix=${filename}    connection_alias=${alias}
#    ${log_full_path_ute}    set variable     ${logpath}/${filename}.pcap
#    csn.download_file   remote_path=/tmp/${filename}.pcap   local_path=${log_full_path_ute}   connection=${alias}
#    csn.execute    command=rm /tmp/${filename}.pcap    connection=${alias}
#    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}
