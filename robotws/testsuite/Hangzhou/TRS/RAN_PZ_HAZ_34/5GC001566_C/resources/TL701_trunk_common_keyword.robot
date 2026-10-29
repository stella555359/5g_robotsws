*** Settings ***
Documentation
...   author: steven.liu@nokia-sbell.com
...   contact: steven.liu@nokia-sbell.com

Library    taf.analyzer.pcap
Library        taf.transport.ssh    WITH NAME    csn
Library    taf.analyzer.pcap    WITH NAME    cap
Library        taf.sbts.oam.coam.admin     WITH NAME      admin
Library        taf.collectors.btslog        WITH NAME    btslog
Library        taf.collectors.core          WITH NAME    core
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot



*** Variables ***
${MRBTS}                       MRBTS-${tl.gnbs[0].instance_id}
${test_line}                   ${tl.gnbs[0].instance_id}
${WEBEM_USERNAME}              ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}              ${tl.gnbs[0].cu.oam_http_connection_details.password}
${1566_C_default_scf}          ${CURDIR}/../../../../../../commissionings/HGZ/7_5_UTE5G401T701/SCF_10.1100_DU.xml
${DU_SSH_IP}                   ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_SSH_USERNAME}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}         ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${test_ute}                    10.57.169.72
${ute_name}                    ute
${test_password}               uteUTE!
${lua_path}                    /opt/luashark/luashark.lua


*** Keywords ***
###################### 1566 keywords ##############################
Modify object
    [Arguments]  ${dn}    ${para_name}    ${operation}
    ${conn}    Connect to DU
    admin.perform_object_recommissioning
    ...    dist_name=${dn}
    ...    parameter=${para_name}    operation=${operation}     skip_parameter_relation_errors=${True}
    ...    should_activate=${True}    connection=${conn}
    [Teardown]    Disconnect from DU

Modify id_para_bfd
    [Arguments]    ${dist_name}    ${parameter}    ${operation}    ${value}    ${connection}=${None}
    admin.perform_parameter_recommissioning   dist_name=${dist_name}
    ...                                        parameter=${parameter}
    ...                                        operation=${operation}
    ...                                        value=${value}
    ...                                        skip_parameter_relation_errors=${True}
    ...                                        should_activate=${True}
    ...                                        connection=${connection}
    sleep  20s

Create IPAPP list via parameters
    #BuiltIn.Log    \n Create IPAPP object \n    console=yes
    ${ipappid}    create dictionary    parameterName=ipAppId    operation=update    value=${1}
    ${dict_ipappid}    create list    ${ipappid}
    [Return]    ${dict_ipappid}

Start to Capture tcpdump
    [Arguments]    ${listen_port}    ${log_dir}    ${filename}     ${connection}=du_con
    csn.connect_to   hostname=${DU_SSH_IP}  username=${DU_SSH_USERNAME}   password=${DU_OAM_SSH_PASSWORD}    alias=${connection}
    csn.send command    command=tcpdump -s0 -i ${listen_port} -w ${log_dir}/${filename}
    ...     connection=${connection}
    sleep    8s

Stop and Download tcpdump
    [Arguments]    ${filename}    ${connection}=du_con
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    5s
    csn.download_file   remote_path=${log_dir}/${filename}     local_path=${LOG_PATH}/${filename}
    ...   connection=${connection}
    sleep    5s
    log to console  Download Log successful
    [Teardown]    csn.Disconnect    connection=${connection}

Download file
    [Arguments]     ${log_dir}    ${filenames}     ${connection}
    csn.connect_to   hostname=${DU_SSH_IP}  username=${DU_SSH_USERNAME}   password=${DU_OAM_SSH_PASSWORD}    alias=${connection}
    sleep    3s
    csn.download_file   remote_path=${log_dir}/${filenames}     local_path=${LOG_PATH}/${filenames}
    ...   connection=${connection}
    sleep     5s
    [Teardown]    csn.Disconnect    connection=${connection}

