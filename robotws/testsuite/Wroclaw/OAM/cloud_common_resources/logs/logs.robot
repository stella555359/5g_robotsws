*** Settings ***
Documentation    Cloud logs and documentations keywords.
...              Authors:    Patryk Tatarek
...              Contact:    patryk.tatarek@nokia.com

Resource    ../connections/connections.robot
Resource    ./pcap_analysis.robot

Library     taf.gnb.oam.coam.cu     WITH NAME    vcu_admin
Library     taf.gnb.oam.coam.vdu    WITH NAME    vdu_admin

*** Keywords ***

#################################################### Main  Keywords ####################################################

Collect Snapshot
    [Documentation]    Description:    Gets local snapshot and saves it under given directory
    ...                Input:          hw_type = vCU/vDU
    ...                                compress = True/False, if True, snapshot will be compressed into one zip file
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${local_dir}    ${compress}=True    ${timeout}=600    ${hw_type}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Collect Snapshot on vCU    dir=${local_dir}    zip=${compress}    timeout=${timeout}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Collect Snapshot on vDU    dir=${local_dir}    zip=${compress}    timeout=${timeout}
    ...    ELSE        FAIL                  hw_type doesn't exist

Trigger Snapshot Collection
    [Documentation]    Description:    Start collecting snapshot without waiting until it finish
    ...                Input:          hw_type = vCU/vDU
    ...                Output:         Operation ID
    ...                Author:         agnieszka.brzoska@nokia.com
    [Arguments]        ${hw_type}=${NONE}
    ${temp_conn}=      Run Keyword If    '${hw_type}'=='vCU'   Connect to ADMIN    hw_type=vCU
    ...    ELSE IF    '${hw_type}'=='vDU'    Connect to ADMIN    hw_type=vDU
    ...    ELSE        FAIL                  hw_type doesn't exist
    ${oper_id}=        Run Keyword If    '${hw_type}'=='vCU'    vcu_admin.trigger_local_snapshot
    ...                                                         connection=${temp_conn}
    ...    ELSE IF    '${hw_type}'=='vDU'    vdu_admin.trigger_local_snapshot    vdu_connection=${temp_conn}
    [Return]           ${oper_id}
    [Teardown]         Disconnect from ADMIN    ${temp_conn}    hw_type=${hw_type}

Cancel Snapshot Operation
    [Documentation]    Description:    Cancel Local/Remote snapshot collection operation
    ...                Input:          hw_type = vCU/vDU
    ...                                is_local = if True it is local snapshot, if False it's Remote
    ...                                oper_id = taken from Trigger Snapshot Collection
    ...                                timeout = Timeout for the opertion, defaults to 30
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${oper_id}     ${timeout}=30    ${is_local}=${True}    ${hw_type}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Cancel Snapshot on vCU    timeout=${timeout}    is_local=${is_local}    operation_id=${oper_id}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Cancel Snapshot on vDU    timeout=${timeout}    is_local=${is_local}    operation_id=${oper_id}
    ...    ELSE        FAIL                  hw_type doesn't exist

Collect FHGW Snapshot
    [Documentation]    Description:    Gets FHGW snapshot and saves it under given directory
    ...                Input:          local_dir = local path where snapshot will be saved to
    ...                                timeout = time in seconds for snapshot collection to complete on FHGW
    ...                Author:         jakub.ozierski@nokia.com
    [Arguments]        ${local_dir}    ${timeout}=600
    ${fhgw_connection}=    Connect to FHGW
    ${cmd_result}=         issh.Execute    command=fhgwcli snapshot save    alias=${fhgw_connection}    check_result=False
    ${snapshot_name}=      Get Regexp Matches    string=${cmd_result}    pattern=Snapshot_FHGW-\\d+.+
    ${snapshot_name}=      Set Variable    ${snapshot_name}[0]
    ${snapshot_name}=      Strip String    ${snapshot_name}
    Wait Until Keyword Succeeds    ${timeout} seconds    10 seconds
    ...    _Check If FHGW Snapshot Collection Is Done    snapshot_name=${snapshot_name}    alias=${fhgw_connection}
    Create Directory  path=${local_dir}/FHGW
    ${fhgw_local_file_path}=     Set Variable    ${local_dir}/FHGW/${snapshot_name}.tar
    ${fhgw_remote_file_path}=    Set Variable    /mnt/symptomreport/${snapshot_name}.tar
    issh.Download File    remote_path=${fhgw_remote_file_path}    local_path=${fhgw_local_file_path}    alias=${fhgw_connection}
    Log To Console    FHGW snapshot with name ${snapshot_name} saved to ${fhgw_local_file_path}
    [Teardown]    issh.Disconnect    alias=${fhgw_connection}

