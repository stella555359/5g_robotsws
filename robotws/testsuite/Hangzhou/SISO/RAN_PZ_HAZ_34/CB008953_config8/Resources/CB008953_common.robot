*** Settings ***
Documentation    author：shushu huang
...              contact: shushu.huang@nokia-sbell.com
...              squad group: mmw_SG_03

Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot

Library             taf.sbts.oam.coam.admin   WITH NAME   admin_cli

*** Variables ***
${CURDIR_path}                  ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}
${gNB_ip}                       ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_username}                 ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}                 ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ul_power_port_list}           ${tl.ues[0].iperf_details.ports[0:3]}
${dl_power_port_list}           ${tl.ues[0].iperf_details.ports[3:6]}
${TS_CASE_LOG_PATH}             /home/ute
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
${luashark_path}                /opt/ute/luashark/luashark_script/generated_luashark
${scf_file_path}    ${commissionings_path}/HGZ/7_5_UTE5G402T712

*** Keywords ***
Setup Commission SCF
    [Arguments]     ${BTS_Host}=${gNB_ip}    ${connection}=GNB_OAM
     ${default_scf}    Get sw build version for scf name
     Connect to gnb coam via ssl    bts_host=${BTS_Host}    username=${gNB_username}    password=${gNB_password}
     ...    connection=${connection}
     COAM Commission with scf file      scf_file_path=${default_scf}     connection=${connection}
     Wait Until Keyword Succeeds   16min   2min     COAM Check GNB cell on air
     run keyword and continue on failure     Wait Until Keyword Succeeds   10min   1min     Unexpect Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_FAULT}    file_path=${OUTPUT_DIR}    connection=${connection}
     [Teardown]    Run keyword and ignore error     COAM Teardown gnb connections    connection=${connection}

Get sw build version for scf name
    Connect to Common Unit Master
    ssh.force_reconnect    connection=ASIK Master
    ${cmd_get_sw_file_name}    Set variable    ls /ffs/run |grep TargetBD.*.xml |grep -v .xml.
    ${sw_file_name}    ssh.execute    command=${cmd_get_sw_file_name}    connection=ASIK Master
    @{sw_version_list}    Get regexp matches    ${sw_file_name}    TargetBD_(.*?)_    1
    Run keyword and ignore error    Remove values From List     ${sw_version_list}    BSR
    ${sw_version_list}    Strip string    ${sw_version_list[0]}
    ${if_SBTS}    run keyword and return status    should contain    ${sw_file_name}     9999
    ${sw_version}    set variable if    ${if_SBTS}    SBTS00    ${sw_version_list}
    ${default_scf_name}    Catenate    SCF_${sw_version}.xml
    ${default_scf}    set variable    ${CURDIR_path}/${default_scf_name}
    set suite variable    ${default_scf}
    [Return]  ${default_scf}

Coam Test Teardown
    log to console    \n*** Coam Test Teardown***
    Connect to gnb coam via ssl
    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status
    log to console  RU status: ${ru_status}
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
    should be true    ${cell_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOW_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    COAM Teardown gnb connections
    CI_interface.Common Case Teardown

#7053-E
Setup Commission SCF_CB007053_08
    [Arguments]     ${BTS_Host}=${gNB_ip}    ${connection}=GNB_OAM
     ${default_scf}    Get_SW_build_version_08
     Connect to gnb coam via ssl    bts_host=${BTS_Host}    username=${gNB_username}    password=${gNB_password}
     ...    connection=${connection}
     COAM Commission with scf file      scf_file_path=${default_scf}     connection=${connection}
     Wait Until Keyword Succeeds   16min   2min     COAM Check GNB cell on air
     run keyword and continue on failure     Wait Until Keyword Succeeds   10min   1min     Unexpect Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_FAULT}    file_path=${OUTPUT_DIR}    connection=${connection}
     [Teardown]    Run keyword and ignore error     COAM Teardown gnb connections    connection=${connection}

Get_SW_build_version_08
    Connect to Common Unit Master
    ssh.force_reconnect    connection=ASIK Master
    ${cmd_get_sw_file_name}    Set variable    ls /ffs/run |grep TargetBD.*.xml |grep -v .xml.
    ${sw_file_name}    ssh.execute    command=${cmd_get_sw_file_name}    connection=ASIK Master
    @{sw_version_list}    Get regexp matches    ${sw_file_name}    TargetBD_(.*?)_    1
    Run keyword and ignore error    Remove values From List     ${sw_version_list}    BSR
    ${sw_version_list}    Strip string    ${sw_version_list[0]}
    ${if_SBTS}    run keyword and return status    should contain    ${sw_file_name}     9999
    ${sw_version}    set variable if    ${if_SBTS}    SBTS00    ${sw_version_list}
    ${default_scf_name}    Catenate    SCF_${sw_version}_08.xml
    ${default_scf}    set variable    ${CURDIR_path}/${default_scf_name}
    set suite variable    ${default_scf}
    [Return]  ${default_scf}
    