Get relative_time from Wireshark log
    [Arguments]    ${filename}    ${condition_expression}    ${connection}=connection_ute
    csn.connect_to    hostname=${test_ute}    username=${ute_name}    password=${test_password}
    ...    alias=${connection}
    csn.send command
    ...    command=/usr/bin/tshark -r ${output_dir}/${filename} -X lua_script:${lua_path} -Y "${filter}" -T fields -e udp.time_relative
    ...    connection=connection_ute
    ${return_value}  csn.Read Output   connection=connection_ute
    @{return_value}    Split To Lines    ${return_value}
    ${return_value}    Evaluate     map(eval, ${return_value})
    ${time_value}     judge_time       time_list=${return_value}
    should be true    ${time_value}
    [Teardown]    csn.Disconnect    connection=${connection}

Get PARAM Value from Wireshark Log
    [Arguments]    ${check_param}    ${element_idx}=${0}    ${default_value}=False    ${condition_expression}=${None}
    ${value}     cap.Get Element Value    element_expression=${check_param}    element_idx=${element_idx}
    ...    default_value=${default_value}    condition_expression=${condition_expression}
    log to console  Get PARAM Value from Wireshark Log successful
    [Return]    ${value}

Delete IPAPP_BFD
    [Arguments]    ${ip_value}    ${b_Id}   ${bfd_Port}  ${bfd_DN}   ${ID}
    ${dict_bfd}    Create BFD list via parameters    ip_value=${ip_value}   b_Id=${b_Id}   bfd_Port=${bfd_Port}
    ...    bfd_DN=${bfd_DN}
    Log To Console      \n Delete IPAPP in progress
    run keyword and continue on failure   Modify object    dn=${MRBTS}/TNLSVC-1/TNL-1/IPAPP-1/BFD-${ID}    para_name=${dict_bfd}   operation=delete
    ${dict_ipappid}    Create IPAPP list via parameters
    Log To Console      \n Delete BFD in progress
    run keyword and continue on failure   Modify object    dn=${MRBTS}/TNLSVC-1/TNL-1/IPAPP-${ID}    para_name=${dict_ipappid}    operation=delete

Create IPAPP_BFD
    [Arguments]    ${ip_value}    ${b_Id}   ${bfd_Port}  ${bfd_DN}   ${ID}
    ${dict_ipappid}    Create IPAPP list via parameters
    Modify object    dn=${MRBTS}/TNLSVC-1/TNL-1/IPAPP-${ID}    para_name=${dict_ipappid}    operation=create
    ${dict_bfd}    Create BFD list via parameters   ip_value=${ip_value}    b_Id=${b_Id}   bfd_Port=${bfd_Port}  bfd_DN=${bfd_DN}
    Modify object    dn=${MRBTS}/TNLSVC-1/TNL-1/IPAPP-1/BFD-${ID}    para_name=${dict_bfd}    operation=create

Connect to DU
    [Arguments]    ${alias}=cOAM_admin
    ${conn}=    admin.connect_to
    ...    bts_host=${DU_SSH_IP}
    ...    username=${WEBEM_USERNAME}
    ...    password=${WEBEM_PASSWORD}
    ...    name=${alias}
    [Return]    ${conn}

Disconnect from DU
    [Arguments]    ${alias}=cOAM_admin
    admin.teardown     connection=${alias}

#Read Log and check
#    [Arguments]    ${bfd_log}    ${filter}=${None}
#    cap.Read Cap     cap_file=${LOG_PATH}/${bfd_log}    display_filter=${filter}
#    log to console  Read Wireshark Log successful
#    ${return_first_value}     Get PARAM Value from Wireshark Log      check_param=bfd.my_discriminator
#    ...    element_idx=${0}     condition_expression=ip.src==${vlan_ip}
#    ${return_second_value}     Get PARAM Value from Wireshark Log      check_param=bfd.my_discriminator
#    ...    element_idx=${0}     condition_expression=ip.src==${src_ip_second}
#    ${return_first_value}    remove duplicates    ${return_first_value}
#    ${return_second_value}    remove duplicates    ${return_second_value}
#    sort list    ${return_first_value}
#    sort list    ${return_second_value}
#    run keyword and expect error    *Lists are different*    lists should be equal    ${return_first_value}     ${return_second_value}

