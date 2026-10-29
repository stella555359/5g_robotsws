*** Settings ***
Documentation     Common keywords which are needed to perform L3 Calls by Qualcomm UEs.

Library           taf.ue.interface.ue                   WITH NAME    ute_ue
Library           taf.transport.ssh.interface.ssh       WITH NAME    tafssh

*** Variables ***
${ue_index}    0
${SN}          ${tl.ues[0].serial_number}

*** Keywords ***

#########################################################################
#                        qualcomm ue special code                       #
#########################################################################

Get PCI on UE
    [Arguments]    ${ue_index}
    ${pci}=    Get Ue Info    UE_${ue_index}    PCI
    Should Be True    ${pci}>0
    [Return]    ${pci}

Qualcomm UE Pre-condition
    [Arguments]  ${ue_index}=${0}    ${cap_index}=${0}
    [Documentation]  TThis keyword is the precondition for Qualcomm ue attach.
    log    INFO:Get ABSTRACT_LIB_CONFIG for Qualcomm UE ...    console=true
    Get ABSTRACT_LIB_CONFIG for Qualcomm UE
    _Require UE By Index    ue_index=${ue_index}    cap_index=${cap_index}
    ADB Reboot UE By Index
    Is UE Connected To Control PC   ${ue_index}

Qualcomm ue require and attach
    [Arguments]    ${RAT}    ${UE_alias}    ${UE_CAPABILITIES}
    log    INFO:require_ue    console=true
    require_ue    ue_alias=${UE_alias}    capabilities=${UE_CAPABILITIES}
    sleep    10s
    log    INFO:attach ue    console=true
    attach_ue    ue_alias=${UE_alias}
    sleep    10s
    Is UE Attached Successfully Via ADB Command    ${RAT}    ${ue_index}

Qualcomm UE Attach
    [Arguments]  ${RAT}    ${ue_index}=${0}
    [Documentation]  This keyword is to perform UE attach and check the attach status.
    ...    and also one time reattach as WA for not success with ute_ue lib connect issue.
    ${attach_status}=    run keyword and return status  Ue Attach By Index    ${ue_index}
    log    ${attach_status}
    run keyword if     '${attach_status}'=='False'    Ue Reattach By Index    ${ue_index}
    Is UE Attached Successfully Via ADB Command    ${RAT}    ${ue_index}

Start UL Traffic Via Iperf From Andriod UE
    [Arguments]    ${ul_throughput}    ${ul_port}=43033    ${ul_length}=1024B    ${ul_duration}=9999    ${ue_index}=${0}
    [Documentation]  This keyword connect to android control pc and start the iperf data.
    Log to console    \n[INFO]:UL Traffic From Andriod UE is starting ...
    Connect To QUE Control PC    ${ue_index}
    tafssh.send command    command=adb shell pkill iperf    connection=cpc_${ue_index}
    ${appserver_addr} =    set variable     ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
    ${iperf_c} =    set variable     adb shell iperf -u -p ${ul_port} -P 1 -t ${ul_duration} -i 1 -f -m
    tafssh.send command
    ...    command=${iperf_c} -b ${ul_throughput}M -l ${ul_length} -T 64 -c ${appserver_addr} &
    ...    connection=cpc_${ue_index}
    [Teardown]    tafssh.disconnect    connection=cpc_${ue_index}

Start DL Traffic Via Iperf on Iperf server
    [Arguments]     ${dl_throughput}    ${ue_addr}=${0}    ${dl_port}=43033    ${dl_length}=1400    ${dl_duration}=9999
    [Documentation]   This keyword Connect to Iperf server and start the iperf data.
    Log to console    \n[INFO]:DL Traffic on Iperf server is starting ...
    wait until keyword succeeds    1 min    10 sec    Connect To Iperf Server
    tafssh.execute
    ...    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}' |xargs sudo kill -9
    ...    connection=APPserver
    tafssh.send command    command=iperf -c ${ue_addr} -u -i1 -l${dl_length} -p ${dl_port} -b ${dl_throughput}M -t ${dl_duration}
    ...    connection=APPserver
    [Teardown]    tafssh.disconnect    connection=APPserver

