*** Settings ***
Documentation
...          	author:  Yin Jie
...          	contact: jie.1.yin@nokia-sbell.com
...          	description: Robot case for taf.ue test
Library      	BuiltIn
Library        ${CURDIR}/../resources/python/common.py
Resource       ${CURDIR}/../resources/robot/common_l3call.robot


*** Variables ***
@{ue_types_list}    android    askey    quectel    simcom

*** Test Cases ***
Proxy Manager And Proxy Startup Test
    [Tags]    proxy_mngr
    Proxy Manger Test

Proxy PYZ Package Test
    [Tags]    ue_proxy
    Proxy pyz package Test

Single Android Proxy Startup Test
    [Documentation]  This test case is used for android proxy startup test
    [Tags]     proxy_startup    android
    Single Proxy Startup Test    ue_type=android
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=cpc

Single Askey Proxy Startup Test
    [Documentation]  This test case is used for askey proxy startup test
    [Tags]     proxy_startup    askey
    Single Proxy Startup Test    ue_type=askey
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=cpc

Single Quectel Proxy Startup Test
    [Documentation]  This test case is used for quectel proxy startup test
    [Tags]     proxy_startup    quectel
    Single Proxy Startup Test    ue_type=quectel
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=cpc

Single Simcom Proxy Startup Test
    [Documentation]  This test case is used for simcom proxy startup test
    [Tags]     proxy_startup    simcom
    Single Proxy Startup Test    ue_type=simcom
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=cpc

NAA Plugin Test
    [Tags]    NAA
    NAA plugin Test

*** Keywords ***
Upgrade taf ue proxy manager
    [Arguments]    ${proxy_mngr_package}    ${cpc_addr}    ${cpc_username}    ${cpc_password}    ${ue}=${ue}    ${alias}=cpc
    upload_taf_ue_package_to_cpc
    ...    taf_ue_package_download_link=${PROXY_MNGR_DOWNLOAD_URL}
    ...    pc_address=${cpc_addr}
    ...    pc_username=${cpc_username}
    ...    pc_password=${cpc_password}
    Log to console    \n\t----------------- PC .shiv folder cleanup and proxy manager uninstallation -----------------\n
    Connect to controlPC
    ...    cpc_addr=${cpc_addr}
    ...    cpc_username=${cpc_username}
    ...    cpc_password=${cpc_password}
    ...    alias=${alias}
    shiv_folder_cleanup
    ...    pc_username=${cpc_username}
    ...    alias=${alias}
    uninstall_proxy_mngr
    ...    OS=${cpc_type}
    ...    alias=${alias}
    Log to console    \n\n\t----------------- Install ${proxy_mngr_package}-----------------\n
    install_taf_lib_from_given_path
    ...    package_name=${proxy_mngr_package}
    ...    package_path=~
    ...    alias=${alias}
    proxy_check_and_recovery
    ...    OS=${cpc_type}
    ...    alias=${alias}
    ...    user=${cpc_username}
    ...    fatal=True
    ${proxy_mngr_version}    get_taf_proxy_mngr_version
    ...    cpc_addr=${cpc_addr}    ue=${ue}
    UE Proxy Startup Test
    ...    cpc_addr=${cpc_addr}    ue=${ue}    ue_types_list=${ue_types_list}

UE Proxy Startup Test
    [Documentation]    Test UE proxy
    [Arguments]    ${cpc_addr}    ${ue}   ${ue_types_list}
    Log to console    \n\n\t----------------- UE PROXY startup test-----------------\n
    ${results}    start_all_ue_proxies
    ...    cpc_addr=${cpc_addr}
    ...    ue=${ue}
    ...    ue_types_list=${ue_types_list}
    FOR    ${ue_type}    ${ue_proxy_result}    IN    &{results}
        IF    ${ue_proxy_result[0]}
            Log to console    \n\t----------------- ${ue_type} proxy starts successfully with version ${ue_proxy_result[1]} -----------------\n
        ELSE
            Log to console    \n\t----------------- ${ue_type} proxy starts failed due to ${ue_proxy_result[1]}-----------------\n
            Run Keyword And Continue On Failure    Fail    ${ue_type} proxy starts failed!!!!
        END
    END