Read Log and check
    [Arguments]      ${bfd_log}   ${connection}=TestPc
    Connect to TestPc
    Convert pcap to text    source=${LOG_PATH}/${bfd_log}    target=${LOG_PATH}/bfd_1.txt   filter='ip.src==10.57.243.66'  connection=${connection}
    Convert pcap to text    source=${LOG_PATH}/${bfd_log}    target=${LOG_PATH}/bfd_2.txt   filter='ip.src==10.57.243.70'  connection=${connection}
    ${return_first_value}    Read_Bdf_Log    file_path=${LOG_PATH}/bfd_1.txt
    ${return_second_value}   Read_Bdf_Log    file_path=${LOG_PATH}/bfd_2.txt
    ${return_first_value}    remove duplicates    ${return_first_value}
    ${return_second_value}    remove duplicates    ${return_second_value}
    sort list    ${return_first_value}
    sort list    ${return_second_value}
    run keyword and expect error    *Lists are different*    lists should be equal    ${return_first_value}     ${return_second_value}
    [Teardown]  Run keyword and ignore error    csn.Disconnect	connection=${connection}

Convert pcap to text
    [Arguments]  ${source}   ${target}   ${filter}   ${connection}
    csn.send_command
    ...  command=nice tshark -X lua_script:${lua_path} -V -r ${source} -T text > ${target} -Y ${filter}
    ...  connection=${connection}
    csn.await execution end  connection=${connection}  timeout=30min

Create BFD list via parameters
    [Arguments]    ${ip_value}    ${b_Id}   ${bfd_Port}  ${bfd_DN}    ${bDIA}=48
    #BuiltIn.Log    \n Create BFD parameters \n    console=yes
    ${bfdActivation}    create dictionary    parameterName=bfdActivation    operation=update    value=${True}
    ${bfdAdminUp}    create dictionary    parameterName=bfdAdminUp    operation=update    value=${True}
    ${bfdDestIpAddr}    create dictionary    parameterName=bfdDestIpAddr    operation=update    value=${ip_value}
    ${bfdDetectMult}    create dictionary    parameterName=bfdDetectMult    operation=update    value=3
    ${bfdDscp}    create dictionary    parameterName=bfdDscp    operation=update    value=${bDIA}
    ${bfdId}    create dictionary    parameterName=bfdId    operation=update    value=${b_Id}
    ${bfdSrcIpAddrDN}    create dictionary    parameterName=bfdSrcIpAddrDN    operation=update    value=${bfd_DN}
    ${bfdSrcUdpPort}    create dictionary    parameterName=bfdSrcUdpPort    operation=update    value=${bfd_Port}
    ${bfdType}    create dictionary    parameterName=bfdType    operation=update    value=singleHopBFD
    ${desMinTxInt}    create dictionary    parameterName=desMinTxInt    operation=update    value=500
    ${reqMinRxInt}    create dictionary    parameterName=reqMinRxInt    operation=update    value=500
    ${dict_bfd}    create list    ${bfdActivation}    ${bfdAdminUp}    ${bfdDestIpAddr}    ${bfdDetectMult}
    ...    ${bfdDscp}    ${bfdId}    ${bfdSrcIpAddrDN}    ${bfdSrcUdpPort}    ${bfdType}    ${desMinTxInt}
    ...    ${reqMinRxInt}    ${reqMinRxInt}
    [Return]    ${dict_bfd}

Get Alarm Info and Check alarm
    [Arguments]   ${timeout}   ${exp_alarm_id}    ${flag}    ${connection}=${None}
    sleep    10s
    @{alarms}    admin.get_active_alarms    timeout=${timeout}    connection=${connection}
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
    run keyword if    ${flag}==${True}    list should contain value     ${fault_id_list}     ${exp_alarm_id}
    run keyword if    ${flag}==${False}    list should not contain value     ${fault_id_list}     ${exp_alarm_id}

