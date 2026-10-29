*** Settings ***
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource            taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Library             ./hbtePositioner/positionerDemo.py
Library             ./CB007306_common.py
Library             ute_syslog
Library             taf.config.scf.interface.scf     WITH NAME   scf
Library             taf.hw.rf_attenuator        WITH NAME       att
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${CURDIR_path}            ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}
${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${DU_OAM_SSH_USERNAME}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${enb_ip}                 ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${eNB_username}           ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${eNB_password}           ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
${ul_power_port_list}     ${tl.ues[0].iperf_details.ports[0:3]}
${dl_power_port_list}     ${tl.ues[0].iperf_details.ports[3:6]}
${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
@{empty_list}
${testline_name}
${model}                     ${tl.attenuator.model}

*** Keywords ***
Setup Commission SCF
    [Arguments]     ${gnbnumber}     ${BTS_Host}=${gNB_ip}
     ${default_scf}    CB007306_common_keyword.Get BTS Version And Perare SCF
     ...    gNB_ip=${BTS_Host}   CURDIR_path=${CURDIR_path}    gnbnumber=${gnbnumber}
     Connect to gnb coam via ssl    bts_host=${BTS_Host}    username=${gNB_username}    password=${gNB_password}
     COAM Commission with scf file    scf_file_path=${default_scf}    timeout=1000
     Wait Until Keyword Succeeds   16min   2min     COAM Check GNB cell on air
     [Teardown]    Run keyword and ignore error     COAM Teardown gnb connections

Get BTS Version And Perare SCF
    [Arguments]   ${gnbnumber}    ${gNB_ip}=${gNB_ip}   ${CURDIR_path}=${CURDIR_path}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl     bts_host=${gNB_ip}
    ${version}    coam.get_sw_version    connection=${connection}
    ${scf_name}    CB007306_common.Covert_BTS_Version      gnbnumber=${gnbnumber}    version=${version}
    ${default_scf}    set variable    ${CURDIR_path}/${scf_name}
    log to console   ${default_scf}
    [Return]    ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Connect gnb and Check cell on air
    [Arguments]     ${BTS_Host}=${gNB_ip}
    Connect to gnb coam via ssl    bts_host=${BTS_Host}    username=${gNB_username}    password=${gNB_password}
    Wait Until Keyword Succeeds   16min   1min   COAM Check GNB cell on air
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Connect gnb and Reset Site
    [Arguments]     ${BTS_Host}=${gNB_ip}
    Connect to gnb coam via ssl    bts_host=${BTS_Host}    username=${gNB_username}    password=${gNB_password}
    coam.reset_site     connection=GNB_OAM
    Wait Until Keyword Succeeds   16min   1min   Connect gnb and Check cell on air
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Connect gnb and Check Unexpect Alarm
    [Arguments]     ${BTS_Host}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${BTS_Host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Wait Until Keyword Succeeds   5min   1min    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    file_path=${OUTPUT_DIR}    connection=${connection}
    Wait Until Keyword Succeeds   5min   1min    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=${ALLOWED_HISTORY_FAULT}        file_path=${OUTPUT_DIR}    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Connect to GNB
    [Arguments]    ${du_index}=${0}    ${alias}=ASIK Master    ${gnb_index}=${0}
    csn.Connect to    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${alias}

Connect to ENB
    [Arguments]       ${enb_index}=${0}   ${alias}=ASIK Master
    csn.Connect to    ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...               ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.username}
    ...               ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${alias}

Iptables UDP destination port ACCEPT
    [Arguments]    ${port1}=51001    ${port2}=50011   ${connection}=ute
    Connect to with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}    alias=${connection}
    csn.Send Command
    ...    command=sudo iptables -I INPUT -i eth0 -p udp --destination-port ${port1} -j ACCEPT
    ...    connection=${connection}
    csn.Send Command
    ...    command=sudo iptables -I INPUT -i eth0 -p udp --destination-port ${port2} -j ACCEPT
    ...    connection=${connection}
    [Teardown]       csn.Disconnect  	connection=${connection}

Adjust the HBTE attenuation value
    [Arguments]     ${value_1}=${0}    ${value_2}=${127}    ${att_port1}=${att_port_5}
    ...    ${att_port2}=${att_port_6}    ${att_port3}=${att_port_7}    ${att_port4}=${att_port_8}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}
    ...    max_attenuation=${127}    vendor=HBTE
    ...    model=${model}
    ${port_list}     Create list      ${0}    ${1}    ${2}    ${3}
    ${port_num}    Get Length   ${port_list}
    FOR    ${i}    IN RANGE    ${port_num}
        att.set_attenuation     port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list[${i}]}].port_no}    value=${value_1}
        ${value_port}    att.read_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list[${i}]}].port_no}
        should be equal    ${value_port}    ${value_1}
    END
    ${port_list1}     Create list    ${4}   ${5}    ${6}    ${7}    ${8}    ${10}
    ${port_num1}    Get Length   ${port_list1}
    FOR    ${i}    IN RANGE    ${port_num1}
        att.set_attenuation     port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list1[${i}]}].port_no}    value=${value_2}
        ${value_port}    att.read_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list1[${i}]}].port_no}
        should be equal    ${value_port}    ${value_2}
    END
    robot_common_operations.Common case Setup

Adjust the HBTE attenuation value Common
    [Arguments]    ${port_index}=${0}    ${value}=${0}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}
    ...    max_attenuation=${127}    vendor=HBTE
    ...    model=${model}
    att.set_attenuation     port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_index}].port_no}    value=${value}
    ${value_port}    att.read_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_index}].port_no}
    should be equal    ${value_port}    ${value}

Set X and Y PositionMotion
    [Arguments]   ${ip}     ${if_X}=${True}    ${if_Y}=${True}      ${exceed}=${180}
    ...    ${start_X}=${0}     ${end_X}=${0}     ${speed_X}=${5}    ${loopCount_X}=${1}
    ...    ${start_Y}=${0}     ${end_Y}=${0}     ${speed_Y}=${5}    ${loopCount_Y}=${1}
    Run keyword if     ${if_X}     positionerDemo.setXPositionMotion     ip=${ip}      start=${start_X}
    ...     end=${end_X}    speed=${speed_X}    loopCount=${loopCount_X}    exceed=${exceed}
    Run keyword if     ${if_Y}     positionerDemo.setYPositionMotion     ip=${ip}      start=${start_Y}
    ...     end=${end_Y}    speed=${speed_Y}    loopCount=${loopCount_Y}    exceed=${exceed}

Get length and Check sum counter value
    [Arguments]     ${list_input}     ${except_value}=2
    ${length}      Get Length       ${list_input}
    ${counter_value_sum}       Set Variable          0
    FOR   ${i}    IN RANGE    ${0}    ${length}     1
        ${counter_value_sum}     Evaluate    ${counter_value_sum}+${list_input}[${i}]
    END
    run keyword and continue on failure     should be true    ${counter_value_sum}==${except_value}

Get sum counter value
    [Arguments]     ${list_input}
    ${length}      Get Length       ${list_input}
    ${counter_value_sum}       Set Variable          0
    FOR   ${i}    IN RANGE    ${0}    ${length}     1
        ${counter_value_sum}     Evaluate    ${counter_value_sum}+${list_input}[${i}]
    END
    [Return]   ${counter_value_sum}

Check counter value
    [Arguments]     ${list_input}
    ${length}      Get Length       ${list_input}
    FOR   ${i}    IN RANGE    ${0}    ${length}     1
        Run keyword if     ${list_input}[${i}]!=${0}      should be true     ${list_input}[${i}]==${1}
    END
    run keyword and continue on failure    list should contain value    ${list_input}    ${1}


Modify Common parameter via Coam
    [Arguments]  ${input_list}    ${gNB_ip}    ${connection}=GNB_connection    ${sleep_time}=30s
    log to console    Modify parameter
    Connect to gnb coam via ssl     bts_host=${gNB_ip}      connection=${connection}
    FOR    ${item}  IN    @{input_list}
        ${dict_value}    CB007306_common_keyword.Get Content From Input Dict    input_dict=${item}
        coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]   value=${dict_value}[2]
        ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
    END
    log to console  change parameter successful,sleep ${sleep_time}
    sleep  ${sleep_time}
    [Teardown]    run keyword and ignore error    coam.teardown    connection=${connection}

Modify Structure parameter via Coam
    [Arguments]   ${class_name}   ${connection}   ${modify_list}   ${keywords_list}    ${index}=0
    ${get_managed_objects}     coam.get_managed_objects     class_name=${class_name}    connection=${connection}
    ${output_dict_list}    return_structure_value    input_list=${get_managed_objects}    modify_list=${modify_list}
    ...    keywords_list=${keywords_list}
    FOR    ${item}  IN  @{output_dict_list}
         ${dict_value}    CB007306_common_keyword.Get Content From Input Dict    input_dict=${item}
         coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]   value=${dict_value}[2]
         ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
         sleep  30s
    END

Get Content From Input Dict
    [Arguments]  ${input_dict}
    ${dist_name}    get from dictionary     ${input_dict}    dist_name
    ${parammeter}    get from dictionary    ${input_dict}    parameter
    ${new_value}     get from dictionary    ${input_dict}    value
    ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
    [Return]  ${value_list}

Connect to with ssh
    [Arguments]    ${hostname}=${gnb_ip}    ${username}=${eNB_username}      ${password}=${eNB_password}   ${alias}=gnb
    csn.connect_to   hostname=${hostname}
        ...    username=${username}    password=${password}    alias=${alias}

