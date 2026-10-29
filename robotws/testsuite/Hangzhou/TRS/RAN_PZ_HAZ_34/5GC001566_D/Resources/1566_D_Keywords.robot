*** Settings ***
Documentation
...    author: author: fengyi Liu
...    contact: feng.y.liu@nokia-sbell.com

Library           taf.sbts.oam.coam.admin       WITH NAME    coam_rest
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    ../../5GC002236_QA/Resources/common_keyword.robot

*** Variables ***
${BTS_NAME}     ${tl.gnbs[0].global_bts_id}
${MRBTS}     ${tl.gnbs[0].global_bts_id}
${dist_name}    MRBTS-${BTS_NAME}/TNLSVC-1/TNL-1/IPNO-1/RTPOL-1
${parameter}    routingPolicies
${operation}    update
${conn}         default
${gnb_path}    /tmp/
${ASOD_USERNAME}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASOD_PASSWORD}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${DU_IP}             ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBEM_USERNAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${1566_D_default_scf}    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_10.1100_DU.xml
${test_ute}    ${tl.test_pc.default_ssh_connection_details.addr}
${ute_name}    ${tl.test_pc.default_ssh_connection_details.username}
${test_password}    ${tl.test_pc.default_ssh_connection_details.password}
${lua_path}   lua_script:/opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${CURDIR_path}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}

*** Keywords ***
Input default SCF
     ${default_scf}    common_keyword.Get BTS Version And Perare SCF    CURDIR_path=${CURDIR_path}
     Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
     COAM Commission with scf file    scf_file_path=${default_scf}
     Wait Until Keyword Succeeds   16min   2min   common_keyword.Check cell on air

Wait Until BTS Should Be Normal
    [Arguments]   ${retry}=400s    ${retry_interval}=10s
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Gnb Cell Should Be Onair

Gnb Cell Should Be Onair
    [Arguments]  ${alias}=default  ${cell_type}=nr
    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
    ${status}      coam_rest.Get_Bts_Statuses   connection=${alias}
    ${operationalState}    Get From Dictionary    ${status}    operationalState
    Should Be Equal as strings    ${operationalState}    Enabled
    ${blockingState}   Get From Dictionary    ${status}    blockingState
    Should Be Equal as strings    ${blockingState}    Unblocked
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    Should Be Equal as strings    ${proceduralState}    OnAir
    #cell info
    ${cell_status}     coam_rest.Get_Cells_Info   cell_type=${cell_type}
    ${Status}    Get From Dictionary    ${cell_status[0]}    status
    ${tmp}   Get From Dictionary    ${status}    operationalState
    Should Be Equal as strings    ${tmp}    Enabled
    ${tmp}   Get From Dictionary    ${status}   availabilityStatus
    Should Be Equal as strings    ${tmp}    Online
    ${tmp}   Get From Dictionary    ${status}  administrativeState
    Should Be Equal as strings    ${tmp}    Unlocked
    ${tmp}   Get From Dictionary    ${status}  blockingState
    Should Be Equal as strings    ${tmp}    Unblocked
    ${tmp}   Get From Dictionary    ${status}  usageState
    Should Be Equal as strings    ${tmp}    Active

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

Connect to ASOD
    [Arguments]  ${ip_address}=${DU_IP}  ${alias}=cOAM_toor4nsn
    ...         ${user}=${ASOD_USERNAME}     ${password}=${ASOD_PASSWORD}
    ${connection}=  csn.Connect to  hostname=${ip_address}
    ...                             username=${user}
    ...                             password=${password}
    ...                             alias=${alias}
    [Return]    ${connection}

Create IPAPP list via parameters
    BuiltIn.Log    \n Create IPAPP object \n    console=yes
    ${ipappid}    create dictionary    parameterName=ipAppId    operation=update    value=${1}
    ${dict_ipappid}    create list    ${ipappid}
    [Return]    ${dict_ipappid}

