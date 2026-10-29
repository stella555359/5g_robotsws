*** Settings ***
Documentation       Plugin keywords
Library      BuiltIn
Library      Collections
Library      String
Library      OperatingSystem
Library      taf.transport.ssh    WITH NAME    ssh
Library      taf.ue
Library      ${CURDIR}/../python/gude_pdu.py
Library      ${CURDIR}/../python/plugin.py

*** Keywords ***
Plugin Attach
    [Arguments]    ${RF}=1
    Setup For Plugin    ${RF}
    Check UE Before Plugin Attach
    Set Attenuation Plugin
    Check Attach Attempt And Require UE
    IF    '${UE}' in ${UE_with_qualcomm_chip}
        Plugin Qualcomm Chip
    END
    Plugin Attach And Verify
    [Teardown]    Set Test Variable    ${attach_was_performed}    ${True}

Plugin Qualcomm Chip
    [Documentation]    Set preferred network type for the device according to the supported capability from init file
    ...                And Verify the interface is visible and ready to proceed after reboot
    ...                author: Amir Abd Rabo
    Log To Console    \n\t${UE} Detected - Setting network mode and checking interface presence
    Set Test Variable    ${interface_name_visible}    ${tl.ues[${UE_index}].data_transfer[0].interface_name}
    ${mode_change_condition}    Evaluate    (len($tl.ues) == 1 and len($tl.ues[0].capabilities) == 1)
    IF    not ${mode_change_condition}
        Set Preferred Network Type
    ELSE
        Log To Console    \tNetwork mode change and UE reboot not needed for single RAT testing
    END
    IF    '${UE}' == 'quectel'
            taf.ue.Attach Ue    ${capability_index}
    END
    Verify Interface Presence    ${interface_name_visible}

Verify Interface Presence
    [Documentation]    Detach to make sure the inteface IP is not 169.xx.xx.xx -> Detach will make it visible as 172.168.xx.xx
    ...                Then wait 10 s and get available interfaces from UEPC
    ...                author: Amir Abd Rabo
    [Arguments]    ${interface_name_visible}    ${loop_check}=6
    Run Keyword If    '${UE}' == 'simcom'    taf.ue.Attach Ue    ${capability_index}
    FOR    ${index}    IN RANGE    ${loop_check}
        TRY
            ${interfaces_uepc}    taf.ue.Get Ue Info    ${capability_index}    ue_params=ips_uepc
        EXCEPT    AS    ${error}
            IF    ${index}!=${${loop_check}-1}
                Log    Error: ${error} - retrying
                BuiltIn.Sleep    10s
                CONTINUE
            ELSE
                Fail    Failed to find ${error}
            END
        END
        IF    '${interface_name_visible}' in str(${interfaces_uepc})
            Log To Console    \tInterface ${interface_name_visible} found
            BREAK
        ELSE IF    ${index}!=${${loop_check}-1}
            BuiltIn.Sleep    10s
            CONTINUE
        ELSE
            Fail    \tInterface ${interface_name_visible} - not found
        END
    END

Check Interface Presence And IP Range
    [Documentation]    If interface is not detected but device is, detach to make sure the ip is not 169.xx.xx.xx
    ...                And retry checking to see if it's available after attach as 192.168.xx.xx or 192.xx.xx.xx for Oulu
    ...                author: Amir Abd Rabo
    [Arguments]    ${interface_name_visible}
    ${interfaces_uepc}    taf.ue.Get Ue Info    ${capability_index}    ue_params=ips_uepc
    Run Keyword If    '${interface_name_visible}' not in ${interfaces_uepc}.keys()
    ...    Fail    \t[ERROR] Interface ${interface_name_visible} not found in interfaces_uepc
    ${interface_ip}=    Set Variable    ${interfaces_uepc}[${interface_name_visible}]
    Log To Console    \tInterfaces_IP: ${interface_ip}
    IF    '${site}' == 'OULU' and '192.' in '${interface_ip}'
        Log To Console    IP ${interface_ip} for interface ${interface_name_visible} is within the range 192.xx.xx.xx
    ELSE IF    '192.168.' in '${interface_ip}'
        Log To Console    IP ${interface_ip} for interface ${interface_name_visible} is within the range 192.168.xx.xx
    ELSE
        Fail   \t[WARN] IP ${interface_ip} for interface ${interface_name_visible} is NOT within the correct range
    END