Start TCPdump
    [Documentation]    Description:    Start ip traffic capture on chosen hw_type.
    ...                                This keyword support using only one pod_name or plane_type at the same time.
    ...                                For now only capture_pod=pod is working properly, that will be fixed by
    ...                                TAF team in the future.
    ...                Input:          hw_type = vCU/vDU
    ...                                capture_type = all/plane/pod
    ...                                measurement_point = NE_Terminated/Transport_Interface
    ...                                plane_type = uplane/cplane/mplane/others, needed only when capture_type = plane
    ...                                pod_names = can be found on WebEM under Diagnostic/IP Traffic Capturing,
    ...                                            needed only when capture_type = pod
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${capture_type}=pod    ${measurement_point}=NE_Terminated
    ...                ${plane_type}=${NONE}    ${pod_names}=${NONE}    ${hw_type}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Start TCPdump on vCU    capture_type=${capture_type}
    ...                measurement_point=${measurement_point}    plane_type=${plane_type}    pod_names=${pod_names}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Start TCPdump on vDU    capture_type=${capture_type}
    ...                measurement_point=${measurement_point}    plane_type=${plane_type}    pod_names=${pod_names}
    ...    ELSE        FAIL                  hw_type doesn't exist

Stop TCPdump and Download Pcap
    [Documentation]    Description:    Stop ip traffic capture and download pcap on chosen hw_type
    ...                Input:          hw_type = vCU/vDU
    ...                                pod_name = can be found on WebEM under Diagnostic/IP Traffic Capturing
    ...                Output:         Local path to downloaded pcap file
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${pod_name}    ${hw_type}=${NONE}
    ${pcap_path}=      Run Keyword If    '${hw_type}'=='vCU'    _Stop TCPdump and Download Pcap on vCU
    ...                                                         pod_name=${pod_name}
    ...                ELSE IF           '${hw_type}'=='vDU'    _Stop TCPdump and Download Pcap on vDU
    ...                                                         pod_name=${pod_name}
    ...                ELSE               FAIL                  hw_type doesn't exist
    [Return]           ${pcap_path}

TCPdump Teardown
    [Documentation]    Description:    Stop ip traffic capture on chosen hw_type.
    ...                                Use this keyword in teardown in case of using TCPdump in test case.
    ...                Input:          hw_type = vCU/vDU
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${hw_type}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _TCPdump Teardown on vCU
    ...    ELSE IF    '${hw_type}'=='vDU'    _TCPdump Teardown on vDU
    ...    ELSE        FAIL                  hw_type doesn't exist

Common Gathering Logs for Test Setup
    Log to console    ${OUTPUT_DIR}/${TEST_NAME}
    Set Test Variable       ${TEST_OUTPUT_DIR}          ${OUTPUT_DIR}/${TEST_NAME}
    Run    mkdir -p ${TEST_OUTPUT_DIR}

Common Gathering Logs for Test Teardown
    logs.Collect Snapshot   hw_type=vCU
    ...                local_dir=${TEST_OUTPUT_DIR}
    ...                compress=True
    ...                timeout=600
    logs.Collect Snapshot   hw_type=vDU
    ...                local_dir=${TEST_OUTPUT_DIR}
    ...                compress=True
    ...                timeout=600

################################################ Supplementary Keywords ################################################

_Collect Snapshot on vCU
    [Arguments]      ${dir}    ${zip}    ${timeout}
    ${temp_conn}=    Connect to ADMIN    hw_type=vCU
    Log              Snapshot collection started   console=True
    vcu_admin.get_local_snapshot    directory=${dir}    compressed=${zip}    operation_timeout=${timeout}    connection=${temp_conn}
    Log              Snapshot collection ended   console=True
    [Teardown]       Disconnect from ADMIN    connection=${temp_conn}    hw_type=vCU