Start wireshark capture from gNB or Enb
    [Documentation]    Description: Start X2 log capture on gNB or Enb
    [Arguments]     ${filename}    ${if_gnb}=${True}    ${interface}=any    ${index}=${0}    ${alias}=ASIK Master
    Run keyword if    ${if_gnb}     Connect to GNB   gnb_index=${index}    alias=${alias}
    ...    ELSE    CB007306_common_keyword.Connect to ENB     enb_index=${index}    alias=${alias}
    ${log_name}    Set variable    ${filename}.pcap
    ${log_full_path_gnb}    join path    /tmp    ${log_name}
    csn.send command    command=ps -ef |grep tcpdump |grep -v grep |grep ${interface} |awk '{print $2}' |xargs kill -2    connection=${alias}
    sleep    2s
    csn.send command    command=nohup tcpdump sctp -i ${interface} -w ${log_full_path_gnb}     connection=${alias}
    sleep    2s
    Trace capturing process should be triggered    log_prefix=${log_name}    connection_alias=${alias}
    [Return]    ${alias}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}

Stop wireshark capture from gNB or Enb
    [Documentation]    Description: Stop X2 log capture on gNB or Enb, and download x2 log to testpc
    [Arguments]     ${filename}    ${logpath}=${OUTPUT_DIR}/${TEST NAME}    ${index}=${0}    ${alias}=ASIK Master    ${if_gnb}=${True}
    Run keyword if    ${if_gnb}    Connect to GNB       gnb_index=${index}    alias=${alias}
    ...    ELSE    CB007306_common_keyword.Connect to ENB     enb_index=${index}    alias=${alias}
    Stop trace capturing    log_prefix=${filename}    connection_alias=${alias}
    ${log_full_path_ute}    set variable     ${logpath}/${filename}.pcap
    csn.download_file   remote_path=/tmp/${filename}.pcap   local_path=${log_full_path_ute}   connection=${alias}
    csn.execute    command=rm /tmp/${filename}.pcap    connection=${alias}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}

start btslog capture on ute
    [Arguments]    ${log_dir}=${OUTPUT_DIR}/${TEST NAME}    ${connection}=ute    ${btslog_name}=btslog.log
    csn.Connect to     hostname=${TEST_PC_IP}     username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    log to console    start syslog...
    ute_syslog.Start Syslog    log_dir=${log_dir}      log_name=${btslog_name}
    ...      host_ip=${TEST_PC_IP}    ssh_username=${TEST_PC_USERNAME}    ssh_password=${TEST_PC_PASSWORD}    alias=${connection}
    ...      virtualenv_dir=/home/ute/CIENV/${testline_name}

Check wireshark log Parameter
    [Arguments]     ${txt_filename}     ${sgnb_chg_ho_message}      ${logpath}=${OUTPUT_DIR}/${TEST NAME}
    ${val_result}    CB007306_common.Check_Wireshark_Parameter_From_Txt    txt_file_path=${logpath}/${txt_filename}
    ...    parameters=${sgnb_chg_ho_message}
    ${val_list}     set variable    ${val_result}[resultList]
    FOR    ${val1}    IN    @{val_list}
        Run Keyword And Continue On Failure    should be equal    ${val1}    ${True}
    END

Check wireshark log data Flow message
    [Arguments]    ${sgnb_chg_flow_message}   ${txt_filename}     ${logpath}=${OUTPUT_DIR}/${TEST NAME}
    ${val_result}    Check Wireshark Message Flow From Txt    txt_file_path=${logpath}/${txt_filename}    message_dict=${sgnb_chg_flow_message}
    Run Keyword And Continue On Failure    should be equal    ${val_result}    ${True}

Convert pcap to text
    [Arguments]    ${pacp_filename}   ${txt_filename}    ${filter}    ${connection}=ute    ${logpath}=${OUTPUT_DIR}/${TEST NAME}
    ${source}      set variable     ${logpath}/${pacp_filename}
    ${target}      set variable     ${logpath}/${txt_filename}
    Connect to with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}    alias=${connection}
    sleep    1s
    csn.send_command
    ...  command=nice tshark -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
#    ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
    csn.await execution end  connection=${connection}  timeout=30min
    [Teardown]       csn.Disconnect  	connection=${connection}

Check wireshark log data not contain message
    [Arguments]     ${txt_filename}   ${command}    ${connection}=ute    ${logpath}=${OUTPUT_DIR}/${TEST NAME}
    Connect to with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}    alias=${connection}
    csn.Send Command    command=cat ${logpath}/${txt_filename} |${command}     connection=${connection}
    ${data}    csn.Read Output    connection=${connection}
    ${data}    strip_string    ${data}
    Run Keyword And Continue On Failure     should be empty    ${data}
    log to console    data:${data}
    [Teardown]       csn.Disconnect  	connection=${connection}

Check wireshark log data contain message
    [Arguments]    ${message}     ${txt_filename}    ${connection}=ute     ${logpath}=${OUTPUT_DIR}/${TEST NAME}
    csn.Send Command  command=cat ${logpath}/${txt_filename} | grep ${message}    connection=${connection}
    ${data}    csn.Read Output    connection=${connection}
    ${data}    strip_string    ${data}
    run keyword and continue on failure     should not be empty    ${data}
    log to console    data:${data}

Wait for counter to be gathered after guard peroid
   [Arguments]  ${interval}=5
   ${list1}=    Create List         00  15  30  45
   ${list2}=    Create List         00  05  10  15  20  25  30  35  40  45  50  55
   ${list}=    Set Variable IF     '${interval}' == '5'    ${list2}    ${list1}
   ${actualTime}=     DateTime.Get Current Date    result_format=%M
   ...                                    time_zone=UTC
   ${time_check}    run keyword and return status   List Should Contain Value    ${list}    ${actualTime}
   run keyword if    ${time_check}   Sleep   ${interval} minutes
   PM Wait To Nearest Measurement Period    interval=${interval}

PM Wait To Nearest Measurement Period
   Log    PM Wait To Nearest Measurement Period    console=yes
   [Arguments]  ${interval}
   Wait Until Keyword Succeeds                     16 min
   ...                                            1 min
   ...                                             Wait For Right Period    interval=${interval}
   Sleep                                           60

Wait For Right Period
   [Arguments]  ${interval}
   ${list1}=           Create List         00  15  30  45
   ${list2}=           Create List         00  05  10  15  20  25  30  35  40  45  50  55
   ${list}=            Set Variable IF     '${interval}' == '5'    ${list2}    ${list1}
   ${actualTime}=     DateTime.Get Current Date    result_format=%M
   ...                                    time_zone=UTC
   ...                                    increment=8 hours
   ${actualHour}=     DateTime.Get Current Date    result_format=%H
   ...                                    time_zone=UTC
    ...                                    increment=8 hours
   ${date}=     DateTime.Get Current Date    result_format=%Y-%m-%d
   ...                                    time_zone=UTC
   ...                                    increment=8 hours
    ${date_nodash}=    DateTime.Get Current Date    result_format=%Y%m%d
   ...                                    time_zone=UTC
   ${actualEpoch}=    DateTime.Convert Date	       ${date} ${actualHour}:${actualTime}:00.000	epoch
   List Should Contain Value	           ${list}  ${actualTime}
   Log                                    ${actualTime}
   ${string_epoch}=   Convert To String   ${actualEpoch}
   ${nopoint_epoch}=   fetch from left   ${string_epoch}   .
   ${integer_epoch}=   convert to integer  ${nopoint_epoch}
   ${epoch_minus_interval}=   Evaluate   ${integer_epoch}-15*60
   ${epoch_minus_interval_string}=   Convert To String   ${epoch_minus_interval}
   set test variable    ${epoch_minus_interval_string}

Check PM counter result
    [Arguments]    ${counter_id}    ${index}=${0}    ${BTS}=BTS    ${CELLS}=CELLS
    ...    ${NRCELL}=NRCELL-1    ${counter_object}=NX2CC    ${connection}=GNB_OAM    ${timeout}=600s
    ${btsip}    Set Variable     ${tl.gnbs[${index}].dus[0].f1_m_ip_addr}
    Connect to gnb coam via ssl    bts_host=${btsip}    connection=${connection}
    ${counter_values}=    coam.get pm counters    counter_ids=${counter_id}    connection=${connection}   timeout=${timeout}
    ${is_large_24R1_release}    Check Release Larged Than Given    release=24R1    gnb_index=${index}
    ${MR_BTS}    set variable    MRBTS-${tl.gnbs[${index}].instance_id}
    ${NR_BTS}    set variable    NRBTS-${tl.gnbs[${index}].global_bts_id}
    ${result}    run keyword if    ${is_large_24R1_release}
    ...    Get Dictionary Values   ${counter_values['${BTS}']['${MR_BTS}']['${NR_BTS}']['${NRCELL}']['${counter_object}']['${counter_id}']}
    ...    ELSE    Get Dictionary Values   ${counter_values['${BTS}']['${CELLS}']['${NRCELL}']['${counter_object}']['${counter_id}']}
    [Return]    ${result}
    [Teardown]      COAM Teardown gnb connections   connection=${connection}

Check Release Larged Than Given
    [Arguments]    ${release}=24R1    ${gnb_index}=${0}    ${connection}=GNB_OAM2
    ${Y_given_string}=    Get SubString    ${release}    0    2
    ${R_given_string}=    Get SubString    ${release}    3    4
    ${Y_given}    Evaluate    int(${Y_given_string})
    ${R_given}    Evaluate    int(${R_given_string})
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${software}    coam.get_software_info    connection=${connection}
    ${activate_version}    Set Variable    ${software}[Active SW version]
    ${Y_active_string}=    Get SubString    ${activate_version}    4    6
    ${R_active_string}=    Get SubString    ${activate_version}    7    8
    ${Y_active}    Evaluate    int(${Y_active_string})
    ${R_active}    Evaluate    int(${R_active_string})
    ${Is_large}    Set variable if    ${Y_active}>${Y_given}    ${True}
    ...    ${Y_active}==${Y_given} and ${R_active}>${R_given}    ${True}    ${False}
    [Return]    ${Is_large}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections  connection=${connection}