Single Proxy Startup Test
    [Arguments]    ${ue_type}
    ${proxy_mngr_test}     Run Keyword And Return Status    Variable Should Exist    ${PROXY_MNGR_DOWNLOAD_URL}
    IF    not ${proxy_mngr_test}
        Log to console    \n\t =========== Proxy Manager test is not performed, skip proxy startup test ===========\t
        RETURN
    END
    ${cpc_addr_list}    Create List
    FOR  ${ue}  IN  @{tl.ues}
        ${cpc_addr}=        Get Variable Value    ${ue.ssh_connection_details.addr}    ${ue.ue_pc_address}
        ${cpc_username}=    Get Variable Value    ${ue.ssh_connection_details.username}    ${ue.ue_pc_login}
        ${cpc_password}=    Get Variable Value    ${ue.ssh_connection_details.password}    ${ue.ue_pc_password}
        IF    '${cpc_addr}' in ${cpc_addr_list}
            Log To Console    ${cpc_addr} has been checked, skip proxy startup test
        ELSE
            Get CPC OS    cpc_addr=${cpc_addr}    cpc_username=${cpc_username}    cpc_password=${cpc_password}
            Log to console    \n\t =========== PC INFO: ${cpc_addr} / ${cpc_username} / ${cpc_password} / ${cpc_type} ===========\t
            @{ue_types_list_for_single}    Create List    ${ue_type}
            UE Proxy Startup Test
            ...    cpc_addr=${cpc_addr}
            ...    ue=${ue}
            ...    ue_types_list=${ue_types_list_for_single}
            Append To List    ${cpc_addr_list}    ${cpc_addr}
        END
    END

