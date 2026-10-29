*** Settings ***
Documentation
...    Author:  Lv Feng
...    Contact: Du Ning
...    Mail:    ning.du@nokia-sbell.com

Library           String
Library           taf.transport.ssh    WITH NAME    tafssh

*** Keywords ***
## Commercial Keywords ##
Commercial.Attach
    [Arguments]    ${ue_config}    &{kwargs}
    _Traffic_UE_Operation.Connect UE PC    ${ue_config}
    ${airplane_on}    Commercial.Get Airplane Mode    ${ue_config}
    ${toggle_times}    Set Variable If    '${airplane_on}'=='OFF'    ${2}    ${1}
    Commercial.Toggle Airplane Switch    ${ue_config}    ${toggle_times}
    ${airplane_on}    Commercial.Get Airplane Mode    ${ue_config}
    Should Be Equal    ${airplane_on}    OFF
    ...    msg=Failed to turn OFF Airplane Mode
    ...    values=False
    ...    ignore_case=True

    Run Keyword If    '${ue_config.ui_version}' != 'huawei_mate40'    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_POWER
    ...    connection=${ue_config.ue_alias}


Commercial.Detach
    [Arguments]    ${ue_config}    &{kwargs}
    _Traffic_UE_Operation.Connect UE PC    ${ue_config}
    ${airplane_on}    Commercial.Get Airplane Mode    ${ue_config}
    Run Keyword If    '${airplane_on}'=='OFF'    Commercial.Toggle Airplane Switch    ${ue_config}
    ${airplane_on}    Commercial.Get Airplane Mode    ${ue_config}
    Should Be Equal    ${airplane_on}    ON
    ...    msg=Failed to turn ON Airplane Mode
    ...    values=False
    ...    ignore_case=True

    Run Keyword If    '${ue_config.ui_version}' != 'huawei_mate40'    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_POWER
    ...    connection=${ue_config.ue_alias}


Commercial.Reboot
    [Arguments]    ${ue_config}    ${timeout}=3min    &{kwargs}
    [Timeout]    ${timeout}

    _Traffic_UE_Operation.Connect UE PC    ${ue_config}
    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} wait-for-device reboot
    ...    connection=${ue_config.ue_alias}

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} wait-for-device devices
    ...    connection=${ue_config.ue_alias}


Commercial.Start Voice Call
    [Arguments]    ${ue_config}    &{kwargs}
    _Traffic_UE_Operation.Connect UE PC    ${ue_config}
    &{coordinates}    get_screen_coordinates    ${ue_config}
    ${dial_command}    Catenate
    ...    adb -s ${ue_config.serial_number} shell
    ...    am start -a android.intent.action.CALL -d tel:${kwargs}[dial]

    _Traffic_UE_Operation.Send Command And Check Output    command=${dial_command}    connection=${ue_config.ue_alias}
    Sleep    5s    wait for the call interface to show up

    Run Keyword If    '${ue_config.ui_version}' == 'huawei_mate40'    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input tap ${coordinates.call}
    ...    connection=${ue_config.ue_alias}

    Run Keyword If    '${ue_config.ui_version}' != 'huawei_mate40'    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_CALL
    ...    connection=${ue_config.ue_alias}

    ${cd}    Convert To Upper Case    ${kwargs}[duration]

    Run Keyword If    '${cd}'=='0' or '${cd}'=='0S' or '${cd}'=='0M' or '${cd}'=='0H' or '${cd}'=='' or '${cd}'=='NONE'    Run Keywords
    ...               Log To Console    \nPlease use operation=stop voice call to terminate the call
    ...               AND
    ...               Return From Keyword

    Log To Console    \nThe voice call will last for ${cd}
    Sleep    ${kwargs}[duration]    wait for the call to the end

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input tap ${coordinates.end_call}
    ...    connection=${ue_config.ue_alias}

    Sleep    2s

Commercial.Stop Voice Call
    [Arguments]    ${ue_config}    &{kwargs}
    &{coordinates}    get_screen_coordinates    ${ue_config}

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input tap ${coordinates.end_call}
    ...    connection=${ue_config.ue_alias}

    Sleep    2s

Commercial.Start Traffic
    [Arguments]    ${ue_config}    &{kwargs}
    ${option}    Convert To Upper Case    ${kwargs}[option]
    ${protocol}    ${direction}    Split String    ${option}    _

    Run Keyword If    "UL" in "${direction}"    Commercial.Start UL ${protocol} Traffic
    ...    ${ue_config}    ${kwargs}[bandwidth]    ${kwargs}[port]    ${kwargs}[duration]

    Run Keyword If    "DL" in "${direction}"    Commercial.Start DL ${protocol} Traffic
    ...    ${ue_config}    ${kwargs}[bandwidth]    ${kwargs}[port]    ${kwargs}[duration]

