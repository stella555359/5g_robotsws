*** Settings ***
Documentation
...   author: steven.liu@nokia-sbell.com
...   contact: steven.liu@nokia-sbell.com

Library            taf.transport.ssh    WITH NAME    csn
Library    taf.analyzer.pcap    WITH NAME   cap
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Variables ***
${ID}                          1
${MRBTS}                       MRBTS-${tl.gnbs[0].instance_id}
${testline_name}               ${tl.gnbs[0].instance_id}
${DU_IP}                       ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBEM_USERNAME}              ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}              ${tl.gnbs[0].cu.oam_http_connection_details.password}
${1566_C_default_scf}          ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_10.1100_DU.xml
${DU_SSH_IP}                   ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_SSH_USERNAME}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}         ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${listen_port}                 fp0.3
${gnb_path}                    /tmp/
${test_ute}                    ${tl.test_pc.default_ssh_connection_details.addr}
${ute_name}                    ${tl.test_pc.default_ssh_connection_details.username}
${test_password}               ${tl.test_pc.default_ssh_connection_details.password}
${connection_ute}              connection_ute
${bDIA}                        48
${lua_path}       lua_script:/opt/ute/luashark/luashark_script/generated_luashark/luashark.lua

*** Keywords ***
Create IPAPP_BFD
    [Arguments]    ${ip_value}
    ${dict_ipappid}    Create IPAPP list via parameters
    Log To Console      \n Create IPAPP in progress
    Create object    dn=${MRBTS}/TNLSVC-1/TNL-1/IPAPP-${ID}    para_name=${dict_ipappid}
    ${dict_bfd}    Create BFD list via parameters    ip_value=${ip_value}
    Log To Console      \n Create BFD in progress
    Create object    dn=${MRBTS}/TNLSVC-1/TNL-1/IPAPP-1/BFD-${ID}    para_name=${dict_bfd}

Delete IPAPP_BFD
    [Arguments]    ${ip_value}
    ${dict_bfd}    Create BFD list via parameters    ip_value=${ip_value}
    Log To Console      \n Delete IPAPP in progress
    run keyword and continue on failure   Delete object    dn=${MRBTS}/TNLSVC-1/TNL-1/IPAPP-1/BFD-${ID}    para_name=${dict_bfd}
    ${dict_ipappid}    Create IPAPP list via parameters
    Log To Console      \n Delete BFD in progress
    run keyword and continue on failure   Delete object    dn=${MRBTS}/TNLSVC-1/TNL-1/IPAPP-${ID}    para_name=${dict_ipappid}

Create IPAPP list via parameters
    #BuiltIn.Log    \n Create IPAPP object \n    console=yes
    ${ipappid}    create dictionary    parameterName=ipAppId    operation=update    value=${1}
    ${dict_ipappid}    create list    ${ipappid}
    [Return]    ${dict_ipappid}

Create BFD list via parameters
    [Arguments]    ${ip_value}
    #BuiltIn.Log    \n Create BFD parameters \n    console=yes
    ${bfdActivation}    create dictionary    parameterName=bfdActivation    operation=update    value=${True}
    ${bfdAdminUp}    create dictionary    parameterName=bfdAdminUp    operation=update    value=${True}
    ${bfdDestIpAddr}    create dictionary    parameterName=bfdDestIpAddr    operation=update    value=${ip_value}
    ${bfdDetectMult}    create dictionary    parameterName=bfdDetectMult    operation=update    value=3
    ${bfdDscp}    create dictionary    parameterName=bfdDscp    operation=update    value=${bDIA}
    ${bfdId}    create dictionary    parameterName=bfdId    operation=update    value=1
    ${bfdSrcIpAddrDN}    create dictionary    parameterName=bfdSrcIpAddrDN    operation=update
    ...    value=${MRBTS}/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-1
    ${bfdSrcUdpPort}    create dictionary    parameterName=bfdSrcUdpPort    operation=update    value=3784
    ${bfdType}    create dictionary    parameterName=bfdType    operation=update    value=singleHopBFD
    ${desMinTxInt}    create dictionary    parameterName=desMinTxInt    operation=update    value=500
    ${reqMinRxInt}    create dictionary    parameterName=reqMinRxInt    operation=update    value=500
    ${dict_bfd}    create list    ${bfdActivation}    ${bfdAdminUp}    ${bfdDestIpAddr}    ${bfdDetectMult}
    ...    ${bfdDscp}    ${bfdId}    ${bfdSrcIpAddrDN}    ${bfdSrcUdpPort}    ${bfdType}    ${desMinTxInt}
    ...    ${reqMinRxInt}    ${reqMinRxInt}
    [Return]    ${dict_bfd}