Proxy pyz package Test
    ${cpc_addr_list}    Create List
    FOR    ${ue_proxy_url}    IN    @{UE_PROXY_DOWNLOAD_URL}
        ${ue_proxy_package}    Set Variable    ${ue_proxy_url.split('/')[-1]}
        Log to console    \n\t----------------- Download package ${ue_proxy_package} -----------------\n
        download_taf_ue_package_to_vm
        ...    taf_ue_package_download_link=${ue_proxy_url}
    END
    FOR  ${ue}  IN  @{tl.ues}
        ${cpc_addr}=        Get Variable Value    ${ue.ssh_connection_details.addr}    ${ue.ue_pc_address}
        ${cpc_username}=    Get Variable Value    ${ue.ssh_connection_details.username}    ${ue.ue_pc_login}
        ${cpc_password}=    Get Variable Value    ${ue.ssh_connection_details.password}    ${ue.ue_pc_password}
        IF    '${cpc_addr}' in ${cpc_addr_list}
            Log To Console    ${cpc_addr} has been checked, skip ue proxy package installation
        ELSE
            Append To List    ${cpc_addr_list}    ${cpc_addr}
            Get CPC OS    cpc_addr=${cpc_addr}    cpc_username=${cpc_username}    cpc_password=${cpc_password}
            Connect to controlPC
            ...    cpc_addr=${cpc_addr}
            ...    cpc_username=${cpc_username}
            ...    cpc_password=${cpc_password}
            ...    alias=cpc
            Log to console    \n\n\t =========== PC INFO: ${cpc_addr} / ${cpc_username} / ${cpc_password} / ${cpc_type} ===========\t
            FOR    ${ue_proxy_url}    IN    @{UE_PROXY_DOWNLOAD_URL}
                ${ue_proxy_package}    Set Variable    ${ue_proxy_url.split('/')[-1]}
                IF    'win' in '${ue_proxy_package}' and '${cpc_type}'=='Linux'
                    Log To Console
                    ...    \n\t----------------- ${ue_proxy_package} is not supported on Linux, skip installation -----------------\n
                    CONTINUE
                ELSE IF    'linux' in '${ue_proxy_package}' and '${cpc_type}'=='Windows'
                    Log To Console
                    ...    \n\t----------------- ${ue_proxy_package} is not supported on Windows, skip installation -----------------\n
                    CONTINUE
                END
                Log to console    \n\t =========== Proxy pyz Package ${ue_proxy_package} Test===========\t
                ${release_folder_path}    get_releases_folder_path_in_PC    alias=cpc
                FOR     ${release_folder}     IN    @{release_folder_path.split('\n')}
                    upload_taf_ue_package_to_cpc
                    ...    taf_ue_package_download_link=${ue_proxy_url}
                    ...    pc_address=${cpc_addr}
                    ...    pc_username=${cpc_username}
                    ...    pc_password=${cpc_password}
                    ...    destination_path=${release_folder.strip()}
                END
                ${ue_proxy_stopped}    stop_ueproxy_by_ue_type
                ...    cpc_addr=${cpc_addr}
                ...    proxy_mngr_port=${ue.proxy_mngr_port}
                ...    ue_type_from_init_file=${ue.ue_type}
                IF   ${ue_proxy_stopped}
                    ${ue_proxy_started}    start_ueproxy_release
                    ...    ueproxy_release=${ue_proxy_package}
                    ...    cpc_addr=${cpc_addr}
                    ...    proxy_mngr_port=${ue.proxy_mngr_port}
                    IF     ${ue_proxy_started}
                        Log To Console
                        ...    \n\t----------------- ${ue_proxy_package} Startup SUCCESS on ${cpc_addr} -----------------\n
                    ELSE
                        Run Keyword And Continue On Failure
                        ...    Fail    ${ue_proxy_package} Startup FAIL on ${cpc_addr}
                        Log To Console
                        ...    \n\t----------------- ${ue_proxy_package} Installation FAIL on ${cpc_addr} -----------------\n
                    END
                ELSE
                    Run Keyword And Continue On Failure
                    ...    Fail    ${ue.ue_type} proxy is not stopped on ${cpc_addr}
                    Log To Console
                    ...    \n\t----------------- ${ue.ue_type} proxy is not stopped on ${cpc_addr} -----------------\n
                END
            END
        END
    END
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=cpc

