*** Settings ***
Documentation
...  author:      Jagoda Kubacka
...  contact:     jagoda.kubacka@nokia.com
...  description: The keywords for test for CB009068 feature.

Resource    ../../../../cloud_common_resources/pods_and_containers/pods.robot
Resource    taf/rfrl/cbts/utilities/init_variables.robot
Resource    ../../../cloud_common_resources/variables/variables.robot

Library     taf.transport.ssh    WITH NAME    csn

*** Variables ***
${INPUT_CP_TRAFFIC_5G_BH_CHAIN}=    nft list chain ip filter CP_TRAFFIC_5G_BH
${INPUT_NGXN_CHAIN}=   nft list chain ip filter NGXN_CHAIN
${INPUT_LIST_SET}=     nft list set ip filter
${table}               /usr/bin/trs-vppctl show ip4_range_classify tables
${8524_vdu_addr}=      10.45.186.137
${8525_vdu_addr}=      10.45.186.138

*** Keywords ***
Get ID for Trsconfig Container
    ${output}             Get All Pods    hw_type=vCU
    ${lines}=             Split String    ${output}    \n
    FOR    ${i}    IN    @{lines}
        ${match}          Run Keyword And Return Status    Should Match Regexp    ${i}    .*trsconfig.*
        ${pod_name}=      Set Variable If    ${match}    ${i}
        Exit For Loop If  ${match}
    END
    ${pod_name}=          Fetch From Left    ${pod_name}    ${SPACE}
    [Return]              ${pod_name}

Get IPs From Primary Node
    ${primary_conn}=                     Connect to ADMIN    hw_type=vCU
    vcu_admin.get_current_plan_file    path=${OUTPUT_DIR}/${TEST_NAME}.xml    include_runtime_data=${True}
    ...                                connection=${primary_conn}
    scf.Load Scf                       ${OUTPUT_DIR}/${TEST_NAME}.xml
    Disconnect from ADMIN    hw_type=vCU    connection=${primary_conn}
    @{vcu_xnlink}=                     scf.Get All Dist Names By Pattern    /XNLINK-[\\d]+$
    @{vcu_xlinks_values}=              Create List
    FOR    ${i}    IN    @{vcu_xnlink}
        Log to console    ${i}
        ${value}=         Check Parameter Value    dist_name=${i}    param_name=localCuIpAddr
        ...               hw_type=vCU
        Append To List    ${vcu_xlinks_values}    ${value}[0]
    END
    ${xnCplaneIpAddr}=    Remove Duplicates    ${vcu_xlinks_values}
    ${xnCplaneLength}=    Get Length           ${xnCplaneIpAddr}
    ${xnCplaneIpAddr}=    Set Variable If     '${xnCplaneLength}'=='1'    ${xnCplaneIpAddr}[0]
    ${ngCplaneIpAddr}=    scf.get_value_from_scf    dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}/SERVEDAMF-1
    ...                                                   p_name=localCuIpAddr
    ${f1CplaneIpAddr}=    scf.get_value_from_scf    dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}/NRDU-1
    ...                                                   p_name=localCuIpAddr
    [Return]      ${xnCplaneIpAddr}    ${ngCplaneIpAddr}    ${f1CplaneIpAddr}

Get IPs From Secondary Node
    ${sec_conn}=                    Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    hw_type=vCU
    vcu_admin.get_current_plan_file    path=${OUTPUT_DIR}/${TEST_NAME}_secondary.xml    include_runtime_data=${True}
    ...                                connection=${sec_conn}
    Disconnect from ADMIN    hw_type=vCU    connection=${sec_conn}
    scf.Load Scf                       ${OUTPUT_DIR}/${TEST_NAME}_secondary.xml
    ${uPlaneRemoteIpAddr}=             get_value_from_scf    dist_name=MRBTS-${MRBTS_CU_2}/NRBTS-${MRBTS}/NRADJGNB-9
    ...                                p_name=ipV4Address    list_name=uPlaneIpAddrList
    [Return]                           ${uPlaneRemoteIpAddr}