check measid
    [Arguments]     ${txt_filename}    ${expect}    ${measConfigDic}    ${logpath}=${OUTPUT_DIR}/${TEST NAME}
    ...    ${para1}=report    ${para2}=eventId    ${mr_n}=1    ${mc_n}=1
    log to console      find measID form the ${mr_n} time meassurement report...
    ${expected_dic}     create Dictionary       measId=${Empty}
    ${measid_dic_1}    create Dictionary    xpath=measurementReport/measResults     expected_value=${expected_dic}      n=${mr_n}
    ${measid_list}     create List    ${measid_dic_1}
    ${val}     Check Wireshark Parameter From Txt        txt_file_path=${logpath}/${txt_filename}    parameters=${measid_list}

    ${val_list}     set variable    ${val}[resultSearch]
    ${val_dic}      set variable    ${val_list}[0]
    ${actual_value}    set variable     ${val_dic}[actual_value]
    log to console
    ...    find measID: ${actual_value}[measId] from the ${mr_n} time meassurement report, will check the ${mc_n} time measConfig.
    ${event}    Get MeasConfig Value From Dictionary     n=${mc_n}     measid=${actual_value}[measId]      para1=${para1}
    ...         para2=${para2}   measConfigDic=${measConfigDic}
    should be equal     ${expect}      ${event}

attach multi power ue
    [Arguments]    ${ue_num}   ${gnb_index}=${0}
    log to console       Prepare UE
    FOR    ${item}    IN RANGE    ${ue_num}
        power_ue.Prepare UE    ue_index=${item}    ue_type=samsung
        ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${item}    ue_type=samsung    log_type=Aasyslog
        power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False    gnb_index=${gnb_index}
    END

start multi power ue traffic ul and dl
    [Arguments]    ${ue_num}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000
    ...    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console      Start traffic    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
        run keyword and continue on failure    run keyword if     ${if_ul}    power_ue.Start traffic    ue_index=${item}    direction=ul
        ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=samsung    iperf_type=via_command    protocol=${protocol}
        ...    iperf_port=${ul_power_port_list}[${item}]
        sleep    1s
        run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Start traffic    ue_index=${item}    direction=dl
        ...    throughput=${dl_throughput}    duration=${dl_duration}    ue_type=samsung    protocol=${protocol}
        ...    iperf_port=${dl_power_port_list}[${item}]
    END


stop multi power ue traffic ul and dl
    [Arguments]    ${ue_num}    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console     Stop traffic    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
        run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=samsung    iperf_type=${protocol}
        ...    protocol=${protocol}    iperf_port=${ul_power_port_list}[${item}]
        run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${item}    ue_type=samsung    protocol=${protocol}
        ...    iperf_port=${dl_power_port_list}[${item}]
    END

detach multi power ue
    [Arguments]    ${ue_num}=${4}
    log to console      UE Detach    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
         power_ue.UE Detach    ue_index=${item}    ue_type=samsung
    END

Get nrcellid with the lcrid
    [Arguments]      ${cell_group_index}=${0}  ${bts_host}=${gNB_ip}    ${username}=${gNB_username}    ${password}=${gNB_password}
    Connect to gnb coam via ssl    connection=GNB_OAM    bts_host=${bts_host}    username=${username}    password=${password}
    ${cell_info}   coam.get_subcells_info   timeout=20    connection=GNB_OAM
    ${cell_from_cellgrp}    Get from Dictionary    ${cell_info}    NRCELLGRP-${cell_group_index}
    ${cell_list}    Get Dictionary Keys    ${cell_from_cellgrp}
    ${nrCellIdentity_list}     create list
    FOR  ${cell}   IN    @{cell_list}
        ${eachcell}    Get from Dictionary    ${cell_from_cellgrp}    ${cell}
        ${nrCellIdentity}    set variable    ${eachcell['NRCELL_L']['parameters']['nrCellIdentity']}
        ${nrCellIdentity}    Convert To String    ${nrCellIdentity}
        append to list      ${nrCellIdentity_list}   ${nrCellIdentity}
    END
    [Return]    ${nrCellIdentity_list}
    [Teardown]    COAM Teardown gnb connections

get total tput
    [Arguments]    ${tput_result}    ${TP_Type}
    ${sum_TP}    set variable    ${0}
    FOR    ${item}    IN    @{tput_result}
        ${TP}    get from dictionary    ${item}    ${TP_Type}
        ${sum_TP}     evaluate    ${sum_TP}+${TP}
    END
    [Return]    ${sum_TP}

Change LTE DefaultLnRelGnbCellId and Return UL and DL Tput
    [Arguments]     ${MODIFY_Parameter}    ${attached_pci}   ${filename}=tcpdump_attach    ${enb}=${enb_ip}    ${gnb}=${gNB_ip}
    ...    ${ul_throughput}=300M    ${dl_throughput}=2048M    ${connection}=GNB_OAM    ${cell_group_index}=${0}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${ENB_MODIFY_Parameter}     gNB_ip=${enb}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${MODIFY_Parameter}     gNB_ip=${enb}
    Connect gnb and Check cell on air    BTS_Host=${gnb}
    Connect gnb and Check cell on air    BTS_Host=${enb_ip}
    ${cell_id}    Get nrcellid with the lcrid   bts_host=${gnb}   cell_group_index=${cell_group_index}
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    power_ue.Prepare UE    ue_index=${0}    ue_type=samsung
    Start wireshark capture from gNB or Enb      filename=${filename}    alias=gnb
    ${attach_status}    Run keyword and return status    CB007306_common_keyword.attach multi power ue    ue_num=${1}
    Stop wireshark capture from gNB or Enb       filename=${filename}    alias=gnb    logpath=${OUTPUT_DIR}/${TEST NAME}
    should be true    ${attach_status}    ${True}
    CB007306_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}
     ...     ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}      protocol=udp
    sleep    5s
    ${log_path}    power_ue.Collect Tput    ue_type=samsung    duration=10s    ignore_time=2s
    ${dl_tput_result}    aastp.get_aasyslog_throughput    direction=dl    log=${log_path}
    ...    cells=${cell_id}    actCarrierAggregation=${False}
    ${ul_tput_result}    aastp.get_aasyslog_throughput    direction=ul    log=${log_path}
    ...    cells=${cell_id}    actCarrierAggregation=${False}
    ${dl_average_TP}    get total tput    tput_result=${dl_tput_result}[0]     TP_Type=average
    ${ul_average_TP}    get total tput    tput_result=${ul_tput_result}[0]     TP_Type=average
    CB007306_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}
    CB007306_common_keyword.Convert pcap to text     pacp_filename=${filename}.pcap
        ...    txt_filename=${filename}.txt    filter=${filter}
    ${attach_pci}    Run keyword and return status     Check wireshark log Parameter
    ...    sgnb_chg_ho_message=${attached_pci}    txt_filename=${filename}.txt
    should be true     ${attach_pci}    ${True}
    should be true    ${dl_average_TP}>0
    should be true    ${ul_average_TP}>0
    [Return]     ${dl_average_TP}     ${ul_average_TP}
    [Teardown]    run keywords    CB007306_common_keyword.detach multi power ue     ue_num=${1}
    ...   AND    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${ENB_Reconver_Parameter}     gNB_ip=${enb_ip}

Check Btslog Thoughput
    [Arguments]    ${btslog_name}    ${ip_list}=${gNB_ip}    ${if_ul}=${True}    ${if_dl}=${True}    ${btslog_path}=${OUTPUT_DIR}/${TEST NAME}
    ${DLtputDataDic}  ${ULtputDataDic}    get_tput_in_syslog      syslog_path=${btslog_path}/${btslog_name}      iplist=${ip_list}
    ${dl_status}     Run keyword if     ${if_dl}    CB007306_common.check_ho_bts_tput     tputDataDic=${DLtputDataDic}
    ${ul_status}     Run keyword if     ${if_ul}    CB007306_common.check_ho_bts_tput     tputDataDic=${ULtputDataDic}
    Run keyword if     ${if_dl}       should be true    ${dl_status}    ${True}
    Run keyword if     ${if_ul}     should be true    ${ul_status}    ${True}

Start tcpdump log attach UE for 573
    [Arguments]    ${NUM}
    power_ue.Prepare UE    ue_index=${0}    ue_type=samsung
    CB007306_common_keyword.detach multi power ue     ue_num=${1}
    Start wireshark capture from gNB or Enb      filename=tcpdump_attach_573_${NUM}    alias=gnb
    log to console    start attach...
    ${attach_status}    Run keyword and return status    CB007306_common_keyword.attach multi power ue    ue_num=${1}
    Stop wireshark capture from gNB or Enb       filename=tcpdump_attach_573_${NUM}    alias=gnb    logpath=${OUTPUT_DIR}/${TEST NAME}
    should be true    ${attach_status}    ${True}

Start tcpdump and send DL or UL traffic for 573
     [Arguments]   ${NUM}   ${if_ul}=${True}    ${if_dl}=${True}   ${ul_throughput}=300M    ${dl_throughput}=2048M
     Start tcpdump log attach UE for 573    NUM=${NUM}
     CB007306_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}   if_ul=${if_ul}    if_dl=${if_dl}
     ...     ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}      protocol=udp
     start btslog capture on ute     btslog_name=btslog_573_${NUM}.log    log_dir=${OUTPUT_DIR}/${TEST NAME}
     Start wireshark capture from gNB or Enb      filename=573_ho_50_80_${NUM}    alias=gnb2
     sleep     3s
     Set X and Y PositionMotion    ip=${PositionMotion_ip1}     if_Y=${False}   start_X=${0}     end_X=${90}
     Set X and Y PositionMotion    ip=${PositionMotion_ip2}     if_X=${False}   start_Y=${90}     end_Y=${180}
     sleep     2s
     Stop wireshark capture from gNB or Enb       filename=573_ho_50_80_${NUM}     alias=gnb2
     CB007306_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${if_ul}    if_dl=${if_dl}
     sleep     5s
     CB007306_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}   if_ul=${if_ul}    if_dl=${if_dl}
     ...      ul_throughput=10M      dl_throughput=10M     protocol=udp
     Start wireshark capture from gNB or Enb      filename=573_ho_80_50_${NUM}    alias=gnb3
     Set X and Y PositionMotion    ip=${PositionMotion_ip2}     if_X=${False}   start_Y=${180}     end_Y=${90}
     Set X and Y PositionMotion    ip=${PositionMotion_ip1}     if_Y=${False}   start_X=${90}      end_X=${0}
     sleep     5s
     Stop wireshark capture from gNB or Enb          filename=573_ho_80_50_${NUM}     alias=gnb3
     CB007306_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${if_ul}    if_dl=${if_dl}
     stop syslog     alias=ute
     [Teardown]    CB007306_common_keyword.detach multi power ue     ue_num=${1}


