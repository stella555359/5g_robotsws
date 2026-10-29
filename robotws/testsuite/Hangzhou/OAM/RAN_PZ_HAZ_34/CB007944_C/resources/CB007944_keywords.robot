*** Settings ***
Documentation
...   author: chun.tian@nokia-sbell.com
...   contact: chun.tian@nokia-sbell.com

Library            taf.transport.ssh    WITH NAME    csn
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Variables ***
${DU_OAM_IP}              ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_USER}             ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}         ${tl.gnbs[0].cu.oam_http_connection_details.password}
${DU_SSH_USERNAME}          ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${MRBTS_ID}               ${tl.gnbs[0].instance_id}
${DN_NAME}               MRBTS-${tl.gnbs[0].instance_id}
${netact_nodeusername}      omc
${netact_nodepassword}      Nokia126_
${netact_nodeip}       10.108.248.82

*** Keywords ***
ssh to du to fill stb space
    [Arguments]    ${DU_OAM_IP}    ${DU_SSH_USERNAME}    ${DU_OAM_SSH_PASSWORD}     ${connection}=du_conn
    csn.connect_to   hostname=${DU_OAM_IP}  username=${DU_SSH_USERNAME}   password=${DU_OAM_SSH_PASSWORD}    alias=${connection}
    csn.send command    command=ls -l /ffs/ | grep -i stb | awk '{print $11}'        connection=${connection}
    sleep    2s
    ${return_stb}  csn.Read Output   connection=${connection}
    ${return_stb}     Remove String     ${return_stb}     \n
    csn.send command    command=df -h | grep -i ${return_stb} | awk '{print $1}'       connection=${connection}
    sleep    2s
    ${return_dev}  csn.Read Output   connection=${connection}
    ${return_dev}     Remove String     ${return_dev}     \n
     csn.send command    command=cd /ffs/stb       connection=${connection}
    csn.send command    command=dd if=${return_dev} of=${return_stb}/test.file bs=5G count=5     connection=${connection}
    sleep    5min
    Wait Until Keyword Succeeds      10min    2s    Judge STB_Directory Full    return_stb=${return_stb}
    ...    connection=${connection}

Judge STB_Directory Full
    [Arguments]    ${return_stb}    ${connection}=du_conn
    ssh.send_command    command=df -h |grep ${return_stb}    connection=${connection}
    ${output}    ssh.read output    connection=${connection}
    should contain    ${output}    100%

delete stb file
    [Arguments]    ${DU_OAM_IP}    ${DU_SSH_USERNAME}    ${DU_OAM_SSH_PASSWORD}     ${connection}=du_conn
    csn.connect_to   hostname=${DU_OAM_IP}  username=${DU_SSH_USERNAME}   password=${DU_OAM_SSH_PASSWORD}    alias=${connection}
    csn.send command    command=ls -l /ffs/ | grep -i stb | awk '{print $11}'        connection=${connection}
    sleep    2s
    ${return_stb}  csn.Read Output   connection=${connection}
    ${return_stb}     Remove String     ${return_stb}   \n
    csn.send command      command=rm -rf ${return_stb}/test.file       connection=${connection}

delete package in ute
    [Arguments]      ${package_name}    ${connection}=TEST_PC
    log to console    delete package in ute
    ${sw_package}   set variable    /home/ute/${package_name}
    csn.Connect to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}     alias=${connection}
    csn.Execute    command=rm -rf /home/ute/${package_name}     connection=${connection}
    sleep    5s
    [Teardown]  Run keyword and ignore error    csn.disconnect    connection=${connection}

Precheck SW via connect_to_nom
  [Arguments]   ${DN_NAME}   ${ne_sw_version}    ${activate}    ${download}   ${timeout}     ${precheck}
  ${client_id}     Connect to NOM
  ${DN_NAME}     Create List    ${DN_NAME}
  ${status}   Run Keyword and Continue on Failure    nom.provision_sw    integrated_ids=${DN_NAME}
  ...    ne_sw_version=${ne_sw_version}        precheck=${precheck}    timeout=${timeout}
  ...    download=${download}    activate=${activate}
  log to console    ${status}
  [Teardown]  NOM Logout     client_id=${client_id}
  [Return]  ${status}

Provision SW via connect_to_nom
  [Arguments]   ${DN_NAME}   ${ne_sw_version}    ${activate}    ${download}   ${timeout}    
  ${client_id}     Connect to NOM
  ${DN_NAME}     Create List    ${DN_NAME}
  ${status}   Run Keyword and Continue on Failure    nom.provision_sw    integrated_ids=${DN_NAME}
  ...    ne_sw_version=${ne_sw_version}          timeout=${timeout}
  ...    download=${download}    activate=${activate}
  log to console    ${status}
  [Teardown]  NOM Logout     client_id=${client_id}
  [Return]  ${status}