Get IPs From Primary Node Remote
    ${connection}=                     Connect to ADMIN    hw_type=vCU
    vcu_admin.get_current_plan_file    path=${OUTPUT_DIR}/${TEST_NAME}.xml    include_runtime_data=${True}
    ...                                connection=${connection}
    Disconnect from ADMIN    hw_type=vCU    connection=${connection}
    scf.Load Scf                       ${OUTPUT_DIR}/${TEST_NAME}.xml
    @{vcu_xnlink}=                     scf.Get All Dist Names By Pattern    /XNLINK-[\\d]+$
    @{vcu_xlinks_values}=              Create List
    FOR    ${i}    IN    @{vcu_xnlink}
        ${value}=         Check Parameter Value    dist_name=${i}    param_name=cPlaneIpAddr
        ...               hw_type=vCU
        Append To List    ${vcu_xlinks_values}    ${value}[0]
    END
    ${xnCplaneIpAddrRemote}=    Remove Duplicates    ${vcu_xlinks_values}
    ${xnCplaneLength}=    Get Length           ${xnCplaneIpAddrRemote}
    ${xnCplaneIpAddrRemote}=    Set Variable If     '${xnCplaneLength}'=='1'    ${xnCplaneIpAddrRemote}[0]    ${xnCplaneIpAddrRemote}
    ${ngCplaneIpAddrRemote}=    scf.get_value_from_scf    dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}/SERVEDAMF-1
    ...                                             p_name=amfIPAddress
    ${f1CplaneIpAddrRemote}=    scf.get_value_from_scf    dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}/NRDU-1
    ...                                                   p_name=remoteDuIpAddr
    [Return]      ${xnCplaneIpAddrRemote}    ${ngCplaneIpAddrRemote}    ${f1CplaneIpAddrRemote}

Get XN-U IPs From Both vCU
    ${connection}=                     Connect to ADMIN    hw_type=vCU
    vcu_admin.get_current_plan_file    path=${OUTPUT_DIR}/${TEST_NAME}.xml    include_runtime_data=${True}
    ...                                connection=${connection}
    Disconnect from ADMIN    hw_type=vCU    connection=${connection}
    scf.Load Scf                       ${OUTPUT_DIR}/${TEST_NAME}.xml
    ${xnUplaneIpAddrPrimary}=    scf.get_value_from_scf
    ...    dist_name=MRBTS-${MRBTS_CU}/TNLSVC-1/TNL-6/IPNO-1/IPIF-3/IPADDRESSV4-1/IPADDRESSV4_R-1
    ...    p_name=localIpAddrAllocated
    ${sec_conn}=                    Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    hw_type=vCU
    vcu_admin.get_current_plan_file    path=${OUTPUT_DIR}/${TEST_NAME}_secondary.xml    include_runtime_data=${True}
    ...                                connection=${sec_conn}
    Disconnect from ADMIN    hw_type=vCU    connection=${sec_conn}
    scf.Load Scf                       ${OUTPUT_DIR}/${TEST_NAME}_secondary.xml
    @{uplane_address}=                 scf.Get All Dist Names By Pattern    /NRADJGNB-[\\d]+$
    ${xnUplaneIpAddrSecondary}=        get_value_from_scf    dist_name=${uplane_address}[0]
    ...                                p_name=ipV4Address    list_name=uPlaneIpAddrList
    [Return]    ${xnUplaneIpAddrPrimary}    ${xnUplaneIpAddrSecondary}

Get IP From Firewall
    [Arguments]    ${nft_tables1}
    ${filtered_names}=    Create List
    ${names}=    Split String    ${nft_tables1}
    FOR    ${i}    IN    @{names}
         ${dot}=    Run Keyword And Return Status   Should Contain    ${i}    .    ignore_case=True
        Run Keyword If    ${dot}    Append To List    ${filtered_names}    ${i}
    END
    @{IpAddrListClear}=    Create List
    FOR    ${i}    IN    @{filtered_names}
        ${i}    Replace String  ${i}  search_for=<name>  replace_with=
        ${i}    Replace String  ${i}  search_for=</name>  replace_with=
        ${i}    Fetch From Left    ${i}    /
        ${i}    Split String    ${i}    _
        Append To List    ${IpAddrListClear}    ${i}[0]
        Append To List    ${IpAddrListClear}    ${i}[1]
    END
    [Return]    ${IpAddrListClear}

Check vDU After Switchover
    [Arguments]       ${f1CplaneIpAddrRemote}
    ${nft_tables}     Get Nft Tables    hw_type=vDU    specific_pod=cprt    command=${INPUT_NGXN_CHAIN}
    Should Contain    ${nft_tables}    NGXN_CHAIN
    Should Contain    ${nft_tables}    ${f1CplaneIpAddrRemote}
    ${alarms}=        Get Active Alarms From BTS    hw_type=vDU
    Should Be Equal   ${alarms}[total]    ${0}
    ${state}=         Get Current BTS State    hw_type=vDU
    Should Be Equal   ${state}    onAir

Check if firewall rules contains remote ip
    [Arguments]       ${remote_ip_addr}
    ${nft_tables}=    Get Nft Tables    hw_type=vDU    specific_pod=cprt
    ...                                 command=nft list table "ip filter" | grep elements
    Should Contain    ${nft_tables}     ${remote_ip_addr}
    ${nft_tables}=    Get Nft Tables    hw_type=vCU    specific_pod=cpif
    ...                                 command=nft list chain "ip filter" NGXN_CHAIN
    Should Contain    ${nft_tables}     @f1CplaneRemoteIpAddr
    Should Contain    ${nft_tables}     ${remote_ip_addr}

