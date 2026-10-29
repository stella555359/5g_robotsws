*** Settings ***
Documentation     author: cindy
...                 contact: cindy.1.jin@nokia-sbell.com
...                 squad group: SG_03
...                 feature : 5GC000710

Library           OperatingSystem
Library           Collections
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.config.scf    WITH NAME    scf
#Library           ../../../../../resources/python_libs/Attenuation.py
Library           taf.hw.rf_attenuator    WITH NAME    att
#Library           ../../../../../resources/python_libs/TestCaseRequirement.py
#Library           ../../../../../resources/python_libs/cells.py
#Library           ../../../../../resources/python_libs/systemd.py
#Library           ../../../../../resources/python_libs/verify_rf.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          taf/rfrl/common_resources/robot/connections.robot
Resource          taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Library          taf.sbts.oam.coam.admin   WITH NAME    coam
Library    taf.analyzer.pcap   WITH NAME    parser
#Library          Attenuation.Attenuation    WITH NAME    atten
#Library          sigspark.SigSpark    WITH NAME    spark
Variables         5GC000710_test_parameters.py
Variables         variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
*** Variables ***
${interface}    fp0
${gnb_path}                 /tmp/
${tshark_path}              /usr/bin/tshark
${command_template_X}       {tshark_path} -r {pcap_file} -Y  \"f1ap\"  -T pdml
${command_template_Y}       {tshark_path} -r {pcap_file} -Y  \"ngap\"  -T pdml
${command_template_Z}       {tshark_path} -r {pcap_file} -Y  \"xnap\"  -T pdml
${command_template_W}       {tshark_path} -r {pcap_file} -Y  \"s1ap\"  -T pdml
${command_template_H}       {tshark_path} -r {pcap_file} -Y  \"s1ap or x2ap\"  -T pdml
${distname_id_1}      MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
${distname_id_2}      MRBTS-${tl.gnbs[1].instance_id}/NRBTS-${tl.gnbs[1].instance_id}
${LOG_PATH}    /opt/workspace/CRT/Master/Case_Logs/
${TS_LOG_PATH_BASE}    /opt/workspace/CRT/Master/Case_Logs/
${TS_CASE_LOG_PATH}    /opt/workspace/CRT/Master/Case_Logs/
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${WEBUI_NAME}         ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}          ${tl.gnbs[0].cu.oam_http_connection_details.password}
${tl_scf_dir_path}     /opt/workspace/CRT/Master/SCF_file/
${epc_log_path}        /opt/workspace/CRT/Master/Case_Logs/
${test_pc}      ${tl.test_pc.default_ssh_connection_details.addr}
${att_api_port}    ${tl.attenuator[0].port}
${vendor}                    ${tl.attenuator[0].vendor}
${max_attenuation_value}      ${127}
${att_port_1}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_2}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_3}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_5}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8}                ${tl.attenuator[0].attenuator_ports[8]}
${att_port_9}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_10}               ${tl.attenuator[0].attenuator_ports[2]}
${atten_ip}                  ${tl.attenuator[0].ip_addr}
${SN}                       ${tl.ues[0].serial_number}
${ue_type}                  ${tl.ues[0].capabilities[0]}
${DL_PORT}                  ${tl.ues[0].iperf_details.ssh_connection_details.port}
${UL_PORT}                  ${tl.ues[0].iperf_details.port}
${DL_TIME}                  600
${DL_LENGTH}                1024B
${UL_TIME}                  600
${UL_LENGTH}                1024B

*** Keywords ***
Precondition for power UE
    [Arguments]    ${ue_type}    ${ui_version}=S20UI2.5    ${ue_index}=${0}
    power_ue.Prepare UE    ue_type=${ue_type}    ui_version=${ui_version}    ue_index=${ue_index}    reset_sol=pc_reset

adjust the HBTE attenuation value
    [Arguments]     ${value}    ${att_port_1}=${att_port_1}    ${att_port_2}=${att_port_2}    ${atten_ip}=${atten_ip}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA value default value[0-63db] if not set the max_attenuation value below
    ...                for value plz set in your case level
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    attenuator.set_attenuation     port=${att_port_1}    value=${value}
    attenuator.set_attenuation     port=${att_port_2}    value=${value}
    ${value_port_1}    attenuator.read_attenuation    port=${att_port_1}
    should be equal    ${value_port_1}    ${value}
    ${value_port_2}    attenuator.read_attenuation    port=${att_port_2}
    should be equal    ${value_port_2}    ${value}
    sleep    5s

adjust the HBTE attenuation value by step
    [Arguments]     ${start_value}    ${end_value}    ${att_port_1}=${att_port_1}    ${att_port_2}=${att_port_2}    ${atten_ip}=${atten_ip}
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    FOR    ${value}    IN RANGE    ${start_value}    ${end_value}+2    2
      attenuator.set_attenuation     port=${att_port_1}    value=${value}
      attenuator.set_attenuation     port=${att_port_2}    value=${value}
      ${value_port_1}    attenuator.read_attenuation    port=${att_port_1}
      should be equal    ${value_port_1}    ${value}
      ${value_port_2}    attenuator.read_attenuation    port=${att_port_2}
      should be equal    ${value_port_2}    ${value}
      sleep    5s
    END