Plugin Attach And Verify
    [Documentation]    Perform plugin Attach, and turn on mobile data so device gets assigned IP addr
    ...                and validate cell ID, Quectel is added to exception since it's AT device
    taf.ue.Attach Ue    ${capability_index}
    Run Keyword If    '${UE}' in ${UE_with_qualcomm_chip}    BuiltIn.Sleep       15 seconds
    Run Keyword If    '${UE}' not in ${UE_with_qualcomm_chip}   Turn Mobile Data On    ${capability_index}
    Validate Cell ID

Set Preferred Network Type
    [Documentation]    Set preferred network type for the device according to the supported capability from init file
    ...                author: Amir Abd Rabo
    Log To Console    \n\t Current capability: ${capability}
    ${networkType_map}    Create Dictionary    _3G=WCDMA    _4G=LTE
    IF    '${UE}' == 'quectel'
        Set To Dictionary    ${networkType_map}    _5G=NR5G:LTE
    ELSE IF    '${UE}' == 'simcom'
        Set To Dictionary    ${networkType_map}    _5G=LTE5G
    ELSE IF    '${UE}' == 'askey'
        taf.ue.Reboot Ue  ${capability_index}
        BuiltIn.Sleep    45s
        IF    'NSA' in '${NODE_NAME}'
            Set To Dictionary    ${networkType_map}    _5G=LTE:5G
        END
    ELSE
        Set To Dictionary    ${networkType_map}    _5G=5G
    END
    ${networkType}    Get From Dictionary    ${networkType_map}    ${capability}
    Log To Console    \n\t ============= Changing network mode to ${networkType} ======
    Change Network Mode    ${capability_index}    ${networkType}
    IF    '${UE}' != 'askey'
        taf.ue.Reboot Ue  ${capability_index}
    END
    Log To Console    \n\t ============= Proceeding to attach and DT ======

Set Attenuation Plugin
    ${LTE_CELL_length}    Get Variable Value    ${LTE_CELL_length}    0
    ${attenuation_port}    Get Variable Value    ${tl.attenuation['attenuation_port']}    3001
    Set Suite Variable    ${attenuation_port}
    Run Keyword If     '${LTE_CELL_length}'!='0' and '${is_atten}'=='${True}'                         Set Attenuators 1RF
    ...    ELSE IF     '${isLTE}'=='${False}' and '${rf_number}'=='3'                                 Set Attenuation For 3RF
    ...    ELSE IF     '${isLTE}'=='${False}' and '${is_atten}'=='${True}' and '${rf_number}'=='1'    Set Attenuators 1RF

Check UE Before Plugin Attach
    Check Target Traffic Values
    Run Keyword And Ignore Error    Reset UE controlPc If Ssh Fail
    ${adb_visible}     Run Keyword And Return Status    Run Keyword If    '${UE}'!='simcom' and '${UE}'!='quectel'    ADB devices
    Run Keyword If     '${tl.tl_cloud_topology}' in $testlines_with_wihajster    Update Wihajster Script On Raspberry
    Run Keyword If     '${adb_visible}'=='${False}' and '${tl.tl_cloud_topology}' in $testlines_with_wihajster
    ...    Reboot UE With Wihajster And Wait For Status Change
    ...    ELSE IF     '${adb_visible}'=='${False}' and '${tl.tl_cloud_topology}' not in $testlines_with_wihajster
    ...    FAIL    Device ${device_model} is not detected in ADB

Check Target Traffic Values
    ${status}    Run Keyword And Return Status    Variable Should Exist    ${tl.target_traffic${capability_index}}
    ${target_traffic}    Set Variable If    '${capability_index}' != '${capability}' and ${status}    ${tl.target_traffic${capability_index}}
    ...                                                                                               ${tl.target_traffic${capability}}
    Set Global Variable    ${target_traffic}

