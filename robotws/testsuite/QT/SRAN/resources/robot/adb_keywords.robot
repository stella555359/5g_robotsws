*** Settings ***
Documentation       ADB keywords
Library      BuiltIn
Library      Collections
Library      taf.transport.ssh    WITH NAME    ssh

*** Keywords ***
ADB devices
    [Arguments]         ${connectionalias}=controlPC    ${device}=${device_model}
    Retry Send Command in CPC    command=adb devices    connection=${connectionalias}
    BuiltIn.Sleep               2s
    ${result}           ssh.read_output    connection=${connectionalias}
    Should Contain      ${result}    ${device}
    Should Contain      ${result}    device
    Log To Console      --> INFO: Device ${device} detected in ADB

ADB reboot UE
    [Arguments]         ${connectionalias}=controlPC
    Retry Send Command in CPC    command=adb -s ${device_model} reboot    connection=${connectionalias}
    Log To Console      --> INFO: reboot UE by adb command [60 sec...]
    BuiltIn.Sleep               60s
    Wait Until Keyword Succeeds    3min  10s    ADB devices

ADB root
    [Arguments]         ${connectionalias}=controlPC
    Retry Send Command in CPC    command=adb -s ${device_model} root   connection=${connectionalias}
    BuiltIn.Sleep               5s

ADB recover from offline or unauthorized
    [Arguments]         ${device}=${device_model}    ${print}=none
    ssh.execute         adb kill-server && adb start-server     connection=controlPC   timeout=60s
    Log to Console      --> INFO: Device was ${print} - adb kill-server && adb start-server  done
    Wait Until Keyword Succeeds    30s  10s    ADB devices    device=${device}
    ADB Check adb devices output    ${device}
    IF      'offline' in '''${is_device_off}''' or 'unauthorized' in '''${is_device_off}'''
        ssh.execute         adb reboot    connection=controlPC    timeout=60s
        Log to Console      --> INFO: Device was ${print} - rebooted - wait 60s
        BuiltIn.Sleep       60s
        Wait until Keyword Succeeds    10x    30s    ADB devices    device=${device}
        ADB Check adb devices output    ${device}
        IF    'offline' in '''${is_device_off}''' or 'unauthorized' in '''${is_device_off}'''
            ${msg}    Set Variable    ADB recover from offline or unauthorized failed: ${is_device_off}
            Set Suite Variable    ${L3call_exception}    ${msg}
            Fail    msg=${msg}
        END
    END

ADB Check if device is offline or unauthorized and reboot
    [Arguments]         ${device}=${device_model}
    ADB Check adb devices output    ${device}
    Run Keyword If    'offline' in '''${is_device_off}''' or 'unauthorized' in '''${is_device_off}'''
    ...               ADB recover from offline or unauthorized    device=${device}    print=${is_device_off}

ADB Check adb devices output
    [Arguments]         ${device}
    Retry Send Command in CPC    command=adb devices | grep ${device}
    ${is_device_off}    ssh.read_output    connection=controlPC
    Set Test Variable   ${is_device_off}

############### Supporting KWs ##############
Connect to controlPC
    [Arguments]         ${cpc_addr}=${tl.ues[0].ssh_connection_details.addr}
    ...                 ${cpc_username}=${tl.ues[0].ssh_connection_details.username}
    ...                 ${cpc_password}=${tl.ues[0].ssh_connection_details.password}
    ...                 ${alias}=controlPC
    FOR   ${_}   IN RANGE   4
        ${cpc_connection}   Run keyword and return status    ssh.connect_to
        ...                 ${cpc_addr}    ${cpc_username}
        ...                 ${cpc_password}    alias=${alias}    timeout=60
        Exit For Loop If    '${cpc_connection}'=='${True}'
        BuiltIn.Sleep    5s
    END
    ${cpc_info}    Set Variable
    ...    ${cpc_addr} / ${cpc_username} / ${cpc_password}
    IF    not ${cpc_connection}
        Set Suite Variable    ${L3call_exception}    CPC connection failed: ${cpc_info}
        Fail    CPC connection failed: ${cpc_info}
    END

Retry Send Command in CPC
    [Arguments]  ${command}   ${connection}=controlPC
    ${keyinput_status}    Run keyword and return status    ssh.send_command    command=${command}    connection=${connection}
    Run keyword if     '${keyinput_status}' == '${False}'    run keywords
    ...   ssh.force reconnect    connection=${connection}          AND
    ...   ssh.send_command    command=${command}    connection=${connection}