login and load scf
    [Arguments]     ${bts_host}    ${connection}    ${tl_scf_file_name}=${tl_scf_file_name}
    Connect to gnb coam via ssl    connection=${connection}    bts_host=${bts_host}
    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}${tl_scf_file_name}    timeout=800    is_pdl_checking_needed=${False}
    ...    connection=${connection}
    [Teardown]    coam.teardown    connection=${connection}

Check cell status on air
    [Arguments]     ${bts_host}    ${connection}
    Connect to gnb coam via ssl    connection=${connection}    bts_host=${bts_host}
    Verify all cells should be onair    connection=${connection}
    [Teardown]    coam.teardown    connection=${connection}

Start Capture Wireshark Logs on gNB
    [Arguments]     ${nglogname}    ${interface}=any    ${gnb_index}=${0}
    gNB connections to ssh    connection=gnb${gnb_index}    gnb_index=${gnb_index}
    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}${nglogname}   connection=gnb${gnb_index}
    sleep    3s
    [Teardown]    csn.disconnect    connection=gnb${gnb_index}

Stop Capture Wireshark Logs on gNB
    [Arguments]    ${nglogname}    ${gnb_index}=${0}
    gNB connections to ssh    connection=gnb${gnb_index}    gnb_index=${gnb_index}
    sleep    5
    csn.send command    command=killall tcpdump     connection=gnb${gnb_index}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${nglogname}   local_path=${epc_log_path}${nglogname}   connection=gnb${gnb_index}
    sleep    3
    [Teardown]    csn.disconnect    connection=gnb${gnb_index}

gNB connections to ssh
    [Arguments]    ${connection}    ${gnb_index}=${0}
    csn.Connect To    hostname=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...               username=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...               password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...               alias=${connection}

Start Capture Wireshark Logs on gNB Slave
    [Arguments]     ${gnb_index}    ${logname}    ${interface}=any
    Connect to Common Unit Slave    gnb_index=${gnb_index}    alias=ASIK${gnb_index}_Slave
    csn.send command    command=tcpdump -i ${interface} -C 25M -w ${gnb_path}${logname}   connection=ASIK${gnb_index}_Slave

Stop and download Wireshark Logs on gNB Slave
    [Arguments]    ${gnb_index}    ${logname}
    Connect to Common Unit Slave    gnb_index=${gnb_index}    alias=ASIK${gnb_index}_Slave
    csn.send command    command=killall tcpdump     connection=ASIK${gnb_index}_Slave
    sleep    3
    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}${logname}   connection=ASIK${gnb_index}_Slave
    sleep    3
    [Teardown]      run keyword and ignore error      Csn.disconnect      connection=ASIK${gnb_index}_Slave

Common Suite Setup for COAM
    COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}
    set_suite_documentation    doc=||| All test suite log will save in this VM IP:${test_pc} logPath:${epc_log_path}
    ...    append=True

Common Suite Teardown for COAM
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    connection=gnb${gnb_index}    bts_host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    COAM Save snapshot via rest api    connection=gnb${gnb_index}    timeout=900
    coam.teardown    connection=gnb${gnb_index}

gNB connections
    [Arguments]    ${ip_addr}=${asik_addr}    ${gnb}=ASIK
    csn.connect To    hostname=${ip_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=${gnb}

Prepare gNB with cells on air
    [Arguments]    ${gnb_index}=${0}    ${tl_scf_file_name}=${tl_scf_file_name}
    login and load scf    bts_host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}    connection=gnb${gnb_index}
    ...                   tl_scf_file_name=${tl_scf_file_name}
    wait until keyword succeeds    10 min    20 sec    Check cell status on air
    ...                   bts_host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}    connection=gnb${gnb_index}

Prepare gNB with cells on air status
    [Arguments]    ${gnb_index}=${0}    ${2ndgnb_index}=${1}    ${tl_scf_file_name}=${tl_scf_file_name}
    ${cell_status}    run keyword and return status    Prepare gNB with cells on air    gnb_index=${gnb_index}
    ...                 tl_scf_file_name=${tl_scf_file_name}
    set suite variable    ${cell_status}

Precondition for cell on air
    [Arguments]    ${gnb_index}=${0}    ${tl_scf_file_name}=${tl_scf_file_name}
    Prepare gNB with cells on air status    gnb_index=${gnb_index}    tl_scf_file_name=${tl_scf_file_name}
    RUN KEYWORD IF    '${cell_status}'=='False'    Prepare gNB with cells on air
    ...    gnb_index=${gnb_index}    tl_scf_file_name=${tl_scf_file_name}
    should be equal    '${cell_status}'    'True'

Get gnb release
    wait until keyword succeeds    1min    10s    Connect to Common Unit Master    alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml    connection=release_info
    ${release_info}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

