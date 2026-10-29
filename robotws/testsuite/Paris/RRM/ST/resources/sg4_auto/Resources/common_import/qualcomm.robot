*** Settings ***

Documentation     Keywords related to Qualcomm handling
...    TODO: Attach, Detach, Data Transfer should be vailid for Viavi also

Library    Collections
Library    ./python/qualcomm.py    WITH NAME    qualcomm_internal
Library	    taf.ue                                  WITH NAME    ute_ue
Library    taf.transport.ssh       WITH NAME    ssh
Resource    ./testline.robot
Resource    ./connect.robot


*** Variables ***
${P_console}         ${False}
${P_DL_COUNTER}      0
${P_UL_COUNTER}      0

*** Keywords ***
Set QCI for UE
    [Documentation]    :Author: Jing Liang
    ...    prepare needed ute_ue config with qci related test
    ...    Important: Must have 'Create Configuration for UTE UE' from ute_handler.robot at Suite Setup, before using this keyword
    ...    Important: This keyword must be used before "Setup Qualcomm UE"
    ...
    ...    :param  qci: used qci for ue
    ...    :param  port: iperf port for this configured qci
    ...    :param  ue_id: (default 0) the ID of UE, Integer or String
    [Arguments]    ${qci}    ${port}    ${ue_id}=0
    ${iper_qci}=    Get Variable Value    ${IPERF_QCI_${ue_id}}
    ${iper_qci}=    qualcomm_internal.update_qci    qci_dict=${iper_qci}    qci=${qci}    port=${port}
    Set Suite Variable    ${IPERF_QCI_${ue_id}}    ${iper_qci}
    ${nested_dict}=    Catenate    SEPARATOR=][
    ...    UE_POOLS.AndroidUePool['inline_config']['Qualcomm_${ue_id}'
    ...    'CONSTRUCTOR_PARAMETERS']['configuration']['data_transfer']
    Set To Dictionary
    ...    ${ABSTRACT_LIB_CONFIG.${nested_dict}}    iperf_options    ${IPERF_QCI_${ue_id}}
    Set Suite Variable    ${ABSTRACT_LIB_CONFIG}


Setup Qualcomm UE
    [Documentation]    :Author: Jing Liang
    ...    This a HIGH Level Keyword which setups Qualcomm UE for the automated usage.
    ...    Important: Must have 'Create Configuration for UTE UE' from ute_handler.robot at Suite Setup
    ...    Important: this keyword must be called before any other Qualcomm related keyword.
    ...    Important: it is expected that TL configuration (i.e. tl.ues from __init__.py) is filled according to Android configuration.
    ...    :param  ue_id: (default 0) the ID of UE, Integer or String
    ...    :param  delete_existing_pyro_logs: (default False) Delete existing pyro logs before you start using Qualcomm
    ...
    ...    :return: UE alias
    [Arguments]    ${ue_id}=0    ${delete_existing_pyro_logs}=${False}
    Run Keyword If    ${delete_existing_pyro_logs}    Delete pyro logs    ue_id=${ue_id}
    ${ue_alias}=    Get Ue Alias    ue_id=${ue_id}
    ute_ue.Require Ue    ${ue_alias}    capabilities=${ue_alias}
    [Return]    ${ue_alias}


Attach Qualcomm Ue
    [Documentation]    :Author:  Jing Liang
    ...    Attach a Single UE
    ...    :param  ue_id: (default 0) the ID of UE, Integer or String
    [Arguments]    ${ue_id}=0
    ${ue_alias}=    Get Ue Alias    ue_id=${ue_id}
    BuiltIn.Log     Attach a Single UE [${ue_alias}] .   console=${P_console}
    ute_ue.Attach Ue    ${ue_alias}
    Sleep    3s
    BuiltIn.Log     .done!        console=${P_console}


Detach Qualcomm Ue
    [Documentation]    :Author: Jing Liang
    ...    Detach a Single UE
    ...    :param  ue_id: (default 0) the ID of UE, Integer or String
    [Arguments]    ${ue_id}=0
    ${ue_alias}=    Get Ue Alias    ue_id=${ue_id}
    BuiltIn.Log     Detach a Single UE [${ue_alias}] .    console=${P_console}
    ute_ue.Detach Ue    ${ue_alias}    timeout=60
    Sleep    3s
    BuiltIn.Log     .done!     console=${P_console}


Parallel Downlink And Uplink Data Transfer With TCP
    [Documentation]    :Author: Michele
    ...    :param  ue_id: (default 0) the ID of UE, Integer or String
    ...    :param  duration: (default 15s) String, e.g. '1 minutes 42 seconds' or '1min 42s'
    ...    :param  app_server: (default APP_0) String, should be APP_*, * is the ID of appserver in appservers
    ...    Limitation: Only Default QCI with iperf2.
    ...
    [Arguments]    ${ue_id}=0    ${duration}=15s    ${app_server}=APP_0
    ${ue_alias}=    Get Ue Alias    ue_id=${ue_id}
    ${transfer_Type}=    Set Variable    DLUL_TCP_${ue_alias}
    BuiltIn.Log     Start ${transfer_Type} for ${duration}  console=${P_console}
    ute_ue.Start Data Transfer    DT_DL_1    ${ue_alias}    DL    duration=${duration}    protocol=tcp    app_server=${app_server}
    ute_ue.Start Data Transfer    DT_UL_2    ${ue_alias}    UL    duration=${duration}    protocol=tcp    app_server=${app_server}
    ute_ue.Await Data Transfer Finish    DT_DL_1
    ute_ue.Await Data Transfer Finish    DT_UL_2


Start UL Data Transfer Qualcomm Ue
    [Documentation]    :Author: Jing Liang
    ...    :param  ue_id: (default 0) the ID of UE, Integer or String
    ...    :param  duration: (default 30s) String, e.g. '1 minutes 42 seconds' or '1min 42s'
    ...    :param  throughput: (default 2 Mbits/sec) String, e.g. '100 MBytes/sec'
    ...    :param  bearer_alias: (default UeAutomatic) String, with UeAutomatic means that UE decides which bearer it will use
    ...    :param  protocol: (default udp) String,  'udp' or 'tcp' or 'icmp' or 'http' or 'ftp'
    ...    :param  app_server: (default APP_0) String, should be APP_*, * is the ID of appserver in appservers
    ...    :param  trafficStartTimeout (default 120) Number, This will await 120s for the iPerf server + iPerf client start.
    ...                                              As soon the iPerf is recognize the Data Transfer is Started.
    ...    :param  protocol_details: (optional) advanced usage
    ...    When ‘icmp’ protocol is used (for ping) additional parameters are required: ping_host_ip, ping_count, allowed_packet_loss.
    ...    When ‘http’ protocol is used additional parameter is required: url.
    ...
    ...    :return: dt_name for stop traffic
    [Arguments]    ${ue_id}=0    ${duration}=30s    ${throughput}=2 Mbits/sec
    ...    ${bearer_alias}=UeAutomatic    ${protocol}=udp    ${app_server}=APP_0    ${trafficStartTimeout}=120    &{protocol_details}
    ${ue_alias}=    Get Ue Alias    ue_id=${ue_id}
    Set Traffic Counter    direction=UL
    ${dt_name}=    Set Variable    UlTraffic_${ue_alias}_${P_UL_COUNTER}
    BuiltIn.Log     Start ${dt_name} ${throughput} ${protocol} for ${duration}      console=${P_console}
    ute_ue.Start Data Transfer    dt_name=${dt_name}    ue_alias=${ue_alias}    direction=ul    duration=${duration}
    ...    throughput=${throughput}    bearer_alias=${bearer_alias}    protocol=${protocol}    app_server=${app_server}
    ...    timeout=${trafficStartTimeout}    &{protocol_details}
    [Return]    ${dt_name}


Start DL Data Transfer Qualcomm Ue
    [Documentation]    :Author: Jing Liang
    ...    :param  ue_id: (default 0) the ID of UE, Integer or String
    ...    :param  duration: (default 30s) String, e.g. '1 minutes 42 seconds' or '1min 42s'
    ...    :param  throughput: (default 2 Mbits/sec) String, e.g. '100 MBytes/sec'
    ...    :param  bearer_alias: (default UeAutomatic) String, with UeAutomatic means that UE decides which bearer it will use
    ...    :param  protocol: (default udp) String,  'udp' or 'tcp' or 'icmp' or 'http' or 'ftp'
    ...    :param  app_server: (default APP_0) String, should be APP_*, * is the ID of appserver in appservers
    ...    :param  trafficStartTimeout (default 120) Number, This will await 120s for the iPerf server + iPerf client start.
    ...                                              As soon the iPerf is recognize the Data Transfer is Started.
    ...    :param  protocol_details: (optional) advanced usage
    ...    When ‘icmp’ protocol is used (for ping) additional parameters are required: ping_host_ip, ping_count, allowed_packet_loss.
    ...    When ‘http’ protocol is used additional parameter is required: url.
    ...
    ...    :return: dt_name for stop traffic
    [Arguments]    ${ue_id}=0    ${duration}=30s    ${throughput}=2 Mbits/sec
    ...    ${bearer_alias}=UeAutomatic    ${protocol}=udp    ${app_server}=APP_0    ${trafficStartTimeout}=120    &{protocol_details}
    ${ue_alias}=    Get Ue Alias    ue_id=${ue_id}
    Set Traffic Counter    direction=DL
    ${dt_name}=    Set Variable    DlTraffic_${ue_alias}_${P_DL_COUNTER}
    BuiltIn.Log     Start ${dt_name} ${throughput} ${protocol} for ${duration}  console=${P_console}
    ute_ue.Start Data Transfer    dt_name=${dt_name}    ue_alias=${ue_alias}    direction=dl    duration=${duration}
    ...    throughput=${throughput}    bearer_alias=${bearer_alias}    protocol=${protocol}    app_server=${app_server}
    ...    timeout=${trafficStartTimeout}    &{protocol_details}
    [Return]    ${dt_name}


Stop Data Transfer
    [Documentation]    :Author: Jing Liang
    ...    Stop Data Transfer for given dt_name
    ...    :param  dt_name:  Name of Data Transfer that is assigned in Start Data Transfer keyword
    [Arguments]    ${dt_name}
    BuiltIn.Log     Stop ongoing data transfer on ${dt_name}    console=${P_console}
    ute_ue.Stop Data Transfer    dt_name=${dt_name}


Reboot Qualcomm Ue and wait for reconnection
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Reboot Qualcomm Ue and wait until it is up again
    [Arguments]    ${ue_id}=0    ${timeout}=${240}
    Reboot Qualcomm Ue    ue_id=${ue_id}
    Wait until keyword succeeds    ${timeout}    5 sec    Qualcomm Ue is connected    ue_id=${ue_id}
    ${ue_alias}=    Get Ue Alias    ue_id=${ue_id}
    BuiltIn.Log    Qualcomm Ue [${ue_alias}] reconnected    console=${P_console}


Qualcomm Ue is connected
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Check if Qualcomm Ue is connected
    [Arguments]    ${ue_id}=0
    ${testpc_alias}=    connect.Connect to UE PC    ue_id=${ue_id}
    ssh.Send command    adb devices    connection=${testpc_alias}
    ${output}=    ssh.Read output    connection=${testpc_alias}
    BuiltIn.Log    ${\n}Qualcomm UE_${ue_id} Id=${output}    console=${P_console}
    Should contain    ${output}    ${tl.ues[${ue_id}].serial_number}
    [Teardown]    ssh.disconnect    connection=${testpc_alias}


Qualcomm Set ADB ROOT
    [Documentation]    :Author: Michele
    ...    Set Qualcomm Ue "adb root".
    [Arguments]    ${ue_id}=0
    ${testpc_alias}=    connect.Connect to UE PC    ue_id=${ue_id}
    ssh.Send Command    adb root    connection=${testpc_alias}
    ${output}=    ssh.Read Output    connection=${testpc_alias}
    ${ue_alias}=    Get Ue Alias    ue_id=${ue_id}
    BuiltIn.Log    ${\n}Qualcomm is ${output}    console=${P_console}
    [Teardown]    ssh.disconnect    connection=${testpc_alias}


Qualcomm Set ADB UNROOT
    [Documentation]    :Author: Michele
    ...    Set Qualcomm Ue "adb unroot".
    [Arguments]    ${ue_id}=0
    ${testpc_alias}=    connect.Connect to UE PC    ue_id=${ue_id}
    ssh.Send Command    adb unroot    connection=${testpc_alias}
    ${output}=    ssh.Read Output    connection=${testpc_alias}
    ${ue_alias}=    Get Ue Alias    ue_id=${ue_id}
    BuiltIn.Log    ${\n}Qualcomm is ${output}    console=${P_console}
    [Teardown]    ssh.disconnect    connection=${testpc_alias}


Get Android IMSI
    [Documentation]    :Author: Jing Liang
    ...    Get Ue IMSI for all UE using ta.ue.plugin.android,
    ...    First try get imsi via ADB,
    ...    if get empty string will try with AT command
    [Arguments]    ${ue_id}=0
    ${ue_imsi}=    Qualcomm Get ADB IMSI    ue_id=${ue_id}
    ${ue_imsi}=    Run Keyword If    '${ue_imsi}' == ''    Qualcomm Get AT IMSI    ue_id=${ue_id}
    ...    ELSE   Set Variable   ${ue_imsi}
    [Return]    ${ue_imsi}


Reboot Qualcomm Ue
    [Documentation]    :Author: Nikolay Shkulepov
    ...    This a HIGH Level Keyword which reboots Qualcomm UE.
    ...    Important: if that keyword works, then your TL is properly configured; otherwise please reference to
    ...    the following http://files.ute.nsn-rdnet.net/package_documentation/ute_ue/interfaces/ute_ue.html.
    ...    :param  ue_id: (default 0) the ID of UE, Integer or String
    [Arguments]    ${ue_id}=0
    ${testpc_alias}=    connect.Connect to UE PC    ue_id=${ue_id}
    ssh.Send Command    adb reboot    connection=${testpc_alias}
    ${output}=    ssh.Read Output    connection=${testpc_alias}
    BuiltIn.Log    Reboot Qualcomm Ue_${ue_id}: stdoutStr = ${output}    level=DEBUG
    ${ue_alias}=    Get Ue Alias    ue_id=${ue_id}
    BuiltIn.Log    Qualcomm Ue [${ue_alias}] rebooted    console=${P_console}
    [Teardown]    ssh.disconnect    connection=${testpc_alias}


Collect pyro logs
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Collect pyro logs from qualcomm test pc.
    ...    Important: You need to set "server_dir='/cygdrive/c/pyro_server'" in __init__.py
    ...
    ...    :param  ue_id: (default 0) the ID of UE, Integer or String
    ...    :param target_dir: Logs target directory
    ...
    [Arguments]    ${ue_id}=0    ${target_dir}=None
    ${resultTestDir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get testcase log directory
    ...    ELSE    Set variable    ${target_dir}
    ${testpc_alias}=    connect.Connect to UE PC    ue_id=${ue_id}
    Create directory    ${resultTestDir}/${testpc_alias}_pyro_logs
    ${log_files}=    Create list    ta_ue_uepc_local.log    ta_uepc_pyro.log
    FOR    ${file}    IN    @{log_files}
        ssh.download_file    remote_path=${tl.ues[${ue_id}].server_dir}/logs/${file}
        ...    local_path=${resultTestDir}/${testpc_alias}_pyro_logs/${file}
        ...    connection=${testpc_alias}
    END
    ${ue_alias}=    Get Ue Alias    ue_id=${ue_id}
    BuiltIn.Log    Qualcomm Ue [${ue_alias}] pyro logs are collected!    console=${P_console}
    [Teardown]    ssh.disconnect    connection=${testpc_alias}


Delete pyro logs
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Delete pyro logs from qualcomm test pc.
    ...
    ...    :param  ue_id: (default 0) the ID of UE, Integer or String
    ...
    [Arguments]    ${ue_id}=0
    ${testpc_alias}=    connect.Connect to UE PC    ue_id=${ue_id}
    ${log_files}=    Create list    ta_ue_uepc_local.log    ta_uepc_pyro.log
    FOR    ${file}    IN    @{log_files}
        ssh.Send Command    command=rm ${tl.ues[${ue_id}].server_dir}/logs/${file}    connection=${testpc_alias}
    END
    [Teardown]    ssh.disconnect    connection=${testpc_alias}


Log Qualcomm Ue Info to Console
    [Documentation]    :Author: Jing Liang
    ...    TODO: to use ute_ue.Log Ue Info once implementation has been done
    ...    This a HIGH Level Keyword which connects to Qualcomm UE, fetches its info and prints it to console.
    ...    Important: if that keyword works, then your TL is properly configured; otherwise please reference to
    ...    the following http://files.ute.nsn-rdnet.net/package_documentation/ute_ue/interfaces/ute_ue.html.
    ...    :param  ue_id: (OPTIONAL) the ID of UE, Integer or String
    [Arguments]    ${ue_id}=0
    ${ue_alias}=    Get Ue Alias    ue_id=${ue_id}
    ${msg}=    qualcomm_internal.qualcomm_ue_log_generator    ${ue_alias}
    Log To Console    ${msg}
    Run Keyword and Ignore Error    Get UE SW Information   ue_id=${ue_id}
    Run Keyword and Ignore Error    Get Android IMSI    ue_id=${ue_id}


Get UE SW Information
    [Documentation]    :Author: Michele
    ...    Get UE SW for all UE using ta.ue.plugin.android,
    ...    First try get SW via ADB,
    ...    if get empty string will try with AT command
    [Arguments]    ${ue_id}=0
    ${ue_SW}=    Print ADB devices BuildID and BaseBand Version    ue_id=${ue_id}
    ${ue_SW}=    Run Keyword If    '${ue_SW}' == 'None'    Qualcomm Get ATI    ue_id=${ue_id}
    ...    ELSE   Set Variable   ${ue_SW}
    [Return]    ${ue_SW}


Print ADB devices BuildID and BaseBand Version
    [Documentation]    :Author: Michele
    ...    Print BuildID and BaseBand Version of devices using ADB(Android Debug Bridge).
    [Arguments]    ${ue_id}=0
    ${testpc_alias}=    connect.Connect to UE PC    ue_id=${ue_id}
    ssh.Send Command    adb shell getprop ro.build.id    connection=${testpc_alias}    timeout=10
    ${ue_build_id}=    ssh.Read Output    connection=${testpc_alias}
    Return From Keyword If    'not found' in '${ue_build_id.strip()}'
    Log To Console    ${\n}Build ID:${\n}\t${ue_build_id}
    ssh.Send Command    adb shell getprop gsm.version.baseband    connection=${testpc_alias}    timeout=10
    ${ue_version_baseband}=    ssh.Read Output    connection=${testpc_alias}
    Log To Console    ${\n}Version BaseBand:${\n}\t${ue_version_baseband}
    [Teardown]    ssh.disconnect    connection=${testpc_alias}


Get Ue Alias
    [Documentation]    :Author: Jing Liang
    ...    :param  ue_id: (default 0) the ID of UE, Integer or String
    ...
    ...    :return: ue alias for ute_ue
    [Arguments]    ${ue_id}=0
    ${ue_alias}=    Set Variable    UE_${ue_id}
    [Return]    ${ue_alias}


Set Traffic Counter
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    ...    :param  direction: UL / DL
    ...
    ...    :return: traffic Counter
    [Arguments]    ${direction}
    ${counter}=    Evaluate    ${P_${direction}_COUNTER}+1
    Set Test Variable    ${P_${direction}_COUNTER}    ${counter}


Set MBN interface for AtCmdUe
    [Documentation]    :Author: Jing Liang
    ...    This keyword is not needed for AT command UE anymore. [Deprecated]
    ...    [PRIVATE]   If UE doesn't have diag_com configured will do nothing
    ...    As WA for AT command UE, once TAF testline config supports this interface, should be removed
    [Arguments]    ${config}    ${ue_id}
    ${is_at}=    Get Variable Value    ${tl.ues[${ue_id}].serial_com}
    Return From Keyword If    '${is_at}'=='None'    ${config}
    ${uepc_alias}=    connect.Connect to UE PC    ue_id=${ue_id}
    ssh.Send Command    netsh mbn show interfaces    connection=${uepc_alias}
    ${output}=    ssh.Read Output    connection=${uepc_alias}
    ${status}=    Run Keyword and Return Status    should contain    ${output}    There is no
    Run Keyword If    ${status}    BuiltIn.Log    UE_${ue_id} : There is no Mobile Broadband interface
    ...    level=WARN    console=${P_console}
    Return From Keyword If    ${status}    ${config}
    ${output}=    Get Lines Matching Regexp    ${output}    \\s{2,}Name.*
    ${nested_dict}=    Catenate    SEPARATOR=][
    ...    UE_POOLS.AndroidUePool['inline_config']['Qualcomm_${ue_id}'
    ...    'CONSTRUCTOR_PARAMETERS']['configuration']
    Set to Dictionary    ${config.${nested_dict}}    interface_name    ${output.split(':')[1].strip()}
    [Return]    ${config}


Qualcomm Get ADB IMSI
    [Documentation]    :Author: Michele
    ...    [PRIVATE]    Get Qualcomm Ue IMSI.
    [Arguments]    ${ue_id}=0
    ${testpc_alias}=    connect.Connect to UE PC    ue_id=${ue_id}
    ssh.Send Command    adb shell service call iphonesubinfo 7    connection=${testpc_alias}    timeout=10
    ${output}=    ssh.Read Output    connection=${testpc_alias}
    ${matches1} =      Get Regexp Matches      ${output}       '(................)
    ${aLLmatches} =  Catenate    ${matches1}
    ${ue_IMSI} =    Remove String    ${aLLmatches}   .    u    '    ,    "    ${SPACE}    [    ]
    BuiltIn.Log    ${\n}Qualcomm UE_${ue_id} IMSI is ${ue_IMSI}    console=${P_console}
    [Return]    ${ue_IMSI}
    [Teardown]    ssh.disconnect    connection=${testpc_alias}


Qualcomm Get AT IMSI
    [Documentation]    :Author: Giangiacomo Guglielmini
    ...    [PRIVATE]    get Ue IMSI using AT command
    ...    works fine for Askey, AT CMD based UE
    ...    requires qualcomm.Setup Qualcomm UE to have been already executed
    [Arguments]    ${ue_id}=0
    ${ue_alias}=    Get Ue Alias    ue_id=${ue_id}
    ${pre_status}=    ute_ue.Send At Cmd To Ue    ${ue_alias}    at_cmd=at+cfun?
    ${at_reply}=    Run Keyword If    '${pre_status[1]}'=='+CFUN: 0'     ute_ue.Send At Cmd To Ue    ${ue_alias}    at_cmd=at+cfun=1
    ${at_reply}=    ute_ue.Send At Cmd To Ue    ${ue_alias}    at_cmd=at+CIMI
    Run Keyword If    '${pre_status[1]}'=='+CFUN: 0'    ute_ue.Send At Cmd To Ue    ${ue_alias}    at_cmd=at+cfun=0
    BuiltIn.Log    IMSI_AT=${at_reply[1]}    console=${P_console}
    [Return]    ${at_reply[1]}


Qualcomm Get ATI
    [Documentation]    :Author: Michele
    ...    get UE SW Information using AT command
    ...    Work with AT CMD based UE
    ...    requires qualcomm.Setup Qualcomm UE to have been already executed
    [Arguments]    ${ue_id}=0
    ${ue_alias}=    Get Ue Alias    ue_id=${ue_id}
    ${at_reply}=    ute_ue.Send At Cmd To Ue    ${ue_alias}    at_cmd=ATI
    BuiltIn.Log    ${\n}SW on UE_${ue_id}: ${at_reply}    console=${P_console}
    [Return]    ${at_reply}
