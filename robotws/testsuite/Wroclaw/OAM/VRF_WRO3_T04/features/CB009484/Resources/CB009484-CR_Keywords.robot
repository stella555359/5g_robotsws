*** Settings ***
Documentation
...  author:     Patryk Tatarek
...  contact:    patryk.tatarek@nokia.com

Resource    taf/rfrl/cbts/utilities/init_variables.robot

*** Keywords ***
Alarm Should be Active on secondary vCU
    ${conn_sec}=    Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    Alarm Should be Active    alarm=7220    hw_type=vCU
    [Teardown]      Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec}    hw_type=vCU

Alarm Should not be Active on secondary vCU
    ${conn_sec}=    Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    Alarm Should not be Active    alarm=7220    hw_type=vCU
    [Teardown]      Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec}    hw_type=vCU

Reinstall certificate on secondary vCU
    ${conn_sec}=                    Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    Initialize Certificate          hw_type=vCU    pre-connection=${conn_sec}
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec}    hw_type=vCU
    Sleep    30s                    reason=Wait until reboot ends
    Wait Until Keyword Succeeds     3min    10s    Alarm Should not be Active    alarm=7220    hw_type=vCU
    Wait Until Keyword Succeeds     3min    10s    Alarm Should not be Active on secondary vCU
    [Teardown]      Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec}    hw_type=vCU

Restore TLS settings
    [Documentation]                 Description:    Enable TLS1.2 and disable TLS1.3 on both vCUs
    ${dn_prim}=    Create List      MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/MPLANENW-1
    ${pn}=         Create List      tls12Enabled    actEnableTLSv13
    ${pv_12}=      Create List      true    false
    Change Multiple Parameters on BTS    ${dn_prim}    ${pn}    ${pv_12}    hw_type=vCU
     Sleep    90s                   reason=Give some time to the other vCU connected via georesiliency
    ${conn_sec}=                    Wait Until Keyword Succeeds     5x    10s
    ...                             Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}    alias=admin_sec    hw_type=vCU
    ${dn_sec}=       Create List    MRBTS-${MRBTS_CU_2}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             MRBTS-${MRBTS_CU_2}/MNL-1/MNLENT-1/MPLANENW-1
    Wait Until Keyword Succeeds     5x    10s    Change Multiple Parameters on BTS
    ...                             ${dn_sec}    ${pn}    ${pv_12}    hw_type=vCU    pre-connection=${conn_sec}
    [Teardown]                      Disconnect from ADMIN    connection=${conn_sec}    hw_type=vCU

Check if deleted POD was recreated
    SSHLibrary.Write      ls
    Sleep    3s           reason=Wait until terminal execute the command
    ${ls}=                SSHLibrary.Read
    ${kuafu_list}=        Get Regexp Matches    ${ls}   kuafu-v......
    ${kuafu}=             Get From List    ${kuafu_list}    ${0}
    SSHLibrary.Write      cd ${kuafu}/scenarios/vcu_l3call/
    Sleep    1s           reason=Wait until terminal execute the command
    SSHLibrary.Write      ./80-list-vcu-containers.sh
    Sleep    5s           reason=Wait until terminal execute the command
    ${output}=            SSHLibrary.Read
    Should Contain        ${output}    po-oamext-0
    SSHLibrary.Write      po-oamext-0
    Sleep    10s          reason=Wait until terminal execute the command
    ${output}=            SSHLibrary.Read
    Should Contain        ${output}    true
    Should not Contain    ${output}    false
    [Teardown]            Run Keywords    SSHLibrary.Write    po-oamext-0
    ...    AND                            Sleep    3s         reason=Wait until terminal execute the command
    ...    AND                            SSHLibrary.Write    cd