_Collect Snapshot on vDU
    [Arguments]      ${dir}    ${zip}    ${timeout}
    ${temp_conn}=    Connect to ADMIN    hw_type=vDU
    Log              Snapshot collection started   console=True
    vdu_admin.get_local_snapshot    directory=${dir}    compressed_or_not=${zip}    operation_timeout=${timeout}    vdu_connection=${temp_conn}
    Log              Snapshot collection ended   console=True
    [Teardown]       Disconnect from ADMIN    connection=${temp_conn}    hw_type=vDU

_Cancel Snapshot on vCU
    [Arguments]      ${timeout}     ${is_local}    ${operation_id}
    ${temp_conn}=    Connect to ADMIN    hw_type=vCU
    Log              Cancel snapshot collection started   console=True
    vcu_admin.cancel_snapshot_operation    operation_id=${operation_id}    timeout=${timeout}    is_local=${is_local}    connection=${temp_conn}
    Log              Snapshot collection canceled   console=True
    [Teardown]       Disconnect from ADMIN    connection=${temp_conn}    hw_type=vCU

_Cancel Snapshot on vDU
    [Arguments]      ${timeout}     ${is_local}    ${operation_id}
    ${temp_conn}=    Connect to ADMIN    hw_type=vDU
    Log              Cancel snapshot collection started   console=True
    vdu_admin.cancel_snapshot_operation    operation_id=${operation_id}    timeout=${timeout}    is_local=${is_local}    vdu_connection=${temp_conn}
    Log              Snapshot collection canceled   console=True
    [Teardown]       Disconnect from ADMIN    connection=${temp_conn}    hw_type=vDU

_Check If FHGW Snapshot Collection Is Done
    [Arguments]    ${snapshot_name}    ${alias}
    ${fhgw_check_cmd}  Set Variable  ls /mnt/symptomreport/ | grep ${snapshot_name}
    ${cmd_result}  issh.Execute  command=${fhgw_check_cmd}  alias=${alias}  check_result=False
    Should Not Contain  container=${cmd_result}  item=running

_Start TCPdump on vCU
    [Arguments]       ${capture_type}    ${measurement_point}    ${plane_type}    ${pod_names}
    ${temp_conn}=     Connect to ADMIN    hw_type=vCU
    ${plane_type}=    Run Keyword Unless    "${plane_type}"=="${NONE}"    Create List    ${plane_type}
    ${pod_names}=     Run Keyword Unless    "${pod_names}"=="${NONE}"    Create List    ${pod_names}
    vcu_admin.start_ip_traffic_capture    capture_type=${capture_type}    measurement_point=${measurement_point}
    ...                                   plane_type=${plane_type}    pod_names=${pod_names}
    ...                                   timeout=60    connection=${temp_conn}
    [Teardown]        Disconnect from ADMIN    connection=${temp_conn}    hw_type=vCU

_Start TCPdump on vDU
    [Arguments]       ${capture_type}    ${measurement_point}    ${plane_type}    ${pod_names}
    ${temp_conn}=     Connect to ADMIN    hw_type=vDU
    ${plane_type}=    Run Keyword Unless    "${plane_type}"=="${NONE}"    Create List    ${plane_type}
    ${pod_names}=     Run Keyword Unless    "${pod_names}"=="${NONE}"    Create List    ${pod_names}
    vdu_admin.start_ip_traffic_capture    capture_type=${capture_type}    measurement_point=${measurement_point}
    ...                                   plane_type=${plane_type}    pod_names=${pod_names}
    ...                                   timeout=60    vdu_connection=${temp_conn}
    [Teardown]        Disconnect from ADMIN    connection=${temp_conn}    hw_type=vDU

