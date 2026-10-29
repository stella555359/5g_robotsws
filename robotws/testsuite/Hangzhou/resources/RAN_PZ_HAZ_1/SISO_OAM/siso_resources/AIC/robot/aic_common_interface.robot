*** Settings ***
Documentation
...    SISO Common Resource files

Library     json
Library     Process
Library     taf.ccs.aashell    WITH NAME    aashell
Library     taf.sw.scout    WITH NAME    scout
Library     ../python/bts/vDuInfo.py
Library     ../python/log/check_rp1_technical_logs.py
Library     ../../tools/truck_roll.py

Resource    ./bts/aic_bts_common_oam.robot
Resource    ../../common_func.robot
Resource    ./log/aic_capture_analysis_log.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ./bts/variables.robot



*** Keywords ***
Online Change cellBarred For Multi Cell
    [Arguments]    ${cell_info}    ${value}=barred   ${vdu_index}=vDU_0    ${cu_index}=CU_0
    ${is_all}    Run Keyword And Return Status    Variable Should Exist    ${MATCHED_UE_INFO["ALL_CELL_BARRED"]}
    ${bar_cell_part}    Run Keyword If    "${is_all}"=="False"    Get Bar Cell For Same RRU And PA    ${cell_info}
    ${bar_cell_all}    Copy List    ${ALL_CELL_LIST}

    Remove Values From List    ${bar_cell_all}    ${cell_info}
#    FOR    ${pci}   IN    @{cell_info["related_cell"]}
#        ${related_cell_info}   Get Cell Info With PCI   ${cell_list}    ${pci}
#        Remove Values From List    ${bar_cell_all}    ${related_cell_info}
#        Remove Values From List    ${bar_cell_part}    ${related_cell_info}
#    END
    ${bar_cell_list}    Set Variable If    "${is_all}"=="True"    ${bar_cell_all}    ${bar_cell_part}

    ${status}    Run Keyword And Return Status    Variable Should Exist    ${cell_info["related_cell"]}
    ${bar_cell_list}   Run Keyword If   ${status}    Remove Cells From Cell List       ${bar_cell_list}   ${cell_info}
    ...   ELSE   Set Variable    ${bar_cell_list}

    ${status}    Run Keyword And Return Status    Should Not Be Empty    ${bar_cell_list}
    Return From Keyword If    '${status}'=='False'
    ${para_list}    get_cell_bar_parameter_list    ${bar_cell_list}   ${value}
    vDU Multi Parameters Recommission By Delta Plan    ${para_list}    operation=replace
        ...    recommission_type=online    vdu_index=${vdu_index}    cu_index=${cu_index}

Collect eCpri RU logs on RU Side
    [Arguments]    ${ru_ip}    ${vdu}    ${ru_username}=rfsw    ${ru_password}=5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ\=
    Connect SSH To VDU    ${vdu}    alias=vdu_kuafu
    ${conenction_kuafu}    csn.get connection by alias    alias=vdu_kuafu
    ${channel} =    Call Method    ${conenction_kuafu}    invoke_shell
    sleep   10s
    Call Method    ${channel}    recv      ${65535}
    Call Method    ${channel}    send    kubectl exec -it -n cran1 po-cran1-oamfh-0 -c ctr-cran1-oamfh -- bash\n
    sleep    1s
    Call Method    ${channel}    recv      ${65535}
    Call Method    ${channel}    send    ssh -o StrictHostKeyChecking\=no ${ru_username}@${ru_ip}\n
    sleep    2s
    Wait Cmd End    password:    ${channel}    wait_time=1s    timeout=10s
    Call Method    ${channel}    send    ${ru_password}\n
    sleep    5s
    ${ret}    Call Method    ${channel}    recv      ${65535}

    ${timestamp}    Get Current Date    result_format=%Y%m%d%H%M%S
    ${rfsw_log_path}    Set Variable    /ram/rfsw_log_${timestamp}\.zip
    Call Method    ${channel}    send    cd /usr/bin;ccsShell.sh log -a -z /ram/rfsw_log_${timestamp}\.zip\n
    Wait Cmd End    AaSysComUserDeregister succeed!    ${channel}    wait_time=5s    timeout=1 min
    [Return]    ${rfsw_log_path}
    [Teardown]    Disconnect SSH To VDU    connection=vdu_kuafu

