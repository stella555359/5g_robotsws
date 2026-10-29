*** Settings ***
Documentation
...   author: steven.liu@nokia-sbell.com
...   contact: steven.liu@nokia-sbell.com

Library           taf.sbts.oam.coam.admin       WITH NAME    coam
Library           taf.transport.ssh    WITH NAME    csn
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot


*** Keywords ***
Check cell on air
    BuiltIn.Log    \n Start to check Cell On Air \n    console=yes
    Cloud DU connect to gnb coam via ssl
    COAM Check GNB cell on air
    [Teardown]   COAM Teardown gnb connections

Get gateway
    ${conn}    Connect to DU
    ${get_managed_objects}=    coam.get_managed_objects    class_name=IPRT_A    connection=${conn}
    ${parameters}    get from dictionary    ${get_managed_objects}[0]    parameters
    ${staticRoutes_list}    get from dictionary    ${parameters}     staticRoutes
    ${gateway}    get from dictionary    ${staticRoutes_list}[0]    gateway
    [Return]     ${gateway}
    [Teardown]   Disconnect from DU

Connect to DU
    [Arguments]    ${alias}=cOAM_admin
    ${conn}=    coam.connect_to    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    name=${alias}
    [Return]    ${conn}

Disconnect from DU
    [Arguments]    ${alias}=cOAM_admin
    coam.teardown     connection=${alias}

Add elements to list for ipv4
    [Arguments]    ${para_name}=staticRoutes
    BuiltIn.Log    \n add elements to list for ipv4 \n    console=yes
    ${conn}    Connect to DU
    ${get_managed_objects}=    coam.get_managed_objects    class_name=IPRT_A    connection=${conn}
    ${parameters}    get from dictionary    ${get_managed_objects}[0]    parameters
    ${staticRoutes_list}    get from dictionary    ${parameters}     staticRoutes
    ${gateway}    get from dictionary    ${staticRoutes_list}[0]    gateway
    FOR    ${staticRoute}    IN    @{staticRoutes_list}
         ${items}     Get Dictionary Items    ${staticRoute}
         Remove None value from Dictionary    items=${items}    staticRoute=${staticRoute}
    END
    ${new_dict}    create dictionary   destIpAddr=20.1.1.0   destinationIpPrefixLength=${24}    gateway=${gateway}
    ...    preference=${1}
    append to list    ${staticRoutes_list}    ${new_dict}
    set to dictionary    ${parameters}    staticRoutes=${staticRoutes_list}
    log    ${parameters}
    set to dictionary    ${get_managed_objects}[0]    parameters=${parameters}
    log    ${get_managed_objects}[0]
    log    ${staticRoutes_list}
    coam.perform_parameter_recommissioning     dist_name=${MRBTS}${IPRT}
    ...                                        parameter=staticRoutes
    ...                                        operation=update
    ...                                        value=${staticRoutes_list}
    ...                                        skip_parameter_relation_errors=${True}
    ...                                        should_activate=${True}
    ...                                        connection=${conn}
    [Teardown]    Disconnect from DU

Remove None value from Dictionary
    [Arguments]    ${items}    ${staticRoute}
    FOR    ${key}    ${value}    IN    @{items}
         run keyword if    '${value}'== 'None'    Remove From Dictionary    ${staticRoute}    ${key}
    END

Check IPV4 route
    [Documentation]    Login gNB and check Route on gNB
    [Arguments]    ${DU_IP}    ${ip_flag}    ${gateway}    ${dst_ip}   ${table}=main
    ${rTable}=    getRTable    table=${table}
    log    ${rTable}
    ${result}=              Login and Send Command    commands=ip ${ip_flag} route list table ${rTable}
    Log To Console          \n checking route on table 1${table}: ${result}
    Should Match Regexp     ${result}   ${dst_ip}.*via.*${gateway} dev.*
    [Return]      ${result}

Check IPV4 not route
    [Documentation]    Login gNB and check Route on gNB
    [Arguments]    ${DU_IP}    ${ip_flag}    ${gateway}    ${dst_ip}   ${table}=main
    ${rTable}=    getRTable    table=${table}
    log    ${rTable}
    ${result}=    Login and Send Command    commands=ip ${ip_flag} route list table ${rTable}
    Log To Console    \n checking route on table 1${table}: ${result}
    Should Not Match Regexp     ${result}   ${dst_ip}.*via.*${gateway} dev.*metric 1 pref medium
    [Return]      ${result}