Start tcpdump log attach UE and send DL traffic for 710_008
    [Arguments]     ${if_ul}=${False}    ${if_dl}=${True}    ${ul_throughput}=300M    ${dl_throughput}=1000M
    power_ue.Prepare UE    ue_index=${0}    ue_type=samsung
    CB007306_common_keyword.detach multi power ue     ue_num=${1}
    Start wireshark capture from gNB or Enb      filename=tcpdump_710_008    alias=gnb
    log to console    start attach...
    ${attach_status}    Run keyword and return status    CB007306_common_keyword.attach multi power ue    ue_num=${1}
    should be true    ${attach_status}    ${True}
    CB007306_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}   if_ul=${if_ul}    if_dl=${if_dl}
    ...    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}     protocol=udp
    start btslog capture on ute     btslog_name=btslog_710_008.log    log_dir=${OUTPUT_DIR}/${TEST NAME}
    Set X and Y PositionMotion    ip=${PositionMotion_ip2}     if_X=${False}   start_Y=${160}     end_Y=${90}
    sleep     5s
    Stop wireshark capture from gNB or Enb       filename=tcpdump_710_008     alias=gnb
    stop syslog     alias=ute
    CB007306_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${if_ul}    if_dl=${if_dl}
    power_ue.UE Detach    ue_index=${0}    ue_type=samsung
    [Teardown]    Run keyword if     ${attach_status}==${False}     Stop wireshark capture from gNB or Enb
    ...    filename=tcpdump_710_008   alias=gnb

Start tcpdump log attach UE and send DL traffic for 710_011
    [Arguments]     ${if_ul}=${False}    ${if_dl}=${True}    ${ul_throughput}=300M    ${dl_throughput}=1000M
    power_ue.Prepare UE    ue_index=${0}    ue_type=samsung
    CB007306_common_keyword.detach multi power ue     ue_num=${1}
    Start wireshark capture from gNB or Enb      filename=tcpdump_710_011    alias=gnb
    log to console    start attach...
    ${attach_status}    Run keyword and return status    CB007306_common_keyword.attach multi power ue    ue_num=${1}
    should be true    ${attach_status}    ${True}
    CB007306_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}   if_ul=${if_ul}    if_dl=${if_dl}
    ...    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}     protocol=udp
    Delete NRMOPRMA_NSA-2 AND NRMOPR_NSA-2     bts_host=${gNB_ip}
    Connect gnb and Check cell on air     BTS_Host=${gNB_ip}
    start btslog capture on ute     btslog_name=btslog_710_011.log     log_dir=${OUTPUT_DIR}/${TEST NAME}
    sleep     3s
    Set X and Y PositionMotion    ip=${PositionMotion_ip2}     if_X=${False}   start_Y=${90}     end_Y=${160}
    sleep     5s
    Stop wireshark capture from gNB or Enb       filename=tcpdump_710_011     alias=gnb
    stop syslog     alias=ute
    CB007306_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${if_ul}    if_dl=${if_dl}
    CB007306_common_keyword.detach multi power ue     ue_num=${1}
    [Teardown]    Run keyword if     ${attach_status}==${False}     Stop wireshark capture from gNB or Enb
    ...    filename=tcpdump_710_011   alias=gnb

Start tcpdump log attach UE and send DL traffic for 1094
    [Arguments]     ${if_ul}=${False}    ${if_dl}=${True}    ${ul_throughput}=300M    ${dl_throughput}=1000M
    power_ue.Prepare UE    ue_index=${0}    ue_type=samsung
    CB007306_common_keyword.detach multi power ue     ue_num=${1}
    Start wireshark capture from gNB or Enb      filename=tcpdump_1094    alias=gnb
    log to console    start attach...
    ${attach_status}    Run keyword and return status    CB007306_common_keyword.attach multi power ue    ue_num=${1}
    should be true    ${attach_status}    ${True}
    CB007306_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}   if_ul=${if_ul}    if_dl=${if_dl}
    ...    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}     protocol=udp
    start btslog capture on ute     btslog_name=btslog_1094.log     log_dir=${OUTPUT_DIR}/${TEST NAME}
    sleep     3s
    Set X and Y PositionMotion    ip=${PositionMotion_ip1}     if_X=${False}   start_Y=${0}      end_Y=${90}
    Set X and Y PositionMotion    ip=${PositionMotion_ip2}     if_X=${False}   start_Y=${90}     end_Y=${160}
    sleep     5s
    Stop wireshark capture from gNB or Enb       filename=tcpdump_1094     alias=gnb
    stop syslog     alias=ute
    CB007306_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${if_ul}    if_dl=${if_dl}
    CB007306_common_keyword.detach multi power ue     ue_num=${1}
    [Teardown]    Run keyword if     ${attach_status}==${False}     Stop wireshark capture from gNB or Enb
    ...    filename=tcpdump_1094   alias=gnb

Start tcpdump log attach UE for 1416
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${ENB_control_GNB1_lock}      gNB_ip=${gNB_ip}
    Connect gnb and Check cell on air     BTS_Host=${gNB_ip}
    Start wireshark capture from gNB or Enb      filename=tcpdump_1416    alias=gnb
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${ENB_control_GNB1_unlock}      gNB_ip=${gNB_ip}
    Connect gnb and Check cell on air     BTS_Host=${gNB_ip}
    Stop wireshark capture from gNB or Enb       filename=tcpdump_1416     alias=gnb
    Start wireshark capture from gNB or Enb      filename=tcpdump_attach_1416    alias=gnb
    log to console    start attach...
    ${attach_status}    Run keyword and return status    CB007306_common_keyword.attach multi power ue    ue_num=${1}
    should be true    ${attach_status}    ${True}
    Stop wireshark capture from gNB or Enb       filename=tcpdump_attach_1416     alias=gnb
    CB007306_common_keyword.detach multi power ue     ue_num=${1}
    [Teardown]    Run keyword if     ${attach_status}==${False}     Stop wireshark capture from gNB or Enb
    ...    filename=tcpdump_attach_1416   alias=gn

Start tcpdump log attach UE for 7564 001
    ${ip_list}    Create list     ${gNB_ip}
    power_ue.Prepare UE    ue_index=${0}    ue_type=samsung
    CB007306_common_keyword.detach multi power ue     ue_num=${1}
    FOR    ${index}    IN RANGE    0    2
        Start wireshark capture from gNB or Enb      filename=tcpdump_7564_001_${index}    alias=gnb
        ${attach_status}    Run keyword and return status    CB007306_common_keyword.attach multi power ue    ue_num=${1}
        Run keyword if     ${attach_status}==${False}    Stop wireshark capture from gNB or Enb
        ...    filename=tcpdump_7564_001_${index}   alias=gnb    logpath=${OUTPUT_DIR}/${TEST NAME}
        should be true    ${attach_status}    ${True}
        CB007306_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}   if_ul=${False}    if_dl=${True}    dl_throughput=1000M
        sleep    10s
        Stop wireshark capture from gNB or Enb       filename=tcpdump_7564_001_${index}     alias=gnb
        CB007306_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${False}    if_dl=${True}
        CB007306_common_keyword.detach multi power ue     ue_num=${1}
        Read Wireshark Log for 7564 001    tcpdump_log=tcpdump_7564_001_${index}.pcap    txt_filename=tcpdump_7564_001_${index}.txt
    END

Start tcpdump log attach UE for 7564 002
    ${ip_list}    Create list     ${gNB_ip}    ${gNB2_ip}
    power_ue.Prepare UE    ue_index=${0}    ue_type=samsung
    CB007306_common_keyword.detach multi power ue     ue_num=${1}
    FOR    ${index}    IN RANGE    0    2
        Start wireshark capture from gNB or Enb      filename=tcpdump_7564_002_${index}    alias=gnb
        ${attach_status}    Run keyword and return status    CB007306_common_keyword.attach multi power ue    ue_num=${1}
        Run keyword if     ${attach_status}==${False}    Stop wireshark capture from gNB or Enb
        ...    filename=tcpdump_7564_002_${index}   alias=gnb    logpath=${OUTPUT_DIR}/${TEST NAME}
        should be true    ${attach_status}    ${True}
        Set X and Y PositionMotion    ip=${PositionMotion_ip1}     if_Y=${False}   start_X=${0}     end_X=${90}
        Set X and Y PositionMotion    ip=${PositionMotion_ip2}     if_X=${False}   start_Y=${90}     end_Y=${180}
        sleep     5s
        Set X and Y PositionMotion    ip=${PositionMotion_ip2}     if_X=${False}   start_Y=${180}     end_Y=${90}
        Set X and Y PositionMotion    ip=${PositionMotion_ip1}     if_Y=${False}   start_X=${90}      end_X=${0}
        sleep    5s
        Stop wireshark capture from gNB or Enb       filename=tcpdump_7564_002_${index}     alias=gnb     logpath=${OUTPUT_DIR}/${TEST NAME}
        CB007306_common_keyword.detach multi power ue     ue_num=${1}
        Read Wireshark Log for 7564 002    tcpdump_log=tcpdump_7564_002_${index}.pcap     txt_filename=tcpdump_7564_002_${index}.txt
    END