Check Attach Attempt And Require UE
    ${status}    Run Keyword And Return Status    Should Be True    ${attach_was_performed} == ${False}
    ${detach_status}    Run Keyword And Return Status    Run Keyword If     '${status}'=='${False}'    taf.ue.Detach Ue    ${capability_index}
    # Run Keyword If      not ${status} and '${UE}' not in ${UE_with_qualcomm_chip}   Restart NAA
    Run Keyword If     '${status}'=='${True}' or ${detach_status}==${False}    Check If UE Required And Require Ue

Setup For Plugin
    [Arguments]    ${RF}=1
    Set suite variable    ${RF}
    Log To Console    \n\t ================================================================
    Log To Console      \t * * * * * * * * * * * * * START ATTACH * * * * * * * * * * * * *
    Log To Console      \t ================================================================
    Run Keyword And Ignore Error    Run    pip install setuptools==44.0.0  # ute-installer requires setuptools<=44

Validate Cell ID
    ${cell_id}     Get Variable Value    ${target_traffic}[cell_id_rf${RF}]    None
    @{cell_ids}    Set Variable    ${cell_id.replace(' ', '').split(',')}
    ${attached}    Set Variable     False
    FOR    ${id}    IN    @{cell_ids}
        ${cell_id_status}    Run Keyword And Return Status             Validate Ue Info    ${capability_index}    CELL_ID    ${id}
        Run Keyword If       ${cell_id_status}    Log To Console       \n UE attached to cell ID: ${id}
        ${attached}          Set Variable If      ${cell_id_status}    True    ${attached}
        IF    ${attached}
            Save UE Info    ${capability_index}    ${UE_index}    ${LOG_PATH}/ue_info.json
            BREAK
        END
    END
    Run Keyword If    '${attached}'!='${True}'    Fail
    ...               UE did not attached to proper cell ID: ${target_traffic}[cell_id_rf${RF}]

Reset UE controlPc If Ssh Fail
    ${status}    Run Keyword And Return Status    Wait Until Keyword Succeeds    60s    30s    ssh.Connect to
    ...               ${cpc_addr}
    ...               ${cpc_username}
    ...               ${cpc_password}    alias=cpc
    Run Keyword If    '${status}'=='${False}'   Run Keywords
    ...                Log To Console    \n Reset UE controlPc
    ...    AND         reboot_gude_port    ${PDU_IP}    ${PDU_slot}

Check Plugin Data Transfer
    Start Transfer
    ...         throughput_DL=${target_traffic}[MAX_DL] Mbits/sec
    ...         throughput_UL=${target_traffic}[MAX_UL] Mbits/sec
    ...         min_expected_tput_DL=${target_traffic}[MIN_DL] Mbits/sec
    ...         min_expected_tput_UL=${target_traffic}[MIN_UL] Mbits/sec