Download eCpri RU logs From RU Side
    [Arguments]    ${rfsw_log_path}    ${download_dir}    ${ru_ip}   ${vdu}    ${ru_username}=rfsw
    ...    ${ru_password}=5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ\=
    Log    ${ru_username}
    ${host_ip}    Get From Dictionary    ${BTS_CONFIG}    HOST_IP
    ${content}    OperatingSystem.Get File    /home/ute/.ssh/id_rsa
    ${content}    Strip String    ${content}    characters=\n
    ${content_list}    Split String    ${content}    \n
    Connect SSH To VDU    ${vdu}    alias=vdu_kuafu
    ${conenction_kuafu}    csn.get connection by alias    alias=vdu_kuafu
    ${channel} =    Call Method    ${conenction_kuafu}    invoke_shell
    sleep   10s
    Call Method    ${channel}    recv      ${65535}
    Call Method    ${channel}    send    kubectl exec -it -n cran1 po-cran1-oamfh-0 -c ctr-cran1-oamfh -- bash\n
    sleep    1s
    Call Method    ${channel}    recv      ${65535}

    Call Method    ${channel}    send    rm /ram/id_rsa\n
    sleep    0.1s
    Call Method    ${channel}    recv      ${65535}
    FOR    ${line}    IN    @{content_list}
        Call Method    ${channel}    send    echo ${line}>>/ram/id_rsa\n
        sleep    0.1s
        Call Method    ${channel}    recv      ${65535}
    END
    Call Method    ${channel}    send    chmod 600 /ram/id_rsa\n
    sleep    0.1s
    Call Method    ${channel}    recv      ${65535}

    Call Method    ${channel}    send    scp -o StrictHostKeyChecking\=no rfsw@${ru_ip}:${rfsw_log_path} ${rfsw_log_path}\n
    Wait Cmd End    password:    ${channel}    wait_time=1s    timeout=10s
    Call Method    ${channel}    send    ${ru_password}\n
    Wait Cmd End    100%    ${channel}    wait_time=1s    timeout=10s

    Call Method    ${channel}    send    scp -i /ram/id_rsa -o StrictHostKeyChecking\=no ${rfsw_log_path} ute@${host_ip}:${download_dir}\n
    Wait Cmd End    100%    ${channel}    wait_time=1s
    ${dir_name}    ${ru_file_name}    Split Path    ${rfsw_log_path}
    ${local_file_path}   Join Path    ${download_dir}    ${ru_file_name}
    [Return]   ${local_file_path}
    [Teardown]    Disconnect SSH To VDU    connection=vdu_kuafu

Get eCpri RFSW Log File List On RU Side
    [Arguments]    ${download_dir}    ${fr_sn}    ${ru_account}=${EMPTY}
    ${status}    Run Keyword And Return Status    Should Not Be Empty    ${ru_account}
    ${ru_account}    Run Keyword If    ${status}    Evaluate    ${ru_account}
    ${status2}    Run Keyword And Return Status    Run Keyword If    ${status}    Dictionary Should Contain Key    ${ru_account}    ${fr_sn}
    ...    ELSE    fail
    ${ru_username}    Set Variable If    ${status2}    ${ru_account["${fr_sn}"]["username"]}    rfsw
    ${ru_password}    Set Variable If    ${status2}    ${ru_account["${fr_sn}"]["password"]}    5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ\=
    ${cu_index}    ${vdu_index}    Get CU vDU Index    fr    ${fr_sn}
    ${vdu}    Set Variable    ${cu_index}-${vdu_index}
    ${ru_ip}    Get eCpri RU IP By Kuafu    ${fr_sn}    ${vdu}
    ${rfsw_log_path}    Collect eCpri RU logs on RU Side    ${ru_ip}    ${vdu}    ru_username=${ru_username}    ru_password=${ru_password}
    ${rfsw_log_on_testpc}    Download eCpri RU logs From RU Side    ${rfsw_log_path}    ${download_dir}    ${ru_ip}    ${vdu}
    ...   ru_username=${ru_username}    ru_password=${ru_password}
    ${unzip_result}    OperatingSystem.Run     unzip -l ${rfsw_log_on_testpc} |tail -n +2
    ${vaild_lines}      Get Lines Matching Regexp    ${unzip_result}     \\d+11_.*    partial_match=true
    ${rfsw_log_names}    Get Regexp Matches      ${vaild_lines}    ([2-9]011)?_.*
    [Return]    ${rfsw_log_names}