Check BTS Should Be Normal
    [Arguments]  ${bts_host}=${gNB_ip}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}
    Log To Console    Verity CELL ON AIR..
    Wait Until Keyword Succeeds    800s    10s    Verify all cells should be onair
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}    file_path=${OUTPUT DIR}
    [Teardown]   Run Keyword And Ignore Error   COAM Teardown gnb connections

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
    [Arguments]     ${time}=120s    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${target_avg_percent}=0.95    ${min_percent}=0.85
    ...    ${cell1}=${183233}    ${cell2}=${183234}
    ${cells1}    create list    ${cell1}
    ${cells2}    create list    ${cell2}
    ${log_path}    power_ue.Collect Tput     ue_type=samsung    duration=${time}    ignore_time=10s
    ${output_ul1}    run keyword and return status    power_ue.Check Tput    ue_type=samsung    direction=ul    target_throughput=${ul_throughput}
    ...     target_avg_percent=${target_avg_percent}    min_percent=${min_percent}   cells=${cells1}    log=${log_path}
    ${output_dl1}    run keyword and return status    power_ue.Check Tput    ue_type=samsung    direction=dl    target_throughput=${ul_throughput}
    ...     target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    cells=${cells1}    log=${log_path}
    ${output_ul2}    run keyword and return status    power_ue.Check Tput    ue_type=samsung    direction=ul    target_throughput=${ul_throughput}
    ...     target_avg_percent=${target_avg_percent}    min_percent=${min_percent}   cells=${cells2}    log=${log_path}
    ${output_dl2}    run keyword and return status    power_ue.Check Tput    ue_type=samsung    direction=dl    target_throughput=${ul_throughput}
    ...     target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    cells=${cells2}    log=${log_path}
    should be true    ${output_ul1}!=${output_ul2}
    should be true    ${output_dl1}!=${output_dl2}

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

Scf commission and wait on-air
    [Arguments]   ${scf_name}   ${connection}=COAM
    log to console    step1:scf commission and wait for on-air
    Conect to DU COAM
    admin_cli.perform_commissioning
    ...   scf_file=${scf_file_path}/${scf_name}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=${connection}
	sleep    60s
    Wait Until Keyword Succeeds    20min    20s    COAM Check All Cells Onair

Conect to DU COAM
    [Arguments]    ${connection}=COAM
    admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
                  ...      username=${WEBUI_USER}
                  ...      password=${WEBUI_PASSWORD}
                  ...      name=${connection}

Power Off pDU
    [Arguments]    ${pdu_ip}    ${pdu_port}    ${model}=HBTE
    Log To Console    Power Off pDU
    pdu.Setup Pdu    model=${model}    host=${pdu_ip}    alias=pdu_alias
    pdu.Power Off    port=${pdu_port}    pdu_device=pdu_alias
    ${Status}    pdu.Get Port Status    port=${pdu_port}    pdu_device=pdu_alias
    should be true    '${Status}'=='off'
    Sleep    15s

Power On pDU
    [Arguments]    ${pdu_ip}    ${pdu_port}    ${model}=HBTE
    Log To Console    Power On pDU
    pdu.Setup Pdu    model=${model}    host=${pdu_ip}    alias=pdu_alias
    pdu.Power On    port=${pdu_port}    pdu_device=pdu_alias
    ${Status}    pdu.Get Port Status    port=${pdu_port}    pdu_device=pdu_alias
    should be true    '${Status}'=='on'

Get All RU Index and Return RU List
    [Arguments]     ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    ${ru_index_list}    Get All RU Index   connection=${connection}
    [Return]  ${ru_index_list}
    [Teardown]    run keyword and ignore error    coam.teardown    connection=${connection}

Get All RU dictionary
    [Arguments]     ${connection}=GNB_OAM
    &{hw_info}       coam.get_detected_hw_info    connection=${connection}
    ${rmod_info}    set variable    ${hw_info.radioModules.rmod}
    ${ru_list}    create list
    FOR  ${ru}  IN  @{rmod_info}
        ${ru_id_internal}  set variable  ${ru.id.internal}
        ${ru_id_configuration}  set variable  ${ru.id.configuration}
        ${ru_index}    get regexp matches    ${ru_id_configuration}    RMOD-(\\d+)    1
        ${dict}    Create Dictionary    ${ru_index}[0]    ${ru_id_internal}
        append to list   ${ru_list}    ${dict}
    END
    [Return]  ${ru_list}