Start Transfer
    [Arguments]    ${throughput_DL}    ${throughput_UL}    ${min_expected_tput_DL}    ${min_expected_tput_UL}
    ${max_try}    Set Variable    2
    ${data_transfer_protocol}    Get Variable Value    ${data_transfer_protocol}    UDP
    FOR    ${index}    IN RANGE    ${max_try}
        Log to console    \n Checking UE IP addr
        Run Keyword If    '${UE}' in ${UE_with_qualcomm_chip}    Wait Until Keyword Succeeds
        ...    15x    5s    Check Interface Presence And IP Range   ${interface_name_visible}
        ...    ELSE    Wait Until Keyword Succeeds    15x    5s    Check UE Ip Status
        &{UE_ip_info}    taf.ue.get_ue_info    ${capability_index}    IPS
        IF    len(&{UE_ip_info}) > 1
            ${apn}=    get_apn_from_ue_info    info_dict=&{UE_ip_info}
        ELSE
            @{apn_list}    Get Dictionary Keys     ${UE_ip_info}
            ${apn}    Set Variable    ${apn_list}[0]
        END
        TRY
            IF    '${data_transfer_protocol}' == 'UDP'
                Log to console    \n Start UDP transfer
                taf.ue.Start Data Transfer
                ...    throughput=${throughput_DL}
                ...    ue_alias=${capability_index}
                ...    duration=${target_traffic}[IPERF_DURATION]s
                ...    dt_name=DT_Downlink${capability}
                ...    direction=dl
                ...    protocol=udp
                ...    apn=${apn}
                ...    packet=1000B
                ...    buffer=512k
            ELSE IF    '${data_transfer_protocol}' == 'TCP'
                Log to console    \n Start TCP transfer
                taf.ue.Start Data Transfer
                ...    ue_alias=${capability_index}
                ...    duration=${target_traffic}[IPERF_DURATION]s
                ...    dt_name=DT_Downlink${capability}
                ...    direction=dl
                ...    protocol=tcp
                ...    apn=${apn}
                ...    max_segment_size=1400
                ...    buffer=512k
            ELSE
                Fail    Protocol ${data_transfer_protocol} is not supported, please update case if needed!!!
            END
            BREAK
        EXCEPT    AS    ${error}
            ${err}    Set Variable    ${error.replace("'", "")}
            IF    'AsyncioSerialConnection got empty chunk of data.' in '''${err}''' and ${index} < ${${max_try}-1}
                Log    Try UE reboot to recover from ${error}!!!
                taf.ue.Reboot Ue  ${capability_index}
            ELSE
                Log to console    Stop Data Transfer
                Run Keyword And Continue On Failure    Stop Data Transfer   DT_Downlink${capability}
                Fail    Start data transfer failed due to ${error}!!!
            END
        END
    END
    TRY
        IF    '${data_transfer_protocol}' == 'UDP'
            taf.ue.Start Data Transfer
            ...    throughput=${throughput_UL}
            ...    ue_alias=${capability_index}
            ...    duration=${target_traffic}[IPERF_DURATION]s
            ...    dt_name=DT_Uplink${capability}
            ...    direction=ul
            ...    protocol=udp
            ...    apn=${apn}
            ...    packet=1000B
            ...    buffer=512k
        ELSE IF    '${data_transfer_protocol}' == 'TCP'
            taf.ue.Start Data Transfer
            ...    ue_alias=${capability_index}
            ...    duration=${target_traffic}[IPERF_DURATION]s
            ...    dt_name=DT_Uplink${capability}
            ...    direction=ul
            ...    protocol=tcp
            ...    apn=${apn}
            ...    max_segment_size=1400
            ...    buffer=512k
        ELSE
            Fail    Protocol ${data_transfer_protocol} is not supported, please update case if needed!!!
        END
    EXCEPT    AS    ${error}
        ${not_support}    Get Regexp Matches    ${error}    Protocol.*is not supported
        IF    ${not_support}
            Fail    ${error}
        ELSE
            Log to console    Stop Data Transfer
            Run Keyword And Continue On Failure    Stop Data Transfer   DT_Downlink${capability}
            Run Keyword And Continue On Failure    Stop Data Transfer   DT_Uplink${capability}
            Fail   Start data transfer failed due to ${error}!!!
        END
    END
    TRY
        Log to console    Await Data Transfer Finish
        Run Keyword And Continue On Failure    Await Data Transfer Finish    DT_Uplink${capability}
        Run Keyword And Continue On Failure    Await Data Transfer Finish    DT_Downlink${capability}
        Log to console    Stop Data Transfer
        Run Keyword And Continue On Failure    Stop Data Transfer   DT_Downlink${capability}
        Run Keyword And Continue On Failure    Stop Data Transfer   DT_Uplink${capability}
    EXCEPT  AS  ${error}
        Fail     Data transfer failed to ${error}!!!
    END
    Log to console    Verify Average Throughput
    ${average_throughput_dl}    Get Average Throughput    DT_Downlink${capability}
    ${average_throughput_ul}    Get Average Throughput    DT_Uplink${capability}
    Log to console       \n\t\t\t\t Uplink:\t ${average_throughput_ul} Kbits/sec
    Log to console       \t\t\t\t Downlink:\t ${average_throughput_dl} Kbits/sec
    Verify Average Throughput    DT_Downlink${capability}    ${min_expected_tput_DL}
    Verify Average Throughput    DT_Uplink${capability}    ${min_expected_tput_UL}