Connect to UE PC
    [Documentation]     Setup connection to UE PC
    [Arguments]         ${UE_control_pc}  ${UE_control_pc_user}     ${UE_control_pc_password}  ${alias}=cpc
    Wait Until Keyword Succeeds    1min    20s    csn.Connect to
    ...                            hostname=${UE_control_pc}    username=${UE_control_pc_user}
    ...                            password=${UE_control_pc_password}    alias=${alias}

Disconnect from UE PC
    [Documentation]    Disconnect from UE PC
    [Arguments]        ${session}=cpc
    csn.disconnect     connection=${session}

Turn off UE airplane mode
    [Documentation]     Turn off Airplane mode on UE
    [Arguments]         ${UE_serial_number}     ${session}=cpc
    csn.Send Command    adb -s ${UE_serial_number} shell cmd connectivity airplane-mode disable
    ...                 connection=${session}
    ...                 timeout=5
    Sleep    30s        reason=Wait until airplane mode is off

Check if firewall rules contains both Uplane addresses
    ${ip_range_tables}=    Get Nft Tables    hw_type=vCU    specific_pod=upue    container=trsfp
    ...                                      command=/usr/bin/trs-vppctl show ip4_range_classify tables
    Should Contain         ${ip_range_tables}    ${F1U_VCU}
    Should Contain         ${ip_range_tables}    ${F1U_VDU}

Check if pod is in given redundant role
    [Arguments]        ${pod_nr}    ${state}
    ${pod_command}=    Catenate    SEPARATOR=${EMPTY}    curl -X 'GET' 'http://healing-controller:50056/api/
    ...                vnfcmgmt/v1/vnfcs?verbose=false&name=po-${pod_nr}' -H 'accept:application/json'
    ${pod_output}=     Execute Command on Specific Container    specific_pod=oamext    container=oamagent
    ...                command=${pod_command}    hw_type=vCU
    ${pod_data}=       Get Regexp Matches    ${pod_output}    "redundantRole":"([a-zA-Z]+)"
    ${pod_role}=       Get From List    ${pod_data}    ${0}
    Should Contain     ${pod_role}    ${state}

Block Cell on Second TL
    ${second_vdu_conn}=    Run Keyword If    "${MRBTS}"=="8524"    Connect to ADMIN
    ...                    custom_LMP_addr=${8525_vdu_addr}    hw_type=vDU
    ...                    ELSE    Connect to ADMIN    custom_LMP_addr=${8524_vdu_addr}    hw_type=vDU
    Block Cell             hw_type=vDU    pre-connection=${second_vdu_conn}
    [Teardown]             Disconnect from ADMIN    connection=${second_vdu_conn}    hw_type=vDU

Unblock Cell on Second TL
    ${second_vdu_conn}=    Run Keyword If    "${MRBTS}"=="8524"    Connect to ADMIN
    ...                    custom_LMP_addr=${8525_vdu_addr}    hw_type=vDU
    ...                    ELSE    Connect to ADMIN    custom_LMP_addr=${8524_vdu_addr}    hw_type=vDU
    Unblock Cell           hw_type=vDU    pre-connection=${second_vdu_conn}
    [Teardown]             Disconnect from ADMIN    connection=${second_vdu_conn}    hw_type=vDU

Check Nft Ruleset [A05, positive]
    ${setsIP4}     Get Nft Tables    specific_pod=cpif    hw_type=vCU    command=nft list table "ip filter" | grep elements
    Should Contain    ${setsIP4}     ${XNC_VCU}
    ${cpTip4}      Get Nft Tables    specific_pod=cpif    hw_type=vCU    command=nft list chain "ip filter" CP_TRAFFIC_5G_BH
    Should Contain    ${cpTip4}      NGXN_CHAIN
    ${ngxnCip4}    Get Nft Tables    specific_pod=cpif    hw_type=vCU    command=nft list chain "ip filter" NGXN_CHAIN
    Should Contain        ${ngxnCip4}    ${XNC_VCU}
    Should Contain Any    ${ngxnCip4}    counter packets 1    counter packets 2    counter packets 3
    ...                                  counter packets 4    counter packets 5    counter packets 6
    ...                                  counter packets 7    counter packets 8    counter packets 9

Check Nft Ruleset [A05, negative]
    ${setsIP4}    Get Nft Tables        specific_pod=cpif    hw_type=vCU    command=nft list table "ip filter" | grep elements
    Should Not Contain    ${setsIP4}    ${XNC_VCU}
    ${cpTip4}    Get Nft Tables         specific_pod=cpif    hw_type=vCU    command=nft list chain "ip filter" CP_TRAFFIC_5G_BH
    Should Contain    ${cpTip4}         NGXN_CHAIN
