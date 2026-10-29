*** Settings ***
Documentation     author: Na Li
...               contact: na.li@nokia-sbell.com
...               squad group: MMW_SG_04

Library           taf.ue  WITH NAME   ute_ue
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Library            ./counter_analysis.py    WITH NAME   counter_analysis
Library            taf.sbts.oam.coam.admin  WITH NAME  coam
Library            OperatingSystem
Library            taf.sbts.oam.coam.admin.interface
Library            Collections
Library            OperatingSystem
Library            Collections
Library            BuiltIn
Library            String
#Library            Resources/analysisxml.py
Library            ./counter_analysis.py
Library            taf.hw.rf_attenuator    WITH NAME    att
Library            taf.transport.ssh    WITH NAME    csn
Library            taf.collectors.core      WITH NAME   core
Library            taf.collectors.btslog    WITH NAME   btslog
#Resource          ../../../../resources/common/tm500.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/tm500_hangzhou.robot
Library           taf.rfrl.common_resources.python.gNB_l2_lo_throughput
Resource          taf/rfrl/common_resources/robot/gnb_classical.robot
Resource          ../../5GC000480_samsung/Resources/5GC000480_common_keyword.robot
Resource          taf/rfrl/common_resources/robot/TTI_Trace.robot
#Resource          ../../5GC000478/Resources/1347_common_keyword.robot
Resource          ../../5GC001655/Resources/1347_common_keyword.robot
#Resource          ../../ECE/Radio_Admission_Control/5GC000480/keywordbook-480.robot
Resource          ../../../../SISO/RAN_PZ_HAZ_34/5GC002029-A/Resources/5GC002029_A_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Variables         Resources/5GC000478_modify_para.py
#Variables         Resources/0478_common_Variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Variables ***
${BTS_NAME}                   ${tl.gnbs[0].instance_id}
${NRBTS_NAME}                 ${tl.gnbs[0].global_bts_id}
${DU_OAM_IP}                  ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${dist_name}                  MRBTS-${BTS_NAME}/NRBTS-${NRBTS_NAME}
${parameter1}                 actGnbInitRlf
${parameter2}                 actUeInitRlf
${parameter3}                 actIntraFreqIntraGnbMobilityNSA
${operation}                  update
${conn}                       default
${DU_IP}                      ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBEM_USERNAME}             ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}             ${tl.gnbs[0].cu.oam_http_connection_details.password}
${DU_OAM_SSH_USERNAME_TL}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD_TL}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${connection_1}               cOAM_admin
${couter_id}                  M55116C00005
${couter_id1}                 M55116C00010
${vendor}                    HBTE
${max_attenuation_value}     127
${att_ipaddr}                ${tl.attenuator.ip_addr}
${att_connection_port}       ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_api_port}              ${tl.attenuator.port}
${att_port_5}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_6}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${test_ute}                  ${tl.test_pc.default_ssh_connection_details.addr}
${ute_name}                  ${tl.test_pc.default_ssh_connection_details.username}
${test_password}             ${tl.test_pc.default_ssh_connection_details.password}
${att_port_7}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_8}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${server_ip}                 ${tl.appserver.iperf_details.network_interface_address}

*** Keywords ***
#Step1: Modify Configuration
ADMIN Wait Until BTS OnAir
    [Arguments]    ${timeout}=15 min
    ...            ${interval}=30 sec
    ...            ${alias}=cOAM_admin
    Wait Until Keyword Succeeds    ${timeout}
    ...                            ${interval}
    ...                            ADMIN Check onair
    ...                            admin_alias=${alias}

ADMIN Check onair
    [Arguments]        ${admin_alias}=${LOGGING_ADMIN_ALIAS}
    ${dict_info}=    coam.Get Bts Info    connection=${admin_alias}
    ${state}=    Get From Dictionary    dictionary=${dict_info['status']}    key=proceduralState
    Should be equal    ${state}    OnAir

Connect to DU
    [Arguments]    ${alias}=cOAM_admin
    ${conn}=    coam.connect_to
    ...    bts_host=${DU_IP}
    ...    username=${WEBEM_USERNAME}
    ...    password=${WEBEM_PASSWORD}
    ...    name=${alias}
    [Return]    ${conn}

Disconnect from DU
    [Arguments]    ${alias}=cOAM_admin
    coam.teardown     connection=${alias}

perform muti Parameter recommissioning
    [Arguments]   ${dist_name}    ${parameter}    ${value}=${True}    ${operation}=create    ${connection}=cOAM_admin
    ...    ${skip_parameter_relation_errors}=${True}     ${should_activate}=${True}
    coam.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    value=${value}
    ...    operation=${operation}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}
    ...    connection=${connection}

COAM Teardown gnb connections
    [Arguments]    ${connection}=GNB_OAM
    coam.teardown    connection=${connection}

Change Configuration
    ${dict1}    create dictionary    parameterName=${parameter1}    operation=update    value=${False}
    ${dict2}    create dictionary    parameterName=${parameter2}    operation=update    value=${True}
    ${dict3}    create dictionary    parameterName=${parameter3}    operation=update    value=${True}
    ${list}    create list    ${dict1}    ${dict2}    ${dict3}
    coam.perform_object_recommissioning    dist_name=${dist_name}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    connection=cOAM_admin
    ADMIN Wait Until BTS OnAir