Create object
    [Arguments]    ${dn}    ${para_name}
    ${conn}    Connect to DU
    coam.perform_object_recommissioning
    ...    dist_name=${dn}
    ...    parameter=${para_name}    operation=create     skip_parameter_relation_errors=${True}
    ...    should_activate=${True}    connection=${conn}
    [Teardown]    Disconnect from DU

Delete object
    [Arguments]    ${dn}    ${para_name}
    ${conn}    Connect to DU
    coam.perform_object_recommissioning
    ...    dist_name=${dn}
    ...    parameter=${para_name}    operation=delete     skip_parameter_relation_errors=${True}
    ...    should_activate=${True}    connection=${conn}
    [Teardown]    Disconnect from DU

Check cell on air
    BuiltIn.Log    \n Start to check Cell On Air \n    console=yes
    Cloud DU connect to gnb coam via ssl
    COAM Check GNB cell on air
    [Teardown]   COAM Teardown gnb connections

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

Input default SCF
    [Timeout]  20 min
    [Arguments]    ${timeout}=10 min
    ${conn}    Connect to DU
    BuiltIn.Log    \n Input default SCF \n    console=yes
    COAM Commission with scf file ignore error    scf_file_path=${1566_C_default_scf}    connection=${conn}
    BuiltIn.Log    \n wait until gnb cell on air \n    console=yes
    wait until keyword succeeds    ${timeout}    30sec   Cloud DU connect to gnb coam via ssl    connection=${conn}
    wait until keyword succeeds    ${timeout}    30sec   COAM Check GNB cell on air    connection=${conn}
    RUN KEYWORD AND IGNORE ERROR    Disconnect from DU

Start Capture Logs
    [Arguments]    ${logname}
    gNB connections
    Start To Capture Wireshark Logs    filename=${logname}    connection=gnb    interface=fp0.3
    sleep    5s
    [Teardown]    csn.Disconnect    connection=gnb

Start To Capture Wireshark Logs
    [Arguments]     ${filename}    ${connection}    ${interface}
    csn.send command    command=tcpdump -s0 -i ${interface} -w ${gnb_path}${filename}   connection=${connection}

gNB connections
    csn.Connect To    hostname=${DU_SSH_IP}
    ...               username=${DU_SSH_USERNAME}
    ...               password=${DU_OAM_SSH_PASSWORD}
    ...               alias=gnb

Stop and Save Logs
    [Arguments]    ${logname}
    gNB connections
    Stop and download Logs    logname=${logname}    connection=gnb
    [Teardown]    csn.Disconnect    connection=gnb

Stop and download Logs
    [Arguments]    ${logname}    ${connection}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${output_dir}/${logname}   connection=${connection}
    sleep    3

Read Wireshark Log
    [Arguments]    ${filename}    ${filter}=${None}
    cap.Read Cap    cap_file=${LOG_PATH}/${filename}    display_filter=${filter}
    log to console  Read Wireshark Log successful
    ${return_dscp}     Get PARAM Value from Wireshark Log      check_param=ip.dsfield.dscp    element_idx=${0}     condition_expression=${none}
    run keyword and continue on failure    list should contain value  ${return_dscp}   ${dscp_value}

Get PARAM Value from Wireshark Log
    [Arguments]    ${check_param}    ${element_idx}=${0}    ${default_value}=False    ${condition_expression}=${None}
    ${value}     cap.Get Element Value    element_expression=${check_param}    element_idx=${element_idx}
    ...    default_value=${default_value}    condition_expression=${condition_expression}
    log to console  Get PARAM Value from Wireshark Log successful
    [Return]    ${value}