Delete trriger object
    [Arguments]   ${dist_name}    ${parameter}   ${operation}   ${skip_parameter_relation_errors}=${True}
    ...    ${should_activate}=${True}    ${connection}=${None}
    admin.perform_object_recommissioning
    ...      dist_name=${dist_name}
    ...      parameter=${parameter}
    ...      operation=${operation}
    ...      skip_parameter_relation_errors= ${True}
    ...      should_activate=${True}
    ...      connection=${connection}

1566_017 case teardown
    [Arguments]  ${ip_value}    ${parameter}    ${bfd_Port}    ${dist_name}
    Delete IPAPP_BFD    ip_value=${ip_value}   bfd_Port=${bfd_Port}   bfd_DN=${DN_value}  b_Id=1  ID=1
    ${conn}    Connect to DU
    Delete trriger object    dist_name=${dist_name}    parameter=${parameter}   operation=delete    connection=${conn}
    Disconnect from DU
    CI_interface.Common Case Teardown



###################### 1577 keywords ###############################
1577 case setup
    Log To Console    case setup:change sync to topp
    @{synctype}    Create list  TOPP
    Change Sync Input Type    synctype=${synctype}    sync_key=syncInputType

1577 case teardown
    Log To Console    case teardown:change sync to GNSS
    @{synctype}    Create list    1pps/ToD from external GNSS receiver
    Change Sync Input Type    synctype=${synctype}    sync_key=syncInputType
    Check Sync Status    sync_list_length=${1}    expect_syncInfo_list=${sync_1577_info_1}
    CI_interface.Common Case Teardown

Stop BTS Log and Check Phase Error
    Log To Console    Stop and collect btslog on local machine
    Stop and collect btslog on local machine
    Check Phase Error

Rest Logout DU
    [Arguments]  ${alias}=default
    [Documentation]   Rest Logout DU
    admin.Teardown  connection=${alias}

Rest Login DU
    [Arguments]  ${ip_address}=${DU_SSH_IP}        ${alias}=default
    ...          ${username}=${WEBEM_USERNAME}  ${password}=${WEBEM_PASSWORD}
    [Documentation]   Rest Login DU
    Run Keyword And Ignore Error    Rest Logout DU   alias=${alias}
    Sleep  2
    ${connection}   admin.Connect To  bts_host=${ip_address}  bts_port=443
    ...                                    name=${alias}
    ...                                    username=${username}  password=${password}
    [Return]  ${connection}

Change Sync Input Type
    [Arguments]    ${synctype}    ${sync_key}
    Log To Console    Change Sync Input Type
    Rest Login DU
    ${object_list}    admin.get_managed_objects    class_name=CLOCK_A
    ${parameter}    get from dictionary     ${object_list}[0]    parameters
    ${syncInputList}     get from dictionary    ${parameter}    syncInputList
    ${synctype_length}   Get Length    ${synctype}
    FOR    ${item}    IN RANGE    ${synctype_length}
        set to dictionary    ${syncInputList}[${item}]     ${sync_key}=${synctype}[${item}]
    END
    ${dict}    create dictionary    parameterName=syncInputList    operation=update    value=${syncInputList}
    ${list}    create list    ${dict}
    admin.perform_object_recommissioning    dist_name=MRBTS-${test_line}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    sleep    5min
    [Teardown]    Rest Logout DU


Check BTS Should Be Normal
    Log To Console  Check BTS Should Be Normal
    Rest Login DU
    Wait Until BTS Should Be Normal
    [Teardown]   Run Keyword And Ignore Error   Rest Logout DU

Wait Until BTS Should Be Normal
    [Arguments]   ${retry}=400s    ${retry_interval}=10s
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Gnb Cell Should Be Onair