Start tcpdump log attach UE for 7564 003
    power_ue.Prepare UE    ue_index=${0}    ue_type=samsung
    CB007306_common_keyword.detach multi power ue     ue_num=${1}
    ${ip_list}    Create list     ${gNB_ip}
    FOR    ${index}    IN RANGE    0    2
        Start wireshark capture from gNB or Enb      filename=tcpdump_7564_003_${index}    alias=gnb
        ${attach_status}    Run keyword and return status    CB007306_common_keyword.attach multi power ue    ue_num=${1}
        Run keyword if     ${attach_status}==${False}    Stop wireshark capture from gNB or Enb
        ...    filename=tcpdump_7564_003_${index}   alias=gnb    logpath=${OUTPUT_DIR}/${TEST NAME}
        should be true    ${attach_status}    ${True}
        CB007306_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}   if_ul=${False}    if_dl=${True}    dl_throughput=1000M
        sleep    10s
        Stop wireshark capture from gNB or Enb       filename=tcpdump_7564_003_${index}     alias=gnb     logpath=${OUTPUT_DIR}/${TEST NAME}
        CB007306_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${False}    if_dl=${True}
        CB007306_common_keyword.detach multi power ue     ue_num=${1}
        Read Wireshark Log for 7564 003    tcpdump_log=tcpdump_7564_003_${index}.pcap    txt_filename=tcpdump_7564_003_${index}
    END
    [Teardown]      Stop syslog    alias=ute

Start tcpdump log attach UE for 7564 004
    ${ip_list}    Create list     ${gNB_ip}    ${gNB2_ip}
    power_ue.Prepare UE    ue_index=${0}    ue_type=samsung
    CB007306_common_keyword.detach multi power ue     ue_num=${1}
    FOR    ${index}    IN RANGE    0    2
        Start wireshark capture from gNB or Enb      filename=tcpdump_7564_004_${index}    alias=gnb
        ${attach_status}    Run keyword and return status    CB007306_common_keyword.attach multi power ue    ue_num=${1}
        Run keyword if     ${attach_status}==${False}    Stop wireshark capture from gNB or Enb
        ...    filename=tcpdump_7564_004_${index}   alias=gnb    logpath=${OUTPUT_DIR}/${TEST NAME}
        should be true    ${attach_status}    ${True}
        Set X and Y PositionMotion    ip=${PositionMotion_ip1}     if_Y=${False}   start_X=${0}     end_X=${90}
        Set X and Y PositionMotion    ip=${PositionMotion_ip2}     if_X=${False}   start_Y=${90}     end_Y=${180}
        sleep     5s
        Set X and Y PositionMotion    ip=${PositionMotion_ip2}     if_X=${False}   start_Y=${180}     end_Y=${90}
        Set X and Y PositionMotion    ip=${PositionMotion_ip1}     if_Y=${False}   start_X=${90}      end_X=${0}
        sleep    5s
        Stop wireshark capture from gNB or Enb       filename=tcpdump_7564_004_${index}     alias=gnb     logpath=${OUTPUT_DIR}/${TEST NAME}
        CB007306_common_keyword.detach multi power ue     ue_num=${1}
        Read Wireshark Log for 7564 004    tcpdump_log=tcpdump_7564_004_${index}.pcap     txt_filename=tcpdump_7564_004_${index}.txt
    END

Check wiresgark log and btslog for 573
    ${ip_list}    Create list     ${gNB_ip}    ${gNB2_ip}
    FOR    ${NUM}    IN RANGE    ${0}    ${2}    1
        ${DLtputDataDic}  ${ULtputDataDic}    get_tput_in_syslog
        ...     syslog_path=${OUTPUT_DIR}/${TEST NAME}/btslog_573_${NUM}.log      iplist=${ip_list}
        CB007306_common_keyword.Convert pcap to text     pacp_filename=tcpdump_attach_573_${NUM}.pcap
        ...    txt_filename=tcpdump_attach_573_${NUM}.txt    filter=${filter}
        Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_50}    txt_filename=tcpdump_attach_573_${NUM}.txt
        Check wireshark log data Flow message     sgnb_chg_flow_message=${attach_message_flow}    txt_filename=tcpdump_attach_573_${NUM}.txt

        CB007306_common_keyword.Convert pcap to text     pacp_filename=573_ho_50_80_${NUM}.pcap
        ...     txt_filename=573_ho_50_80_${NUM}.txt    filter=${filter}
        Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_80}    txt_filename=573_ho_50_80_${NUM}.txt
        Check wireshark log Parameter    sgnb_chg_ho_message=${sgnb_chg_ho_cause}    txt_filename=573_ho_50_80_${NUM}.txt
        Check wireshark log data Flow message
        ...    sgnb_chg_flow_message=${intra_freq_inter_gnb_ho_message_flow}    txt_filename=573_ho_50_80_${NUM}.txt

        CB007306_common_keyword.Convert pcap to text     pacp_filename=573_ho_80_50_${NUM}.pcap
        ...     txt_filename=573_ho_80_50_${NUM}.txt    filter=${filter}
        Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_50}    txt_filename=573_ho_80_50_${NUM}.txt
        Check wireshark log Parameter    sgnb_chg_ho_message=${sgnb_chg_ho_cause}    txt_filename=573_ho_80_50_${NUM}.txt
        Check wireshark log data Flow message
        ...    sgnb_chg_flow_message=${intra_freq_inter_gnb_ho_message_flow}    txt_filename=573_ho_80_50_${NUM}.txt
        ${measConfigDic}     Create dictionary
        ${measConfigDic}    Get MeasConfig From Txt N     txt_file_path=${OUTPUT_DIR}/${TEST NAME}/tcpdump_attach_573_${NUM}.txt
        ...    measConfigDic=${measConfigDic}
        ${measConfigDic}    Get MeasConfig From Txt N     measConfigDic=${measConfigDic}
        ...    txt_file_path=${OUTPUT_DIR}/${TEST NAME}/573_ho_50_80_${NUM}.txt
        ${measConfigDic}    Get MeasConfig From Txt N     measConfigDic=${measConfigDic}
        ...    txt_file_path=${OUTPUT_DIR}/${TEST NAME}/573_ho_80_50_${NUM}.txt
        #Check measid    txt_filename=573_ho_50_80_${NUM}.txt   para1=report    para2=eventId    expect=eventA3
        #...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=1
        #Check measid    txt_filename=573_ho_50_80_${NUM}.txt    para1=report    para2=ho_method    expect=rsrp
        #...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=1
        #Check measid    txt_filename=573_ho_80_50_${NUM}.txt    para1=report    para2=eventId    expect=eventA3
        #...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=2
        #Check measid    txt_filename=573_ho_80_50_${NUM}.txt    para1=report    para2=ho_method    expect=rsrp
        #...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=2
    END


Check wiresgark log and btslog for 710_008
    ${ip_list}    Create list     ${gNB_ip}
    CB007306_common_keyword.Convert pcap to text     pacp_filename=tcpdump_710_008.pcap
    ...     txt_filename=tcpdump_710_008.txt     filter=${filter}
    remove_repeat_measurement_report     txt_file_path=${OUTPUT_DIR}/${TEST NAME}/tcpdump_710_008.txt
    Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_50}    txt_filename=tcpdump_710_008.txt
    Check wireshark log Parameter    sgnb_chg_ho_message=${spid}    txt_filename=tcpdump_710_008.txt

    Check wireshark log Parameter    sgnb_chg_ho_message=${measGap}    txt_filename=tcpdump_710_008.txt
    Check wireshark log data Flow message     sgnb_chg_flow_message=${inter_freq_a2_a1_message_flow}    txt_filename=tcpdump_710_008.txt

    Run Keyword And Continue On Failure     Check Btslog Thoughput    btslog_name=btslog_710_008.log    ip_list=${ip_list}    if_ul=${False}
    ${measConfigDic}     Create dictionary
    ${measConfigDic}    Get MeasConfig From Txt N     txt_file_path=${OUTPUT_DIR}/${TEST NAME}/tcpdump_710_008.txt    measConfigDic=${measConfigDic}

    Run Keyword And Continue On Failure   Check measid    txt_filename=tcpdump_710_008.txt   para1=report    para2=eventId    expect=eventA2
    ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=1
    Run Keyword And Continue On Failure   Check measid    txt_filename=tcpdump_710_008.txt    para1=report    para2=ho_method    expect=rsrp
    ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=1
    Run Keyword And Continue On Failure   Check measid    txt_filename=tcpdump_710_008.txt   para1=report    para2=eventId    expect=eventA1
    ...         measConfigDic=${measConfigDic}    mr_n=2    mc_n=2
    Run Keyword And Continue On Failure   Check measid    txt_filename=tcpdump_710_008.txt    para1=report    para2=ho_method    expect=rsrp
    ...         measConfigDic=${measConfigDic}    mr_n=2    mc_n=2
    ${measid}    Get_Meas_Id    measConfigDic=${measConfigDic}     ssbFrequency=2078299    eventId=eventA3    ho_method=rsrp    n=2
    Run Keyword And Continue On Failure    should not be true     ${measid}==${-1}
    ${measid1}    Get_Meas_Id    measConfigDic=${measConfigDic}     ssbFrequency=2074267    eventId=eventA3    ho_method=rsrp    n=2
    should not be true     ${measid1}==${-1}