Login and Send Command
    [Documentation]   Login gNB and execute commands on gNB
    [Arguments]    ${commands}
    ${connection}=      Connect to ASIK
    ${result}=          csn.execute         command=${commands}         connection=${connection}
    ${stdout}=          csn.Read Output     connection=${connection}
    ${stderr}=          csn.Read Error      connection=${connection}
    [Teardown]          csn.Disconnect      connection=${connection}
    [Return]    ${result}

Connect to ASIK
    [Arguments]  ${ip_address}=${DU_IP}  ${alias}=cOAM_toor4nsn    ${user}=${ASIK_USERNAME}     ${password}=${ASIK_PASSWORD}
    ${connection}=  csn.Connect to  hostname=${ip_address}    username=${user}    password=${password}    alias=${alias}
    [Return]    ${connection}

Recover the test ENV
    [Timeout]  20 min
    [Arguments]    ${timeout}=10 min     ${if_commission}=${True}
    ${conn}    Connect to DU
    BuiltIn.Log    \n recover the test env \n    console=yes
    run keyword if   ${if_commission}==${True}    COAM Commission with scf file    scf_file_path=${1566_default_scf}    connection=${conn}
    BuiltIn.Log    \n wait until gnb cell on air \n    console=yes
    wait until keyword succeeds    ${timeout}    30sec   Cloud DU connect to gnb coam via ssl    connection=${conn}
    wait until keyword succeeds    ${timeout}    30sec   COAM Check GNB cell on air    connection=${conn}
    [Teardown]    Disconnect from DU

Create IPADDRESSV4-2 Table
    [Arguments]    ${gateway}   ${dest_leng}    ${IPADDRESS_ID}    ${para_name}=staticRoutes
    ${conn}    Connect to DU
    BuiltIn.Log    \n Create IPADDRESSV4-2 Table \n    console=yes
    ${list_para}    Create IPADDRESSV4-2 parameters
    ...    gateway=${gateway}    dest_leng=${dest_leng}    IPADDRESS_ID=${IPADDRESS_ID}
    coam.perform_object_recommissioning
    ...    dist_name=${MRBTS}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-${IPADDRESS_ID}
    ...    parameter=${list_para}    operation=create     skip_parameter_relation_errors=${True}
    ...    should_activate=${False}    connection=${conn}
    BuiltIn.Log    \n add route to list for ipv4 \n    console=yes
    ${get_managed_objects}=    coam.get_managed_objects    class_name=IPRT_A    connection=${conn}
    ${parameters}    get from dictionary    ${get_managed_objects}[0]    parameters
    ${staticRoutes_list}    get from dictionary    ${parameters}     staticRoutes
    FOR    ${staticRoute}    IN    @{staticRoutes_list}
         ${items}     Get Dictionary Items    ${staticRoute}
         Remove None value from Dictionary    items=${items}    staticRoute=${staticRoute}
    END
    ${new_dict}    create dictionary   destIpAddr=${destIpAddr}    destinationIpPrefixLength=${dest_leng}
    ...    gateway=${gateway}    preference=${1}
    append to list    ${staticRoutes_list}    ${new_dict}
    ${output}    coam.perform_parameter_recommissioning     dist_name=${MRBTS}${IPRT}
    ...                                        parameter=staticRoutes
    ...                                        operation=update
    ...                                        value=${staticRoutes_list}
    ...                                        skip_parameter_relation_errors=${TRUE}
    ...                                        should_activate=${False}
    ...                                        connection=${conn}
    Check error after add IPADDRESSV4-2    output=${output}
    [Teardown]    Disconnect from DU