Gnb Cell Should Be Onair
    [Arguments]  ${alias}=default  ${cell_type }=nr
    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
    ${status}      admin.Get_Bts_Statuses   connection=${alias}
    ${operationalState}    Get From Dictionary    ${status}    operationalState
    Should Be Equal    ${operationalState}    Enabled
    ${blockingState}   Get From Dictionary    ${status}    blockingState
    Should Be Equal    ${blockingState}    Unblocked
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    Should Be Equal    ${proceduralState}    OnAir
    ${cell_status}     admin.Get_Cells_Info   cell_type=${cell_type}
    ${Status}    Get From Dictionary    ${cell_status[0]}    status
    ${tmp}   Get From Dictionary    ${status}    operationalState
    Should Be Equal    ${tmp}    Enabled
    ${tmp}   Get From Dictionary    ${status}   availabilityStatus
    Should Be Equal    ${tmp}    Online
    ${tmp}   Get From Dictionary    ${status}  administrativeState
    Should Be Equal    ${tmp}    Unlocked
    ${tmp}   Get From Dictionary    ${status}  blockingState
    Should Be Equal    ${tmp}    Unblocked
    ${tmp}   Get From Dictionary    ${status}  usageState
    Should Be Equal    ${tmp}    Active

Check Sync Status
    [Arguments]    ${sync_list_length}    ${expect_syncInfo_list}
    Log To Console    Check Sync Status
    ${connection}    Rest Login DU
    ${bts_sync_status}    admin.get_bts_sync_source_status    connection=${connection}
    ${bts_syncMode}    Get From Dictionary    ${bts_sync_status}    syncMode
    should be equal    ${bts_syncMode}    PhaseSync
    ${tuningMode}    Get From Dictionary    ${bts_sync_status}    tuningMode
    should be equal    ${tuningMode}    Normal tuning
    ${syncSourceInfo}    Get From Dictionary    ${bts_sync_status}    syncSourceInfo
    Check SyncSourceInfo Status    syncSourceInfo=${syncSourceInfo}    sync_list_length=${sync_list_length}
    ...    expect_syncInfo_list=${expect_syncInfo_list}
    [Teardown]    Rest Logout DU

Check SyncSourceInfo Status
    [Arguments]    ${syncSourceInfo}    ${sync_list_length}    ${expect_syncInfo_list}
    FOR   ${i}    IN RANGE    ${sync_list_length}
        ${except_single_sync_vlaue}    set variable   ${expect_syncInfo_list}[${i}]
        ${isActive}    Get From Dictionary    ${syncSourceInfo}[${i}]    isActive
        should be equal    ${isActive}    ${except_single_sync_vlaue}[0]
        ${status}    Get From Dictionary    ${syncSourceInfo}[${i}]    status
        ${availability}    Get From Dictionary    ${status}    availability
        should be equal    ${availability}    ${except_single_sync_vlaue}[1]
        ${usability}    Get From Dictionary    ${status}    usability
        should be equal    ${usability}    ${except_single_sync_vlaue}[2]
        ${syncInputPrio}    Get From Dictionary    ${syncSourceInfo}[${i}]    syncInputPrio
        should be equal    ${syncInputPrio}    ${except_single_sync_vlaue}[3]
        ${syncInputType}    Get From Dictionary    ${syncSourceInfo}[${i}]    syncInputType
        should be equal    ${syncInputType}    ${except_single_sync_vlaue}[4]
    END


Start Catch BTS Log
    [Arguments]   ${name}=btslog    ${bts_logs_dir}=/tmp/btslog2
    Log To Console    Start Catch BTS Log
    __Make empty BTS logs dir      bts_logs_dir=${bts_logs_dir}
    btslog.create_btslog_collector    name=${name}    log_dir=${bts_logs_dir}
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}

__Make empty BTS logs dir
    [Arguments]     ${bts_logs_dir}
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi

Disconnect Sync Connector less than 5s
    Log To Console    Disconnect Sync Connector less than 5s
    csn.Connect to    hostname=${DU_SSH_IP}    username=${DU_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}    alias=VM
    sleep    2s
    csn.send_command    command=iptables -I INPUT -s ${TOPMASTERIP} -j DROP    connection=VM
    sleep    3s
    csn.send_command    command=iptables -D INPUT -s ${TOPMASTERIP} -j DROP    connection=VM
    [Teardown]    csn.disconnect    connection=VM

Stop and collect btslog on local machine
    [Arguments]   ${name}=btslog
    Log To Console    Stop and collect btslog on local machine
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}