Check wiresgark log and btslog for 710_011
    ${ip_list}    Create list     ${gNB_ip}
    CB007306_common_keyword.Convert pcap to text     pacp_filename=tcpdump_710_011.pcap
    ...     txt_filename=tcpdump_710_011.txt     filter=${filter}
    remove_repeat_measurement_report     txt_file_path=${OUTPUT_DIR}/${TEST NAME}/tcpdump_710_011.txt
    Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_50}    txt_filename=tcpdump_710_011.txt
    Check wireshark log Parameter    sgnb_chg_ho_message=${spid}    txt_filename=tcpdump_710_011.txt

    Check wireshark log Parameter    sgnb_chg_ho_message=${measGap_011}    txt_filename=tcpdump_710_011.txt
    Check wireshark log data Flow message     sgnb_chg_flow_message=${inter_freq_a2_message_flow}    txt_filename=tcpdump_710_011.txt

    Run Keyword And Continue On Failure     Check Btslog Thoughput    btslog_name=btslog_710_011.log    ip_list=${ip_list}    if_ul=${False}
    ${measConfigDic}     Create dictionary
    ${measConfigDic}    Get MeasConfig From Txt N     txt_file_path=${OUTPUT_DIR}/${TEST NAME}/tcpdump_710_011.txt     measConfigDic=${measConfigDic}
    Run Keyword And Continue On Failure        Check measid    txt_filename=tcpdump_710_011.txt   para1=report    para2=eventId    expect=eventA2
    ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=1
    Run Keyword And Continue On Failure     Check measid    txt_filename=tcpdump_710_011.txt    para1=report    para2=ho_method    expect=rsrp
    ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=1
    ${measid}    Get_Meas_Id     measConfigDic=${measConfigDic}     ssbFrequency=2078299    eventId=eventA3    ho_method=rsrp    n=2
    Run Keyword And Continue On Failure     should not be true     ${measid}==${-1}
    ${measid1}    Get_Meas_Id    measConfigDic=${measConfigDic}     ssbFrequency=2074267    eventId=eventA3    ho_method=rsrp    n=2
    Run Keyword And Continue On Failure     should be true      ${measid1}==${-1}

Check wiresgark log and btslog for 1094
    ${ip_list}    Create list     ${gNB_ip}
    CB007306_common_keyword.Convert pcap to text     pacp_filename=tcpdump_1094.pcap
    ...     txt_filename=tcpdump_1094.txt     filter=${filter}
    Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_50}    txt_filename=tcpdump_1094.txt
    Check wireshark log Parameter    sgnb_chg_ho_message=${blackCellsToAddModList}    txt_filename=tcpdump_1094.txt
    Check wireshark log data not contain message     txt_filename=tcpdump_1094.txt     command=grep measurementReport
    Check Btslog Thoughput    btslog_name=btslog_1094.log    ip_list=${ip_list}    if_ul=${False}

Check case 1416 wireshark log data contain attach message
    [Arguments]     ${connection}=ute
    CB007306_common_keyword.Convert pcap to text     pacp_filename=tcpdump_1416.pcap
    ...     txt_filename=tcpdump_1416.txt     filter=${filter}
    Connect to with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}    alias=${connection}
    CB007306_common_keyword.Check wireshark log data contain message    txt_filename=tcpdump_1416.txt     message='ENDCX2SetupRequest'
    CB007306_common_keyword.Check wireshark log data contain message    txt_filename=tcpdump_1416.txt     message='ENDCX2SetupResponse'
    CB007306_common_keyword.Check wireshark log data contain message    txt_filename=tcpdump_1416.txt     message='freqBandIndicatorNr: 257'
    CB007306_common_keyword.Check wireshark log data contain message    txt_filename=tcpdump_1416.txt     message='freqBandIndicatorNr: 261'
    CB007306_common_keyword.Convert pcap to text     pacp_filename=tcpdump_attach_1416.pcap
    ...     txt_filename=tcpdump_attach_1416.txt     filter=${filter}
    Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_50}    txt_filename=tcpdump_attach_1416.txt
    [Teardown]    run keyword and ignore error    csn.Disconnect	connection=${connection}

check cell band
    [Arguments]    ${BTS_Host}=${gNB_ip}    ${expect}=n257, n261    ${cell_id}=${GNB1_NRCELL_1}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${BTS_Host}    connection=${connection}
    ${cell_status}    coam.get_cell_specific_info    cell_id=${cell_id}     connection=${connection}
    ${band}    get from dictionary    ${cell_status}    band
    should be equal as strings    ${band}    ${expect}
    [Teardown]   COAM Teardown gnb connections    connection=${connection}

Check counter number on gNB1 and gNB2 for 573
    ${M55112C02501}    Check PM counter result    counter_id=M55112C02501
    ${M55112C02502}    Check PM counter result    counter_id=M55112C02502
    ${M55112C02503}    Check PM counter result    counter_id=M55112C02503    index=${1}
    ${M55112C02504}    Check PM counter result    counter_id=M55112C02504    index=${1}
    ${M55112C02505}    Check PM counter result    counter_id=M55112C02505    index=${1}
    ${M55112C02506}    Check PM counter result    counter_id=M55112C02506    index=${1}
    Get length and Check sum counter value      list_input=${M55112C02501}
    Get length and Check sum counter value      list_input=${M55112C02502}
    Get length and Check sum counter value      list_input=${M55112C02503}
    Get length and Check sum counter value      list_input=${M55112C02504}
    Get length and Check sum counter value      list_input=${M55112C02505}
    Get length and Check sum counter value      list_input=${M55112C02506}

Check DL and UL counter for 573
    ${M55316C05001}    Check PM counter result    counter_id=M55316C05001    counter_object=NCADU
    Check counter value    ${M55316C05001}
    ${M55316C06001}    Check PM counter result    counter_id=M55316C06001    counter_object=NCADU
    Check counter value    ${M55316C06001}
#    ${DL_nrCellId_list}    create list
#    ${DL_nrCellId_list}    Get nrcellid with the lcrid      bts_host=${gNB_ip}
#    ${UL_nrCellId_list}    Get nrcellid with the lcrid      bts_host=${gNB_ip}
#    ${M55316C03003}    Check PM counter result    counter_id=M55316C03003    counter_object=NCADU
#    ${M55316C03003_sum}    Get sum counter value    ${M55316C03003}
#    ${M55316C04001}    Check PM counter result    counter_id=M55316C04001    counter_object=NCADU
#    ${M55316C04001_sum}    Get sum counter value    ${M55316C04001}
#    ${DLcounter}    get_counter_data_in_syslog    syslog_path=${OUTPUT_DIR}/${TEST NAME}/btslog_573_0.log
#    ...    celllist=${DL_nrCellId_list}   type=DL
#    ${ULcounter}    get_counter_data_in_syslog    syslog_path=${OUTPUT_DIR}/${TEST NAME}/btslog_573_1.log
#    ...    celllist=${UL_nrCellId_list}   type=UL
#    ${DLcounterdif}    Evaluate   abs(${DLcounter}-${M55316C03003_sum})
#    ${ULcounterdif}    Evaluate   abs(${ULcounter}+${M55316C03003_sum}-${M55316C04001_sum})
#    run keyword and continue on failure     should be true     ${DLcounterdif}<=50
#    run keyword and continue on failure     should be true     ${ULcounterdif}<=50

Check sum counter for 573
    ${M55316C03000}    Check PM counter result    counter_id=M55316C03000    counter_object=NCADU
    ${M55316C03001}    Check PM counter result    counter_id=M55316C03001    counter_object=NCADU
    ${M55316C03002}    Check PM counter result    counter_id=M55316C03002    counter_object=NCADU
    ${M55316C03003}    Check PM counter result    counter_id=M55316C03003    counter_object=NCADU
    ${M55316C02000}    Check PM counter result    counter_id=M55316C02000    counter_object=NCADU
    ${M55316C03000_sum}    Get sum counter value    ${M55316C03000}
    ${M55316C03001_sum}    Get sum counter value    ${M55316C03001}
    ${M55316C03002_sum}    Get sum counter value    ${M55316C03002}
    ${M55316C03003_sum}    Get sum counter value    ${M55316C03003}
    ${M55316C02000_sum}    Get sum counter value    ${M55316C02000}
    ${M55316C0300_sum}     Evaluate    ${M55316C03000_sum}+${M55316C03001_sum}+${M55316C03002_sum}+${M55316C03003_sum}
    run keyword and continue on failure     should be true     ${M55316C02000_sum}==${M55316C0300_sum}
    ${M55316C04000}    Check PM counter result    counter_id=M55316C04000    counter_object=NCADU
    ${M55316C04001}    Check PM counter result    counter_id=M55316C04001    counter_object=NCADU
    ${M55316C02001}    Check PM counter result    counter_id=M55316C02001    counter_object=NCADU
    ${M55316C04000_sum}    Get sum counter value    ${M55316C04000}
    ${M55316C04001_sum}    Get sum counter value    ${M55316C04001}
    ${M55316C02001_sum}    Get sum counter value    ${M55316C02001}
    ${M55316C0400_sum}     Evaluate    ${M55316C04000_sum}+${M55316C04001_sum}
    run keyword and continue on failure     Should be true     ${M55316C02001_sum}==${M55316C0400_sum}
    run keyword and continue on failure     Check Counter in range    ${M55316C02000}
    run keyword and continue on failure     Check Counter in range    ${M55316C02001}

Check Counter in range
    [Arguments]     ${list_input}
    ${length}      Get Length       ${list_input}
    FOR   ${i}    IN RANGE    ${0}    ${length}     1
        ${count_item}    Set Variable    ${list_input}[${i}]
        run keyword and continue on failure    should be true    ${count_item} <= 300
    END

Check counter number on gNB1 for 710
    [Arguments]     ${value1}    ${value2}     ${except_value}=1
    ${counter_value1}    Get sum counter value     list_input=${value1}
    ${counter_value2}    Get sum counter value     list_input=${value2}
    ${dif}      Evaluate     ${counter_value2}-${counter_value1}
    run keyword and continue on failure     should be true       ${dif}==${except_value}

Get counter number on gNB1 for 7564_001
    Wait for counter to be gathered after guard peroid
    ${result1}    Check PM counter result    counter_object=NNGCC    counter_id=M55125C09021
    ${counter_value_sum1}    Get sum counter value    ${result1}
    ${result2}    Check PM counter result    counter_object=NRACH    counter_id=M55306C09000
    ${counter_value_sum2}    Get sum counter value    ${result2}
    ${result3}    Check PM counter result    counter_object=NRACH    counter_id=M55306C09002
    ${counter_value_sum3}    Get sum counter value    ${result3}
    ${result4}    Check PM counter result    counter_object=NRACH    counter_id=M55306C09003
    ${counter_value_sum4}    Get sum counter value    ${result4}
    [Return]       ${counter_value_sum1}    ${counter_value_sum2}   ${counter_value_sum3}   ${counter_value_sum4}