All RU Locked and check status
    [Arguments]    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    ${ru_list}    Get All RU dictionary
    FOR    ${ru}     IN    @{ru_list}
        ${ru_id}    get_dictionary_keys       ${ru}
        ${ru_disname}    get_dictionary_values     ${ru}
        log to console    \n***RF ${ru_id}[0] Lock from GUI***
        coam.lock     dist_name=${ru_disname}[0]    connection=${connection}    timeout=120s
        wait until keyword succeeds  1min  30sec  RU Should Be Locked  ru_index=${ru_id}[0]    connection=${connection}
    END
    [Teardown]    run keyword and ignore error    coam.teardown    connection=${connection}

All RU UnLocked and check status
    [Arguments]    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    ${ru_list}    Get All RU dictionary
    FOR    ${ru}    IN    @{ru_list}
        ${ru_id}    get_dictionary_keys       ${ru}
        ${ru_disname}    get_dictionary_values     ${ru}
        log to console    \n***RF ${ru_id}[0] UnLock from GUI***
        coam.unlock      dist_name=${ru_disname}[0]    connection=${connection}    timeout=120s
        wait until keyword succeeds  5min  20sec  RU Should Be UnLocked  ru_index=${ru_id}[0]    connection=${connection}
    END
    [Teardown]    run keyword and ignore error    coam.teardown    connection=${connection}

Online Cell addition deletion
    [Documentation]  Online last Cell addition deletion via webem
    [Arguments]  ${addition_deletion_cell}=2   ${addition_deletion_cellgrp}=1    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    ${cell_grp}   Get All Cell Group Id
    ${cell_id}    Get All Cell Id
    ${cell_id_len}    get length    ${cell_id}
    ${cell_list}    Get Cell From Cell Group    cellgrp_id=${addition_deletion_cellgrp}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${OUTPUT_DIR}
    selenium login and disable screen lock
    log to console  delete object
    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${addition_deletion_cell}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${addition_deletion_cellgrp}    timeout=15
    ${cell_grp_len}    get length    ${cell_grp}
    FOR    ${index}    IN RANGE    ${cell_grp_len}
        ${value}    selenium_coam.get_parameter_value     dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
        run keyword if    '${value}'=='${addition_deletion_cellgrp}'    selenium_coam.remove_element
        ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${False}
    COAM Check GNB cell on air
    ${after_del_cell_id}    Get All Cell Id
    ${after_del_cell_id_len}    get length    ${after_del_cell_id}  
    ${cell_id_dif}    Evaluate   ${cell_id_len}-${after_del_cell_id_len}
    should be true    ${cell_id_dif}==1
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_path}
    get_planned_parameter_value    dist_name=MRBTS-${MRBTS_ID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    log to console  add object
    selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${addition_deletion_cellgrp}
    ...    include_subobject=${True}   id_value=${addition_deletion_cellgrp}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell}
    ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    object_class_name=NRCELL    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${addition_deletion_cell}
    ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${addition_deletion_cell}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${2}
    selenium_coam.add_element    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
    ...    abbr=refNrCellGroup    filter_param=Reference to cell group
    ...    timeout=15
    FOR  ${i}  IN  @{cell_grp}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    filter_param=Reference to cell group     new_value=${i}
        ...    node_index=${i}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${False}
    sleep    60s
    verify all cells should be onair
    ${cell_list_add}    Get Cell From Cell Group    cellgrp_id=${addition_deletion_cellgrp}
    lists should be equal     ${cell_list_add}    ${cell_list}
    [Teardown]     selenium logout and close browser

Connect to GNB
    [Arguments]    ${du_index}=${0}    ${alias}=ASIK Master    ${gnb_index}=${0}
    csn.Connect to    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${alias}

Start wireshark capture from gNB
    [Documentation]    Description: Start X2 log capture on gNB or Enb
    [Arguments]     ${filename}    ${interface}=any    ${index}=${0}    ${alias}=ASIK Master
    Connect to GNB   gnb_index=${index}    alias=${alias}
    ${log_name}    Set variable    ${filename}.pcap
    ${log_full_path_gnb}    join path    /tmp    ${log_name}
    csn.send command    command=ps -ef |grep tcpdump |grep -v grep |grep ${interface} |awk '{print $2}' |xargs kill -2    connection=${alias}
    sleep    2s
    csn.send command    command=nohup tcpdump sctp -i ${interface} -w ${log_full_path_gnb}     connection=${alias}
    sleep    2s
    Trace capturing process should be triggered    log_prefix=${log_name}    connection_alias=${alias}
    [Return]    ${alias}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}