Stop UL Traffic on Andriod UE
    [Arguments]    ${ue_index}=${0}
    [Documentation]  This keyword connect to android control pc and start the iperf data.
    Log to console    \n[INFO]:UL Traffic on Andriod UE is stopping ...
    Connect To QUE Control PC    ${ue_index}
    tafssh.send command    command=adb shell pkill iperf    connection=cpc_${ue_index}
    [Teardown]    tafssh.disconnect    connection=cpc_${ue_index}

Stop DL Traffic on Iperf server
    [Arguments]     ${dl_port}=43033
    [Documentation]   This keyword Connect to Iperf server and start the iperf data.
    Log to console    \n[INFO]:DL Traffic on Iperf server is stopping ...
    wait until keyword succeeds    1 min    10 sec    Connect To Iperf Server
    tafssh.execute
    ...    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}' |xargs sudo kill -9
    ...    connection=APPserver
    [Teardown]    tafssh.disconnect    connection=APPserver

Connect To QUE Control PC
    [Arguments]  ${ue_index}=${0}
    [Documentation]  connect the control PC
    Wait Until Keyword Succeeds    2min    20s
    ...   tafssh.Connect to   ${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...                       ${tl.ues[${ue_index}].ssh_connection_details.username}
    ...                       ${tl.ues[${ue_index}].ssh_connection_details.password}   alias=cpc_${ue_index}

Connect To Iperf Server
    [Arguments]    ${ue_index}=${0}    ${alias}=APPserver
    [Documentation]  connect to iperf server
    tafssh.Connect to    hostname=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
    ...               username=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.username}
    ...               password=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.password}
    ...               alias=${alias}

Get ABSTRACT_LIB_CONFIG for Qualcomm UE
    ${testline}=    Get hostname
    Set Test Variable    ${ABSTRACT_LIB_CONFIG}    /home/ute/testline_configuration/${testline}/modules/inseego.yml
    Log To Console    \n[INFO]:The ABSTRACT_LIB_CONFIG is ${ABSTRACT_LIB_CONFIG}

_Require UE By Index
    [Arguments]  ${ue_index}=${0}    ${cap_index}=${0}
    [Documentation]  This keyword is used to detect ue that Connect To QUE Control PC by USB.
    ${ue_cap} =    set variable    ${tl.ues[${ue_index}].capabilities[${cap_index}]}
    ute_ue.require Ue    ue_alias=UE_${ue_index}    capabilities=${ue_cap}

Is UE Connected To Control PC
    [Arguments]  ${ue_index}=${0}
    [Documentation]  Check the UE device is Connect To QUE Control PC normally.
    Connect To QUE Control PC    ${ue_index}
    wait until keyword succeeds    3 min    10s
    ...     _Is ADB Device Connected   alias=cpc_${ue_index}    serial_number=${SN}
    tafssh.disconnect   connection=cpc_${ue_index}

_Is ADB Device Connected
    [Arguments]  ${alias}    ${serial_number}
    [Documentation]  Check the UE device connection status.
    tafssh.send_command   command=adb devices    connection=${alias}    timeout=5
    Sleep   3s
    ${result}    tafssh.read output    connection=${alias}
    Should contain   ${result}   ${serial_number}
    should not contain  ${result}   connecting

Ue Detach By Index
    [Arguments]  ${ue_index}=${0}
    [Documentation]  When with UE_CAPABILITIES is REAL_ANDORID_UE,
    ...    the keyword will send adb command to turn on the airplane mode.
    ute_ue.detach_ue    UE_${ue_index}