Get counter number on gNB1 for 7564_002
    ${result1}     Check PM counter result    counter_object=NNGCC    counter_id=M55125C09022
    ${counter_value_sum1}    Get sum counter value    ${result1}
    ${result2}     Check PM counter result    counter_object=NRACH    counter_id=M55306C09001
    ${counter_value_sum2}    Get sum counter value    ${result2}
    ${result3}     Check PM counter result    counter_object=NRACH    counter_id=M55306C09004
    ${counter_value_sum3}    Get sum counter value    ${result3}
    [Return]     ${counter_value_sum1}    ${counter_value_sum2}   ${counter_value_sum3}

Get counter number on gNB2 for 7564_002
    ${result1}    Check PM counter result    index=${1}    counter_object=NNGCC    counter_id=M55125C09022
    ${counter_value_sum1}   Get sum counter value   ${result1}
    ${result2}    Check PM counter result    index=${1}    counter_object=NRACH    counter_id=M55306C09001
    ${counter_value_sum2}    Get sum counter value    ${result2}
    ${result3}    Check PM counter result    index=${1}    counter_object=NRACH    counter_id=M55306C09004
    ${counter_value_sum3}    Get sum counter value    ${result3}
    [Return]     ${counter_value_sum1}    ${counter_value_sum2}   ${counter_value_sum3}

Get counter number on gNB1 for 7564_004
    ${result}     Check PM counter result    counter_object=NRACH    counter_id=M55306C09007
    ${counter_value_sum}    Get sum counter value    ${result}
    [Return]     ${counter_value_sum}

Get counter number on gNB2 for 7564_004
    ${result}    Check PM counter result    index=${1}    counter_object=NRACH    counter_id=M55306C09007
    ${counter_value_sum}   Get sum counter value   ${result}
    [Return]     ${counter_value_sum}

Read Wireshark Log for 7564 001
    [Arguments]      ${tcpdump_log}      ${txt_filename}     ${logpath}=${OUTPUT_DIR}/${TEST NAME}  ${connection}=TestPc
    Convert pcap to text    pacp_filename=${tcpdump_log}    txt_filename=${txt_filename}     logpath=${logpath}
    ...   filter=${filter}    connection=${connection}
    Check wireshark log Parameter    sgnb_chg_ho_message=${sgnb_attach_cause_2083_001}    txt_filename=${txt_filename}   logpath=${logpath}
    Check wireshark log data Flow message     sgnb_chg_flow_message=${attach_message_flow}    txt_filename=${txt_filename}    logpath=${logpath}
    ${SgNBContent}    Get File    path=${logpath}/${txt_filename}
    run keyword and continue on failure    should not contain    ${SgNBContent}    'SGNB Addition Trigger Indication'

Read Wireshark Log for 7564 002
    [Arguments]      ${tcpdump_log}  ${txt_filename}   ${logpath}=${OUTPUT_DIR}/${TEST NAME}   ${connection}=TestPc
    log to console    \n\tRead Log and check
    Convert pcap to text    pacp_filename=${tcpdump_log}    txt_filename=${txt_filename}     logpath=${logpath}
    ...   filter=${filter}    connection=${connection}
    Check wireshark log Parameter    sgnb_chg_ho_message=${sgnb_attach_cause_2083_002}    txt_filename=${txt_filename}   logpath=${logpath}
    Check wireshark log data Flow message     sgnb_chg_flow_message=${attach_and_intra_freq_inter_gnb_ho}
    ...    txt_filename=${txt_filename}    logpath=${logpath}
    ${SgNBContent}    Get File    path=${logpath}/${txt_filename}
    run keyword and continue on failure    should not contain    ${SgNBContent}    'SGNB Addition Trigger Indication'
    [Teardown]    Run keyword and ignore error    ssh.Disconnect	  connection=${connection}

Read Wireshark Log for 7564 003
    [Arguments]      ${tcpdump_log}   ${txt_filename}   ${logpath}=${OUTPUT_DIR}/${TEST NAME}   ${connection}=TestPc
    Convert pcap to text    pacp_filename=${tcpdump_log}    txt_filename=${txt_filename}     logpath=${logpath}
    ...   filter=${filter}    connection=${connection}
    Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_50}    txt_filename=${txt_filename}   logpath=${logpath}
    [Teardown]    Run keyword and ignore error    ssh.Disconnect	  connection=${connection}

Read Wireshark Log for 7564 004
    [Arguments]      ${tcpdump_log}   ${txt_filename}   ${logpath}=${OUTPUT_DIR}/${TEST NAME}   ${connection}=TestPc
    Convert pcap to text    pacp_filename=${tcpdump_log}    txt_filename=${txt_filename}     logpath=${logpath}
    ...   filter=${filter}    connection=${connection}
    Check wireshark log Parameter    sgnb_chg_ho_message=${sgnb_attach_cause_2083_004}    txt_filename=${txt_filename}   logpath=${logpath}
    Check wireshark log data Flow message     sgnb_chg_flow_message=${attach_and_intra_freq_inter_gnb_ho}
    ...    txt_filename=${txt_filename}    logpath=${logpath}
    [Teardown]    Run keyword and ignore error    ssh.Disconnect	  connection=${connection}

Check btslog for 7564 001
    [Arguments]    ${target}   ${connection}=ute
    log to console    Check btslog meassage...
    csn.Connect to     hostname=${TEST_PC_IP}     username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    csn.Send Command    command=cat ${target} | grep 'handleAckCRCOkForMsg3CFRA'
    ...    connection=${connection}
    ${free3}  csn.Read Output    connection=${connection}
    run keyword and continue on failure     should not be empty    ${free3}
    csn.Send Command    command=cat ${target} | grep 'handleSuccessfulCrcWithCfra'
    ...    connection=${connection}
    ${free4}  csn.Read Output    connection=${connection}
    run keyword and continue on failure     should not be empty    ${free4}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Check btslog for 7564 002
    [Arguments]    ${target}   ${connection}=ute
    log to console    Check btslog meassage...
    csn.Connect to     hostname=${TEST_PC_IP}     username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    csn.Send Command    command=cat ${target} | grep 'Sent to L2PS itf::l2::ps::user::UserSetupReq_t'
    ...    connection=${connection}
    ${free1}  csn.Read Output    connection=${connection}
    run keyword and continue on failure   should not be empty    ${free1}
    csn.Send Command    command=cat ${target} | grep '"ueAddCause":"SGNBADDITION"'
    ...    connection=${connection}
    ${free2}  csn.Read Output    connection=${connection}
    run keyword and continue on failure    should not be empty    ${free2}
    csn.Send Command    command=cat ${target} | grep 'Received itf::l2::ps::user::UserSetupResp - OK'
    ...    connection=${connection}
    ${free3}  csn.Read Output    connection=${connection}
    run keyword and continue on failure    should not be empty    ${free3}
    csn.Send Command    command=cat ${target} | egrep '(Received from L2PS itf::l2::ps::user::UserSetupResp_t)*("cRnti":)'
    ...    connection=${connection}
    ${free4}  csn.Read Output    connection=${connection}
    run keyword and continue on failure    should not be empty    ${free4}
    log to console    Check btslog meassage successful
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Check btslog for 7564 003
    [Arguments]    ${target}    ${connection}=ute
    log to console    Check btslog meassage...
    csn.Connect to     hostname=${TEST_PC_IP}     username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    csn.Send Command
    ...    command=cat ${target} | grep 'UE attached'
    ...    connection=${connection}
    ${free2}  csn.Read Output    connection=${connection}
    run keyword and continue on failure    should not be empty    ${free2}
    csn.Send Command
    ...    command=cat ${target} | grep 'handleRaContResSuccessUe'
    ...    connection=${connection}
    ${free3}  csn.Read Output    connection=${connection}
    run keyword and continue on failure    should not be empty    ${free3}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Check btslog for case4
    [Arguments]    ${target}   ${connection}=ute
    log to console    Check btslog meassage...
    csn.Connect to     hostname=${TEST_PC_IP}     username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    csn.Send Command    command=cat ${target} | grep 'Sent to L2PS itf::l2::ps::user::UserSetupReq_t'
    ...    connection=${connection}
    ${free1}  csn.Read Output    connection=${connection}
    should not be empty    ${free1}
    csn.Send Command
    ...    command=cat ${target} | egrep '(cp_rt)*(Sent to L2PS itf::l2::ps::user::UserSetupReq_t)*("ueAddCause":"SGNBADDITION")'
    ...    connection=${connection}
    ${free2}  csn.Read Output    connection=${connection}
    should not be empty    ${free2}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

RMODs_Lock_and_Unlock
    [Arguments]  ${Lock_RMOD_List}=${empty_list}    ${unLock_RMOD_List}=${empty_list}    ${gnb_index}=0    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    ${MRBTSID}    set variable    ${tl.gnbs[${gnb_index}].instance_id}
    FOR    ${item}    IN    @{unLock_RMOD_List}
        coam.unlock    dist_name=MRBTS-${MRBTSID}/EQM-1/APEQM-1/${item}    timeout=${60}    connection=${connection}
    END
    FOR    ${item}    IN    @{Lock_RMOD_List}
        coam.lock    dist_name=MRBTS-${MRBTSID}/EQM-1/APEQM-1/${item}    timeout=${60}    connection=${connection}
    END
    sleep    1min
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=GNB_OAM