COAM Commission with scf file ignore error
    [Documentation]  Author: Liu Steven
    ...              Description: Do commission and verify commission status
    ...                           2019-11-12, add argument ${is_pdl_checking_needed} to open interface to tester if pdl checking is needed,
    ...                                       Valid values are: ${True} or ${False}, if ${True}, then pdl validation is needed,
    ...                                       otherwise will ignore this validation. Now it's default to ${True}
    [Arguments]  ${scf_file_path}    ${connection}=GNB_OAM    ${timeout}=300    ${is_pdl_checking_needed}=${True}
    &{result}    coam.perform_commissioning    scf_file=${scf_file_path}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${True}    connection=${connection}

Tests_suite_setup
    Input default SCF

Check Alarm Info
    [Arguments]    ${alarmID}    ${alarmInfo}
    Log To Console      \n Start checking alarm
    @{alarms}    selenium_coam.get_active_alarm_info    timeout=${100}    #alarm_filter=${alarm_filter}
    sleep    1s
    log     ${alarms}
    ${fault_id_list}    create list
    ${fault_name_list}    create list
    FOR    ${item}    IN    @{alarms}
        ${fault_id}    get from dictionary    ${item}    Fault ID
        ${fault_name}    get from dictionary    ${item}    Fault name
        append to list    ${fault_id_list}    ${fault_id}
        append to list    ${fault_name_list}    ${fault_name}
    END
    list should contain value     ${fault_id_list}    ${alarmID}
    list should contain value     ${fault_name_list}    ${alarmInfo}
    Log To Console      \n 61605 BFD-1 down in ingress exist

Check BFD Alarm Info Not Exist
    WEBUI Login
    Wait Until Keyword Succeeds    15min    10s    Check Alarm Info Not Exist
    [Teardown]    WEBUI Logout

Check Alarm Info Not Exist
    [Arguments]    ${alarmID}    ${alarmInfo}
    Log To Console      \n Start checking alarm
    @{alarms}    selenium_coam.get_active_alarm_info    timeout=${100}    #alarm_filter=${alarm_filter}
    sleep    1s
    log     ${alarms}
    ${fault_id_list}    create list
    ${fault_name_list}    create list
    FOR    ${item}    IN    @{alarms}
        ${fault_id}    get from dictionary    ${item}    Fault ID
        ${fault_name}    get from dictionary    ${item}    Fault name
        append to list    ${fault_id_list}    ${fault_id}
        append to list    ${fault_name_list}    ${fault_name}
    END
    list should not contain value     ${fault_id_list}    ${alarmID}
    list should not contain value     ${fault_name_list}    ${alarmInfo}
    Log To Console      \n 61605 BFD-1 down in ingress not exist

WEBUI Login
    [Arguments]      ${virtual_enable}=${True}
    [Documentation]   WEBUI Login
    Log To Console  START:WEBUI Login
    Run Keyword If     ${virtual_enable}     Run Keyword And Ignore Error    selenium_coam.Enable_Virtual_Display
    Log To Console  Try to logout before login...
    Run Keyword And Ignore Error    selenium_coam.Logout
    Log To Console  Logout successfully...
    Log To Console  Try to login...
    selenium_coam.Login    url=${DU_URL}     username=${WEBEM_USERNAME}   password=${WEBEM_PASSWORD}
    Log To Console  Login successfully...
    Sleep    15s
    Log To Console  END:WEBUI Login!

WEBUI Logout
    [Arguments]     ${virtual_disable}=${True}
    [Documentation]   WEBUI Logout
    Log To Console  Try to logout...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Enable_Virtual_Display
    Run Keyword And Ignore Error  selenium_coam.Logout
    Log To Console  Logout successfully...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Disable_Virtual_Display
    Sleep    1s
    Log To Console  END:WEBUI Logout!

Modify BFD parameter
    [Arguments]    ${filter_param}    ${new_value}
    Log To Console      \n start change bfdAdminUp to false
    selenium_coam.set parameter value    dist_name=${MRBTS}/TNLSVC-1/TNL-1/IPAPP-1/BFD-1
    ...                              filter_param=${filter_param}
    ...                              new_value=${new_value}
    Active New Parameter Value