Commercial.Stop Traffic
    [Arguments]    ${ue_config}    &{kwargs}
    ${option}    Convert To Upper Case    ${kwargs}[option]
    ${protocol}    ${direction}    Split String    ${option}    _

    Run Keyword If    "UL" in "${direction}"    Commercial.Stop UL ${protocol} Traffic
    ...    ${ue_config}

    Run Keyword If    "DL" in "${direction}"    Commercial.Stop DL ${protocol} Traffic
    ...    ${ue_config}    ${kwargs}[port]

Commercial.Get
    [Arguments]    ${ue_config}    &{kwargs}
    _Traffic_UE_Operation.Connect UE PC    ${ue_config}
    Run Keyword And Return    Commercial.Get UE ${kwargs}[item]    ${ue_config}


Commercial.Set
    [Arguments]    ${ue_config}    &{kwargs}
    _Traffic_UE_Operation.Connect UE PC    ${ue_config}
    Run Keyword And Return    Commercial.Set UE ${kwargs}[item]    ${ue_config}    ${value}


Commercial.Check Average Tput
    [Arguments]    ${ue_config}    ${dl_threshold}=${0}    ${ul_threshold}=${0}    &{kwargs}
    Sleep    5s

    ${result}    Commercial.Collect Tput    ${ue_config}    &{kwargs}
    ${dl_avg}    ${ul_avg}    calculate_average_throughput    ${result}

    log to console    \nAverage Traffic: DL ${dl_avg} MB, UL ${ul_avg} MB

    Should Be True    ${dl_avg} > ${dl_threshold}    msg=Average TP ${dl_avg} is expected > ${dl_threshold}
    Should Be True    ${ul_avg} > ${ul_threshold}    msg=Average TP ${ul_avg} is expected > ${ul_threshold}

    [Return]    ${dl_avg}    ${ul_avg}


Commercial.Check Peak Tput
    [Arguments]    ${ue_config}    ${dl_threshold}=${0}    ${ul_threshold}=${0}    &{kwargs}
    Sleep    5s

    ${result}    Commercial.Collect Tput    ${ue_config}    &{kwargs}
    ${dl_peak}    ${ul_peak}    calculate_peak_throughput    ${result}

    log to console    \nPeak Traffic: DL ${dl_peak} MB, UL ${ul_peak} MB

    Should Be True    ${dl_peak} > ${dl_threshold}    msg=Peak TP ${dl_peak} is expected > ${dl_threshold}
    Should Be True    ${ul_peak} > ${ul_threshold}    msg=Peak TP ${ul_peak} is expected > ${ul_threshold}

    [Return]    ${dl_peak}    ${ul_peak}


Commercial.Collect Tput
    [Arguments]    ${ue_config}    ${period}=1min    &{kwargs}

    _Traffic_UE_Operation.Connect UE PC    ${ue_config}
    Log     Start collecting throughput from NAA...

    ${airplane_mode}    Commercial.Get Airplane Mode    ${ue_config}
    Should Be Equal As Strings    ${airplane_mode}    OFF
    ...    values=${False}
    ...    ignore_case=${True}
    ...    msg=Airplane Mode is currently ON

    ${pid}    Commercial.Start NAA Application Only NAA Not Run    ${ue_config}
    ${pattern}    Set Variable    NetworkTrafficStats.*mobileAvgThrRx ([0-9]+), mobileAvgThrTx ([0-9]+)

    ${clear_throughput_cmd}    Set Variable    adb -s ${ue_config.serial_number} logcat --clear

    ${log_result}    Wait Until Keyword Succeeds    1min    5sec
    ...    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=${clear_throughput_cmd}
    ...    connection=${ue_config.ue_alias}

    Sleep    ${period}

    ${get_throughput_cmd}    Catenate
    ...    adb -s ${ue_config.serial_number} logcat
    ...    --pid=${pid}
    ...    -d
    ...    --regex '${pattern}'

    ${log_result}    Wait Until Keyword Succeeds    1min    5sec
    ...    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=${get_throughput_cmd}
    ...    connection=${ue_config.ue_alias}


    ${result}    Get Regexp Matches    ${log_result}    ${pattern}    1    2

    [Return]    ${result}