Create BFD list via parameters
    BuiltIn.Log    \n Create BFD parameters \n    console=yes
    ${bfdActivation}    create dictionary    parameterName=bfdActivation    operation=update    value=${True}
    ${bfdAdminUp}    create dictionary    parameterName=bfdAdminUp    operation=update    value=${True}
    ${bfdDestIpAddr}    create dictionary    parameterName=bfdDestIpAddr    operation=update    value=10.57.243.129
    ${bfdDetectMult}    create dictionary    parameterName=bfdDetectMult    operation=update    value=3
    ${bfdDscp}    create dictionary    parameterName=bfdDscp    operation=update    value=48
    ${bfdId}    create dictionary    parameterName=bfdId    operation=update    value=1
    ${bfdSrcIpAddrDN}    create dictionary    parameterName=bfdSrcIpAddrDN    operation=update
    ...    value=MRBTS-${BTS_NAME}/TNLSVC-1/TNL-1/IPNO-1/IPIF-4/IPADDRESSV4-1
    ${bfdSrcUdpPort}    create dictionary    parameterName=bfdSrcUdpPort    operation=update    value=3784
    ${bfdType}    create dictionary    parameterName=bfdType    operation=update    value=singleHopBFD
    ${desMinTxInt}    create dictionary    parameterName=desMinTxInt    operation=update    value=500
    ${reqMinRxInt}    create dictionary    parameterName=reqMinRxInt    operation=update    value=500
    ${dict_bfd}    create list    ${bfdActivation}    ${bfdAdminUp}    ${bfdDestIpAddr}    ${bfdDetectMult}
    ...    ${bfdDscp}    ${bfdId}    ${bfdSrcIpAddrDN}    ${bfdSrcUdpPort}    ${bfdType}    ${desMinTxInt}
    ...    ${reqMinRxInt}    ${reqMinRxInt}
    [Return]    ${dict_bfd}

Create IPAA object
    [Arguments]    ${ID}
    ${dict_ipappid}    Create IPAPP list via parameters
    Create object    dn=MRBTS-${BTS_NAME}/TNLSVC-1/TNL-1/IPAPP-${ID}    para_name=${dict_ipappid}
    [Return]    ${dict_ipappid}

Create BFD object
    [Arguments]    ${ID}
    ${dict_bfd}    Create BFD list via parameters
    Create object    dn=MRBTS-${BTS_NAME}/TNLSVC-1/TNL-1/IPAPP-1/BFD-${ID}    para_name=${dict_bfd}
    [Return]    ${dict_bfd}

Create object
    [Arguments]    ${dn}    ${para_name}
    ${conn}    Connect to DU
    coam.perform_object_recommissioning
    ...    dist_name=${dn}
    ...    parameter=${para_name}    operation=create     skip_parameter_relation_errors=${True}
    ...    should_activate=${True}    connection=${conn}
    [Teardown]    Disconnect from DU

Delete BFD parameters
    [Arguments]    ${dn}    ${dict_bfd}
    Delete object    dn=${dn}    para_name=${dict_bfd}

Delete IPAPP parameters
    [Arguments]    ${dn}    ${dict_ipappid}
    Delete object    dn=${dn}    para_name=${dict_ipappid}

Delete object
    [Arguments]    ${dn}    ${para_name}
    ${conn}    Connect to DU
    coam.perform_object_recommissioning
    ...    dist_name=${dn}
    ...    parameter=${para_name}    operation=delete     skip_parameter_relation_errors=${True}
    ...    should_activate=${True}    connection=${conn}
    [Teardown]    Disconnect from DU

BFD TCPDUMP LOG
    [Arguments]     ${filename}    ${interface}    ${remote_path}    ${local_path}
    ${conn}   Connect to ASOD
    BuiltIn.Log    \n Start To Capture tcpdump \n    console=yes
    csn.send command    command=tcpdump -s0 -i ${interface} -w ${remote_path}/${filename}    connection=${conn}
    sleep    40s
    BuiltIn.Log    \n Stop To Capture tcpdump \n    console=yes
    csn.send command    command=killall tcpdump     connection=${conn}
    ${tcpdunmp_log}    csn.download_file   remote_path=${remote_path}/${filename}
    ...    local_path=${local_path}/${filename}   connection=${conn}
    [Teardown]    csn.Disconnect    connection=${conn}