NAA plugin Test
    [Documentation]    Test NAA plugin pre-release
    ${naa_package}     Set Variable    ${NAA_PLUGIN_DOWNLOAD_URL.split('/')[-1]}
    Log to console    \n\t----------------- Download package ${naa_package} -----------------\n
    ${cpc_addr_list}    Create List
    ${device_model_list}     Create List
    ${match_str}     Get Regexp Matches    ${naa_package}    \\d+[-.]\\d+[-.]\\d+
    ${target_plugin_ver}     Set Variable    ${match_str[0].replace('-', '.')}
    download_taf_ue_package_to_vm
    ...    taf_ue_package_download_link=${NAA_PLUGIN_DOWNLOAD_URL}
    FOR  ${ue}  IN  @{tl.ues}
        ${cpc_addr}=        Get Variable Value    ${ue.ssh_connection_details.addr}    ${ue.ue_pc_address}
        ${cpc_username}=    Get Variable Value    ${ue.ssh_connection_details.username}    ${ue.ue_pc_login}
        ${cpc_password}=    Get Variable Value    ${ue.ssh_connection_details.password}    ${ue.ue_pc_password}
        ${device_model}=    Set Variable    ${ue.serial_number}
        IF    '${ue.ue_type}' != 'android'
            Log To Console
            ...    \n\t----------------- ${device_model} is not android, skip NAA plugin installation -----------------\n
            CONTINUE
        END
        IF    '${cpc_addr}' not in ${cpc_addr_list}
            upload_taf_ue_package_to_cpc
            ...    taf_ue_package_download_link=${NAA_PLUGIN_DOWNLOAD_URL}
            ...    pc_address=${cpc_addr}
            ...    pc_username=${cpc_username}
            ...    pc_password=${cpc_password}
            Append To List    ${cpc_addr_list}    ${cpc_addr}
        END
        IF   '${device_model}' in ${device_model_list}
            CONTINUE
        END
        Append To List    ${device_model_list}    ${device_model}
        Log to Console
        ...    \n\t ====== PC INFO: ${cpc_addr} / ${cpc_username} / ${cpc_password}, Device Model: ${device_model} ======\t\n
        Log to console    \n\t----------------- Install ${naa_package} -----------------\n
        Connect to controlPC
        ...    cpc_addr=${cpc_addr}
        ...    cpc_username=${cpc_username}
        ...    cpc_password=${cpc_password}
        ...    alias=controlPC
        Wait Until Keyword Succeeds    60s    10s
        ...                    ssh.execute   adb -s ${device_model} uninstall com.nokia.android.application
        ...                    connection=controlPC    timeout=60s
        Wait Until Keyword Succeeds    60s    10s
        ...                    ssh.execute   adb -s ${device_model} install -g -t ${naa_package}
        ...                    connection=controlPC    timeout=60s
        ${plugin_ver}    Check Plugin Version On LabPC
        ...    cpc_addr=${cpc_addr}
        ...    cpc_username=${cpc_username}
        ...    cpc_password=${cpc_password}
        ...    device_model=${device_model}
        Log To Console         NAA Plugin version on UE after sw update: ${plugin_ver}
        ${result}    Run Keyword And Return Status    Should Be Equal    ${plugin_ver}    ${target_plugin_ver}
        IF    ${result}
            Log To Console
            ...    \n\t----------------- ${naa_package} Installation SUCCESS on ${device_model} -----------------\n
        ELSE
            Run Keyword And Continue On Failure
            ...    Fail    NAA Plugin version on UE is not as expected: ${plugin_ver}, expected: ${target_plugin_ver}
            Log To Console
            ...    \n\t----------------- ${naa_package} Installation FAIL on ${device_model} -----------------\n
        END
    END
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=controlPC

Proxy Manger Test
    [Documentation]    Test the proxy manager pre-release
    ${proxy_mngr_package}     Set Variable    ${PROXY_MNGR_DOWNLOAD_URL.split('/')[-1]}
    ${cpc_addr_list}    Create List
    Log to console    \n\t----------------- Download package ${proxy_mngr_package} -----------------\n
    download_taf_ue_package_to_vm
    ...    taf_ue_package_download_link=${PROXY_MNGR_DOWNLOAD_URL}
    FOR  ${ue}  IN  @{tl.ues}
        ${cpc_addr}=        Get Variable Value    ${ue.ssh_connection_details.addr}    ${ue.ue_pc_address}
        ${cpc_username}=    Get Variable Value    ${ue.ssh_connection_details.username}    ${ue.ue_pc_login}
        ${cpc_password}=    Get Variable Value    ${ue.ssh_connection_details.password}    ${ue.ue_pc_password}
        IF    '${cpc_addr}' in ${cpc_addr_list}
            Log To Console    ${cpc_addr} has been checked, skip proxy manager package installation
        ELSE
            Append To List    ${cpc_addr_list}    ${cpc_addr}
            Get CPC OS    cpc_addr=${cpc_addr}    cpc_username=${cpc_username}    cpc_password=${cpc_password}
            Log to console    \n\n\t =========== PC INFO: ${cpc_addr} / ${cpc_username} / ${cpc_password} / ${cpc_type} ===========\t
            Log to console    \n\t =========== Proxy Manager ${proxy_mngr_package} Test===========\t
            Upgrade taf ue proxy manager
            ...    proxy_mngr_package=${proxy_mngr_package}
            ...    cpc_addr=${cpc_addr}
            ...    cpc_username=${cpc_username}
            ...    cpc_password=${cpc_password}
            ...    ue=${ue}
        END
    END
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=cpc