Commercial.Start UL UDP Traffic
    [Arguments]    ${ue_config}    ${bandwidth}    ${port}    ${duration}    ${interval}=1
    [Documentation]    This kw is used to Start UL traffic
    Log    ${interval}
    _Traffic_UE_Operation.Connect UE PC    ${ue_config}
    ${pid}    Commercial.Start NAA Application    ${ue_config}

    &{coordinates}    get_screen_coordinates    ${ue_config}

    sleep    2s

    ##### Try unlocking the phone #####
    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_MENU
    ...    connection=${ue_config.ue_alias}
    sleep    1s

    #####Press the Home button to open the screen#####
    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_HOME
    ...    connection=${ue_config.ue_alias}
    sleep    1s

    #####Swipe up to unlock the phone#####
    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input swipe ${coordinates.swipe}
    ...    connection=${ue_config.ue_alias}
    sleep    3s
    _Traffic_UE_Operation.Send Command
    ...    command=adb -s ${ue_config.serial_number} shell pm clear com.nextdoordeveloper.miperf.miperf
    ...    connection=${ue_config.ue_alias}
    sleep    4s

    ${iperf_cmd}    Catenate
    ...    adb -s ${ue_config.serial_number} shell am start -n
    ...    com.nextdoordeveloper.miperf.miperf/com.nextdoordeveloper.miperf.miperf.MainActivity

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=${iperf_cmd}
    ...    connection=${ue_config.ue_alias}
    sleep    4s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_MOVE_END
    ...    connection=${ue_config.ue_alias}
    sleep    2s

    FOR    ${i}    IN RANGE    7
        _Traffic_UE_Operation.Send Command And Check Output
        ...    adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_DEL
        ...    connection=${ue_config.ue_alias}
        sleep    1s
    END

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input text iperf
    ...    connection=${ue_config.ue_alias}
    sleep    1.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_SPACE
    ...    connection=${ue_config.ue_alias}
    sleep    0.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input text --client
    ...    connection=${ue_config.ue_alias}

    sleep    1.5s
    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_SPACE
    ...    connection=${ue_config.ue_alias}
    sleep    0.5s

    @{chars}    Split String To Characters    ${ue_config.iperf_address}
    FOR    ${char}    IN     @{chars}
        _Traffic_UE_Operation.Send Command And Check Output
        ...    command=adb -s ${ue_config.serial_number} shell input text ${char}
        ...    connection=${ue_config.ue_alias}
        sleep    1s
    END

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_SPACE
    ...    connection=${ue_config.ue_alias}
    sleep    0.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input text --udp
    ...    connection=${ue_config.ue_alias}
    sleep    1.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_SPACE
    ...    connection=${ue_config.ue_alias}
    sleep    0.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input text --port
    ...    connection=${ue_config.ue_alias}
    sleep    1.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_SPACE
    ...    connection=${ue_config.ue_alias}
    sleep    0.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input text ${port}
    ...    connection=${ue_config.ue_alias}
    sleep    1.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_SPACE
    ...    connection=${ue_config.ue_alias}
    sleep    0.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input text --time
    ...    connection=${ue_config.ue_alias}
    sleep    1.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_SPACE
    ...    connection=${ue_config.ue_alias}
    sleep    0.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input text ${duration}
    ...    connection=${ue_config.ue_alias}
    sleep    1.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_SPACE
    ...    connection=${ue_config.ue_alias}
    sleep    0.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input text --interval
    ...    connection=${ue_config.ue_alias}
    sleep    1.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_SPACE
    ...    connection=${ue_config.ue_alias}
    sleep    0.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input text 1
    ...    connection=${ue_config.ue_alias}
    sleep    1s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_SPACE
    ...    connection=${ue_config.ue_alias}
    sleep    0.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input text --parallel
    ...    connection=${ue_config.ue_alias}
    sleep    2.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_SPACE
    ...    connection=${ue_config.ue_alias}
    sleep    0.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input text 1
    ...    connection=${ue_config.ue_alias}
    sleep    1s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_SPACE
    ...    connection=${ue_config.ue_alias}
    sleep    0.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input text --format
    ...    connection=${ue_config.ue_alias}
    sleep    1.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_SPACE
    ...    connection=${ue_config.ue_alias}
    sleep    0.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input text m
    ...    connection=${ue_config.ue_alias}
    sleep    1s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_SPACE
    ...    connection=${ue_config.ue_alias}
    sleep    0.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input text --bandwidth
    ...    connection=${ue_config.ue_alias}
    sleep    2.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_SPACE
    ...    connection=${ue_config.ue_alias}
    sleep    0.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input text ${bandwidth}
    ...    connection=${ue_config.ue_alias}
    sleep    1.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_SPACE
    ...    connection=${ue_config.ue_alias}
    sleep    0.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input text --len
    ...    connection=${ue_config.ue_alias}
    sleep    1.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_SPACE
    ...    connection=${ue_config.ue_alias}
    sleep    0.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input text 1024B
    ...    connection=${ue_config.ue_alias}
    sleep    1.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_SPACE
    ...    connection=${ue_config.ue_alias}
    sleep    0.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input text --ttl
    ...    connection=${ue_config.ue_alias}
    sleep    1.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_SPACE
    ...    connection=${ue_config.ue_alias}
    sleep    0.5s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input text 64
    ...    connection=${ue_config.ue_alias}
    sleep    1s

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input tap ${coordinates.iperf_button}
    ...    connection=${ue_config.ue_alias}


