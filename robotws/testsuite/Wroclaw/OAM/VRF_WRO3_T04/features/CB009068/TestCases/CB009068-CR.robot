*** Settings ***
Documentation
...  author:      Jagoda Kubacka
...  contact:     jagoda.kubacka@nokia.com
...  description: The test cases about testing the CB009068-C

Resource    taf/rfrl/cbts/utilities/init_variables.robot
Resource    ../../../../cloud_common_resources/parameters/parameters.robot
Resource    ../../../../cloud_common_resources/resets/resets.robot
Resource    ../../../../cloud_common_resources/alarms/alarms.robot
Resource    ../Resources/CB009068-CR_Resources.robot
Resource    ../../../../cloud_common_resources/commissioning/commissioning.robot

Library    taf.config.scf    WITH NAME    scf
Library    ../Resources/CB009068_Resources.py

*** Variables ***
${B2_TestPC_addr}=    10.42.224.63
${B2_TestPC_user}=    labadmin
${B2_TestPC_pass}=    ZAQ!2wsxCDE#4rfv
${B2_serial_nr}=      HZQN1876AAK82901990
${NGC_addr}=          10.27.28.136
${jump_info}=         jump NGXN_CHAIN
${dummyIP}=           1.2.1.2

*** Keywords ***
CB009068_C_Dynamic_Firewall_Activation_Deactivation_Georedundancy_Switchover
    Log    Step 1: Disabling the actDynamicFirewall parameter    console=true
    Change Parameter on BTS        dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}
    ...                            param_name=actDynamicFirewall    param_value=false    hw_type=vCU
    Wait Until Keyword Succeeds    5min    1min    Check if Unit Status is OnAir    hw_type=vCU
    Log    Step 2: Checking the nft tables if does not contain NGXN_CHAIN    console=true
    ${nft_tables}                  Get Nft Tables    hw_type=vCU    specific_pod=cpif    command=${INPUT_CP_TRAFFIC_5G_BH_CHAIN}
    Should Not Contain             ${nft_tables}    NGXN_CHAIN
    Log    Step 3: Perform reset and check again if nts tables does not contain NGXN_CHAIN    console=true
    Perform Reset and Wait for Expected State    state=onAir   hw_type=vCU
    ${nft_tables}                  Get Nft Tables    hw_type=vCU    specific_pod=cpif    command=${INPUT_CP_TRAFFIC_5G_BH_CHAIN}
    Should Not Contain             ${nft_tables}    NGXN_CHAIN
    Log    Step 4: Activating actDynamicFirewall parameter for vDU and vCU    console=true
    Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}
    ...                        param_name=actDynamicFirewall    param_value=true    hw_type=vCU
    Change Parameter on BTS    dist_name=MRBTS-${MRBTS}/NRBTS-${MRBTS}
    ...                        param_name=actDynamicFirewall    param_value=true    hw_type=vDU
    Log    Step 5: Performing reset for vCU and waiting for onAir state    console=true
    Perform Reset and Wait for Expected State    state=onAir   hw_type=vCU
    Log    Step 6: Getting the IP to check if nft tables contains the proper one    console=true
    ${xnCplaneIpAddr}    ${ngCplaneIpAddr}    ${f1CplaneIpAddr}=    Get IPs From Primary Node
    @{ALL_IPS}    Create List
    Append To List    ${ALL_IPS}    ${xnCplaneIpAddr}  ${ngCplaneIpAddr}  ${f1CplaneIpAddr}
    Log    Step 7: Checking if the nft tables in cpif pod contain NGXN_CHAIN and NX-C, NG-C and F1-C addresses    console=true
    ${nft_tables}              Get Nft Tables    hw_type=vCU    specific_pod=cpif    command=${INPUT_CP_TRAFFIC_5G_BH_CHAIN}
    Should Contain             ${nft_tables}    NGXN_CHAIN
    ${nft_tables}              Get Nft Tables    hw_type=vCU    specific_pod=cpif    command=${INPUT_NGXN_CHAIN}
    Should Contain             ${nft_tables}    ${xnCplaneIpAddr}
    Should Contain             ${nft_tables}    ${ngCplaneIpAddr}
    Should Contain             ${nft_tables}    ${f1CplaneIpAddr}
    ${IpAddrList}         Get Nft Tables    hw_type=vCU    specific_pod=cpif
     ...    command=${INPUT_NGXN_CHAIN} | grep -o '@[^ ]*_1
    Log    Step 8: Getting the addresses from nft tables    console=true
    ${IpAddrList}=    Split String    ${IpAddrList}
    @{IpAddrListClear}=    Create List
    FOR    ${i}    IN    @{IpAddrList}
        ${i}    Replace String  ${i}  search_for=@  replace_with=
        Append To List    ${IpAddrListClear}    ${i}
    END
    Log    Step 9: Getting the addresses from primary node    console=true
    ${xnCplaneIpAddrRemote}    ${ngCplaneIpAddrRemote}    ${f1CplaneIpAddrRemote}=    Get IPs From Primary Node Remote
    Log    Step 10: Comparing the output from nft tables with IP from primary node    console=true
    ${ngCplaneRemoteIpAddrList_1}    Get Nft Tables    hw_type=vCU    specific_pod=cpif
    ...                              command=${INPUT_LIST_SET} ${IpAddrListClear}[0]
    ${xnCplaneRemoteIpAddrList_1}    Get Nft Tables    hw_type=vCU    specific_pod=cpif
    ...                              command=${INPUT_LIST_SET} ${IpAddrListClear}[1]
    ${f1CplaneRemoteIpAddrList_1}    Get Nft Tables    hw_type=vCU    specific_pod=cpif
    ...                              command=${INPUT_LIST_SET} ${IpAddrListClear}[2]
    Should Contain    ${ngCplaneRemoteIpAddrList_1}    ${ngCplaneIpAddrRemote}
    Should Contain    ${f1CplaneRemoteIpAddrList_1}    ${f1CplaneIpAddrRemote}
    Append To List    ${ALL_IPS}    ${ngCplaneIpAddrRemote}  ${f1CplaneIpAddrRemote}
    FOR    ${i}    IN    ${xnCplaneIpAddrRemote}
        Should Contain    ${xnCplaneRemoteIpAddrList_1}    ${i}
        Append To List    ${ALL_IPS}    ${i}
    END
    Log    Step 11: Checking if nft tables upue pod contains NGXN_CHAIN    console=true
    ${nft_tables}                    Get Nft Tables    hw_type=vCU    specific_pod=upue    command=${INPUT_CP_TRAFFIC_5G_BH_CHAIN}
    Should Contain    ${nft_tables}    NGXN_CHAIN
    Log    Step 12: Getting the ID for trsconfig container    console=true
    ${nft_tables}                    Get Nft Tables    hw_type=vCU    specific_pod=upue    command=${table}
    ...                              container=trsfp
    ${podname}=    Get ID for Trsconfig Container
    ${ssh_conn}=       Connect to ADMIN via SSH    hw_type=vCU
    Log    Step 13: Checking if nft tables contains information about enabled dynamic firewall    console=true
    ${nft_tables}=     ssh.Send Command
    ...   kubectl exec -it -n ${CRAN_VCU} ${podname} -- sysrepocfg --export --module nokia-firewall | grep dynamic-firewall-enabled
    ...   connection=${ssh_conn}
    ${nft_tables}=     ssh.Read Output    connection=${ssh_conn}
    ${dynamic_firewall}=    Split String    ${nft_tables}
    FOR    ${i}    IN    @{dynamic_firewall}
        Should Contain    ${i}    true
        Should Not Contain    ${i}    false
    END
    Log    Step 14: Checking if nft tables contains IP addresses from BTS: ${ALL_IPS}    console=true
    ${nft_tables1}=     ssh.Send Command
    ...    kubectl exec -it -n ${CRAN_VCU} ${podname} -- sysrepocfg --export --module nokia-firewall | grep name
    ...    connection=${ssh_conn}
    ${nft_tables1}=     ssh.Read Output    connection=${ssh_conn}
    ${IpAddrListClear1}=    Get IP From Firewall    ${nft_tables1}
    ${IpAddrListClear1}=   Remove Duplicates    ${IpAddrListClear1}
    List Should Contain Sub List    ${IpAddrListClear1}    ${ALL_IPS}
    ${result}=    Remove Elements    ${IpAddrListClear1}    ${ALL_IPS}
    Log    Step 15: Getting the XN-U Plane addresses from both vCU (primary and secondary)    console=true
    ${xnUplaneIpAddrPrimary}    ${xnUplaneIpAddrSecondary}=    Get XN-U IPs From Both vCU
    Should Contain    ${result}    ${xnUplaneIpAddrPrimary}
    Should Contain    ${result}    ${xnUplaneIpAddrSecondary}
    FOR    ${loop}    IN RANGE    0    2
        ${connection}=    Connect to ADMIN    custom_LMP_addr=${VCU_SECOND_IP}    hw_type=vCU
        Log    Step 16: Activating the secondary vCU    console=true
        ${status}=        vcu_admin.activate_cu_vnf    timeout=30    connection=${connection}
        Sleep    60    reason=Waiting when status will be clarified
        ${status1}=    vcu_admin.get_activate_cu_vnf_status    operation_id=${status}[id]    timeout=30    connection=${connection}
        Log    Step 17: The state for status: ${status1}    console=true
        ${status2}=    vcu_admin.get_cu_vnf    timeout=30    connection=${connection}
        Log    Step 18: The state for vCU: ${status2}    console=true
        ${xn_link_status}=    vcu_admin.get_xn_link_status    connection=${connection}
        Should Not Be True    ${xn_link_status}[created][0][is_second_xn_link]
        Disconnect from ADMIN    hw_type=vCU    connection=${connection}
        Log    Step 19: Checking vDU after switchover    console=true
        Check vDU After Switchover    ${f1CplaneIpAddrRemote}
        Log    Step 20: Activating the primary vCU    console=true
        ${connection}=    Connect to ADMIN    hw_type=vCU
        ${status}=        vcu_admin.forcefully_activate_cu_vnf    timeout=30    connection=${connection}
        ${status1}=    vcu_admin.get_forcefully_activate_cu_vnf_status    operation_id=${status}[id]
        ...            timeout=30    connection=${connection}
        Log    Step 21: The state for status: ${status1}    console=true
        ${status2}=    vcu_admin.get_cu_vnf    timeout=30    connection=${connection}
        Log    Step 22: The state for vCU: ${status2}    console=true
        Check vDU After Switchover    ${f1CplaneIpAddrRemote}
        Log    Step 23: Checking vDU after switchover    console=true
    END
    [Teardown]    Disconnect from ADMIN via SSH    connection=${ssh_conn}    hw_type=vCU