Another Check bfd state in tcpdump
    [Arguments]    ${local_path}    ${filename}    ${condition_expression}
    csn.connect_to    hostname=${test_ute}    username=${ute_name}    password=${test_password}
    ...    alias=connection_ute
    csn.send command   command=/usr/bin/tshark -r ${local_path}/${filename} -X ${lua_path} -Y "${condition_expression}" -T fields -e bfd.sta
    ...    connection=connection_ute
    ${return_value}    csn.Read Output    connection=connection_ute
    run keyword and continue on failure    should not be empty    ${return_value}
    sleep    10s
    csn.Disconnect    connection=connection_ute

Check ipv4 route about trigger
    [Documentation]    Login gNB and check Route on gNB
    [Arguments]    ${interface}    ${ip_flag}    ${gateway}   ${table}=main
    ${result}=              Login and Send Command    commands=ip ${ip_flag} route list table ${table}
    Log To Console          \n checking route on table 1${table}: ${result}
    Should Match Regexp     ${result}   default via.*${gateway} dev.*${interface}
    [Return]      ${result}

Check ipv4 route not have about trigger
    [Documentation]    Login gNB and check Route on gNB
    [Arguments]    ${interface}    ${ip_flag}    ${gateway}   ${table}=main
    ${result}=              Login and Send Command    commands=ip ${ip_flag} route list table ${table}
    Log To Console          \n checking route on table 1${table}: ${result}
    Should not Match Regexp     ${result}   default via.*${gateway} dev.*${interface}
    [Return]      ${result}

Login and Send Command
    [Documentation]   Login gNB and execute commands on gNB
    [Arguments]    ${commands}
    ${connection}=    Connect to ASOD
    ${result}=    csn.execute    command=${commands}    connection=${connection}
    ${stdout}=    csn.Read Output    connection=${connection}
    ${stderr}=    csn.Read Error    connection=${connection}
    [Teardown]    csn.Disconnect    connection=${connection}
    [Return]    ${result}

modify parameter
    [Arguments]    ${dn}    ${parameter}    ${value}    ${connection}
    coam.perform_parameter_recommissioning     dist_name=${dn}
    ...                                        parameter=${parameter}
    ...                                        operation=update
    ...                                        value=${value}
    ...                                        skip_parameter_relation_errors=${True}
    ...                                        should_activate=${True}
    ...                                        connection=${connection}

Check cell on air
    BuiltIn.Log    \n Start to check Cell On Air \n    console=yes
    Cloud DU connect to gnb coam via ssl
    COAM Check GNB cell on air
    [Teardown]   COAM Teardown gnb connections


Start Capture Logs
    [Arguments]    ${logname}
    gNB connections
    Start To Capture Wireshark Logs    filename=${logname}    connection=gnb    interface=fp0.3
    sleep    5s
    [Teardown]    csn.Disconnect    connection=gnb

Start To Capture Wireshark Logs
    [Arguments]     ${filename}    ${connection}    ${interface}
    csn.send command    command=tcpdump -s0 -i ${interface} -w ${gnb_path}${filename}   connection=${connection}

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

gNB connections
    csn.Connect To    hostname=${DU_IP}
    ...               username=${ASOD_USERNAME}
    ...               password=${ASOD_PASSWORD}
    ...               alias=gnb

perform muti object recommissioning
    [Arguments]   ${dist_name}    ${parameter}   ${operation}=create   ${skip_parameter_relation_errors}=${True}
    ...    ${should_activate}=${True}    ${connection}=GNB_OAM
    admin.perform_object_recommissioning
    ...      dist_name=${dist_name}
    ...      parameter=${parameter}
    ...      operation=${operation}
    ...      skip_parameter_relation_errors= ${skip_parameter_relation_errors}
    ...      should_activate=${should_activate}
    ...      connection=${connection}

perform muti Parameter recommissioning
    [Arguments]   ${dist_name}    ${parameter}   ${value}     ${operation}=create    ${connection}=GNB_OAM
    ...    ${skip_parameter_relation_errors}=${True}     ${should_activate}=${True}
    admin.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    value=${value}
    ...    operation=${operation}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}
    ...    connection=${connection}