Commercial.Start DL UDP Traffic
    [Arguments]    ${ue_config}    ${bandwidth}    ${port}    ${duration}    ${interval}=1
    _Traffic_UE_Operation.Connect UE PC    ${ue_config}
    ${ue_ip}    Commercial.Get UE Ipv4    ${ue_config}
    Should Not Be Empty    ${ue_ip}

    ${iperf_alias}    Set Variable    ${ue_config.ue_alias}_iperf

    tafssh.Connect To    hostname=${ue_config.iperf_address}
        ...    username=${ue_config.iperf_user}
        ...    password=${ue_config.iperf_password}
        ...    alias=${iperf_alias}
        ...    timeout=2 minutes

    sleep    2s

    ${iperf_cmd}    Catenate
    ...    ps -ef |
    ...    grep 'iperf' |
    ...    grep -v grep |
    ...    grep ${port} |
    ...    awk '{print $2}' |
    ...    xargs kill -9
    _Traffic_UE_Operation.Send Command    command=${iperf_cmd}    connection=${iperf_alias}

    ${iperf_cmd}    Catenate
    ...    iperf --client ${ue_ip} --udp --time ${duration}
    ...    --interval ${interval} --port ${port}
    ...    --parallel 1 --format m --bandwidth ${bandwidth}
    ...    --len 1024B --ttl 64 &
    _Traffic_UE_Operation.Send Command Without Read Output    command=${iperf_cmd}    connection=${iperf_alias}

Commercial.Stop UL UDP Traffic
    [Arguments]    ${ue_config}    ${port}='None'    ${interval}=1
    Log    ${port}
    Log    ${interval}
    _Traffic_UE_Operation.Connect UE PC    ${ue_config}
    Commercial.Exit Magic Iperf Application    ${ue_config}

Commercial.Stop DL UDP Traffic
    [Arguments]    ${ue_config}    ${port}    ${interval}=1
    Log    ${interval}
    _Traffic_UE_Operation.Connect UE PC    ${ue_config}
    ${ue_ip}    Commercial.Get UE Ipv4    ${ue_config}
    Should Not Be Empty    ${ue_ip}

    ${iperf_alias}    Set Variable    ${ue_config.ue_alias}_iperf

    tafssh.Connect To    hostname=${ue_config.iperf_address}
        ...    username=${ue_config.iperf_user}
        ...    password=${ue_config.iperf_password}
        ...    alias=${iperf_alias}
        ...    timeout=2 minutes

    sleep    2s

    ${iperf_cmd}    Catenate
    ...    ps -ef |
    ...    grep 'iperf' |
    ...    grep -v grep |
    ...    grep ${port} |
    ...    awk '{print $2}' |
    ...    xargs kill -9
    _Traffic_UE_Operation.Send Command    command=${iperf_cmd}    connection=${iperf_alias}

Commercial.Get UE Alive
    [Arguments]    ${ue_config}
    [Documentation]    Check if an Android UE is listed in adb devices
    ${res}    _Traffic_UE_Operation.Send Command And Check Output
        ...    command=adb -s ${ue_config.serial_number} get-state
        ...    connection=${ue_config.ue_alias}

    ${alive}    Evaluate    '${res}' == 'device'

    [Return]    ${alive}


Commercial.Get UE Mode
    [Arguments]    ${ue_config}
    [Documentation]    Check if an Android UE is listed in adb devices
    ${airplane_on}    Commercial.Get Airplane Mode    ${ue_config}
    ${airplane}    Evaluate    '${airplane_on}' == 'OFF'
    [Return]    ${airplane}