Adding_blocking_F1-C_peers
    Log                            Step 2: Turn on actDynamicFirewall    console=true
    Change Parameter on BTS        dist_name=MRBTS-${MRBTS}/NRBTS-${MRBTS}
    ...                            param_name=actDynamicFirewall    param_value=true    hw_type=vDU
    Wait Until Keyword Succeeds    5min    1min    Check if Unit Status is OnAir    hw_type=vDU
    Log                            Step 3: Check if proper firewall rules are present    console=true
    ${remote_ip}=                  Check Parameter Value    param_name=remotef1CplaneIpAddr
    ...                                                     dist_name=MRBTS-${MRBTS}/NRBTS-${MRBTS}/NRDU-${MRBTS}
    ...                                                     hw_type=vDU
    Wait Until Keyword Succeeds    5min     10s    Check if firewall rules contains remote ip    ${remote_ip}
    [Teardown]    Change Parameter on BTS    dist_name=MRBTS-${MRBTS}/NRBTS-${MRBTS}
    ...           param_name=actDynamicFirewall    param_value=false    hw_type=vDU

Allowing_traffic_from_peer_GTP-U_path_endpoints_(F1-U)
    Log                            Step 0: Preconditions    console=true
    Block Cell on Second TL
    Log                            Step 1: Turn on actDynamicFirewall    console=true
    Change Parameter on BTS        dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}
    ...                            param_name=actDynamicFirewall    param_value=true    hw_type=vCU
    Wait Until Keyword Succeeds    5min    1min    Check if Unit Status is OnAir    hw_type=vCU
    Change Parameter on BTS        dist_name=MRBTS-${MRBTS}/NRBTS-${MRBTS}
    ...                            param_name=actDynamicFirewall    param_value=true    hw_type=vDU
    Wait Until Keyword Succeeds    5min    1min    Check if Unit Status is OnAir    hw_type=vDU
    Log                            Step 2: Attach UE to the cell    console=true
    Connect to UE PC               ${B2_TestPC_addr}    ${B2_TestPC_user}    ${B2_TestPC_pass}
    Turn off UE airplane mode      ${B2_serial_nr}
    Log                            Step 3: Check if proper firewall rules are present    console=true
    Wait Until Keyword Succeeds    5min     10s    Check if firewall rules contains both Uplane addresses
    [Teardown]                     Run Keywords    Disconnect from UE PC
    ...    AND                     Unblock Cell on Second TL
    ...    AND                     Change Parameter on BTS          dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}
    ...                            param_name=actDynamicFirewall    param_value=false    hw_type=vCU
    ...    AND                     Change Parameter on BTS          dist_name=MRBTS-${MRBTS}/NRBTS-${MRBTS}
    ...                            param_name=actDynamicFirewall    param_value=false    hw_type=vDU