Create IPADDRESSV4-2 parameters
    [Arguments]    ${IPADDRESS_ID}    ${gateway}    ${dest_leng}
    ${dict_Method}    create dictionary    parameterName=ipAddressAllocationMethod    operation=update    value=MANUAL
    ${dict_IPV4id}    create dictionary    parameterName=ipAddressV4Id    operation=update    value=${IPADDRESS_ID}
    ${dict_Addr}    create dictionary    parameterName=localIpAddr    operation=update    value=${gateway}
    ${dict_PreLen}    create dictionary    parameterName=localIpPrefixLength    operation=update    value=${dest_leng}
    ${list_para}    create list    ${dict_Method}    ${dict_IPV4id}    ${dict_Addr}    ${dict_PreLen}
    [Return]    ${list_para}

Check error after add IPADDRESSV4-2
    [Arguments]    ${output}
    ${activate_result}    get from dictionary    ${output}    validationResult
    ${activate_result1}    get from dictionary    ${activate_result}    pdlValidationResult
    ${activate_result2}    get from dictionary    ${activate_result1}    logs
    ${activate_result3}    get from dictionary    ${activate_result2}    relationErrors
    ${activate_result4}    get from dictionary    ${activate_result3}[0]    feedback
    should contain    ${activate_result4}    ${errorMsg1}
    should contain    ${activate_result4}    ${errorMsg2}

Delete elements to list for ipv4
    [Arguments]    ${para_name}=staticRoutes
    BuiltIn.Log    \n delete elements to list for ipv4 \n    console=yes
    ${conn}    Connect to DU
    ${get_managed_objects}=    coam.get_managed_objects    class_name=IPRT_A    connection=${conn}
    ${parameters}    get from dictionary    ${get_managed_objects}[0]    parameters
    ${staticRoutes_list}    get from dictionary    ${parameters}     staticRoutes
    FOR    ${staticRoute}    IN    @{staticRoutes_list}
         ${items}     Get Dictionary Items    ${staticRoute}
         Remove None value from Dictionary    items=${items}    staticRoute=${staticRoute}
    END
    remove_from_list    ${staticRoutes_list}    index=1
    coam.perform_parameter_recommissioning     dist_name=${MRBTS}${IPRT}
    ...                                        parameter=staticRoutes
    ...                                        operation=update
    ...                                        value=${staticRoutes_list}
    ...                                        skip_parameter_relation_errors=${True}
    ...                                        should_activate=${True}
    ...                                        connection=${conn}
    [Teardown]    Disconnect from DU

Step1: Case Setup ready
    1566_2238_common_keyword.Du login page via webUI
    selenium_coam.set parameter value    dist_name=${DST_FOR_FRM}    filter_param=DSCP   new_value=${dscp_value}
    Active New Parameter Value
    [Teardown]    Run Keyword And Ignore error    DU COAM selenium logout

Du login page via webUI
    [Documentation]  Author: Tian Chun
    ...              Description: If case failed, the snapshot from webUI will be stored in the ${download_dir} folder
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${DU_IP}
    ...                    username=${WEBEM_USERNAME}
    ...                    password=${WEBEM_PASSWORD}
    selenium_coam.disable_message_box

Active New Parameter Value
    selenium_coam.validate plan
    ${activate_result}    selenium_coam.activate plan    activate_plan_despite_errors=True    timeout=720

Step2: attach multi power ue
    [Arguments]    ${ue_num}
    log to console       Prepare UE
    FOR    ${item}    IN RANGE    ${ue_num}
         ${status}    run keyword and return status    power ue attach again    ${item}
         run keyword if  not ${status}    power ue attach again    ${item}
    END
    start multi power ue traffic ul  ue_num=${1}    ul_throughput=${ul_throughput}

power ue attach again
    [Arguments]    ${ue_index}
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=samsung    log_type=Aasyslog
    power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False

start multi power ue traffic ul
    [Arguments]    ${ue_num}    ${ul_throughput}=${None}    ${ul_duration}=6000    ${protocol}=udp
    log to console      Start traffic    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
         power_ue.Start traffic    ue_index=${item}    direction=ul    iperf_port=${ue_power_port}
         ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=samsung    iperf_type=via_command    protocol=${protocol}
          sleep    1s
    END