Commercial.Get UE Ipv4
    [Arguments]    ${ue_config}
    [Documentation]    Check if an Android UE is listed in adb devices

    ${mode}    Commercial.Get UE Mode    ${ue_config}

    Should Be True    ${mode}
    ...    msg=Could not get IP address. The ue ${ue_config.ue_alias} mode is OFF.

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell ip -f inet addr
    ...    connection=${ue_config.ue_alias}

    ${ip_pattern}    Set Variable    (([0-9])+\\.){3}[0-9]+\\/[0-9]+.*([_a-z0-9]+)
    ${ip_cmd}    Catenate
    ...    adb -s ${ue_config.serial_number} shell ip -f inet addr |
    ...    grep -P "inet ${ip_pattern}" |
    ...    grep -Po "${ip_pattern}"

    ${ip_str}    Wait Until Keyword Succeeds    1min    5sec
    ...    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=${ip_cmd}
    ...    connection=${ue_config.ue_alias}

    Log     UE IP address: ${ip_str}

    @{ip_list}    Split String    ${ip_str}    ${\n}
    Should Not Be Empty    ${ip_list}

    @{ims_ip}    Create List
    @{data_ip}    Create List

    FOR    ${ip_entry}    IN    @{ip_list}
        ${whole_ip}    Fetch From Left    ${ip_entry}    ${SPACE}
        ${ip}    Fetch From Left    ${whole_ip}    /
        ${interface}    Fetch From Right    ${ip_entry}    ${SPACE}
        Run Keyword IF    ${interface.find('_ims')} > -1    Append To List    ${ims_ip}    ${ip}
        ...    ELSE IF    "${interface}"=="lo"    No Operation
        ...    ELSE    Append To List    ${data_ip}    ${ip}
    END

    Log    obtained ims ips ${ims_ip}
    Log    obtained data ips ${data_ip}

    ${ims_ip_length}    Get Length    ${ims_ip}
    ${data_ip_length}    Get Length    ${data_ip}

    ${candidate_ims_ip}    Run Keyword If    ${ims_ip_length}>0    Get From List    ${ims_ip}    0
    ...    ELSE    Set Variable    ${EMPTY}

    ${ip}    Run Keyword If    ${data_ip_length}==0    Set Variable    ${candidate_ims_ip}
    ...    ELSE IF    ${data_ip_length}==1    Get From List    ${data_ip}    0
    ...    ELSE    Commercial.Get IP From Active Network    ${ue_config}    ${data_ip}

    ${ip}    Strip String    ${ip}

    Set Suite Variable    ${UE_IP}    ${ip}

    [Return]    ${ip}


Commercial.Get IP From Active Network
    [Arguments]    ${ue_config}    ${alternative_ip_list}
    [Documentation]    Send command to a connection and check if any error occured
    ${ip_cmd}    Set Variable    adb -s ${ue_config.serial_number} shell dumpsys connectivity
    ${dumped}    Wait Until Keyword Succeeds    1min    5sec
    ...    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=${ip_cmd}
    ...    connection=${ue_config.ue_alias}

    @{active_network}    Get RegExp Matches    ${dumped}    Active default network: (\\d+)    1

    ${active_network}    Get From List    ${active_network}    0
    ${ip_pattern}    Set Variable    (([0-9])+\\.){3}[0-9]+

    ${pattern}    Set Variable    network\\{${active_network}\\}.*?LinkAddresses:\\s*\\[\\s*(${ip_pattern})\\/\\d+.*\\]
    @{ip_list}    Get RegExp Matches    ${dumped}    ${pattern}    1

    ${ip_length}    Get Length    ${ip_list}

    ${ip}    Run Keyword If    ${ip_length}>0    Get From List    ${ip_list}    0
    ...    ELSE    Get From List    ${alternative_ip_list}    0

    [Return]    ${ip}


Commercial.Get UE Cellid
    [Arguments]    ${ue_config}
    [Documentation]    Trying to get serving cell id from NAA log (PZ1HAZTA-285)

    ${mode}    Commercial.Get UE Mode    ${ue_config}

    Should Be True    ${mode}
    ...    msg=Could not get IP address. The ue ${ue_config.ue_alias} mode is OFF.

    ${pid}    Commercial.Start NAA Application    ${ue_config}
    ${cell_id_cmd}    Catenate
    ...    adb -s ${ue_config.serial_number} logcat -d --pid=${pid} |
    ...    grep 'serving cell' |
    ...    grep -Po '(\\bn?ci=)[0-9]+'|
    ...    tail -1

    Sleep    5s
    ${cell_id}    Wait Until Keyword Succeeds    1min    5sec
    ...    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=${cell_id_cmd}
    ...    connection=${ue_config.ue_alias}

    ${cell_id}    Fetch From Right    ${cell_id}    =

    Commercial.Exit NAA Application    ${ue_config}

    [Return]    ${cell_id}


Commercial.Start NAA Application
    [Arguments]    ${ue_config}
    [Documentation]    Trying to start Nokia Android Application

    ${naa}    Set Variable    com.nokia.android.application/com.nokia.android.application.NaaActivity

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell am start -S -n ${naa}
    ...    connection=${ue_config.ue_alias}

    ${ps_arg}    Set Variable if    "${ue_config.ue_type}"=="Qualcomm"    ${EMPTY}    -A

    ${pid_cmd}    Catenate
    ...    adb -s ${ue_config.serial_number} shell ps ${ps_arg} |
    ...    grep -P nokia\.android\.application |
    ...    head -1 |
    ...    awk '{print $2}'

    ${pid}    Wait Until Keyword Succeeds    1min    5sec
    ...    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=${pid_cmd}
    ...    connection=${ue_config.ue_alias}

    [Return]    ${pid}