Check And Upgrade NAA Plugin Version
    [Documentation]    Check and upgrade NAA Plugin version on UE
    [Arguments]    ${cpc_addr}=${cpc_addr}     ${cpc_username}=${cpc_username}    ${cpc_password}=${cpc_password}
    ...            ${device_model}=${device_model}
    ${plugin_ver}    Check Plugin Version On LabPC
    ...    cpc_addr=${cpc_addr}
    ...    cpc_username=${cpc_username}
    ...    cpc_password=${cpc_password}
    ...    device_model=${device_model}
    ${target_plugin_version}    Get Variable Value    ${target_plugin_version}    ${EMPTY}
    IF    '${target_plugin_version}' == ''
        ${custom_plugin_version}    Get Variable Value    ${NAA_plugin_version}    ${EMPTY}
        ${artifactory_connection_status}=    Run Keyword And Return Status    Check Ping result    artifactory-espoo1.ext.net.nokia.com
        IF    not ${artifactory_connection_status}
            Log To Console    \nArtifactory is not accessible, skip NAA Plugin Version check!!!
            RETURN
        END
        ${full_package}    ${newest_version}    get_plugin_version    ${plugin_artifactory_url}    ${custom_plugin_version}
        ...                                                           ${espoo1_prodzn_API_Key}
        IF    $full_package is None
            Log    Failed to get NAA package from artifactory, please check avialable packages in: ${plugin_artifactory_url}    WARN
            RETURN
        END
        IF    $custom_plugin_version is None or "${custom_plugin_version}" == "" or "${custom_plugin_version}" == "not_set"
            Log To Console    \nNAA Plugin version is not specified, using the newest version from Artifactory: ${newest_version}
            ${target_plugin_version}    Set Variable    ${newest_version}
        ELSE
            Log To Console    \nNAA Plugin version is specified: ${custom_plugin_version}, using it for installation
            ${target_plugin_version}    Set Variable    ${custom_plugin_version}
        END
    ELSE
        ${full_package}    ${newest_version}    get_plugin_version    ${plugin_artifactory_url}    ${target_plugin_version}
        ...                                                           ${espoo1_prodzn_API_Key}
    END
    Set Suite Variable    ${target_plugin_version}
    IF    "${plugin_ver}" != "${target_plugin_version}"
        IF    "${plugin_ver}"=="${EMPTY}"
            Log To Console    NAA Plugin is not installed on UE, installation process has been started with version: ${target_plugin_version}
        ELSE
            Log To Console
            ...    NAA Plugin version on UE: ${plugin_ver} and target version is: ${target_plugin_version}, installation process has been started
        END
        Install NAA Plugin If Is Available
        ...    artifactory_path=${plugin_artifactory_url}
        ...    full_package=${full_package}
        ...    cpc_addr=${cpc_addr}
        ...    cpc_username=${cpc_username}
        ...    cpc_password=${cpc_username}
        ...    device_model=${device_model}
    ELSE
        Log To Console    NAA Plugin Version on UE is the same as in target version: ${target_plugin_version}
    END