Active New Parameter Value
    selenium_coam.validate plan
    ${activate_result}    selenium_coam.activate plan    activate_plan_despite_errors=True    timeout=720
    #Should be true    ${activate_result}
    [Teardown]    run keyword and ignore error    selenium_coam.logout

Create IPAPP_BFD_again
    [Arguments]    ${ip_value}    ${b_Id}   ${bfd_Port}   ${bfd_DN}  ${id}
    ${dict_ipappid}    Create IPAPP list via parameters
    Create object    dn=${MRBTS}/TNLSVC-1/TNL-1/IPAPP-${ID}    para_name=${dict_ipappid}
    ${dict_bfd}    Create BFD list via parameters_again   ip_value=${ip_value}   b_Id=${b_Id}   bfd_Port=${bfd_Port}  bfd_DN=${bfd_DN}
    Create object    dn=${MRBTS}/TNLSVC-1/TNL-1/IPAPP-1/BFD-${id}    para_name=${dict_bfd}

Delete IPAPP_BFD_again
    [Arguments]   ${ip_value}    ${b_Id}   ${bfd_Port}   ${bfd_DN}  ${id}
    ${dict_bfd}    Create BFD list via parameters_again    ip_value=${bfd_dest_ip_addrs}   b_Id=${b_Id}   bfd_Port=${bfd_Port}  bfd_DN=${bfd_DN}
    Delete object    dn=${MRBTS}/TNLSVC-1/TNL-1/IPAPP-1/BFD-${ID}    para_name=${dict_bfd}
    ${dict_ipappid}    Create IPAPP list via parameters
    Delete object    dn=${MRBTS}/TNLSVC-1/TNL-1/IPAPP-${id}    para_name=${dict_ipappid}

Create BFD list via parameters_again
    [Arguments]    ${ip_value}    ${b_Id}   ${bfd_Port}  ${bfd_DN}
    BuiltIn.Log    \n Create BFD parameters \n    console=yes
    ${bfdActivation}    create dictionary    parameterName=bfdActivation    operation=update    value=${True}
    ${bfdAdminUp}    create dictionary    parameterName=bfdAdminUp    operation=update    value=${True}
    ${bfdDestIpAddr}    create dictionary    parameterName=bfdDestIpAddr    operation=update    value=${ip_value}
    ${bfdDetectMult}    create dictionary    parameterName=bfdDetectMult    operation=update    value=3
    ${bfdDscp}    create dictionary    parameterName=bfdDscp    operation=update    value=${bDIA}
    ${bfdId}    create dictionary    parameterName=bfdId    operation=update    value=${b_Id}
    ${bfdSrcIpAddrDN}    create dictionary    parameterName=bfdSrcIpAddrDN    operation=update
    ...    value=${MRBTS}/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-1
    ${bfdSrcUdpPort}    create dictionary    parameterName=bfdSrcUdpPort    operation=update    value=${bfd_Port}
    ${bfdType}    create dictionary    parameterName=bfdType    operation=update    value=singleHopBFD
    ${desMinTxInt}    create dictionary    parameterName=desMinTxInt    operation=update    value=500
    ${reqMinRxInt}    create dictionary    parameterName=reqMinRxInt    operation=update    value=500
    ${dict_bfd}    create list    ${bfdActivation}    ${bfdAdminUp}    ${bfdDestIpAddr}    ${bfdDetectMult}
    ...    ${bfdDscp}    ${bfdId}    ${bfdSrcIpAddrDN}    ${bfdSrcUdpPort}    ${bfdType}    ${desMinTxInt}
    ...    ${reqMinRxInt}    ${reqMinRxInt}
    [Return]    ${dict_bfd}