Commercial.Start NAA Application Only NAA Not Run
    [Arguments]    ${ue_config}
    [Documentation]    Trying to start Nokia Android Application

    ${naa}    Set Variable    com.nokia.android.application/com.nokia.android.application.NaaActivity

    ${ps_arg}    Set Variable if    "${ue_config.ue_type}"=="Qualcomm"    ${EMPTY}    -A

    ${pid_cmd}    Catenate
    ...    adb -s ${ue_config.serial_number} shell ps ${ps_arg} |
    ...    grep -P nokia\.android\.application |
    ...    head -1 |
    ...    awk '{print $2}'

    ${pid}    Wait Until Keyword Succeeds    1min    5sec
    ...    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=${pid_cmd}
    ...    connection=${ue_config.ue_alias}

    ${NAA_Running}    Run Keyword If    '${pid}' != ''    Commercial.Check NAA Running    ${ue_config}    ${pid}

    Run Keyword If    '${NAA_Running}' == 'False' or '${pid}' == ''    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell am start -S -n ${naa}
    ...    connection=${ue_config.ue_alias}

    ${pid}    Wait Until Keyword Succeeds    1min    5sec
    ...    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=${pid_cmd}
    ...    connection=${ue_config.ue_alias}

    [Return]    ${pid}

Commercial.Check NAA Running
    [Arguments]    ${ue_config}    ${pid}
    ${pattern}    Set Variable    NetworkTrafficStats.*mobileAvgThrRx ([0-9]+), mobileAvgThrTx ([0-9]+)
    ${clear_throughput_cmd}    Set Variable    adb -s ${ue_config.serial_number} logcat --clear

    ${log_result}    Wait Until Keyword Succeeds    1min    5sec
    ...    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=${clear_throughput_cmd}
    ...    connection=${ue_config.ue_alias}

    Sleep    10s

    ${get_throughput_cmd}    Catenate
    ...    adb -s ${ue_config.serial_number} logcat
    ...    --pid=${pid}
    ...    -d
    ...    --regex '${pattern}'

    ${log_result}    Wait Until Keyword Succeeds    1min    5sec
    ...    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=${get_throughput_cmd}
    ...    connection=${ue_config.ue_alias}

    ${log_result_length}    Get Length    ${log_result}

    ${NAA_Running}    Set Variable If    '${log_result_length}' == '0'    ${False}    ${True}

    [Return]    ${NAA_Running}


Commercial.Exit NAA Application
    [Arguments]    ${ue_config}
    [Documentation]    Trying to stop Nokia Android Application

    ${naa}    Set Variable    com.nokia.android.application

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell am force-stop ${naa}
    ...    connection=${ue_config.ue_alias}

Commercial.Exit Magic Iperf Application
    [Arguments]    ${ue_config}
    [Documentation]    Trying to stop Mafic Iperf Application

    ${miperf}    Set Variable    com.nextdoordeveloper.miperf.miperf

    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell am force-stop ${miperf}
    ...    connection=${ue_config.ue_alias}


Commercial.Toggle Airplane Switch
    [Arguments]    ${ue_config}    ${toggle_times}=${1}
    [Documentation]    Toggle Airplane Switch of a Commercial UE

    Run Keyword If    '${ue_config.ui_version}'=='MTP845'
    ...    Commercial.Toggle Airplane Mode From Notification    ${ue_config}    ${toggle_times}
    ...    ELSE    Commercial.Toggle Airplane Mode From Settings    ${ue_config}    ${toggle_times}



Commercial.Get Airplane Mode
    [Arguments]    ${ue_config}
    [Documentation]    Get AIRPLANE Mode from a Commercial UE
    ${res}    Wait Until Keyword Succeeds    1min    5sec
    ...    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell settings get global airplane_mode_on
    ...    connection=${ue_config.ue_alias}
    Should Not Be Empty    ${res}

    ${airplane_on}    Fetch From Right    ${res}    ${\n}
    ${airplane_on}    Set Variable If    "${airplane_on}" == "1"    ON    OFF

    [Return]    ${airplane_on}