Check Plugin Version On LabPC
    [Documentation]    Check NAA Plugin version on LabPC
    [Arguments]    ${cpc_addr}=${cpc_addr}     ${cpc_username}=${cpc_username}    ${cpc_password}=${cpc_password}
    ...            ${device_model}=${device_model}
    Connect to controlPC    cpc_addr=${cpc_addr}
    ...                     cpc_username=${cpc_username}
    ...                     cpc_password=${cpc_password}
    ${plugin}              ssh.execute    adb -s ${device_model} shell dumpsys package com.nokia.android.application | grep versionName
    ...                                   connection=controlPC    timeout=60s
    ${plugin_ver_pattern}    Set Variable    [0-9]+\\.[0-9]+\\.[0-9]+
    ${plugin_ver}    Get Regexp Matches    ${plugin}    ${plugin_ver_pattern}
    IF    ${plugin_ver}
        RETURN     ${plugin_ver[0]}
    ELSE
        RETURN     ${EMPTY}
    END

Install NAA Plugin If Is Available
    [Arguments]    ${artifactory_path}    ${full_package}    ${cpc_addr}=${cpc_addr}
    ...            ${cpc_username}=${cpc_username}    ${cpc_password}=${cpc_password}
    ...            ${device_model}=${device_model}
    Run                    sudo mkdir /home/ute/naa_plugin
    ${cmd}    Catenate     cd /home/ute/naa_plugin; sudo wget --header="X-API-Key: ${espoo1_prodzn_API_Key}"
    ...                    ${artifactory_path}/${full_package}
    Run       ${cmd}
    Connect to controlPC    cpc_addr=${cpc_addr}
    ...                     cpc_username=${cpc_username}
    ...                     cpc_password=${cpc_password}
    ssh.upload_file        remote_path=./${full_package}
    ...                    local_path=/home/ute/naa_plugin/${full_package}
    ...                    connection=controlPC
    Run                    sudo rm -rf /home/ute/naa_plugin
    Wait Until Keyword Succeeds    60s    10s
    ...                    ssh.execute   adb -s ${device_model} uninstall com.nokia.android.application
    ...                    connection=controlPC    timeout=60s
    Wait Until Keyword Succeeds    60s    10s
    ...                    ssh.execute   adb -s ${device_model} install -g -t ${full_package}
    ...                    connection=controlPC    timeout=60s
    ${plugin_ver}    Check Plugin Version On LabPC
    ...    cpc_addr=${cpc_addr}
    ...    cpc_username=${cpc_username}
    ...    cpc_password=${cpc_password}
    ...    device_model=${device_model}
    IF    '${plugin_ver}' == ''
        Log To Console    NAA Plugin installation failed, please check the logs and try to install it manually
        Fail    NAA Plugin installation failed
    END
    Log To Console         NAA Plugin version on UE after sw update: ${plugin_ver}

Kill sshd And Start Cygwin
    ${cpc_connection}=    Run Keyword And Return Status    Connect to controlPC    cpc_addr=${cpc_addr}
    ...                cpc_username=${cpc_username}
    ...                cpc_password=${cpc_password}
    Run Keyword If    ${cpc_connection}    Run Keywords
    ...    ssh.upload_file        remote_path=./kill_sshd_start_cyg.ps1
    ...                    local_path=/home/ute/robotws/testsuite/QT/SRAN/resources/scripts/kill_sshd_start_cyg.ps1
    ...                    connection=controlPC
    ...    AND    ssh.Send Command             powershell
    ...                          connection=controlPC
    Run Keyword If     ${cpc_connection}    ssh.Send Command
    ...                          Start-Process powershell -verb runas -ArgumentList "-file C:\cygwin64\home\wro5gqt\kill_sshd_start_cyg.ps1"
    ...                          connection=controlPC
    [Teardown]    Run Keyword If    ${cpc_connection}    ssh.disconnect    connection=controlPC

