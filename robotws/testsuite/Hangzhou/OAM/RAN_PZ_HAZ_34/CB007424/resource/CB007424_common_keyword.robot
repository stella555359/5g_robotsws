*** Settings ***
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library         taf.sbts.oam.coam.admin  WITH NAME   coam

*** Variables ***
${DU_OAM_IP}              ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_USER}             ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}         ${tl.gnbs[0].cu.oam_http_connection_details.password}
${DU_SSH_USERNAME}          ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${MRBTS_ID}               ${tl.gnbs[0].instance_id}
${DN_NAME}               MRBTS-${tl.gnbs[0].instance_id}
${package}                SBTS00_ENB_9999_220601_000018
${url}               https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS00_packages/${package}/
${package_name}           ${package}_release_BTSSM_downloadable_A54.zip
${TEST_PC_IP}        ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}      ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}      ${tl.test_pc.default_ssh_connection_details.password}
${connection}       du_conn
${sw_package}          /home/ute/SBTS00_ENB_9999_220601_000018_release_BTSSM_downloadable_A54.zip

*** Keywords ***
Download Software
    [Arguments]  ${url}    ${package_name}    ${connection}=TEST_PC
    log to console    Start download software
    ${package}    set variable    ${url}${package_name}
    csn.Connect to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}     alias=${connection}
    csn.Execute    command=cd /home/ute;wget ${package}    connection=${connection}
    sleep    3min
    ${sw_package}   set variable    /home/ute/${package_name}
    [Return]  ${sw_package}
    [Teardown]  Run keyword and ignore error    csn.disconnect    connection=${connection}

Connect to DU and update Software
    [Arguments]    ${sw_package}     ${should_active}   ${connection}=default      ${timeout}=30min
    ${connection}    SBTS Login
    log to console    start software update
    ${result}    coam.update_software    sw_package=${sw_package}    should_activate=${should_active}
    ...    timeout=${timeout}    connection=${connection}
    [Teardown]  Run keyword and ignore error   SBTS Logout

SBTS Login
    [Arguments]    ${ip_address}=${DU_OAM_IP}    ${username}=${WEBUI_USER}
    ...    ${password}=${WEBUI_PASSWORD}    ${alias}=default
    Connect to gnb coam via ssl    bts_host=${ip_address}    username=${username}    password=${password}    connection=${alias}
    ${connection}    set variable    ${alias}
    [Return]    ${connection}

SBTS Logout
    [Arguments]   ${alias}=default
    coam.Teardown    connection=${alias}

Rollback_Software_via_WebEM
    ${connection}    SBTS Login
    coam.rollback_software     timeout=2400  connection=${connection}
    [Teardown]  Run keyword and ignore error   SBTS Logout

Check BTS Should Be Normal
     [Arguments]    ${all_cell_info}=${all_cell_info}
    Log To Console  Check BTS Should Be Normal
    SBTS Login
    Wait Until BTS Should Be Normal     all_cell_info=${all_cell_info}
    [Teardown]   Run Keyword And Ignore Error   SBTS Logout

Wait Until BTS Should Be Normal
    [Arguments]   ${all_cell_info}=${all_cell_info}
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Gnb Cell Should Be Onair    all_cell_info=${all_cell_info}

Gnb Cell Should Be Onair
    [Arguments]  ${all_cell_info}=${all_cell_info}  ${alias}=default  ${cell_type }=nr
    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
    ${status}      coam.Get_Bts_Statuses   connection=${alias}
    ${operationalState}    Get From Dictionary    ${status}    operationalState
    Should Be Equal    ${operationalState}    Enabled
    ${blockingState}   Get From Dictionary    ${status}    blockingState
    Should Be Equal    ${blockingState}    Unblocked
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    Should Be Equal    ${proceduralState}    OnAir
    #cell info
    FOR    ${item}    IN    @{all_cell_info}
        ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}
        ${Status}    Get From Dictionary    ${cell_status[${item}]}    status
        ${tmp}   Get From Dictionary    ${status}    operationalState
        Should Be Equal    ${tmp}    enabled
#        ${tmp}   Get From Dictionary    ${status}   availabilityStatus
#        Should Be Equal    ${tmp}    Online
        ${tmp}   Get From Dictionary    ${status}  administrativeState
        Should Be Equal    ${tmp}    Unlocked
        ${tmp}   Get From Dictionary    ${status}  blockingState
        Should Be Equal    ${tmp}    Unblocked
        ${tmp}   Get From Dictionary    ${status}  usageState
        Should Be Equal    ${tmp}    Active
   END

delete package in ute
    [Arguments]      ${package_name}    ${connection}=TEST_PC
    log to console    delete package in ute
    ${sw_package}   set variable    /home/ute/${package_name}
    csn.Connect to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}     alias=${connection}
    csn.Execute    command=rm -rf /home/ute/${package_name}     connection=${connection}
    sleep    5s
    [Teardown]  Run keyword and ignore error    csn.disconnect    connection=${connection}

case teardown
    delete package in ute       package_name=${package_name}
    CI_interface.Common Case Teardown

Get Fault List Before BTS upgrade
    ${connection}    SBTS Login
    ${fault_name_list}     ${faultlist1}     Get Alarm Info     timeout=1
    sort list    ${faultlist1}
    [Return]    ${faultlist1}
    [Teardown]   Run keyword and ignore error    SBTS Logout

Get Fault List After BTS upgrade
    ${connection}    SBTS Login
    ${fault_name_list}     ${faultlist2}     Get Alarm Info     timeout=1
    sort list    ${faultlist2}
    [Return]    ${faultlist2}
    [Teardown]   Run keyword and ignore error   SBTS Logout

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