Case setup for CNI 107623
#    Connect gnb and Check cell on air     BTS_Host=${gNB2_ip}
#    Adjust the HBTE attenuation value    value_1=${127}    value_2=${0}
#    ${Lock_RMOD_List}    Create List    RMOD-2    RMOD-3
#    RMODs_Lock_and_Unlock     Lock_RMOD_List=${Lock_RMOD_List}    gnb_index=0
#    Set X and Y PositionMotion    ip=${PositionMotion_ip1}    if_Y=${false}    start_X=${90}    end_X=${90}
    Connect gnb and Check cell on air     BTS_Host=${gNB_ip}
    Adjust the HBTE attenuation value    value_1=${0}    value_2=${127}
    Adjust the HBTE attenuation value Common    port_index=${8}    value=${0}
    Adjust the HBTE attenuation value Common    port_index=${10}    value=${0}
    ${Lock_RMOD_List}    Create List    RMOD-2    RMOD-3
    RMODs_Lock_and_Unlock     Lock_RMOD_List=${Lock_RMOD_List}    gnb_index=0
    Set X and Y PositionMotion    ip=${PositionMotion_ip1}    if_Y=${false}    start_X=${90}    end_X=${90}

Case teardown for CNI 107623
#    Modify Common parameter via Coam      input_list=${freq_2071387_nrCarPrio_8}     gNB_ip=${gNB2_ip}    sleep_time=10s
#    ${unLock_RMOD_List}    Create List    RMOD-2    RMOD-3
#    RMODs_Lock_and_Unlock     unLock_RMOD_List=${unLock_RMOD_List}    gnb_index=0
#    Connect gnb and Check cell on air     BTS_Host=${gNB_ip}
#    robot_common_operations.Common case Teardown
    Modify Common parameter via Coam      input_list=${freq_2071387_nrCarPrio_8}     gNB_ip=${gNB_ip}    sleep_time=10s
    ${unLock_RMOD_List}    Create List    RMOD-2    RMOD-3
    RMODs_Lock_and_Unlock     unLock_RMOD_List=${unLock_RMOD_List}    gnb_index=0
    Connect gnb and Check cell on air     BTS_Host=${gNB_ip}
    robot_common_operations.Common case Teardown

Start and check tcpdump log attach UE for CNI_107623
    [Arguments]    ${ue_index}=${0}    ${case_type}=fr1
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung
    CB007306_common_keyword.detach multi power ue     ue_num=${1}
    FOR    ${index}    IN RANGE    0    1
        ${log_file_name}    set variable    tcpdump_CNI_107623_001_${case_type}_${index}
        Start wireshark capture from gNB or Enb    if_gnb=${False}    filename=${log_file_name}    alias=enb    index=${0}
        ${attach_status}    Run keyword and return status    CB007306_common_keyword.attach multi power ue    ue_num=${1}
        ...    gnb_index=${1}
        should be true    ${attach_status}    ${True}
        sleep    5s
        Stop wireshark capture from gNB or Enb    if_gnb=${False}    filename=${log_file_name}     alias=enb    index=${0}
        CB007306_common_keyword.detach multi power ue     ue_num=${1}
        Convert pcap to text    pacp_filename=${log_file_name}.pcap    txt_filename=${log_file_name}.txt
        ...    filter=${filter2}    connection=TestPc
        Check Wireshark Log for CNI_107623    txt_filename=${log_file_name}.txt    case_type=${case_type}
    END

Check Wireshark Log for CNI_107623
    [Arguments]      ${txt_filename}    ${case_type}=fr1    ${log_path}=${OUTPUT_DIR}/${TEST NAME}
    ${if_4193}    run keyword and return status    should contain    ${case_type}    b1
    ${if_FR2}    run keyword and return status    should contain    ${case_type}    fr2
    ${if_FR1}    run keyword and return status    should contain    ${case_type}    fr1
    ${checked_para}    set variable if    ${if_FR1}    ${attached_pci_100}
    ...    ${if_FR2}    ${attached_pci_80}    ${EMPTY}
    Check wireshark log Parameter    sgnb_chg_ho_message=${nrRestrictionInEPS}    txt_filename=${txt_filename}
    Run keyword if    '${case_type}'!='none'    Check wireshark log Parameter
    ...    sgnb_chg_ho_message=${checked_para}    txt_filename=${txt_filename}
    ${check_result}    Run keyword if    '${case_type}'=='none'    Check Wireshark Message Flow From Txt
    ...    message_dict=${only_attach_lte}    txt_file_path=${logpath}/${txt_filename}
    ...    ELSE    checkBandResrictionfr1Andfr2    txt_filename=${log_path}/${txt_filename}
    should be True    ${check_result}
    ${check_result2}    Run keyword if    ${if_4193}    checkb1report    txt_filename=${log_path}/${txt_filename}
    Run keyword if    ${if_4193}    should be true    ${check_result2}

Start and check tcpdump log for CNI_107623 HO SUCC Case
    [Arguments]    ${ue_index}=${0}    ${case_type}=HO_OK
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung
    CB007306_common_keyword.detach multi power ue     ue_num=${1}
    FOR    ${index}    IN RANGE    0    1
        ${log_file_name}    set variable    tcpdump_CNI_107623_001_${case_type}_${index}
        Start wireshark capture from gNB or Enb    if_gnb=${False}    filename=${log_file_name}    alias=enb    index=${0}
        # Attach
        log to console    UE attach.
        ${attach_status}    Run keyword and return status    CB007306_common_keyword.attach multi power ue    ue_num=${1}
        ...    gnb_index=${1}
        should be true    ${attach_status}    ${True}
        sleep    5s
        log to console    HO FR2->FR1.
        # HO FR2->FR1
        Adjust the HBTE attenuation value Common    port_index=${8}    value=${0}
        Adjust the HBTE attenuation value Common    port_index=${10}    value=${0}
        Set X and Y PositionMotion    ip=${PositionMotion_ip1}    if_Y=${false}    start_X=${0}    end_X=${0}
        sleep    10s
        Stop wireshark capture from gNB or Enb    if_gnb=${False}    filename=${log_file_name}     alias=enb    index=${0}
        log to console    Check HO FR2->FR1 OK case.
        Convert pcap to text    pacp_filename=${log_file_name}.pcap    txt_filename=${log_file_name}.txt
        ...    filter=${filter2}    connection=TestPc
        Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_80}    txt_filename=${log_file_name}.txt
        Check wireshark log Parameter    sgnb_chg_ho_message=${HO_attached_pci_100}    txt_filename=${log_file_name}.txt
        Check Wireshark Message Flow From Txt    message_dict=${inter_freq_intra_gnb_message_flow}
        ...    txt_file_path=${OUTPUT_DIR}/${TEST NAME}/${log_file_name}.txt
        log to console    HO FR1->FR2.
        # HO FR1->FR2
        ${log_file_name_2}    set variable    tcpdump_CNI_107623_001_${case_type}_${index}_FR1_TO_FR2
        Start wireshark capture from gNB or Enb    if_gnb=${False}    filename=${log_file_name_2}    alias=enb    index=${0}
        Set X and Y PositionMotion    ip=${PositionMotion_ip1}    if_Y=${false}    start_X=${90}    end_X=${90}
        Adjust the HBTE attenuation value Common    port_index=${8}    value=${10}
        Adjust the HBTE attenuation value Common    port_index=${10}    value=${10}
        Adjust the HBTE attenuation value Common    port_index=${8}    value=${20}
        Adjust the HBTE attenuation value Common    port_index=${10}    value=${20}
        sleep    10s
        Stop wireshark capture from gNB or Enb    if_gnb=${False}    filename=${log_file_name_2}     alias=enb    index=${0}
        CB007306_common_keyword.detach multi power ue     ue_num=${1}
        log to console    Check HO FR1->FR2 OK case.
        Convert pcap to text    pacp_filename=${log_file_name_2}.pcap    txt_filename=${log_file_name_2}.txt
        ...    filter=${filter2}    connection=TestPc
        Check wireshark log Parameter    sgnb_chg_ho_message=${HO_attached_pci_80}    txt_filename=${log_file_name_2}.txt
        Check Wireshark Message Flow From Txt    message_dict=${inter_freq_intra_gnb_message_flow}
        ...    txt_file_path=${OUTPUT_DIR}/${TEST NAME}/${log_file_name_2}.txt
    END

Start and check tcpdump log for CNI_107623 HO FAIL Case
    [Arguments]    ${ue_index}=${0}    ${case_type}=HO_NOK
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung
    CB007306_common_keyword.detach multi power ue     ue_num=${1}
    FOR    ${index}    IN RANGE    0    1
        ${log_file_name}    set variable    tcpdump_CNI_107623_001_${case_type}_${index}
        Start wireshark capture from gNB or Enb    if_gnb=${False}    filename=${log_file_name}    alias=enb    index=${0}
        # Attach
        ${attach_status}    Run keyword and return status    CB007306_common_keyword.attach multi power ue    ue_num=${1}
        ...    gnb_index=${1}
        should be true    ${attach_status}    ${True}
        sleep    5s
        log to console    HO FR2->FR1 NOK case.
        # HO FR2->FR1
        Adjust the HBTE attenuation value Common    port_index=${8}    value=${0}
        Adjust the HBTE attenuation value Common    port_index=${10}    value=${0}
        Set X and Y PositionMotion    ip=${PositionMotion_ip1}    if_Y=${false}    start_X=${0}    end_X=${0}
        sleep    5s
        Stop wireshark capture from gNB or Enb    if_gnb=${False}    filename=${log_file_name}     alias=enb    index=${0}
        CB007306_common_keyword.detach multi power ue     ue_num=${1}
        log to console    Check HO FR2->FR1 NOK case.
        Convert pcap to text    pacp_filename=${log_file_name}.pcap    txt_filename=${log_file_name}.txt
        ...    filter=${filter2}    connection=TestPc
        Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_80}    txt_filename=${log_file_name}.txt
        Check wireshark log Parameter    sgnb_chg_ho_message=${HO_NOT_attached_pci_100}    txt_filename=${log_file_name}.txt
    END