Online modify parmeters
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}    ${timeout}=${300}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}    timeout=${timeout}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Online delete parmeters
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}    ${timeout}=${300}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM delete parameters via rest api    parameters_to_delete_via_api=${parameters_to_update}    timeout=${timeout}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Online delete objects
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM delete objects via rest api    objects_to_delete_via_api=${parameters_to_update}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Online add parmeters
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}    ${timeout}=${300}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM add several parameters via rest api    parameters_to_add_via_api=${parameters_to_update}    timeout=${timeout}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Check PM counter Result
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_index}=${0}    ${counter_end}=${1}    ${counter_increase}=True
    ${counter_value}    Check PM counter from webui    counter_id=${counter_id}    full_path=${dic_path}    gnb_index=${gnb_index}
    ${counter_latest}    get slice from list    ${counter_value}    0    ${counter_end}
#    @{counter_latest}    set variable    ${counter_value[0]}    ${counter_value[1]}
    Run keyword if    "${counter_increase}" == "True"    should contain    '${counter_latest}'   1
    ...    ELSE    should not contain     '${counter_latest}'    1

Check PM counter from webui
    [Arguments]    ${counter_id}    ${full_path}    ${gnb_index}=${0}    ${date}=all
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${full_path}    date=${date}
    [Return]    ${counter_value}
    [Teardown]    COAM Teardown gnb connections

Attach and check power UE
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${4G_check}=False
     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    4G_check=${4G_check}

Check the cell DLUL throughput
    [Arguments]    ${cellid}    ${gnb_index}=${0}
    Set nrcellid suit varaible    cellid=${cellid}    gnb_index=${gnb_index}
    Wait Until Keyword Succeeds   5x    10s    power_ue.Check Throughput    sample=${6}    gnb_index=${gnb_index}
    ...    ue_type=${ue_type}    direction=dl    throughput=${dlexpect_tput}    cellid=${nrcellid}    sleep_time=${20}
    Wait Until Keyword Succeeds   5x    10s    power_ue.Check Throughput    sample=${6}    gnb_index=${gnb_index}
    ...    ue_type=${ue_type}    direction=ul    throughput=${ulexpect_tput}    cellid=${nrcellid}    sleep_time=${20}

Set nrcellid suit varaible
    [Arguments]    ${cellid}    ${gnb_index}=${0}
    ${nrcellid}    COAM Get nrcellid with the lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    set suite variable    ${nrcellid}

Power UE Start DL traffic
    [Arguments]    ${dl_throughput}   ${duration}=${DL_TIME}    ${dl_length}=${DL_LENGTH}    ${dl_port}=${DL_PORT}
    ...    ${ue_index}=${0}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=${duration}
    ...                       iperf_port=${dl_port}    ue_index=${0}    cap_index=${0}    buffer_size=${dl_length}

Power UE Start UL traffic
    [Arguments]    ${ul_throughput}   ${duration}=${UL_TIME}    ${ul_length}=${UL_LENGTH}    ${ul_port}=${UL_PORT}
    ...    ${ue_index}=${0}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    duration=${duration}
    ...                       iperf_port=${ul_port}    ue_index=${0}    cap_index=${0}    buffer_size=${ul_length}
    ...                       iperf_type=via_command

Stop ul dl data transfer
    [Arguments]    ${ue_index}=${0}
    power_ue.Stop traffic    ue_type=${ue_type}   direction=ul    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}   direction=dl    ue_index=${ue_index}

Slave disconnect
    run keyword and ignore error    csn.disconnect    connection=ASIK0_Slave
    run keyword and ignore error    csn.disconnect    connection=ASIK1_Slave

Delete all NRADJGNB object
    Delete NRADJGNB object on gnb    gnb_index=${0}
    Delete NRADJGNB object on gnb    gnb_index=${1}

Delete NRADJGNB object on gnb
    [Arguments]    ${gnb_index}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
    selenium_coam.disable_message_box
    Run Keyword And Ignore Error    selenium_coam.remove_object
    ...    object_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRADJGNB-0
    sleep    3s
    Run Keyword And Ignore Error    selenium_coam.remove_object
    ...    object_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRADJGNB-1
    sleep    3s
    Run Keyword And Ignore Error    selenium_coam.remove_object
    ...    object_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRADJGNB-2
    sleep    3s
    Run Keyword And Ignore Error    selenium_coam.remove_object
    ...    object_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].instance_id}/XNLINK-0
    sleep    3s
    Run Keyword And Ignore Error    selenium_coam.remove_object
    ...    object_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].instance_id}/XNLINK-1
    sleep    3s
    Run Keyword And Ignore Error    selenium_coam.remove_object
    ...    object_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].instance_id}/XNLINK-2
    sleep    3s
    selenium_coam.validate_plan
    sleep    5s
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
    sleep    5s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

Check the throughput on enb UI
    [Arguments]     ${eNB_asik_addr}=${asik_addr}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${eNB_asik_addr}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    Check the bts counter M8012C71 from ${M8012C71_path} as 10000
    Check the bts counter M8012C76 from ${M8012C76_path} as 10000
    sleep    5s
    [Teardown]    Run keyword and ignore error   selenium_coam.logout

Check the bts counter ${counter_id} from ${counter_path} as ${expected_value}
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id}
    ...                 full_path=${counter_path}
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}

Prepare with PM counter time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}