Create BFD list via parameters_bfd
    [Arguments]    ${ip_value}    ${b_Id}   ${bfd_Port}  ${bfd_DN}
    BuiltIn.Log    \n Create BFD parameters \n    console=yes
    ${bfdActivation}    create dictionary    parameterName=bfdActivation    operation=update    value=${True}
    ${bfdAdminUp}    create dictionary    parameterName=bfdAdminUp    operation=update    value=${True}
    ${bfdDestIpAddr}    create dictionary    parameterName=bfdDestIpAddr    operation=update    value=${ip_value}
    ${bfdDetectMult}    create dictionary    parameterName=bfdDetectMult    operation=update    value=3
    ${bfdDscp}    create dictionary    parameterName=bfdDscp    operation=update    value=${bDIA}
    ${bfdId}    create dictionary    parameterName=bfdId    operation=update    value=${b_Id}
    ${bfdSrcIpAddrDN}    create dictionary    parameterName=bfdSrcIpAddrDN    operation=update
    ...    value=${MRBTS}/TNLSVC-1/TNL-1/IPNO-1/IPIF-3/IPADDRESSV4-1
    ${bfdSrcUdpPort}    create dictionary    parameterName=bfdSrcUdpPort    operation=update    value=${bfd_Port}
    ${bfdType}    create dictionary    parameterName=bfdType    operation=update    value=singleHopBFD
    ${desMinTxInt}    create dictionary    parameterName=desMinTxInt    operation=update    value=500
    ${reqMinRxInt}    create dictionary    parameterName=reqMinRxInt    operation=update    value=500
    ${dict_bfd}    create list    ${bfdActivation}    ${bfdAdminUp}    ${bfdDestIpAddr}    ${bfdDetectMult}
    ...    ${bfdDscp}    ${bfdId}    ${bfdSrcIpAddrDN}    ${bfdSrcUdpPort}    ${bfdType}    ${desMinTxInt}
    ...    ${reqMinRxInt}    ${reqMinRxInt}
    [Return]    ${dict_bfd}

Start to Capture tcpdump
    [Arguments]    ${listen_port}    ${log_dir}    ${filename}     ${connection}
    csn.connect_to   hostname=${DU_OAM_IP}  username=${DU_SSH_USERNAME}   password=${DU_OAM_SSH_PASSWORD}    alias=${connection}
    csn.send command    command=tcpdump -s0 -i ${listen_port} -w ${log_dir}/${filename}
    ...     connection=${connection}
    sleep    8s

Stop and Download tcpdump
    [Arguments]    ${filename}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    5s
    csn.download_file   remote_path=${log_dir}/${filename}     local_path=${BFD_CASE_LOG_PATH}/${filename}
    ...   connection=${connection}
    sleep    5s
    log to console  Download Log successful

Read Log and check
    [Arguments]    ${bfd_log}    ${filter}=${None}
    cap.Read Cap     cap_file=${BFD_CASE_LOG_PATH}/${bfd_log}    display_filter=${filter}
    log to console  Read Wireshark Log successful
    ${return_first_value}     Get PARAM Value from Wireshark Log      check_param=bfd.my_discriminator
    ...    element_idx=${0}     condition_expression=ip.src==${vlan_ip}

    ${return_second_value}     Get PARAM Value from Wireshark Log      check_param=bfd.my_discriminator
    ...    element_idx=${0}     condition_expression=ip.src==${src_ip_second}
    ${return_first_value}    remove duplicates    ${return_first_value}
    ${return_second_value}    remove duplicates    ${return_second_value}
    sort list    ${return_first_value}
    sort list    ${return_second_value}
    run keyword and expect error    *Lists are different*    lists should be equal    ${return_first_value}     ${return_second_value}
    [Teardown]    csn.Disconnect    connection=${connection}

Start to Capture Log
    [Arguments]    ${listen_port}    ${log_dir}    ${bfd_log}     ${connection}
    csn.connect_to   hostname=${DU_OAM_IP}  username=${DU_SSH_USERNAME}   password=${DU_OAM_SSH_PASSWORD}    alias=${connection}
    csn.send command    command=tcpdump -s0 -i ${listen_ports} -w ${log_dir}/${bfd_log}
    ...     connection=${connection}
    sleep    8s

Download Log
    [Arguments]    ${bfd_log}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    5s
    csn.download_file   remote_path=${log_dir}/${bfd_log}     local_path=${BFD_CASE_LOG_PATH}/${bfd_log}
    ...   connection=${connection}
    sleep    5s
    log to console  Download Log successful