Step3: Start to Capture wireshark Log
    [Arguments]    ${listen_port}    ${log_dir}    ${filename}     ${connection}=cu_conn
    csn.connect_to   hostname=${CU_OAM_IP}  username=${CU_SSH_USERNAME}    password=${CU_OAM_SSH_PASSWORD}    alias=${connection}
    csn.send command    command=ssh mmw-${tl_name}-1-upue-000.local -- timeout 3 sudo tcpdump -i ${listen_port} -w ${log_dir}/${filename} -Z root
    ...     connection=${connection}
    sleep    3s
    Stop and Download Log     filename=${filename}
    stop multi power ue traffic ul    ue_num=${1}

Stop and Download Log
    [Arguments]    ${filename}    ${connection}=cu_conn
    csn.Execute    command=ssh mmw-${tl_name}-1-upue-000.local -- sudo killall tcpdump    connection=${connection}
    csn.send command    command=ssh mmw-tl721-1-upue-000.local -- sudo scp /tmp/${filename} mmw-${tl_name}-1-oam-000.local:/tmp
    ...  connection=${connection}
    sleep    20s
    csn.send command    command=ssh mmw-tl721-1-upue-000.local -- sudo rm /tmp/${filename}    connection=${connection}
    csn.connect_to    hostname=${test_ute}    username=${ute_name}    password=${test_password}    alias=connection_ute
    csn.send command   command=sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "${CU_OAM_IP}"     connection=connection_ute
    csn.send command   command=sudo sshpass -p rastre1 scp robot@${CU_OAM_IP}:/tmp/${filename} ${DSCP_CASE_LOG_PATH}
    ...     connection=connection_ute
    sleep    30s
    csn.Disconnect    connection=connection_ute
    log to console  Download Log successful

stop multi power ue traffic ul
    [Arguments]    ${ue_num}    ${protocol}=tcp    ${if_ul}=${True}
    log to console     Stop traffic    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
         run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=samsung    iperf_type=via_command
         ...    protocol=${protocol}    iperf_port=${ue_power_port}
    END

Convert pcap to text And Get txt Content
    [Arguments]      ${pacp_filename}  ${txt_filename}    ${except_ver_value}    ${except_DU_URL}    ${except_F1_U}
    Connect to TestPc
    Convert pcap to text    source=${DSCP_CASE_LOG_PATH}/${pacp_filename}
    ...  target=${DSCP_CASE_LOG_PATH}/${txt_filename}   filter=" "  connection=TestPc
    ${dscp_list}  ${version_number}  ${du_ip}  ${F1_U_ip}      get_DSCP_by_txt_file    file_path=${DSCP_CASE_LOG_PATH}/${txt_filename}
    ...    message=DSCP: AF11
    Run keyword And Continue on Failure     list should contain value      ${dscp_list}   ${dscp_value}
    Run keyword And Continue on Failure     Should be equal as integers    ${version_number}   ${except_ver_value}
    Run keyword And Continue on Failure     Should Be Equal As Strings     ${du_ip}   ${except_DU_URL}
    Run keyword And Continue on Failure     Should Be Equal As Strings     ${F1_U_ip}   ${except_F1_U}
    [Teardown]  Run keyword and ignore error    csn.Disconnect	connection=TestPc

Convert pcap to text
    [Arguments]  ${source}   ${target}   ${filter}   ${connection}
    ssh.send_command
    ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y ${filter}
    ...  connection=${connection}
    Sleep    40s
#    ssh.await execution end  connection=${connection}  timeout=30min

Case Teardown
    [Arguments]  ${connection}=cu_conn
    csn.Disconnect    connection=${connection}
    CI_interface.Common Case Teardown

################### UTE Cloud ######################
Commission_CU_DU
    [Documentation]
    ...                Description: do cu and du commission
    Cloud DU connect to gnb coam via ssl    bts_host=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    COAM Commission with scf file
    ...    scf_file_path=${CURDIR}/../../../../commissionings/HGZ/7_5_UTE5G401T721/SCF_10.1100_DU.xml
    ...    is_pdl_checking_needed=${False}    timeout=1200
    CU Full Commission
    ...    path_of_commission_file=${CURDIR}/../../../../commissionings/HGZ/7_5_UTE5G401T721/SCF_10.1100_CU.xml
    wait until keyword succeeds    25 min    10 sec    COAM Check GNB cell on air
    COAM Teardown gnb connections

Test Suite Setup
    Commission_CU_DU
