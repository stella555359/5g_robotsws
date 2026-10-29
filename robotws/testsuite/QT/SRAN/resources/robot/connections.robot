*** Settings ***
Documentation     Keyword allows ssh connection to remote machine.
...               IP addresses are available in common variables files or can be overwritten in every TL config.

Library    taf.transport.ssh      WITH NAME    ssh
Library    taf.gnb.oam.coam.cu    WITH NAME    coam_cu
Library    taf.wts.runner         WITH NAME    wts_runner

*** Keywords ***
Connect To DU From OAM
    [Arguments]         ${alias}=BB1    ${proxy}=OAM
    ${BB1_IP}           Get Variable Value    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}    192.168.2.60
    Set Suite Variable  ${BB1_IP}
    ssh.connect_to      hostname=${BB1_IP}    username=${BB1_LOGIN}    password=${BB1_PASSWORD}
    ...                 proxy=${proxy}        alias=${alias}

Connect to Common Unit
    [Arguments]       ${alias}=ASIK Master
    ssh.connect_to    ${tl.${gnb_or_enb}s[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...               ${tl.${gnb_or_enb}s[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               ${tl.${gnb_or_enb}s[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               proxy=${None}   alias=${alias}

Connect To Uncommissioned Common Unit
    ${dus}            testline_info.get_du_list    ${tl}
    ssh.connect_to    ${LMP_IP}
    ...               ${dus[0].airscale.common_units[0].lmp_connection.username}
    ...               ${dus[0].airscale.common_units[0].lmp_connection.password}
    ...               proxy=${None}   alias=master

Connect to host
    [Arguments]       ${hostname}=${tl.test_pc.default_ssh_connection_details.addr}
    ...               ${username}=${tl.test_pc.default_ssh_connection_details.username}
    ...               ${password}=${tl.test_pc.default_ssh_connection_details.password}
    ...               ${alias}=host
    ssh.connect to    hostname=${hostname}
    ...               username=${username}
    ...               password=${password}
    ...               alias=${alias}

Wait For BTS To Be Available
    [Arguments]    ${T1orT2}=None    ${AF_PATH}=${AF_PATH}
    Check If BTS Is Not Pingable And Check SW Version    T1orT2=${T1orT2}    timeout=15    AF_PATH=${AF_PATH}
    ${firmware}       Run Keyword And Return Status    Check If Firmware Update Exist
    Run Keyword If    ${firmware}    Log To Console    New firmware available, GNB reset will take extra 10 mins
    ${duration}        Set Variable If    ${firmware}    960    360
    Wait Until Keyword Succeeds    ${duration}    5    Check If BTS Is Pingable

Check If BTS Is Pingable
    [Arguments]    ${times}=5    ${ip}=192.168.255.129    ${Pingable_or_NotPingable}=Pingable    ${alias}=None
    ${check_msg}    Set Variable If    '${Pingable_or_NotPingable}'=='Pingable'    ${times} packets transmitted, ${times} received
    ...                                                                            100% packet loss
    IF    '${alias}'=='None'
        ${output}    Run    ping -c ${times} ${ip}
    ELSE
        ${output}    ssh.execute    command=ping ${ip} -c ${times}    connection=${alias}    timeout=20
    END
    Should Contain    ${output}    ${check_msg}

Check If BTS Is Not Pingable
    [Arguments]    ${times}=5
    ${output}    Run    ping -c ${times} 192.168.255.129
    Should Contain   ${output}    ${times} packets transmitted, 0 received

Check If BTS Is Not Pingable And Check SW Version
    [Arguments]    ${timeout}    ${T1orT2}=None     ${AF_PATH}=${AF_PATH}
    FOR    ${item}    IN RANGE    0    ${timeout}+1
        ${message}          Run Keyword And Ignore Error    Check active SW version on cOAM
        ...    T1orT2=${T1orT2}    check_times=1    log=${False}    AF_PATH=${AF_PATH}
        ${active_SW_status}     Set Variable If    'FAIL' in '${message}[0]'    FAIL
        ...                     PASS
        ${not_pingable}     Run Keyword And Return Status    Check If BTS Is Not Pingable
        Exit For Loop If    "${not_pingable}"=="True"
        Exit For Loop If    "${active_SW_status}"=="PASS" and "${not_pingable}"=="False"
        ${check_sw_fail}    Get Variable Value    ${sw_message}    None
        Run Keyword If      "${item}"=="${timeout}" and "${active_SW_status}"=="FAIL" and "${check_sw_fail}"!="None"
        ...                 Fail    msg=${check_sw_fail}
        ...    ELSE IF      "${item}"=="${timeout}" and "${active_SW_status}"=="FAIL"
        ...                 Fail    msg=Check active SW version failed: ${message[1]}
        Builtin.sleep    20s
    END

Check If IP Is Pingable
    [Arguments]    ${ip}    ${times}=5
    ${output}    Run    ping -c ${times} ${ip}
    Should Contain    ${output}    ${times} packets transmitted, ${times} received

Check If Firmware Update Exist
    ${output}    Run    grep -i 'New firmware version:' /tmp/btslog2/*.LOG /tmp/btslog2/*.log
    Should Contain    ${output}    is greater than the current one

Connect To vCU
    [Arguments]    ${host_ip}=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...            ${port}=${EMPTY}
    ...            ${username}=Nemuadmin
    ...            ${secure}=True
    ...            ${alias}=${EMPTY}
    ...            ${timeout}=30
    ...            ${loop_check}=${2}
    ${password}    Set Variable    Nokia@123
    ${update_expired_password}     Set Variable    False
    ${total_loop}    Set Variable If    ${loop_check} == ${1}    ${3}    ${loop_check+1}
    FOR    ${i}    IN RANGE    ${1}    ${total_loop}
        TRY
            coam_cu.connect_to
            ...    host=${host_ip}
            ...    port=${port}
            ...    username=${username}
            ...    password=${password}
            ...    secure=${secure}
            ...    alias=${alias}
            ...    timeout=${timeout}
            BREAK
        EXCEPT     AS    ${error}
            ${authentication_failed}     Get Regexp Matches    ${error}
            ...    AuthenticationFailed|authentication to security API failed
            IF    ${authentication_failed}
                IF    ${i} == ${1}
                    Log    CU WebUI authentication failed, try with different password nemuuser    WARN
                    ${password}    Set Variable    nemuuser
                    ${update_expired_password}     Set Variable    True
                    Builtin.sleep    5s
                    CONTINUE
                END
                Fail    CU WebUI authentication failed after retrying with different password, error: ${error}
            ELSE IF    ${i} == ${loop_check}
                Fail    Connect to CU WebUI failed, error: ${error}
            ELSE
                Log    Connect to CU WebUI failed, retrying...    WARN
                BuiltIn.Sleep    30s
            END
        END
    END

Connect To vDU
    [Arguments]    ${host_ip}=${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
    ...            ${port}=${EMPTY}
    ...            ${username}=Nemuadmin
    ...            ${secure}=True
    ...            ${connection_name}=du_admin
    ...            ${timeout}=30
    ...            ${loop_check}=${1}
    ${password}    Set Variable    Nokia@123
    ${update_expired_password}     Set Variable    False
    ${total_loop}    Set Variable If    ${loop_check} == ${1}    ${3}    ${loop_check+1}
    FOR    ${i}    IN RANGE    ${1}    ${total_loop}
        TRY
            vdu.connect to
            ...    host=${host_ip}
            ...    port=${port}
            ...    username=${username}
            ...    password=${password}
            ...    secure=${secure}
            ...    connection_name=${connection_name}
            ...    update_expired_password=${update_expired_password}
            ...    timeout=${timeout}
            BREAK
        EXCEPT     AS    ${error}
            ${authentication_failed}
            ...    Get Regexp Matches    ${error}    AuthenticationFailed|authentication to security API failed
            IF    ${authentication_failed}
                IF    ${i} == ${1}
                    Log    DU WebUI authentication failed, try with different password nemuuser    WARN
                    ${password}    Set Variable    nemuuser
                    ${update_expired_password}     Set Variable    True
                    Builtin.sleep    5s
                    CONTINUE
                END
                Fail    DU WebUI authentication failed after retrying with different password, error: ${error}
            ELSE IF    ${i} == ${loop_check}
                Fail    Connect to DU WebUI failed, error: ${error}
            ELSE
                Log    Connect to DU WebUI failed, retrying...    WARN
                BuiltIn.Sleep    30s
            END
        END
    END