Change Configuration GNB
    ${dict1}    create dictionary    parameterName=${parameter1}    operation=update    value=${True}
    ${dict2}    create dictionary    parameterName=${parameter2}    operation=update    value=${False}
    ${dict3}    create dictionary    parameterName=${parameter3}    operation=update    value=${False}
    ${list}    create list    ${dict1}    ${dict2}    ${dict3}
    coam.perform_object_recommissioning    dist_name=${dist_name}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    connection=cOAM_admin
    ADMIN Wait Until BTS OnAir

Adjust the HBTE attenuation value
    [Arguments]      ${value_1}    ${value_2}        ${att_port1}=${att_port_5}
    ...    ${att_port2}=${att_port_6}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    att.set_attenuation     port=${att_port1}    value=${value_1}
    att.set_attenuation     port=${att_port2}    value=${value_2}
    ${value_port1}    att.read_attenuation    port=${att_port1}
    should be equal    ${value_port1}    ${value_1}
    ${value_port2}    att.read_attenuation    port=${att_port2}
    should be equal    ${value_port2}    ${value_2}

Prepare Askey Variables
    [Arguments]  ${ue_index}=${0}
    ${ue_config}   get_common_ue_config   ue_info=${tl.ues[0]}    index=${ue_index}
    set suite variable    ${cpc_ip}     ${ue_config['cpc_ip']}
    set suite variable    ${cpc_username}    ${ue_config['cpc_username']}
    set suite variable    ${cpc_password}    ${ue_config['cpc_password']}
    set suite variable    ${serial}    ${ue_config['serial_number']}
    set suite variable    ${capabilities}    ${ue_config['capabilities']}

Askey attach
    log to console    Askey Attach
    Prepare Askey
    ${5Grach_ed}      inseego.UE Attach
    log to console    Verify attach
    Verify attach     5Grach_ed=${5Grach_ed}    4G_check=False
    log to console    Askey attach successful
    sleep             60s

Prepare Askey
    [Arguments]    ${ue_index}=${0}    &{kwargs}
    Prepare At Cmd Askey    ue_index=${ue_index}

Prepare At Cmd Askey
    [Arguments]  ${ue_index}=${0}    ${reboot_ue}=${False}
    Prepare Askey Variables    ue_index=${ue_index}
    csn.connect_to   ${cpc_ip}     ${cpc_username}    ${cpc_password}
    ...    timeout=120    alias=cpc_${ue_index}
    run keyword if    '${reboot_ue}'=='${True}'    Reboot UE    connection=cpc_${ue_index}
    ute_ue.require_ue    ue_alias=UE_${ue_index}    capabilities=${capabilities[0]}

start extract log
    [Arguments]    ${filename}=gnb_tcpdump1.pcap
    ${connection_1}    csn.connect_to   hostname=${DU_IP}
    ...    username=${DU_OAM_SSH_USERNAME_TL}    password=${DU_OAM_SSH_PASSWORD_TL}    alias=VM
    csn.Send Command   command=cd /ffs/run && tcpdump -n -i br1 -w /tmp/${filename}    connection=${connection_1}
    log to console  start pmut extract log successful
    sleep    5s
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection_1}

end extract log
    ${connection_1}    csn.connect_to   hostname=${DU_IP}
    ...    username=${DU_OAM_SSH_USERNAME_TL}    password=${DU_OAM_SSH_PASSWORD_TL}    alias=VM
    csn.Send Command  command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'   connection=${connection_1}
    ${PID}  csn.Read Output    connection=${connection_1}
    ${PID}  strip_string    ${PID}
    log to console  Extract log successful
    log to console  PID output: ${PID}
    csn.Send Command  command=kill -9 ${PID}    connection=${connection_1}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection_1}

check tcpdump log
    [Arguments]    ${filename}=gnb_tcpdump1.pcap    ${asik}=ASIK Master
    Connect to Common Unit Master
    csn.download_file    remote_path=${gnb_tmp_log_dir}/${filename}    local_path=${OUTPUT DIR}/${filename}
    ...    connection=${asik}
    sleep    2s
    ${release}    Run    tshark -r ${OUTPUT DIR}/${filename} | grep SgNBReleaseRequired
    Should Contain    ${release}    SgNBReleaseRequired
    ${output}    Run    tshark -r ${OUTPUT DIR}/${filename} | grep SgNBReleaseConfirm
    Should Contain    ${output}    SgNBReleaseConfirm
    ${release}    Run    tshark -r ${OUTPUT DIR}/${filename} | grep UEContextRelease
    Should Contain    ${release}    UEContextRelease
    Csn.Disconnect	connection=${asik}