Android UE Recover
    [Arguments]  ${ue_index}=${0}
    [Documentation]  This keyword is the recovery action if ue attach failed
    ...    action contain UE reboot and airplane mode turn on.
    Is UE Connected To Control PC    ${ue_index}
    ADB Reboot UE By Index    ${ue_index}
    Is UE Connected To Control PC    ${ue_index}
    wait until keyword succeeds    2min    10s    Ue Detach By Index    ${ue_index}

ADB Reboot UE By Index
    [Arguments]  ${ue_index}=${0}
    [Documentation]  Use adb command to reboot the android ue device
    Connect To QUE Control PC    ${ue_index}
    tafssh.execute    command=adb -s ${SN} shell reboot   connection=cpc_${ue_index}
    tafssh.disconnect   connection=cpc_${ue_index}

Is UE Attached Successfully Via ADB Command
    [Arguments]  ${RAT}    ${ue_index}=${0}
    [Documentation]  Verify UE network type normal by ADB command.
    Connect To QUE Control PC    ${ue_index}
    wait until keyword succeeds    1min    10s    UE_${ue_index} Attached to ${RAT}
    [Teardown]    tafssh.disconnect   connection=cpc_${ue_index}

UE_${ue_index} Attached to ${RAT}
    [Documentation]    4G and 5G (LTE and NR_SA)
    tafssh.send command
    ...    command=adb -s ${SN} shell getprop gsm.network.type
    ...    connection=cpc_${ue_index}
    ...    timeout=10
    ${result}    tafssh.read output    connection=cpc_${ue_index}
    Run Keyword If    '${RAT.upper()}'=='4G'    Should contain  ${result}  LTE      [ERROR]UE_${ue_index} is failed to attach LTE
    Run Keyword If    '${RAT.upper()}'=='5G'    Should contain  ${result}  NR_SA    [ERROR]UE_${ue_index} is failed to attach NR_SA
    Log To Console    \n[INFO]:${RAT} UE ATTACH successfully.

Start The QPST Progress
    [Arguments]  ${ue_index}=${0}
    [Documentation]  To start the Control PC qpst.exe progress to catch the ue crash dump ,
    Connect To QUE Control PC    ${ue_index}
    tafssh.Send Command    command=${QPSTexe}   connection=cpc_${ue_index}    timeout=5
    sleep    3s
    tafssh.disconnect      connection=cpc_${ue_index}

Ue Attach By Index
    [Arguments]  ${ue_index}=${0}
    [Documentation]  This keyword's behavior are different when using different plugins.
    ...    If UE_CAPABILITIES is REAL_ANDORID_UE, the keyword will send adb command to turn off the airplane mode.
    run keyword and return status    ute_ue.attach_ue    UE_${ue_index}

Ue Reattach By Index
    [Arguments]  ${ue_index}=${0}
    [Documentation]  This keyword's is a WA for ute_ue.ue attach sometimes not connect success and attach fail.
    Android UE Recover    ${ue_index}
    sleep    30s
    wait until keyword succeeds    5min    10s    Ue Detach By Index    ${ue_index}
    Ue Attach By Index   ue_index=${ue_index}

Start The UEmanager App
    [Arguments]    ${ue_index}=${0}
    [Documentation]  This keyword is to start uemanager app on ue via adb command.
    Connect To QUE Control PC  ${ue_index}
    tafssh.Send Command
    ...    command=adb -s ${SN} shell monkey -p com.nokia.syve.uemanager.mobile -c android.intent.category.LAUNCHER 1
    ...    connection=cpc_${ue_index}
    ...    timeout=5
    sleep    5s
    tafssh.disconnect      connection=cpc_${ue_index}