Connect to NOM
   ${client_id}=  get unique id
   ${client_secret}=  nom.register_the_client   client_id=${client_id}
    ...       username=cnms01
    ...       password=Qwer_1234
    ...       apigw_uri=https://apigw.srncnms07.srnblr.nsn-rdnet.net
   nom.connect_to     user_mgmt_uri=https://user-mgmt.srncnms07.srnblr.nsn-rdnet.net
   ...                apigw_uri=apigw.srncnms07.srnblr.nsn-rdnet.net
   ...                client_id=${client_id}
   ...                client_secret=${client_secret}
   ...                port=443
   ...                username=cnms01
   ...                password=Qwer_1234
   ...                nom_version=nom_v1
   ...                secure=${True}
   [Return]     ${client_id}

NOM Logout
    [Arguments]   ${client_id}
    [Documentation]    Logout NOM via rest api.
    ...  author:             mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  client_id  |  Yes  |  client id returned by NOM Rest Login  |

    ...    *RETURN VALUE*
    ...
    ...    Example
    ...    |  Nom Rest Logout  |  client_id=aaa  |
   nom.delete_the_client  client_id=${client_id}
   ...       username=cnms01
   ...       password=Qwer_1234
   ...       apigw_uri=https://apigw.srncnms07.srnblr.nsn-rdnet.net

Integrate to NOM
    ${client_id}     Connect to NOM
    log to console    deintegrate TL on NOM before run cases
    ${operation_deintegrate_id}    nom.deintegrate_ne  plan_name=${deintegrate_plan_name}  timeout=1200
    log to console    integrate TL on NOM before run cases
    ${operation_integrate_id}    nom.integrate_ne    plan_name=${integrate_plan_name}  timeout=1200    reintegrate=${False}

DeIntegrate to NOM
    ${client_id}=  get unique id
    Run Keyword And Ignore Error    NOM Logout    client_id=${client_id}


Rest Login DU
    [Arguments]    ${ip_address}=${DU_OAM_IP}    ${username}=${WEBUI_USER}
    ...    ${password}=${WEBUI_PASSWORD}    ${alias}=default
    [Documentation]   Rest Login DU
    Connect to gnb coam via ssl    bts_host=${ip_address}    username=${username}    password=${password}    connection=${alias}
    ${connection}     set variable    ${alias}
    [Return]    ${connection}

Disconnect from DU
    [Arguments]    ${alias}=default
    coam.teardown     connection=${alias}

Get Alarm Info
    [Arguments]   ${timeout}    ${connection}=default
    sleep    10s
    @{alarms}    coam.get_active_alarms    timeout=${timeout}    connection=default
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
    [Return]    ${fault_name_list}    ${fault_id_list}

Check BTS Should Be Normal
    Log To Console  Check BTS Should Be Normal
    Rest Login DU
    Wait Until BTS Should Be Normal
    [Teardown]   Run Keyword And Ignore Error   Disconnect from DU

Wait Until BTS Should Be Normal
    [Arguments]   ${retry}=800s    ${retry_interval}=10s
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Gnb Cell Should Be Onair

Gnb Cell Should Be Onair
    [Arguments]  ${alias}=default  ${cell_type }=nr
    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
    ${status}      coam.Get_Bts_Statuses   connection=${alias}
    ${operationalState}    Get From Dictionary    ${status}    operationalState
    Should Be true    '${operationalState}'=='Enabled' or '${operationalState}'=='enabled'
    ${blockingState}   Get From Dictionary    ${status}    blockingState
    Should Be Equal    ${blockingState}    Unblocked
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    Should Be Equal    ${proceduralState}    OnAir
    ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}
    ${Status}    Get From Dictionary    ${cell_status[0]}    status
    ${tmp}   Get From Dictionary    ${status}    operationalState
    Should Be true    '${operationalState}'=='Enabled' or '${operationalState}'=='enabled'
    ${tmp}   Get From Dictionary    ${status}  administrativeState
    Should Be Equal    ${tmp}    Unlocked
    ${tmp}   Get From Dictionary    ${status}  blockingState
    Should Be Equal    ${tmp}    Unblocked
    ${tmp}   Get From Dictionary    ${status}  usageState
    Should Be Equal    ${tmp}    Active

Get gNB SW version string
    [Arguments]
    csn.connect_to   hostname=${DU_OAM_IP}    username=${DU_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}    alias=connection_du
    csn.send command    command=ls -al /ffs/run/ | grep -i TargetBD | grep -v .p7 | awk '{print $9}'
    ...  connection=connection_du
    ${return_active_version}  csn.Read Output   connection=connection_du
    ${return_active_version}     Remove String    ${return_active_version}   TargetBD_
    ${return_active_version}     Remove String    ${return_active_version}   .xml\n
    log to console   ${return_active_version}
    csn.send command    command=ls -al /ffs/stb/ | grep -i TargetBD | grep -v .p7 | awk '{print $9}'
    ...    connection=connection_du
    ${return_passive_version}  csn.Read Output   connection=connection_du
    ${return_passive_version}     Remove String    ${return_passive_version}   TargetBD_
    ${return_passive_version}     Remove String    ${return_passive_version}   .xml\n
    log to console   ${return_passive_version}
    [Teardown]  csn.disconnect     connection=connection_du
    [Return]    ${return_active_version}
