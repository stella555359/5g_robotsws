*** Settings ***
Documentation    Keywords to change mcc
...              Author:    Klaudyna Piechocka
...              Contact:   klaudyna.piechocka@nokia.com


Resource    taf/rfrl/cbts/utilities/init_variables.robot
Library     taf.transport.ssh    WITH NAME    ssh
Library     Collections

*** Keywords ***
Send packets from test PC using scapy sendpfast
    [Documentation]    Description:    KW to send packets from test pc
    ...                Input:          packets = packets to be send, for example sendpfast(Ether(src='${SIM_RU_MAC}',
    ...                                dst='${FHNET_MAC}')/IP(dst='${FHNET_IP}')/
    ...                                UDP(dport=5001), iface='${interface}',
    ...                                pps=10, count=1000, parse_results=1)
    ...                Output:         None
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]    ${packets}
    ssh.Connect to    hostname=${TEST_PC_IP}
    ...               username=${TEST_PC_USER}
    ...               password=${TEST_PC_PASS}
    ...               alias=bts_connection

    ${output}=       ssh.Execute      command=sudo python3 -c "from scapy.all import Ether, IP, ICMP, UDP, TCP, sendpfast; ${packets}"
    ...              connection=bts_connection

Get SW Info
    [Arguments]        ${hw_type}=${NONE}
    ${connection}=     Connect to ADMIN      hw_type=${hw_type}
    ${dictionary}        Run Keyword If        '${hw_type}'=='vCU'    vcu_admin.get_cu_state   connection=${connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    vdu_admin.get_vdu_state_data    vdu_connection=${connection}
    ...    ELSE        FAIL                  hw_type doesn't exist
    ${software_version}=    Get From Dictionary    ${dictionary}    software_version
    [Return]    ${software_version}
    [Teardown]    Disconnect from ADMIN    hw_type=${hw_type}    connection=${connection}

Check Counter Value In INPUT Chain
    [Documentation]    Description:    KW to check if FW counters are raised
    ...                Input:          filter = a list of packet properties, for example: tcp    21
    ...                Output:         packets = Number of packets received by a FW rule
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]    ${filter}
    ssh.Connect to    hostname=${SSH_VDU_IP}
    ...               username=${SSH_K8S_USERNAME}
    ...               password=${SSH_K8S_PASSWORD}
    ...               alias=bts_connection
    ${webem_sw_version}=    Get SW Info    vDU
    ${if_branch}    Run Keyword And Return Status    Should Contain    ${webem_sw_version}    25R3
    ${command_trunk}    Set Variable    kubectl exec -it po-oamfh-0 -n ${CRAN_VDU} -c ctr-nftmgmt -- nft list chain ip filter INPUT
    ${command_branch}    Set Variable
    ...    kubectl exec -it po-${CRAN_VDU}-oamfh-0 -n ${CRAN_VDU} -c ctr-${CRAN_VDU}-nftmgmt -- nft list chain ip filter INPUT
    ${command}    Set Variable If    '${if_branch}'=='True'    ${command_branch}    ${command_trunk}
    ${num}=     Get Length    ${filter}
    ${grep}=    Set Variable    ${EMPTY}
    FOR    ${i}    IN RANGE    ${num}
           ${grep}=  Set Variable    ${grep}| grep ${filter[${i}]}
    END
    ${output}=       ssh.Execute      command=${command}${grep}
    ...              connection=bts_connection
    ${split1}=    Split String    ${output}   packets${SPACE}
    ${split2}=    Split String    ${split1[1]}    ${SPACE}
    ${packets}=   Set Variable    ${split2[0]}
    [Return]      ${packets}