Check if deleted secondary POD was recreated
    SSHLibrary.Write      ls -1d --color=never */
    Sleep    3s           reason=Wait until terminal execute the command
    ${ls}=                SSHLibrary.Read
    ${clean_output}=      Replace String Using Regexp    ${ls}    \x1B\[[0-9;?]*[A-Za-z]    ${EMPTY}
    ${clean_output}=      Replace String Using Regexp    ${clean_output}    \n    ${EMPTY}
    ${tls_list}=          Split String    ${clean_output}    \r
    ${tl_dict}=           Set Variable    ${EMPTY}
    FOR    ${item}    IN    @{tls_list}
        ${status}=     Run Keyword and Return Status    Should Contain    ${item}    ${MRBTS}
        ${tl_dict}=    Set Variable If    ${status}    ${item}    ${tl_dict}
    END
    SSHLibrary.Write      cd ${tl_dict}
    Sleep    1s           reason=Wait until terminal execute the command
    SSHLibrary.Write      ls
    Sleep    3s           reason=Wait until terminal execute the command
    ${ls}=                SSHLibrary.Read
    ${kuafu_list}=        Get Regexp Matches    ${ls}    kuafu-v......
    ${kuafu}=             Get From List    ${kuafu_list}    ${0}
    SSHLibrary.Write      cd ${kuafu}/scenarios/vcu_l3call/
    Sleep    1s           reason=Wait until terminal execute the command
    SSHLibrary.Write      ./80-list-vcu-containers.sh
    Sleep    5s           reason=Wait until terminal execute the command
    ${output}=            SSHLibrary.Read
    Should Contain        ${output}    po-oamext-0
    SSHLibrary.Write      po-oamext-0
    Sleep    10s          reason=Wait until terminal execute the command
    ${output}=            SSHLibrary.Read
    Should Contain        ${output}    true
    Should not Contain    ${output}    false
    [Teardown]            Run Keywords    SSHLibrary.Write    po-oamext-0
    ...    AND                            Sleep    3s         reason=Wait until terminal execute the command
    ...    AND                            SSHLibrary.Write    cd

Check if secondary Unit Status is OnAir
    [Arguments]    ${conn}
    ${cells_summary}=    vcu_admin.get_cells_summary    timeout=30    connection=${conn}
    Run Keyword and Continue on Failure    Should be Equal as Integers
    ...    ${cells_summary["basic_cells_summary"]["administrative_state"]["shutting_down"]}
    ...    0    Some cells are shutting down!
    Run Keyword and Continue on Failure    Should be Equal as Integers
    ...    ${cells_summary["basic_cells_summary"]["administrative_state"]["locked"]}
    ...    0    Some cells are locked!

Configure CMP on vCU-2
    [Documentation]    Description:    Configure primary CMP on vCU-2
    ...                Input:          server_type = RSA/ECDSA
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${ca_subject_name}    ${server_type}=RSA    ${ca_server_host}=${CA_SERVER_IP}
    ...                ${server_path}=${CA_SERVER_PATH}    ${ca_server_port}=${CA_DEFAULT_PORT}
    ...                ${ee_subject_name}=CN=MRBTS-${MRBTS}    ${pre-connection}=${NONE}
    ${server_object_name}=    Get From Dictionary    ${CMP_OBJECT}    ${server_type}
    ${dn}=    Create List     MRBTS-${MRBTS_CU_2}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS_CU_2}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS_CU_2}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS_CU_2}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS_CU_2}/MNL-1/CERTH-1/${server_object_name}
    ${pn}=    Create List     caSubjectName    eeSubjectName    serverHost    serverPath    serverPort
    ${pv}=    Create List     ${ca_subject_name}    ${ee_subject_name}    ${ca_server_host}
    ...                       ${server_path}        ${ca_server_port}
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vCU    pre-connection=${pre-connection}