Get eCpri RU IP By Kuafu
    [Arguments]    ${fr_sn}    ${vdu}
    ${code}    convert_sn_to_code    ${fr_sn}
    Connect SSH To VDU    ${vdu}    alias=vdu_kuafu
    ${command}    Set Variable
    ...  kubectl exec -it -n cran1 po-cran1-oamfh-0 -c ctr-cran1-dhcp -- cat /var/log/kea-leasesdb/kea-leases4.csv
    ${conditional_command}    Set Variable    ${command} | grep -i 300 | grep ${code} | tail -1
    ${ret}    csn.execute    ${conditional_command}    connection=vdu_kuafu
    ${ru_ip}    Fetch From Left    ${ret}    ,
    [Return]    ${ru_ip}
    [Teardown]    Disconnect SSH To VDU    connection=vdu_kuafu

Check RFSW Log In Snapshot
    [Arguments]    ${rfsw_log_on_snapshot}    ${ru_account}=${EMPTY}
    ${log_on_snapshot}    OperatingSystem.Run    unzip -l ${rfsw_log_on_snapshot} |tail -n +2
    ${match}    ${fr_sn}    Should Match Regexp    ${log_on_snapshot}    BTS_(.*)_RMOD_L
    ${ru_type}    Get RU type    ${fr_sn}
    ${logs_on_ru_side}    Run Keyword If    "${ru_type}"=="eCPRI"    Get eCpri RFSW Log File List On RU Side
    ...    ${TEST_LOGS_DIR_PATH}    ${fr_sn}    ru_account=${ru_account}
    ${not_include_list}    Create List
    FOR  ${item}  IN  @{logs_on_ru_side}
       ${item_new}=     String.Split String    ${item}    .
       ${status}  Run Keyword And Return Status  Should Match Regexp   ${log_on_snapshot}   .*${item_new}[0].*
       Run Keyword If  ${status}==${False}     Append to List    ${not_include_list}     ${item_new}[0]
    END
    ${length}    Get Length    ${not_include_list}
    Should Be Equal As Integers   ${length}   ${0}   msg=Item ${not_include_list} not include in snapshot logs

Check All RFSWs Log In Snapshot
    [Arguments]    ${snapshot_path}    ${ru_account}=${EMPTY}
    OperatingSystem.Run    unzip ${snapshot_path}/RU_logs.zip -d ${snapshot_path}/RU_logs
    ${ru_log_list}    OperatingSystem.List Files In Directory    ${snapshot_path}/RU_logs
    FOR    ${ru_log}    IN    @{ru_log_list}
        Check RFSW Log In Snapshot    ${snapshot_path}/RU_logs/${ru_log}    ru_account=${ru_account}
    END