Start NAA Application
    [Arguments]    ${ue_index}=0
    [Documentation]    Trying to start Nokia Android Application

    Log To Console    \n[INFO] Starting NAA ...
    ${naa}    Set Variable    com.nokia.android.application/com.nokia.android.application.NaaActivity

    tafssh.Send Command    command=adb -s ${SN} shell am start -S -n ${naa}    connection=cpc_${ue_index}

    ${pid_cmd}    Catenate
    ...    adb -s ${SN} shell ps -A | grep nokia\.android\.application | head -1

    tafssh.Send Command    command=adb -s ${SN} devices    connection=cpc_${ue_index}
    Sleep    5s
    tafssh.Send Command    command=${pid_cmd}    connection=cpc_${ue_index}    timeout=10
    ${process}    tafssh.read output    connection=cpc_${ue_index}
    Run Keyword If     '${process.strip()}'=='None'    Fail    msg=[ERROR]NAA Application can NOT be started.
    ${naa_process_info}    Set Variable    ${process.strip().split(' ')}
    ${naa_process_info}    Remove Duplicates    ${naa_process_info}
    ${pid}    Set Variable    ${naa_process_info[2]}
    Log To Console    \n[INFO] NAA started -- PID: ${pid}

    [Return]    ${pid.strip()}

Exit NAA Application
    [Arguments]    ${ue_index}=0
    [Documentation]    Trying to stop Nokia Android Application

    Log To Console    \n[INFO] Exiting NAA ...
    ${naa}    Set Variable    com.nokia.android.application

    tafssh.Send Command    command=adb -s ${SN} shell am force-stop ${naa}    connection=cpc_${ue_index}

Get Serving Cell Id
    [Arguments]    ${ue_index}=0
    [Documentation]    Trying to get serving cell id from NAA log (PZ1HAZTA-285)

    Log To Console    \n[INFO] Start getting serving cell id...
    Connect To QUE Control PC    ${ue_index}

    ${airplane_mode}    Get Airplane Mode    ${ue_index}
    Should Be Equal As Strings    ${airplane_mode}    OFF
    ...    values=${False}
    ...    ignore_case=${True}
    ...    msg=Airplane Mode is currently ON

    ${pid}    Start NAA Application    ${ue_index}
    ${cell_id_cmd}    Catenate
    ...    adb -s ${SN} logcat -d --pid=${pid} | grep 'serving cell' | tail -1

    tafssh.Send Command    command=adb -s ${SN} devices    connection=cpc_${ue_index}
    Sleep    10s
    tafssh.Send Command    command=${cell_id_cmd}    connection=cpc_${ue_index}    timeout=10
    ${serving_cell_info}    tafssh.read output    connection=cpc_${ue_index}
    Run Keyword If     '${serving_cell_info.strip()}'=='None'    Fail    msg=[ERROR]Serving cell info can NOT be got on NAA Application.
    ${pci}    Run    echo '${serving_cell_info.strip()}' | sed 's/.*pci=//' | sed 's/,.*//'
    ${nci}    Run    echo '${serving_cell_info.strip()}' | sed 's/.*nci=//' | sed 's/,.*//'

    [Return]    ${pci}    ${nci}
    [Teardown]    Run Keywords    Exit NAA Application    ${ue_index}    AND    tafssh.disconnect    connection=cpc_${ue_index}

Get Airplane Mode
    [Arguments]    ${ue_index}=0
    [Documentation]    Get AIRPLANE Mode from a Commercial UE

    ${airplane_cmd}    Set Variable    adb -s ${SN} shell settings get global airplane_mode_on
    tafssh.Send Command    command=adb -s ${SN} devices    connection=cpc_${ue_index}
    tafssh.Send Command    command=${airplane_cmd}    connection=cpc_${ue_index}    timeout=5
    ${airplane_on}    tafssh.read output    connection=cpc_${ue_index}
    ${airplane_on}    Fetch From Right    ${airplane_on.strip()}    ${\n}
    ${airplane_on}    Set Variable If    "${airplane_on}" == "1"    ON    OFF
    Log To Console    \n[INFO]Fetched Airplane Mode [${airplane_on}] from UE_${ue_index} ${SN}
    [Return]    ${airplane_on}