Setup georesiliency user on both vCUs
    ${temp_conn}=                      Connect to Admin    hw_type=vCU
    ${result}=                         vcu_admin.update_service_account_password    username=${geo_login}
    ...                                new_password=${geo_password}    connection=${temp_conn}
    Should Be True                     "${result["content"]}"=="Success"
    Run Keyword and Ignore Error       Disconnect from ADMIN    connection=${temp_conn}    hw_type=vCU
    ${conn_sec}=                       Wait Until Keyword Succeeds     5x    10s
    ...                                Connect to ADMIN    custom_LMP_addr=${LMP_VCU_IP_2}
    ...                                alias=admin_sec    hw_type=vCU
    ${result}=                         vcu_admin.update_service_account_password    username=${geo_login}
    ...                                new_password=${geo_password}    connection=${conn_sec}
    Should Be True                     "${result["content"]}"=="Success"
    [Teardown]    Run Keywords         Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                                connection=${temp_conn}    hw_type=vCU
    ...    AND                         Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                                connection=${conn_sec}    hw_type=vCU

Check if there is no new alarm after POD recreation on vCU-1
    ${alarms_after}=                Get Active Alarms From BTS    hw_type=vCU
    ${alarms_list}=                 Get from Dictionary    ${alarms_after}    alarms
    @{fault_ids_after_vcu1}=        Create List
    FOR    ${fault}    IN    @{alarms_list}
        ${fault_id}=                Get From Dictionary    ${fault}    fault_id
        Append to List              ${fault_ids_after_vcu1}    ${fault_id}
    END
    ${is_empty}=                    Run Keyword and Return Status    Should be Empty    ${fault_ids_after_vcu1}
    Run Keyword If                  not ${fault_ids_before_vcu1}==${fault_ids_after_vcu1} and not ${is_empty}
    ...                             FAIL    msg=New alarms have appeared
    ${alarms_after}=                Get Active Alarms From BTS    hw_type=vDU
    ${alarms_list}=                 Get from Dictionary    ${alarms_after}    alarms
    @{fault_ids_after_vdu}=         Create List
    FOR    ${fault}    IN    @{alarms_list}
        ${fault_id}=                Get From Dictionary    ${fault}    fault_id
        Append to List              ${fault_ids_after_vdu}    ${fault_id}
    END
    ${is_empty}=                    Run Keyword and Return Status    Should be Empty    ${fault_ids_after_vdu}
    Run Keyword If                  not ${fault_ids_before_vdu}==${fault_ids_after_vdu} and not ${is_empty}
    ...                             FAIL    msg=New alarms have appeared

Check if there is no new alarm after POD recreation on vCU-2
    [Arguments]                     ${conn_sec}
    ${alarms_after}=                Get Active Alarms From BTS    hw_type=vCU    pre-connection=${conn_sec}
    ${alarms_list}=                 Get from Dictionary    ${alarms_after}    alarms
    @{fault_ids_after_vcu2}=        Create List
    FOR    ${fault}    IN    @{alarms_list}
        ${fault_id}=                Get From Dictionary    ${fault}    fault_id
        Append to List              ${fault_ids_after_vcu2}    ${fault_id}
    END
    ${is_empty}=                    Run Keyword and Return Status    Should be Empty    ${fault_ids_after_vcu2}
    Run Keyword If                  not ${fault_ids_before_vcu2}==${fault_ids_after_vcu2} and not ${is_empty}
    ...                             FAIL    msg=New alarms have appeared
    ${alarms_after}=                Get Active Alarms From BTS    hw_type=vDU
    ${alarms_list}=                 Get from Dictionary    ${alarms_after}    alarms
    @{fault_ids_after_vdu}=         Create List
    FOR    ${fault}    IN    @{alarms_list}
        ${fault_id}=                Get From Dictionary    ${fault}    fault_id
        Append to List              ${fault_ids_after_vdu}    ${fault_id}
    END
    ${is_empty}=                    Run Keyword and Return Status    Should be Empty    ${fault_ids_after_vdu}
    Run Keyword If                  not ${fault_ids_before_vdu}==${fault_ids_after_vdu} and not ${is_empty}
    ...                             FAIL    msg=New alarms have appeared