Check All RFSWs Log In Minor Snapshot
    [Arguments]    ${snapshot_path}
    OperatingSystem.Run    unzip ${snapshot_path}/RU_logs.zip -d ${snapshot_path}/RU_logs
    ${ru_log_list}    OperatingSystem.List Files In Directory    ${snapshot_path}/RU_logs
    FOR    ${ru_log}    IN    @{ru_log_list}
        ${log_on_snapshot}    OperatingSystem.Run    unzip -l ${snapshot_path}/RU_logs/${ru_log} |tail -n +2
        ${match}    ${fr_sn}    Should Match Regexp    ${log_on_snapshot}    BTS_(.*)_RMOD_L
        Should Match Regexp   ${log_on_snapshot}    BTS_${fr_sn}_RMOD_L_\\d+_startup
        Should Match Regexp   ${log_on_snapshot}    BTS_${fr_sn}_RMOD_L_\\d+_runtime
        Should Match Regexp   ${log_on_snapshot}    BTS_${fr_sn}_RMOD_L_\\d+_fault_history_log
        Should Match Regexp   ${log_on_snapshot}    BTS_${fr_sn}_RMOD_L_\\d+_BBOX5
    END

Power Off Radio
    [Arguments]    ${fr_serial_number}    ${pre_alias}=${CASE_NAME}
    Log    ${pre_alias}
    PDU Turn Off Unit    pdu_type=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['type']}
    ...    pdu_ip=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['ip_addr']}
    ...    pdu_port=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['port']}
    ${not_testing_related_frs}    ${fr_next_hops_list}    Get Not Testing Realted And Next Hops FR List
    ...    ${fr_serial_number}
    Wait Until Keyword Succeeds    300s    30 sec
    ...    Check RU Status As Expected    ru_sn=${fr_serial_number}   expected_administrative_state=unlocked
    ...    expected_operational_state=enabled    expected_availability_status=off line
    ...    expected_procedural_status=configured
    Check Not Testing Related FRs States When Testing FR Is Resetting    ${not_testing_related_frs}
    END

Check Not Testing Related FRs States When Testing FR Is Resetting
    [Arguments]    ${not_testing_related_frs}
    FOR    ${fr_sn}    IN    @{not_testing_related_frs}
        Check RU Status As Expected    ${fr_sn}
    END

Power On Radio
    [Arguments]    ${fr_serial_number}
    PDU Turn On Unit    pdu_type=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['type']}
    ...    pdu_ip=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['ip_addr']}
    ...    pdu_port=${BTS_CONFIG['FR']['${fr_serial_number}']['pdu']['port']}
     Wait Until Keyword Succeeds    300s    30 sec     Check RU List Status Should Be As Expected

Get Not Testing Realted And Next Hops FR List
    [Arguments]    ${fr_serial_number}
    ${fr_chain_list}    Set Variable    ${NODE_CFG["CU_0"]["vDU_0"]["fr_chain_list"]}
    ${fr_next_hops_list}    Run Keyword If    "${fr_serial_number}" in "${fr_chain_list}"    Get Next Hops FR List
    ...    ${fr_serial_number}    ${fr_chain_list}
    ...    ELSE    Create List
    ${not_testing_related_frs}    Create List    @{USED_FR_SN_LIST}
    Remove Values From List    ${not_testing_related_frs}    @{fr_next_hops_list}    ${fr_serial_number}
    [Return]    ${not_testing_related_frs}    ${fr_next_hops_list}

Get Next Hops FR List
    [Arguments]    ${fr_serial_number}    ${fr_chain_list}
    FOR    ${fr_chain}    IN    @{fr_chain_list}
         ${status}    Run Keyword And Return Status    Should Match Regexp    ${fr_chain}    .*${fr_serial_number}(->)?(.*)
         Continue For Loop If    not ${status}
         ${fr_next_hops}    Should Match Regexp    ${fr_chain}    .*${fr_serial_number}(->)?(.*)
         ${fr_next_hops_list}    Split String    ${fr_next_hops[2]}    ->
    END
    ${fr_next_hops_list}    Run Keyword If    "${fr_next_hops_list[0]}" == ""    Create List
    ...    ELSE    Set Variable    ${fr_next_hops_list}
    [Return]    ${fr_next_hops_list}