Create nft Rule To Break Link To RU
    [Documentation]    Description:    KW to create firewall rule that breaks connection to RU
    ...                Input:          radio_ip = a ru ip that you want to break connection to
    ...                Output:         None
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]       ${radio_ip}
    ssh.Connect to    hostname=${SSH_VDU_IP}
    ...               username=${SSH_K8S_USERNAME}
    ...               password=${SSH_K8S_PASSWORD}
    ...               alias=bts_connection
    ${nft_table}  Set Variable  nft add table ip table1
    ${nft_chain}  Set Variable  nft add chain ip table1 chain1 '{ type filter hook input priority 10; policy accept; }'
    ${nft_rule}  Set Variable  nft add rule ip table1 chain1 ip saddr ${radio_ip} drop
    Log    Create nft rule    console=True
    ssh.Execute       command= kubectl exec -n ${CRAN_VDU} po-oamfh-0 -c ctr-${CRAN_VDU}-nwmgmt -- ${nft_table}
    ...               connection=bts_connection
    ssh.Execute       command=kubectl exec -n ${CRAN_VDU} po-oamfh-0 -c ctr-${CRAN_VDU}-nwmgmt -- ${nft_table}
    ...               connection=bts_connection
    ssh.Execute       command=kubectl exec -n ${CRAN_VDU} po-oamfh-0 -c ctr-${CRAN_VDU}-nwmgmt -- ${nft_chain}
    ...               connection=bts_connection
    ssh.Execute       command=kubectl exec -n ${CRAN_VDU} po-oamfh-0 -c ctr-${CRAN_VDU}-nwmgmt -- ${nft_rule}
    ...               connection=bts_connection
    [Teardown]    ssh.Disconnect    connection=bts_connection

Delete nft Rule to Unbreak Link to RU
    [Documentation]    Description:    KW to delete firewall rule that breaks connection to RU
    ...                Input:          None
    ...                Output:         None
    ...                Author:         klaudyna.piechocka@nokia.com
    ssh.Connect to    hostname=${SSH_VDU_IP}
    ...               username=${SSH_K8S_USERNAME}
    ...               password=${SSH_K8S_PASSWORD}
    ...               alias=bts_connection
    Log    Delete nft rule    console=True
    ${nft_table}=    Set Variable    nft delete table ip table1
    ssh.Execute       command=kubectl exec -n ${CRAN_VDU} po-oamfh-0 -c ctr-${CRAN_VDU}-nwmgmt -- ${nft_table}
    ...               connection=bts_connection
    [Teardown]    ssh.Disconnect    connection=bts_connection

Check If RU operationalState has expected value
    [Documentation]    Description:    KW to check If RU operationalState has expected value
    ...                Input:          excpected_value = expected RU state, for example enabled
    ...                Output:         None
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]    ${excpected_value}
    Log    Checking If RU operational state is ${excpected_value}    console=True
    ${conn}=         Connect To Admin                hw_type=vDU
    ${list_RMODs}=   _Get RMODs vDU Status
    ${RU_operationalState}=  Get From Dictionary     ${list_RMODs[1]}   operational_state
    Should Match Regexp      ${RU_operationalState}  ${excpected_value}
    [Teardown]    Disconnect From Admin    ${conn}    hw_type=vDU

Check If FID 10 Is Present On vDU
    [Documentation]    Description:    KW to check if FID 10 Is Present On vDU for a given RU
    ...                Input:          RMOD_ID = RMOD DN, for example RMOD-1
    ...                Output:         None
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]    ${RMOD_ID}
    ${alarm_list}=    Get Active Alarms From BTS    hw_type=vDU
    ${num_alarms}=    Get From Dictionary     ${alarm_list}    total
    FOR    ${i}    IN RANGE    ${num_alarms}-1
        ${obj_alarm}=     Get From Dictionary     ${alarm_list['alarms'][${i}]}    alarming_object
        IF    'MRBTS-${MRBTS}/EQM_R-1/APEQM_R-1/${RMOD_ID}'=='${obj_alarm}'
            ${fault_id}=     Get From Dictionary     ${alarm_list['alarms'][${i}]}    fault_id
            Should contain    ${fault_id}    10
            Exit For Loop
        ELSE
            Log    Wrong object
        END
    END

Get FH Mac address
    [Documentation]    Description:    KW to get current FH address
    ...                Input:          interface = interface used to send traffic from test PC
    ...                Output:         None
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]    ${interface}
    SSHLibrary.Open Connection   host=${TEST_PC_IP}
    SSHLibrary.Login             username=${TEST_PC_USER}       password=${TEST_PC_PASS}
    SSHLibrary.Write             ip n | grep ${interface}
    Sleep    2
    ${output}=    SSHLibrary.Read
    ${FH_data}=  Split String    ${output}    ${SPACE}
    ${FH_MAC_ADDRESS}=   Set Variable  ${FH_data}[4]
    [Return]    ${FH_MAC_ADDRESS}

_Get RMODs vDU Status
    [Documentation]    Description:    Get vDU RMODs Status
    [Arguments]        ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...                ELSE    Set Variable    ${pre-conn}
    ${list_RMODs}=     vdu_admin.get_rmods_status                   vdu_connection=${temp_conn}
    [Return]           ${list_RMODs}
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN    hw_type=vDU