_Stop TCPdump and Download Pcap on vCU
    [Arguments]        ${pod_name}
    ${temp_conn}=      Connect to ADMIN    hw_type=vCU
    vcu_admin.stop_ip_traffic_capture    timeout=60    connection=${temp_conn}
    Sleep              10    reason=Wait until ip traffic capture is completed
    vcu_admin.generate_ip_traffic_capture_files    credentials=     timeout=60    connection=${temp_conn}
    Sleep              10    reason=Wait until ip traffic files are generated
    ${info}=           vcu_admin.get_ip_traffic_capture_status    connection=${temp_conn}
    ${all_pods_status}=    Set Variable        ${info['pod_status']}
    ${length}=             Get Length    ${all_pods_status}
    ${pod_name_str}=       Convert to String    ${pod_name}
    FOR    ${l}    IN RANGE    ${length}
        ${pod_info}=             Get From List    ${all_pods_status}    ${l}
        ${pod_info_str}=         Convert to String    ${pod_info}
        ${status}=               Run Keyword and Return Status    Should Contain    ${pod_info_str}    ${pod_name_str}
        ${correct_file_name}=    Set Variable If    "${status}"=="True"    ${pod_info['file_name']}
        Exit For Loop If        "${status}"=="True"
    END
    ${upload_info}=    vcu_admin.activated_file_upload_operation    timeout=60    connection=${temp_conn}
    Should Be True     "${upload_info['status']}"=="success"
    ${pcap_path}=      vcu_admin.upload_ip_traffic_capture_file    operation_id=${upload_info['operation_id']}
    ...                file_name=${correct_file_name}    local_path=${OUTPUT DIR}
    ...                timeout=60    connection=${temp_conn}
    [Return]           ${pcap_path}
    [Teardown]         Run Keywords    Sleep    15s    reason=Wait until upload operation can be removed
    ...                AND             Wait Until Keyword Succeeds                         3min    10s
    ...                                vcu_admin.delete_file_upload_operation
    ...                                connection=${temp_conn}
    ...                AND             Disconnect from ADMIN    connection=${temp_conn}    hw_type=vCU

_Stop TCPdump and Download Pcap on vDU
    [Arguments]        ${pod_name}
    ${temp_conn}=      Connect to ADMIN    hw_type=vDU
    vdu_admin.stop_ip_traffic_capture    timeout=60    vdu_connection=${temp_conn}
    Sleep              30    reason=Wait until ip traffic capture is completed
    vdu_admin.generate_ip_traffic_capture_files    credentials=     timeout=60    vdu_connection=${temp_conn}
    Sleep              30    reason=Wait until ip traffic files are generated
    ${info}=           vdu_admin.get_ip_traffic_capture_status    vdu_connection=${temp_conn}
    ${all_pods_status}=    Set Variable        ${info['pod_status']}
    ${length}=             Get Length    ${all_pods_status}
    ${pod_name_str}=       Convert to String    ${pod_name}
    FOR    ${l}    IN RANGE    ${length}
        ${pod_info}=             Get From List    ${all_pods_status}    ${l}
        ${pod_info_str}=         Convert to String    ${pod_info}
        ${status}=               Run Keyword and Return Status    Should Contain    ${pod_info_str}    ${pod_name_str}
        ${correct_file_name}=    Set Variable If    "${status}"=="True"    ${pod_info['file_name']}
        Exit For Loop If        "${status}"=="True"
    END
    Sleep              30    reason=Wait until ip traffic files are ready to be downloaded
    ${upload_info}=    vdu_admin.activated_file_upload_operation    timeout=60    vdu_connection=${temp_conn}
    Should Be True     "${upload_info['status']}"=="success"
    ${pcap_path}=      vdu_admin.upload_ip_traffic_capture_file    operation_id=${upload_info['operation_id']}
    ...                file_name=${correct_file_name}    local_path=${OUTPUT DIR}
    ...                timeout=60    vdu_connection=${temp_conn}
    [Return]           ${pcap_path}
    [Teardown]         Run Keywords    Sleep    15s    reason=Wait until upload operation can be removed
    ...                AND             Wait Until Keyword Succeeds    3min    10s
    ...                                vdu_admin.delete_file_upload_operation
    ...                                vdu_connection=${temp_conn}
    ...                AND             Disconnect from ADMIN    connection=${temp_conn}    hw_type=vDU

_TCPdump Teardown on vCU
    ${temp_conn}=    Connect to ADMIN    hw_type=vCU
    Run Keyword and Ignore Error    vcu_admin.stop_ip_traffic_capture    timeout=60    connection=${temp_conn}
    [Teardown]       Disconnect from ADMIN    connection=${temp_conn}    hw_type=vCU

_TCPdump Teardown on vDU
    ${temp_conn}=    Connect to ADMIN    hw_type=vDU
    Run Keyword and Ignore Error    vdu_admin.stop_ip_traffic_capture    timeout=60    vdu_connection=${temp_conn}
    [Teardown]       Disconnect from ADMIN    connection=${temp_conn}    hw_type=vDU