High_Availability_support_for_firewall_operations
    Log                            Step 0: Turn on actDynamicFirewall    console=true
    ${pod_name}                    Get Pod Prefix    hw_type=vCU
    Change Parameter on BTS        dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}
    ...                            param_name=actDynamicFirewall    param_value=true    hw_type=vCU
    Wait Until Keyword Succeeds    5min    1min    Check if Unit Status is OnAir    hw_type=vCU
    Log                            Step 1: Check linked cPlane address    console=true
    ${XNC_addr_list}=              Check Parameter Value    param_name=cPlaneIpAddr
    ...                            dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}/XNLINK-1    hw_type=vCU
    ${XNC_addr}=                   Get From List    ${XNC_addr_list}    ${0}
    Log                            Step 2: Check which pod is active    console=true
    ${cpif_0_command}=             Catenate    SEPARATOR=${EMPTY}    curl -X 'GET' 'http://healing-controller:50056/api/
    ...                            vnfcmgmt/v1/vnfcs?verbose=false&name=${pod_name}-cpif-0' -H 'accept:application/json'
    ${cpif_1_command}=             Catenate    SEPARATOR=${EMPTY}    curl -X 'GET' 'http://healing-controller:50056/api/
    ...                            vnfcmgmt/v1/vnfcs?verbose=false&name=${pod_name}-cpif-1' -H 'accept:application/json'
    ${cpif_0_output}=              Execute Command on Specific Container    specific_pod=oamext    container=oamagent
    ...                            command=${cpif_0_command}    hw_type=vCU
    ${cpif_1_output}=              Execute Command on Specific Container    specific_pod=oamext    container=oamagent
    ...                            command=${cpif_1_command}    hw_type=vCU
    ${cpif_0_data}=                Get Regexp Matches    ${cpif_0_output}    "redundantRole":"([a-zA-Z]+)"
    ${cpif_1_data}=                Get Regexp Matches    ${cpif_1_output}    "redundantRole":"([a-zA-Z]+)"
    ${cpif_0}=                     Get From List    ${cpif_0_data}    ${0}
    ${cpif_1}=                     Get From List    ${cpif_1_data}    ${0}
    ${status_cpif_0}=              Run Keyword and Return Status    Should Contain    ${cpif_0}    active
    ${status_cpif_1}=              Run Keyword and Return Status    Should Contain    ${cpif_1}    standby
    ${active_cpif}=                Run Keyword If    ${status_cpif_0}    Set Variable    ${0}
    ...                            ELSE IF       not ${status_cpif_1}    Set Variable    ${1}
    ${standby_cpif}=               Run Keyword If    ${status_cpif_1}    Set Variable    ${1}
    ...                            ELSE IF       not ${status_cpif_0}    Set Variable    ${0}
    Log                            Step 3: Check if active pod contains necessary ip addresses    console=true
    ${nft_elements}=               Execute Command on Fully Given Container    pod=${pod_name}-cpif-${active_cpif}
    ...                            container=ctr-nftmgmt    hw_type=vCU
    ...                            command=nft list table "ip filter" | grep elements
    Should Contain                 ${nft_elements}     ${F1C_VDU}
    Should Contain                 ${nft_elements}     ${XNC_addr}
    Should Contain                 ${nft_elements}     ${NGC_addr}
    ${nft_cp_traffic}=             Execute Command on Fully Given Container
    ...                            pod=${pod_name}-cpif-${active_cpif}    hw_type=vCU
    ...                            container=ctr-nftmgmt    command=${INPUT_CP_TRAFFIC_5G_BH_CHAIN}
    Should Contain                 ${nft_cp_traffic}    ${jump_info}
    ${nft_ngxn_chain}=             Execute Command on Fully Given Container
    ...                            pod=${pod_name}-cpif-${active_cpif}    hw_type=vCU
    ...                            container=ctr-nftmgmt    command=${INPUT_NGXN_CHAIN}
    Should Contain                 ${nft_ngxn_chain}     ${F1C_VCU}
    Should Contain                 ${nft_ngxn_chain}     ${XNC_VCU}
    Should Contain                 ${nft_ngxn_chain}     ${NGC_VCU}
    Log                            Step 4: Restart active cpif and check if standby cpif is now active    console=true
    ${restart_comm}=               Catenate    SEPARATOR=${EMPTY}    curl -X 'POST' 'http://healing-controller:50056/
    ...                            api/vnfcmgmt/v1/vnfcs?operation=restart' -H 'Content-Type:application/json' -d '{\
    ...                            "name\":\"${pod_name}-cpif-${active_cpif}\"}'
    ${restart_comm_teardown}=      Catenate    SEPARATOR=${EMPTY}    curl -X 'POST' 'http://healing-controller:50056/
    ...                            api/vnfcmgmt/v1/vnfcs?operation=restart' -H 'Content-Type:application/json' -d '{\
    ...                            "name\":\"${pod_name}-cpif-${standby_cpif}\"}'
    Execute Command on Specific Container    specific_pod=oamext    container=oamagent    command=${restart_comm}    hw_type=vCU
    Sleep    60s                   reason=Wait until pod reset happends
    Wait Until Keyword Succeeds    5min    30s    Check if pod is in given redundant role
    ...                            cpif-${standby_cpif}    active
    Wait Until Keyword Succeeds    5min    30s    Check if pod is in given redundant role
    ...                            cpif-${active_cpif}    standby
    Log                            Step 5: Check if active pod contains necessary ip addresses    console=true
    ${nft_elements}=               Execute Command on Fully Given Container    pod=${pod_name}-cpif-${standby_cpif}
    ...                            container=ctr-nftmgmt    hw_type=vCU
    ...                            command=nft list table "ip filter" | grep elements
    Should Contain                 ${nft_elements}     ${F1C_VDU}
    Should Contain                 ${nft_elements}     ${XNC_addr}
    Should Contain                 ${nft_elements}     ${NGC_addr}
    ${nft_cp_traffic}=             Execute Command on Fully Given Container
    ...                            pod=${pod_name}-cpif-${standby_cpif}    hw_type=vCU
    ...                            container=ctr-nftmgmt    command=${INPUT_CP_TRAFFIC_5G_BH_CHAIN}
    Should Contain                 ${nft_cp_traffic}    ${jump_info}
    ${nft_ngxn_chain}=             Execute Command on Fully Given Container
    ...                            pod=${pod_name}-cpif-${standby_cpif}    hw_type=vCU
    ...                            container=ctr-nftmgmt    command=${INPUT_NGXN_CHAIN}
    Should Contain                 ${nft_ngxn_chain}     ${F1C_VCU}
    Should Contain                 ${nft_ngxn_chain}     ${XNC_VCU}
    Should Contain                 ${nft_ngxn_chain}     ${NGC_VCU}
    [Teardown]    Run Keywords     Execute Command on Specific Container    specific_pod=oamext    container=oamagent
    ...                            command=${restart_comm_teardown}    hw_type=vCU
    ...    AND                     Sleep    60s    reason=Wait until pod reset happends
    ...    AND                     Wait Until Keyword Succeeds    5min    30s
    ...                            Check if pod is in given redundant role    cpif-${active_cpif}    active
    ...    AND                     Wait Until Keyword Succeeds    5min    30s
    ...                            Check if pod is in given redundant role    cpif-${standby_cpif}    standby
    ...    AND                     Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}
    ...                            param_name=actDynamicFirewall    param_value=false    hw_type=vCU
    ...    AND                     Wait Until Keyword Succeeds    5min    1min
    ...                            Check if Unit Status is OnAir    hw_type=vCU

Change_of_CP_IP_address_of_OM_controlled_peer_CPlane_vCU
    Download SCF                  scf_path=${CURDIR}/scf.xml    hw_type=vCU
    Change Parameter on BTS              dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}
    ...                                  param_name=actDynamicFirewall    param_value=true    hw_type=vCU
    ${pn}=        Create List     cPlaneIpAddr    cPlaneIpAddrCtrl
    ${pv}=        Create List     ${XNC_VCU}      oamControlled
    Create Object with Multiple Parameters on BTS    dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}/XNLINK-35
    ...                                              param_names=${pn}    param_values=${pv}    hw_type=vCU
    ${setsIP4}=    Get Nft Tables    hw_type=vCU    specific_pod=cpif    command=nft list table "ip filter" | grep elements
    Should Contain    ${setsIP4}    ${XNC_VCU}
    ${ngxnCip4}=      Get Nft Tables    hw_type=vCU    specific_pod=cpif    command=nft list chain ip filter CP_TRAFFIC_5G_BH
    Should Contain    ${ngxnCip4}    NGXN_CHAIN
    ${nft_tables}     Get Nft Tables    hw_type=vCU    specific_pod=cpif    command=nft list chain ip filter NGXN_CHAIN
    Should Contain    ${nft_tables}    xnCplaneRemoteIpAddrList
    Should Contain    ${nft_tables}    ngCplaneRemoteIpAddrList
    Should Contain    ${nft_tables}    f1CplaneRemoteIpAddrList
    Delete Object on BTS    dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}/XNLINK-35    hw_type=vCU
    ${pv}=            Create List     ${dummyIP}      oamControlled
    Create Object with Multiple Parameters on BTS    dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}/XNLINK-35
    ...                                              param_names=${pn}    param_values=${pv}    hw_type=vCU
    ${setsIP4}=       Get Nft Tables    hw_type=vCU    specific_pod=cpif    command=nft list table "ip filter" | grep elements
    Should Contain    ${setsIP4}    ${dummyIP}
    ${ngxnCip4}=      Get Nft Tables    hw_type=vCU    specific_pod=cpif    command=nft list chain ip filter CP_TRAFFIC_5G_BH
    Should Contain    ${ngxnCip4}    NGXN_CHAIN
    ${nft_tables}     Get Nft Tables    hw_type=vCU    specific_pod=cpif    command=nft list chain ip filter NGXN_CHAIN
    Should Contain    ${nft_tables}    xnCplaneRemoteIpAddrList
    Should Contain    ${nft_tables}    ngCplaneRemoteIpAddrList
    Should Contain    ${nft_tables}    f1CplaneRemoteIpAddrList
    [Teardown]    Run Keywords    Deploy SCF    scf_path=${CURDIR}/scf.xml    hw_type=vCU
    ...    AND                    Run    rm ${CURDIR}/scf.xml
    ...    AND                    Sleep    300s    reason=Wait until reset after recommissioning ends