Commercial.Toggle Airplane Mode From Settings
    [Arguments]    ${ue_config}    ${toggle_times}
    [Documentation]    toggling AIRPLANE Mode of a Universial Commercial UE

    ${awhile}    Set Variable    7s
    &{coordinates}    get_screen_coordinates    ${ue_config}

    ##### Trying to unlock the phone
    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_MENU
    ...    connection=${ue_config.ue_alias}
    sleep    2s

    #####Press the Home button to turn on the screen#####
    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_HOME
    ...    connection=${ue_config.ue_alias}
    sleep    2s

    #####Swipe up to unlock the phone#####
    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input swipe ${coordinates.swipe}
    ...    connection=${ue_config.ue_alias}
    sleep    ${awhile}

    #####Click the task button#####
    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_APP_SWITCH
    ...    connection=${ue_config.ue_alias}
    sleep    ${awhile}

    #####Turn off all running tasks on the phone#####
    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input tap ${coordinates.close_task}
    ...    connection=${ue_config.ue_alias}
    sleep    ${awhile}

    ##### Enter Airplane Setting Page #####
    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell am start -a android.settings.AIRPLANE_MODE_SETTINGS
    ...    connection=${ue_config.ue_alias}
    sleep    ${awhile}

    FOR    ${i}    IN RANGE    ${toggle_times}
        #####Tap the airplane mode switch to enable airplane mode#####
        _Traffic_UE_Operation.Send Command And Check Output
        ...    command=adb -s ${ue_config.serial_number} shell input tap ${coordinates.airplane}
        ...    connection=${ue_config.ue_alias}
        sleep    ${awhile}
    END

    #####return to home screen before clicking multi-task button#####
    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_HOME
    ...    connection=${ue_config.ue_alias}
    sleep    ${awhile}

    #####Click the task button#####
    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_APP_SWITCH
    ...    connection=${ue_config.ue_alias}
    sleep    ${awhile}

    #####Turn off all running tasks on the phone#####
    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input tap ${coordinates.close_task}
    ...    connection=${ue_config.ue_alias}
    sleep    ${awhile}



Commercial.Toggle Airplane Mode From Notification
    [Arguments]    ${ue_config}    ${toggle_times}
    [Documentation]    toggling AIRPLANE Mode of a Commercial UE such as MTP845
    ${awhile}    Set Variable    7s
    &{coordinates}    get_screen_coordinates    ${ue_config}

    ##### Trying to unlock the phone
    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_MENU
    ...    connection=${ue_config.ue_alias}
    sleep    2s
    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_MENU
    ...    connection=${ue_config.ue_alias}
    sleep    2s
    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_HOME
    ...    connection=${ue_config.ue_alias}
    sleep    2s

    #####Swipe up to open the drawer #####
    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input swipe ${coordinates.swipe_notification}
    ...    connection=${ue_config.ue_alias}

    sleep    ${awhile}

    FOR    ${i}    IN RANGE    ${toggle_times}
        #####Tap the airplane mode switch to enable airplane mode#####
        _Traffic_UE_Operation.Send Command And Check Output
        ...    command=adb -s ${ue_config.serial_number} shell input tap ${coordinates.switch}
        ...    connection=${ue_config.ue_alias}
        sleep    ${awhile}
    END

    #####return to home screen before clicking multi-task button#####
    _Traffic_UE_Operation.Send Command And Check Output
    ...    command=adb -s ${ue_config.serial_number} shell input keyevent KEYCODE_HOME
    ...    connection=${ue_config.ue_alias}



## AT Keywords ##
At.Attach
    [Arguments]    ${ue_config}
    [Documentation]    Check if an Android UE is listed in adb devices
    _Traffic_UE_Operation.Connect UE PC    ${ue_config}
    ${res}    _Traffic_UE_Operation.Send AT Command And Check Output
        ...    command=sendcom COM${ue_config.com_id} at+cfun=1
        ...    connection=${ue_config.ue_alias}


At.Detach
    [Arguments]    ${ue_config}    &{kwargs}
    _Traffic_UE_Operation.Connect UE PC    ${ue_config}
    ${res}    _Traffic_UE_Operation.Send AT Command And Check Output
        ...    command=sendcom COM${ue_config.com_id} at+cfun=0
        ...    connection=${ue_config.ue_alias}


At.Reboot
    [Arguments]    ${ue_config}    ${timeout}=3    &{kwargs}
    Log    ${timeout}
    _Traffic_UE_Operation.Connect UE PC    ${ue_config}
    ${res}    _Traffic_UE_Operation.Send AT Command And Check Output
        ...    command=sendcom COM${ue_config.com_id} AT+CFUN=1,1
        ...    connection=${ue_config.ue_alias}


At.Start Voice Call
    [Arguments]    ${ue_config}    &{kwargs}
    Log    ${ue_config}
    No Operation


At.Start Traffic
    [Arguments]    ${ue_config}    &{kwargs}
    Log    ${ue_config}
    No Operation


At.Get
    [Arguments]    ${ue_config}    ${item}    &{kwargs}
    _Traffic_UE_Operation.Connect UE PC    ${ue_config}
    Run Keyword And Return    Commercial.Get UE ${item}    ${ue_config}


At.Set
    [Arguments]    ${ue_config}    ${item}    ${value}    &{kwargs}
    _Traffic_UE_Operation.Connect UE PC    ${ue_config}
    Run Keyword And Return    Commercial.Set UE ${item}    ${ue_config}    ${value}