Stop wireshark capture from gNB
    [Documentation]    Description: Stop X2 log capture on gNB or Enb, and download x2 log to testpc
    [Arguments]     ${filename}    ${logpath}=${OUTPUT_DIR}   ${index}=${0}    ${alias}=ASIK Master
    Connect to GNB       gnb_index=${index}    alias=${alias}
    Stop trace capturing    log_prefix=${filename}    connection_alias=${alias}
    ${log_full_path_ute}    set variable     ${logpath}/${filename}.pcap
    csn.download_file   remote_path=/tmp/${filename}.pcap   local_path=${log_full_path_ute}   connection=${alias}
    csn.execute    command=rm /tmp/${filename}.pcap    connection=${alias}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}

##Connect to TestPc
#    [Arguments]    ${hostname}=${enb_ip}    ${username}=${eNB_username}      ${password}=${eNB_password}   ${alias}=enb
#    csn.connect_to   hostname=${hostname}
#        ...    username=${username}    password=${password}    alias=${alias}

Convert pcap to text
    [Arguments]    ${source}    ${target}    ${filter}   ${connection}=ute
    csn.send_command
    ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
    csn.await execution end  connection=${connection}  timeout=30min
    sleep    5s

Check wireshark log data common
    [Arguments]    ${command}    ${pacp_filename}   ${txt_filename}    ${filter}    ${connection}=ute
    Connect to TestPc       alias=${connection}
    sleep    1s
    log to console    ${LOG_PATH}
    log to console    ${pacp_filename}
    Convert pcap to text   source=${OUTPUT_DIR}/${pacp_filename}.pcap
    ...  target=${OUTPUT_DIR}/${txt_filename}.txt   connection=${connection}    filter=${filter}
    csn.Send Command  command=cat ${OUTPUT_DIR}/${txt_filename}.txt |${command}    connection=${connection}
    ${data}    csn.Read Output    connection=${connection}
    ${data}    strip_string    ${data}
    [Return]   ${data}
    [Teardown]    run keyword and ignore error    csn.Disconnect  	connection=${connection}

Check wireshark log data should be empty
    [Arguments]    ${command}    ${pacp_filename}   ${txt_filename}    ${filter}    ${connection}=ute
    ${data}    Check wireshark log data common    command=${command}    pacp_filename=${pacp_filename}    connection=${connection}
    ...   txt_filename=${txt_filename}      filter=${filter}
    should be empty    ${data}
    log to console    data:${data}
    [Teardown]    run keyword and ignore error    csn.Disconnect	connection=${connection}

#Get nrCellIdentity form BTS by NRCELL id
#    [Arguments]     ${nrcell_id}=NRCELL-1
#    Connect to gnb coam via ssl    connection=GNB_OAM    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
#    ${subcells_info}    coam.get_subcells_info    connection=GNB_OAM
#    ${cell_group}    Get All Cell Group Id    connection=GNB_OAM
#    FOR  ${group_id}  IN  @{cell_group}
#        ${nrcell_list}    set variable    ${subcells_info['NRCELLGRP-${group_id}']}
#        ${nrcell_id_list}    get dictionary keys    ${nrcell_list}
#        ${cell_id}    set variable    ${nrcell_list['@{nrcell_id_list}[0]']['NRCELL_L']['parameters']['nrCellIdentity']}
#        EXIT FOR LOOP IF    '${nrcell_id}'=='@{nrcell_id_list}[0]'
#    END
#    [Return]     ${cell_id}
#    [Teardown]    Run keyword and ignore error     COAM Teardown gnb connections
#
#L3 Call
#    [Arguments]    ${nrcell_id}    ${ul_throughput}    ${dl_throughput}    ${expected_ul}    ${expected_dl}    ${time}
#    ${cellid}    Get nrCellIdentity form BTS by NRCELL id    nrcell_id=${nrcell_id}
#    attach power ue
#    start power ue traffic ul and dl      ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}
#    Check power ue Tput    ul_throughput=${expected_ul}    dl_throughput=${expected_dl}    time=${time}    cells=${cellid}
#    stop multi power ue traffic ul and dl
#    detach multi power ue