Check Phase Error
    [Arguments]    ${bts_logs_dir}=/tmp/btslog2
    Log To Console    Check Phase Error
    csn.Connect to    hostname=${test_ute}    username=${ute_name}    password=${test_password}    alias=VM
    sleep    2s
    csn.send_command    cat ${bts_logs_dir}/SYSLOG_1.LOG | grep 'phase error'| grep 'time_object:' | rev |cut -d ' ' -f 1| rev | tail -n 1
    ...    connection=VM
    sleep    2s
    ${output}    csn.read output    connection=VM
    ${number}    evaluate    float(${output})
    should be true    ${number} < ${1500.0}
    [Teardown]    csn.disconnect    connection=VM

################ 2377 keyword ##################
2377 Setup
    Add And Change Sync Input Type    synctype1=1pps/ToD from external GNSS receiver     synctype2=TOPP


2377 Teardown
    Delete And Change Sync Input Type    synctype=1pps/ToD from external GNSS receiver
    CI_interface.Common Case Teardown

Add And Change Sync Input Type
    [Arguments]    ${synctype1}    ${synctype2}
    Log To Console    Add And Change Sync Input Type
    Rest Login DU
    ${object_list}    admin.get_managed_objects    class_name=CLOCK_A
    ${parameter}    get from dictionary     ${object_list}[0]    parameters
    ${syncInputList}     get from dictionary    ${parameter}    syncInputList
    set to dictionary    ${syncInputList}[0]     syncInputType=${synctype1}
    ${structure2}    create dictionary     syncInputPrio=2    syncInputType=${synctype2}
    append to list    ${syncInputList}    ${structure2}
    ${dict}    create dictionary    parameterName=syncInputList    operation=update    value=${syncInputList}
    ${list}    create list    ${dict}
    admin.perform_object_recommissioning    dist_name=${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Log To Console    sleep 5min
    sleep    5min
    [Teardown]    Rest Logout DU

Delete And Change Sync Input Type
    [Arguments]    ${synctype}
    Log To Console    Delete And Change Sync Input Type
    Rest Login DU
    ${object_list}    admin.get_managed_objects    class_name=CLOCK_A
    ${parameter}    get from dictionary     ${object_list}[0]    parameters
    ${syncInputList}     get from dictionary    ${parameter}    syncInputList
    remove from list    ${syncInputList}    1
    set to dictionary    ${syncInputList}[0]     syncInputType=${synctype}
    ${dict}    create dictionary    parameterName=syncInputList    operation=update    value=${syncInputList}
    ${list}    create list    ${dict}
    admin.perform_object_recommissioning    dist_name=${MRBTS}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    sleep    30s
    [Teardown]    Rest Logout DU


################# Setup #####################
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
    Sleep    20s

COAM Commission with scf file ignore error
    [Documentation]  Author: Liu Steven
    ...              Description: Do commission and verify commission status
    ...                           2019-11-12, add argument ${is_pdl_checking_needed} to open interface to tester if pdl checking is needed,
    ...                                       Valid values are: ${True} or ${False}, if ${True}, then pdl validation is needed,
    ...                                       otherwise will ignore this validation. Now it's default to ${True}
    [Arguments]  ${scf_file_path}    ${connection}=GNB_OAM    ${timeout}=300    ${is_pdl_checking_needed}=${True}
    &{result}   admin.perform_commissioning    scf_file=${scf_file_path}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${True}    connection=${connection}


################### UTE Cloud ######################
Commission_CU_DU
    [Documentation]
    ...                Description: do cu and du commission
    Cloud DU connect to gnb coam via ssl    bts_host=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    COAM Commission with scf file
    ...    scf_file_path=${CURDIR}/../../../../commissionings/HGZ/7_5_UTE5G401T701/SCF_10.1100_DU.xml
    ...    is_pdl_checking_needed=${False}    timeout=1200
    CU Full Commission
    ...    path_of_commission_file=${CURDIR}/../../../../commissionings/HGZ/7_5_UTE5G401T701/SCF_10.1100_CU.xml
    wait until keyword succeeds    25 min    10 sec    COAM Check GNB cell on air
    COAM Teardown gnb connections

Test Suite Setup
    Commission_CU_DU