At.Check Average Tput
    [Arguments]    ${ue_config}    &{kwargs}
    Log    ${ue_config}
    No Operation


At.Check Peak Tput
    [Arguments]    ${ue_config}    &{kwargs}
    Log    ${ue_config}
    No Operation


At.Check Call State
    [Arguments]    ${ue_config}    &{kwargs}
    Log    ${ue_config}
    No Operation

At.Send AT Cmd
    [Arguments]    ${ue_config}    &{kwargs}
    ${connection}    _Traffic_UE_Operation.Connect UE PC    ${ue_config}
    ${output}    _Traffic_UE_Operation.Send AT Command And Check Output
    ...    command=sendcom COM${ue_config.com_id} ${kwargs}[cmd]
    ...    connection=${connection}
    [Return]    ${output}

At.Get UE Alive
    [Arguments]    ${ue_config}
    [Documentation]    Check if an AT UE is reachable
    ${res}    _Traffic_UE_Operation.Send AT Command And Check Output
        ...    command=sendcom COM${ue_config.com_id} at
        ...    connection=${ue_config.ue_alias}

    ${alive}    Evaluate    '${res}' == 'OK'

    [Return]    ${alive}


At.Get UE Mode
    [Arguments]    ${ue_config}
    Log    ${ue_config}
    No Operation


At.Get UE Ipv4
    [Arguments]    ${ue_index}=${0}    &{kwargs}
    [Documentation]    This kw is used to get UE IP
    Log    ${ue_index}
    No Operation


At.Legacy.Attach UE
    [Arguments]    ${ue_config}
    ${res}    ute_ue.Send At Cmd To Ue    ${ue_config.ue_alias}    at_cmd=AT+CFUN=0
    Should Contain    ${res}    OK    ignore_case=True
    Sleep    3s
    ${res}    ute_ue.Send At Cmd To Ue    ${ue_config.ue_alias}    at_cmd=AT+CFUN=1
    Should Contain    ${res}    OK    ignore_case=True
    Sleep    3s


At.Proxy.Attach UE
    [Arguments]    ${ue_config}
    ute_ue.Detach UE    ${ue_config.ue_alias}
    ute_ue.Attach UE    ${ue_config.ue_alias}


At.Legacy.Detach UE
    [Arguments]    ${ue_config}
    ${res}    ute_ue.Send At Cmd To Ue    ${ue_config.ue_alias}    at_cmd=AT+CFUN=0
    Should Contain    ${res}    OK    ignore_case=True
    Sleep    3s


At.Proxy.Detach UE
    [Arguments]    ${ue_config}
    ute_ue.Detach UE    ${ue_config.ue_alias}
    ute_ue.Attach UE    ${ue_config.ue_alias}



## Common Keywords ##
_Traffic_UE_Operation.Connect UE PC
    [Arguments]    ${ue_config}
    tafssh.Connect To    hostname=${ue_config.cpc_ip}
    ...    username=${ue_config.cpc_username}
    ...    password=${ue_config.cpc_password}
    ...    alias=${ue_config.ue_alias}
    ...    timeout=2 minutes
    [Return]    ${ue_config.ue_alias}

_Traffic_UE_Operation.Send Command
    [Arguments]    ${command}    ${connection}
    [Documentation]    Send command to a connection
    tafssh.Send Command    command=${command}    connection=${connection}

    ${output}    tafssh.Read Output    connection=${connection}
    Run Keyword And Return    Strip String    ${output}

_Traffic_UE_Operation.Send Command And Check Output
    [Arguments]    ${command}    ${connection}
    [Documentation]    Send command to a connection and check if any error occured
    tafssh.Send Command    command=${command}    connection=${connection}

    ${error}    tafssh.Read Error    connection=${connection}
    ${error}    Strip String    ${error}
    Should Be Empty    ${error}    msg=Error: ${error}

    ${output}    tafssh.Read Output    connection=${connection}
    Run Keyword And Return    Strip String    ${output}

_Traffic_UE_Operation.Send Command Without Read Output
    [Arguments]    ${command}    ${connection}
    [Documentation]    Send command to a connection
    tafssh.Send Command    command=${command}    connection=${connection}

    [Return]    ${None}

_Traffic_UE_Operation.Send AT Command And Check Output
    [Arguments]    ${command}    ${connection}
    [Documentation]    Send command to a connection and check if any error occured
    ${output}    _Traffic_UE_Operation.Send Command And Check Output    command=${command}    connection=${connection}
    Should Contain    ${output}    OK    ignore_case=True
    ${output}   Strip String    ${output}
    ${ret}    Evaluate    ${output}
    [Return]    ${ret}