start UL Traffic
    [Arguments]    ${serverip}    ${port}    ${throughput}    ${ue_index}=${0}    ${connection}=cpc_${ue_index}
    csn.connect_to   ${cpc_ip}    ${cpc_username}    ${cpc_password}
    ...    timeout=120    alias=${connection}
    csn.send_command    command=adb -s a4ba5818 shell iperf -u -t 100 -i 1 -p ${port} -P 1 -f m -b ${throughput} -l 1400B -T 64 -c ${serverip} &
    ...    connection=${connection}
    [Teardown]    csn.disconnect    connection=${connection}
Get PID
    [Arguments]    ${connection}    ${command}
    Log To Console    Get PID
    csn.send_command    command=${command}   connection=${connection}
    ${PID}    csn.read output    connection=${connection}
    ${PID}    strip_string    ${PID}
    should not be empty    ${PID}
    [Return]    ${PID}

Wait for counter to be gathered after guard peroid
   [Arguments]  ${interval}
   ${list}=           Create List         00  15  30  45
   ${actualTime}=     Get Current Date    result_format=%M
   ...                                    time_zone=UTC
   ${time_check}    run keyword and return status   List Should Contain Value    ${list}    ${actualTime}
   run keyword if    ${time_check}   Sleep   ${interval} minutes
   5GC002481_common_keywords.PM Wait To Nearest Measurement Period

PM Wait To Nearest Measurement Period
   Log    PM Wait To Nearest Measurement Period    console=yes
   Wait Until Keyword Succeeds                     16 min
   ...                                             1 min
   ...                                             5GC002481_common_keywords.Wait For Right Period
   Sleep                                           60

Wait For Right Period
   ${list}=           Create List         00  15  30  45
   ${actualTime}=     Get Current Date    result_format=%M
   ...                                    time_zone=UTC
   ...                                    increment=8 hours
   ${actualHour}=     Get Current Date    result_format=%H
   ...                                    time_zone=UTC
    ...                                    increment=8 hours
   ${date}=     Get Current Date    result_format=%Y-%m-%d
   ...                                    time_zone=UTC
   ...                                    increment=8 hours
    ${date_nodash}=    Get Current Date    result_format=%Y%m%d
   ...                                    time_zone=UTC
   ${actualEpoch}=    Convert Date	       ${date} ${actualHour}:${actualTime}:00.000	epoch
   List Should Contain Value	           ${list}  ${actualTime}
   Log                                    ${actualTime}
   ${string_epoch}=   Convert To String   ${actualEpoch}
   ${nopoint_epoch}=   fetch from left   ${string_epoch}   .
   ${integer_epoch}=   convert to integer  ${nopoint_epoch}
   ${epoch_minus_interval}=   Evaluate   ${integer_epoch}-15*60
   ${epoch_minus_interval_string}=   Convert To String   ${epoch_minus_interval}
   set test variable    ${epoch_minus_interval_string}

Login DU
    selenium_coam.login    https://${WEBUI_ADDR}    ${WEBUI_USER}    ${WEBUI_PASSWORD}

Check if counters value is correct
   [Documentation]  This keyword can be expanded for getting PM counters at the start of test case (after time slot
   ...   is correct) and collect all counters and iterate over dict here to improve performance.
   [Arguments]  ${counter_id}    ${expected_value}
   Case Setup ready
   ${counter_values}=   coam.get pm counters   ${counter_id}    connection=GNB_OAM
   ${string_values}=   Convert To String   ${counter_values}
   @{all_counter_value}    counter_analysis.get_cell_counter_value    counter_values=${counter_values}    cellId=NRCELL-1
   ...     measType=NNSAUE    measId=${counter_id}    epochTime=${epoch_minus_interval_string}
   ${expected_value}=    convert to integer   ${expected_value}
   ${status}    set variable    ${None}
   FOR    ${i}    IN    @{all_counter_value}
       ${status}    run keyword and return status    Should be True    ${i}>=${expected_value}
       Exit For Loop If    ${status}==${True}
   END
   Should be True    ${status}==${True}
   [Teardown]    coam.teardown     connection=GNB_OAM

Case Setup ready
    Connect to gnb coam via ssl
    sleep   2min


Check if counters value is correct GNB
   [Documentation]  This keyword can be expanded for getting PM counters at the start of test case (after time slot
   ...   is correct) and collect all counters and iterate over dict here to improve performance.
   [Arguments]  ${counter_id}    ${expected_value}
   Case Setup ready
   ${counter_values}=   coam.get pm counters   ${counter_id}    connection=GNB_OAM
   ${string_values}=   Convert To String   ${counter_values}
   @{all_counter_value}    counter_analysis.get_cell_counter_value    counter_values=${counter_values}    cellId=NRCELL-1
   ...     measType=NX2CC    measId=${counter_id}    epochTime=${epoch_minus_interval_string}
   ${expected_value}=    convert to integer   ${expected_value}
   FOR    ${i}    IN    @{all_counter_value}
       ${status}    run keyword and return status    Should be True    ${i}>=${expected_value}
       Exit For Loop If    ${status}==${True}
       set test variable    ${status}
   END
   Should be True    ${status}==${True}
   [Teardown]    coam.teardown     connection=GNB_OAM