Save UE plugin logs
    Get CPC OS         cpc_addr=${cpc_addr}
    ...                cpc_username=${cpc_username}
    ...                cpc_password=${cpc_password}
    Connect to controlPC    cpc_addr=${cpc_addr}
    ...                     cpc_username=${cpc_username}
    ...                     cpc_password=${cpc_password}
    Run Keyword And Ignore Error    Move Files    ${OUTPUT_DIR}/*_ue*     ${ue_log_dir}
    Run Keyword And Ignore Error    Move Files    ${OUTPUT_DIR}/ue.*     ${ue_log_dir}
    Run Keyword And Ignore Error    Collect proxy mngr log  OS=${cpc_type}  alias=controlPC
    ssh.download_file    remote_path=C:\\pyro_server\\${tl.tl_cloud_topology}\\logs\\ta_ue_uepc_local.log
    ...                  local_path=${ue_log_dir}/ta_ue_uepc_local.log
    ...                  connection=controlPC
    [Teardown]    ssh.disconnect    connection=controlPC

Collect proxy mngr log
    [Arguments]  ${OS}   ${alias}=controlPC
    ${proxy_mngr_log}=  save_proxy_mngr_logs  OS=${OS}  alias=${alias}
    Run Keyword If  '${proxy_mngr_log}'!=''  ssh.download_file
    ...  remote_path=${proxy_mngr_log}  local_path=${OUTPUT DIR}/L3_Call/proxy_mngr.log  connection=${alias}  timeout=120s

Clear UE plugin logs
    [Documentation]    empty all files under C:\pyro_server
    ...                author: tong weichao
    ${windows}    Set Variable    for folder in `find /cygdrive/c/pyro_server -maxdepth 1 -mindepth 1 -type d`; do rm -rf $folder/*; done
    ${linux}      Set Variable    for folder in `find /home/ute/pyro_server -maxdepth 1 -mindepth 1 -type d`; do rm -rf $folder/*; done
    ${cpc_addr}        Get Variable Value    ${tl.ues[0].ssh_connection_details.addr}        ${tl.ues[0].ue_pc_address}
    ${cpc_password}    Get Variable Value    ${tl.ues[0].ssh_connection_details.password}    ${tl.ues[0].ue_pc_password}
    ${cpc_username}    Get Variable Value    ${tl.ues[0].ssh_connection_details.username}    ${tl.ues[0].ue_pc_login}
    Get CPC OS         cpc_addr=${cpc_addr}
    ...                cpc_username=${cpc_username}
    ...                cpc_password=${cpc_password}
    Connect to controlPC    cpc_addr=${cpc_addr}
    ...                     cpc_username=${cpc_username}
    ...                     cpc_password=${cpc_password}
    Run Keyword If      '${cpc_type}'=='Linux'
    ...                 ssh.send_command    ${linux}
    ...                 connection=controlPC
    ...       ELSE      ssh.send_command    ${windows}
    ...                 connection=controlPC
    [Teardown]    ssh.disconnect    connection=controlPC

Restart NAA
    [Documentation]       Perform NAA Restart
    Log To Console        \nPerform NAA Restart
    TRY
        Retry Send Command in CPC      adb -s ${device_model} shell am force-stop com.nokia.android.application    connection=cpc
        Wait Until Keyword Succeeds    3x  10s    Check NAA Output
    EXCEPT    .*Unrecognized alias.*    type=Regexp
        Log    Skip NAA Restart to due Unrecognized alias: 'cpc' cannot be fixed by CPC reconnection!!!   WARN
    EXCEPT  AS  ${error}
        Log     Perform NAA Restart failed due to ${error}, try to reboot UE to reocver it   WARN
        ADB reboot UE
    END

Check NAA Output
    [Documentation]       Check ps output
    ${ps_output}          ssh.execute    command=adb -s ${device_model} shell ps | grep com.nokia.android.application    connection=cpc
    ...                                  timeout=60s
    Should Not Contain    ${ps_output}    com.nokia.android.application    ignore_case=True

Check UE Ip Status
    [Documentation]    check if ue ip is assigned
    ...                author: tong weichao, mateusz porzucek
    Connect to controlPC    cpc_addr=${cpc_addr}
    ...                     cpc_username=${cpc_username}
    ...                     cpc_password=${cpc_password}
    ${ip_output}    ssh.execute    command=adb -s ${device_model} shell ip a |grep -i inet |grep -i global    connection=controlPC
    ...                            timeout=60s
    Should Match Regexp    ${ip_output}    \\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}    msg=IP is not ready yet

Check If UE Required And Require Ue
    [Documentation]    check if ue is required, if not require ue
    ...                author: tong weichao
    Connect to controlPC    cpc_addr=${cpc_addr}
    ...                     cpc_username=${cpc_username}
    ...                     cpc_password=${cpc_password}
    TRY
        taf.ue.Require Ue    ${capability_index}    capabilities=${capability_index}
        Log To Console    \n\t require UE successfully
    EXCEPT   .*AliasAlreadyAssignedError.*    type=Regexp
        Log To Console    \n\t UE is already required, continue to test
    EXCEPT  AS  ${error}
        Require UE Exception Handling    ${error}
        taf.ue.Require Ue    ${capability_index}    capabilities=${capability_index}
        Log To Console    \n\t require UE successfully
    END

Require UE Exception Handling
    [Documentation]    Handle exception during UE require
    [Arguments]    ${error}
    ${err_msg}    Set Variable    ${error.replace('"', '')}
    IF    'The reservation could be made manually or by previous Robot TC' in """${err_msg}"""
        Log To Console    \n!!!Restart UE proxy to fix taf reserve UE issue!!!
        start_latest_ue_proxy
        ...    OS=${cpc_type}    site=${site}    alias=cpc    ue=${tl.ues[${UE_index}]}    skip_lock_check=${True}
    ELSE IF    'Could not start mobile app on UE' in """${err_msg}""" or 'get_ue_firmware_version' in """${err_msg}"""
        Log To Console    \n!!!Reboot UE proxy to fix exception ${error}!!!
        ADB reboot UE
    ELSE
        Log    TAF UE require failed due to ${error}!    WARN
        Set Suite Variable    ${L3call_exception}    ${error}
        Fail
    END

Prepare NAA Plugin
    Get CPC OS         cpc_addr=${cpc_addr}
    ...                cpc_username=${cpc_username}
    ...                cpc_password=${cpc_password}
    Connect to controlPC    cpc_addr=${cpc_addr}
    ...                     cpc_username=${cpc_username}
    ...                     cpc_password=${cpc_password}
    TRY
        ${is_proxy_mngr}   ${is_proxy_running}    is_proxy_mngr_or_ue_proxy_running    OS=${cpc_type}    alias=controlPC
        IF    not ${is_proxy_running}
            Log    Proxy is detected not running, it may lead to requrie UE failure!!!!    WARN
        END
        IF    not ${is_proxy_mngr}
            Run Keyword And Ignore Error
            ...   Check And Upgrade Taf Lib In CPC    site=${site}    OS=${cpc_type}   taf_lib_name=taf.ue.proxy    alias=controlPC
            Run Keyword And Ignore Error
            ...   Check And Upgrade Taf Lib In CPC    site=${site}    OS=${cpc_type}   taf_lib_name=taf.ue.proxy.access.android    alias=controlPC
        END
    EXCEPT    AS    ${error}
        Set Suite Variable    ${L3call_exception}    ${error}
        ${err_msg}    Set Variable    ${error.replace("'", '')}
        IF    'CommandOutputTimeoutError' in '''${err_msg}'''
            Fail    Check proxy manager status failed to ${error}!
        ELSE
            Log    Check proxy manager status failed to ${error}!    WARN
        END
    END
    Check status of adb device
    IF    '${device_in_adb}'=='True' and '${tl.ues[0].imsi}'!='xiaomi'
        ${skip_NAA_update}     Get Variable Value    ${skip_NAA_update}    False
        IF    ${skip_NAA_update}
            Log To Console    \nSkip NAA Plugin Version check and update
        ELSE
            TRY
                Check And Upgrade NAA Plugin Version
            EXCEPT    AS    ${error}
                Log    Check and upgrade NAA Plugin Version failed due to ${error}!!!    WARN
            END
        END
    END
    IF    '${device_in_adb}'=='False'
        ${error}    Set Variable     ERROR: Device ${device_model} is not detected in ADB!!!
        Set Suite Variable    ${L3call_exception}    ${error}
        FAIL    ${error}
    END
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=controlPC
