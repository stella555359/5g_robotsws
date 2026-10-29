*** Settings ***
Documentation
...   author: steven.liu@nokia-sbell.com
...   contact: steven.liu@nokia-sbell.com

Library           taf.sbts.oam.coam.admin       WITH NAME    coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Variables ***
${BTS_NAME}     ${tl.gnbs[0].instance_id}
${dist_name}    MRBTS-${BTS_NAME}/TNLSVC-1/TNL-1/IPNO-1/RTPOL-1
${parameter}    routingPolicies
${operation}    update
${conn}         default
${ASIK_USERNAME}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_PASSWORD}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${DU_IP}             ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBEM_USERNAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}

*** Keywords ***
Rest Login DU
    [Arguments]  ${ip_address}=${tl.gnbs[0].dus[0].f1_m_ip_addr}        ${alias}=default
    ...          ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...          ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    [Documentation]   Rest Login DU
    Run Keyword And Ignore Error    Rest Logout DU   alias=${alias}
    Sleep  2
    ${connection}   coam.Connect To  bts_host=${ip_address}  bts_port=443
    ...                                    name=${alias}
    ...                                    username=${username}  password=${password}
    [Return]  ${connection}

Remove None value from Dictionary
    [Arguments]    ${items}    ${staticRoute}
    FOR    ${key}    ${value}    IN    @{items}
         run keyword if    '${value}'== 'None'    Remove From Dictionary    ${staticRoute}    ${key}
    END

Rest Logout DU
    [Arguments]  ${alias}=default
    [Documentation]   Rest Logout DU
    coam.Teardown  connection=${alias}


Wait Until BTS Should Be Normal
    [Arguments]   ${retry}=400s    ${retry_interval}=10s
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Gnb Cell Should Be Onair

Gnb Cell Should Be Onair
    [Arguments]  ${alias}=default  ${cell_type}=nr
    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
    ${status}      coam.Get_Bts_Statuses   connection=${alias}
    ${operationalState}    Get From Dictionary    ${status}    operationalState
    Should Be Equal as strings    ${operationalState}    Enabled
    ${blockingState}   Get From Dictionary    ${status}    blockingState
    Should Be Equal as strings    ${blockingState}    Unblocked
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    Should Be Equal as strings    ${proceduralState}    OnAir
    #cell info
    ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}
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

Connect to ASIK
    [Arguments]  ${ip_address}=${DU_IP}  ${alias}=cOAM_toor4nsn
    ...         ${user}=${ASIK_USERNAME}     ${password}=${ASIK_PASSWORD}
    ${connection}=  csn.Connect to  hostname=${ip_address}
    ...                             username=${user}
    ...                             password=${password}
    ...                             alias=${alias}
    [Return]    ${connection}