Adding_Blocking_access_of_OM_controlled_peer_CPlane_vCU_via_Netact
    Download SCF                         scf_path=${CURDIR}/scf.xml    hw_type=vCU
    Change Parameter on BTS              dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}
    ...                                  param_name=actDynamicFirewall    param_value=true    hw_type=vCU
#    ${NMS_LAB}    Integrate Cloud BTS with NMS Lab without TLS    hw_type=vCU    preferred_lab=srnclab1046
#    Change Parameter with NMS
#    ...    MOC_DN=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}/XNLINK-1
#    ...    param_name=cPlaneIpAddr
#    ...    param_value=${XNC_VCU}
#    ...    LAB_NAME=${NMS_LAB}
    ${pn}=        Create List     cPlaneIpAddr    cPlaneIpAddrCtrl
    ${pv}=        Create List     ${XNC_VCU}      oamControlled
    Create Object with Multiple Parameters on BTS    dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}/XNLINK-45
    ...                                              param_names=${pn}    param_values=${pv}    hw_type=vCU
    Check Nft Ruleset [A05, positive]
    Delete Object on BTS    dist_name=MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}/XNLINK-45    hw_type=vCU
    Check Nft Ruleset [A05, negative]
    [Teardown]    Run Keywords           Deploy SCF    scf_path=${CURDIR}/scf.xml    hw_type=vCU
    ...    AND                           Run    rm ${CURDIR}/scf.xml
    ...    AND                           Sleep    300s    reason=Wait until reset after recommissioning ends
#    [Teardown]    Deintegrate Cloud BTS from NMS Lab    LAB_NAME=${NMS_LAB}    hw_type=vCU