#Read Wireshark Log and check
#    [Arguments]    ${filename}    ${filter}=${None}
#    cap.Read Cap     cap_file=${LOG_PATH}/${filename}    display_filter=${filter}
#    log to console  Read Wireshark Log successful
#    ${return_time}     Get PARAM Value from Wireshark Log      check_param=udp.time_relative
#    ...    element_idx=${0}     condition_expression=${None}
#    ${time_value}     judge_time       time_list=${return_time}
#    should be true    ${time_value}
#    [Teardown]    csn.Disconnect    connection=${connection}

Get relative_time from Wireshark log
    [Arguments]    ${filename}    ${condition_expression}
    csn.connect_to    hostname=${test_ute}    username=${ute_name}    password=${test_password}
    ...    alias=connection_ute
    csn.send command
    ...    command=/usr/bin/tshark -r ${output_dir}/${filename} -X ${lua_path} -Y "${filter}" -T fields -e udp.time_relative
    ...    connection=connection_ute
    sleep   5s
    ${return_value}  csn.Read Output   connection=connection_ute
    @{return_value}    Split To Lines    ${return_value}
    ${return_value}    Evaluate     map(eval, ${return_value})
    ${time_value}     judge_time       time_list=${return_value}
    should be true    ${time_value}
    [Teardown]    csn.Disconnect    connection=${connection}


Modify id_para_bfd
     [Arguments]    ${connection}=${None}
     coam.perform_parameter_recommissioning     dist_name=${bfd_dist_name}
    ...                                        parameter=bfdDestIpAddr
    ...                                        operation=update
    ...                                        value=${bfd_dest_ip_addr}
    ...                                        skip_parameter_relation_errors=${True}
    ...                                        should_activate=${True}
    ...                                        connection=${connection}
    sleep  20s

perform muti object recommissioning
    [Arguments]   ${dist_name}    ${parameter}   ${operation}=create   ${skip_parameter_relation_errors}=${True}
    ...    ${should_activate}=${True}    ${connection}=${None}
    coam.perform_object_recommissioning
    ...      dist_name=${dist_name}
    ...      parameter=${PARAMS_TRIGGER}
    ...      operation=create
    ...      skip_parameter_relation_errors= ${True}
    ...      should_activate=${True}
    ...      connection=${connection}

Delete trriger object
    [Arguments]   ${dist_name}    ${parameter}   ${operation}=delete   ${skip_parameter_relation_errors}=${True}
    ...    ${should_activate}=${True}    ${connection}=${None}
    coam.perform_object_recommissioning
    ...      dist_name=${dist_name}
    ...      parameter=${PARAMS_TRIGGER}
    ...      operation=delete
    ...      skip_parameter_relation_errors= ${True}
    ...      should_activate=${True}
    ...      connection=${connection}

Multi para_update
   [Arguments]   ${dist_name_iptr}    ${parameter}   ${value}     ${operation}=update  ${skip_parameter_relation_errors}=${True}
    ...    ${should_activate}=${False}    ${connection}=${None}
   coam.perform_parameter_recommissioning     dist_name=${dist_name_iptr}
    ...                                        parameter=${parameter}
    ...                                        operation=update
    ...                                        value=${PARAMS_staticRoutes_11}
    ...                                        skip_parameter_relation_errors=${True}
    ...                                        should_activate=${True}
    ...                                        connection=${connection}
    sleep  10s

Get Alarm Info and Check alarm
    [arguments]   ${timeout}   ${exp_alarm_id}    ${connection}=${None}
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
    list should contain value     ${fault_id_list}     ${exp_alarm_id}
#   list should contain value     ${fault_name_list}    ${expect_name}

Get Alarm Info and Check alarm again
    [arguments]   ${timeout}   ${exp_alarm_id}    ${connection}=${None}
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
    list should not contain value     ${fault_id_list}     ${exp_alarm_id}

Download file
    [Arguments]        ${log_dir}    ${filenames}     ${connection}
    csn.connect_to   hostname=${DU_OAM_IP}  username=${DU_SSH_USERNAME}   password=${DU_OAM_SSH_PASSWORD}    alias=${connection}
    sleep    3s
    csn.download_file   remote_path=${log_dir}/${filenames}     local_path=${LOG_PATH}/${filenames}
    ...   connection=${connection}
    sleep     5s
    [Teardown]    csn.Disconnect    connection=${connection}