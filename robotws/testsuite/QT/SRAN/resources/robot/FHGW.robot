*** Settings ***
Documentation     File containing keywords used for FHGW testing
Library           OperatingSystem
Library           Collections
Library           Telnet
Library           String
Library           taf.transport.ssh.interface.ssh            WITH NAME    ssh

*** Keywords ***
check if ruproxy pod successful removed
    [Documentation]  this keyword if used to check if ruproxy delete successfully
    run keyword and ignore error    ssh.disconnect    connection=FHGW
    ssh.Connect to    hostname=${FHGW_IP}    username=${FHGW_USERNAME}    password=${FHGW_PASSWORD}    alias=FHGW
    ${connection} =    ssh.get connection by alias    alias=FHGW
    ${channel}    Call Method    ${connection}    invoke_shell
    BuiltIn.Sleep    3s
    Call Method    ${channel}    send    docker service ls |grep ruproxy\n
    BuiltIn.Sleep    3s
    ${ruproxy_res} =     Call Method    ${channel}    recv      ${65535}
    BuiltIn.Sleep   3s
    ${ruproxy_res}=  Decode Bytes To String  ${ruproxy_res}  UTF-8
    should not contain     ${ruproxy_res}   replicated'

check if ruproxy pod successful running
    [Documentation]  check if ruproxy is running
    run keyword and ignore error    ssh.disconnect    connection=FHGW
    ssh.Connect to    hostname=${FHGW_IP}    username=${FHGW_USERNAME}    password=${FHGW_PASSWORD}    alias=FHGW
    ${connection} =    ssh.get connection by alias    alias=FHGW
    ${channel}    Call Method    ${connection}    invoke_shell
    BuiltIn.Sleep    3s
    Call Method    ${channel}    send    root\n
    BuiltIn.Sleep    3s
    Call Method    ${channel}    send    docker service ls |grep ruproxy\n
    BuiltIn.Sleep    3s
    ${ruproxy_res} =     Call Method    ${channel}    recv      ${65535}
    BuiltIn.Sleep   3s
    ${ruproxy_res}=  Decode Bytes To String  ${ruproxy_res}  UTF-8
    should contain     ${ruproxy_res}   replicated

Check RF Power for FDD
    [Documentation]    Do some common thing for every postcondition of cases
    ...    Example
    ...    | Check RF Power for vDU |
    IF  not ${FHGW_Exist}
        Log     -->Testline doesn't have FHGW, skip FHGW related checking!
        RETURN
    END
    ${rf_check_result}    check_rf_power
    ...    ipaddr=${FHGW_IP}  conn_username=${FHGW_USERNAME}  conn_password=${FHGW_PASSWORD}
    Should Be True    ${rf_check_result}    msg=RF power Check Failed

Check GNSSEMOD-1 state in FHGW
    [Documentation]  check if GNSSEMOD-1 is enabled in FHGW, if disabled need restart switch-manager startfpga
     ...   fpgaAgent syncApp and gpsd service
    IF   ${FHGW_Exist} == False
        Log     -->Testline doesn't have FHGW, skip FHGW related checking!
        RETURN
    END
    run keyword and ignore error    ssh.disconnect    connection=FHGW
    ssh.Connect to    hostname=${FHGW_IP}    username=${FHGW_USERNAME}    password=${FHGW_PASSWORD}    alias=FHGW
    ${connection} =    ssh.get connection by alias    alias=FHGW
    ${channel}    Call Method    ${connection}    invoke_shell
    BuiltIn.Sleep    3s
    Call Method    ${channel}    send    fhgwcli has show state managed-object-type FHGW --inc-services | grep GNSSEMOD-1\n
    wait until keyword succeeds    3x   10s  Output pattern matches  ${channel}  ENABLED

check FHGW status to recover RF power
    [Documentation]  this keyword is used to check if L1 symbol is correct, if not will restart fpga
    ssh.Connect to   hostname=${${par_prefix}_k8s_addr}   username=${${par_prefix}_k8s_user}
    ...    password=${${par_prefix}_k8s_pwd}  alias=RM_alias
    Get pod name    namespace=${DU_tenant}
    ssh.write_input   kubectl exec -it ${uprt_pod} -c ctr-${${par_prefix}_tenant}-l1hi bash -n ${${par_prefix}_tenant}    connection=RM_alias
    BuiltIn.Sleep   10s
    ssh.write_input   fhp_cli   connection=RM_alias
    ssh.read_output_until   FHP_CLI#    connection=RM_alias
    ssh.write_input    fhpshow stats summary    connection=RM_alias
    ${output_1}=  ssh.read_output_until   FHP_CLI#    connection=RM_alias
    ssh.write_input   fhpshow stats summary    connection=RM_alias
    ${output_2}=  ssh.read_output_until   FHP_CLI#    connection=RM_alias
    ${resp}     Replace String Using Regexp    ${output_1}    \r\n    ,
    ${resp1}     Split String    ${resp}   ,
    ${resp}     Replace String Using Regexp    ${output_2}    \r\n    ,
    ${resp2}     Split String    ${resp}   ,
    ${res_tmp}    run keyword and ignore error    check_l1_symbol  ${resp1}  ${resp2}
    ${res}    set variable     ${res_tmp}[1]
    run keyword if  ${res} == False   run keyword   Restart FPGA service

Restart FPGA service
    [Documentation]  to restart startfpga and fpgaAgent services on fpga
    [Arguments]  ${cmd}= systemctl restart startfpga fpgaAgent
    IF   ${FHGW_Exist} == False
        Log     -->Testline doesn't have FHGW, skip FHGW related checking!
        RETURN
    END
    run keyword and ignore error    ssh.disconnect    connection=FHGW
    ssh.Connect to    hostname=${FHGW_IP}    username=${FHGW_USERNAME}    password=${FHGW_PASSWORD}    alias=FHGW
    ${connection} =    ssh.get connection by alias    alias=FHGW
    ${channel}    Call Method    ${connection}    invoke_shell
    BuiltIn.Sleep    3s
    Call Method    ${channel}    send    ${cmd}\n
    BuiltIn.Sleep    3s

WA for Switchmanger restart
    [Documentation]  this keyword is used to add WA when Switchmanger restart
    ...   author: Chen penghang
    IF   ${FHGW_Exist} == False
        Log     -->Testline doesn't have FHGW, skip FHGW related checking!
        RETURN
    END
    ssh.Connect to    hostname=${FHGW_IP}    username=${FHGW_USERNAME}    password=${FHGW_PASSWORD}    alias=FHGW
    ${connection} =    ssh.get connection by alias    alias=FHGW
    ${channel}    Call Method    ${connection}    invoke_shell
    BuiltIn.Sleep    3s
    Call Method    ${channel}    send    root\n
    Log To Console       \t\t- - - WA start - - -
    Call Method    ${channel}    send    docker exec sonic-cli config interface startup Ethernet2
    BuiltIn.Sleep    3s
    Run keyword If    '${is_TDD}'=='True'    run keywords
    ...    Call Method    ${channel}    send    bcmcmd c /opt/nokia/bin/remove_portsec.cint\n
    ...    AND    BuiltIn.Sleep    3s
    ...    AND    Call Method    ${channel}    send    /opt/nokia/FHGW-NW-SONIC/scripts/swssconfig.py /etc/sonic/ip2mecopp.json\n
    ...    AND    BuiltIn.Sleep    3s
    ...    AND    Call Method    ${channel}    send    /opt/nokia/FHGW-NW-SONIC/scripts/swssconfig.py /etc/sonic/arpicmpcopp.json\n
    ...    AND    BuiltIn.Sleep    3s
    Log To Console       \t\t- - - WA done - - -

Get eCpriMaerPortConfList
    [Documentation]   this keyword is used to check if RF and FHGW port are up
    IF   ${FHGW_Exist} == False
        Log     -->Testline doesn't have FHGW, skip FHGW related checking!
        RETURN
    END
    ssh.Connect to    hostname=${FHGW_IP}    username=${FHGW_USERNAME}    password=${FHGW_PASSWORD}    alias=FHGW
    ${connection} =    ssh.get connection by alias    alias=FHGW
    ${channel}    Call Method    ${connection}    invoke_shell
    BuiltIn.Sleep    3s
    Call Method    ${channel}    send    root\n
    Log   --> Start to check if ecpri config in FHGW[...]
    Call Method    ${channel}    send    redis-cli get eCpriMasterPortConfList\n
    BuiltIn.Sleep   3s
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    ${FHGW_version_check}=   Get Variable Value       ${FHGW_version}    None
    ${OE_version_check}=   Get Variable Value       ${OE_version}    None
    Run keyword If    '${FHGW_version_check}' == '21A'    Should Contain   ${output}   "PORT-2;PORT-19"
    ...    ELSE IF    '${FHGW_version_check}' == '22R1' and '${OE_version_check}' == 'OE19' and '${site}' == 'WRO'
    ...               Should Contain   ${output}   "PORT-2;PORT-24"
    ...    ELSE IF    '${FHGW_version_check}' == '22R1' and '${OE_version_check}' == 'OE20' and '${site}' == 'WRO'
    ...               Should Contain   ${output}   "PORT-2;PORT-24"
    ...    ELSE IF    '${FHGW_version_check}' == '22R1' and '${OE_version_check}' == 'OE20'    Should Contain   ${output}   "PORT-2;PORT-25"
    ...    ELSE IF    '${FHGW_version_check}' == '22R1' and '${OE_version_check}' == 'OE19'    Should Contain   ${output}   "PORT-2;PORT-23"
    ...    ELSE IF    '${FHGW_version_check}' == '22R2' and '${OE_version_check}' == 'OE20'    Should Contain   ${output}   "PORT-16;PORT-23"
    ...    ELSE IF    '${FHGW_version_check}' == '22R3' and '${OE_version_check}' != None    Should Contain   ${output}   "PORT-16;PORT-23"
    ...    ELSE    Log    Skip ecpri config check in FHGW
    Log To Console   --> get eCpriMasterPortConfList:${output}
    Call Method    ${channel}    close

Check FHGW_Ethernet
    [Documentation]   this keyword is used to check if all Ethernet are up in FHGW
    IF   ${FHGW_Exist} == False
        Log     -->Testline doesn't have FHGW, skip FHGW related checking!
        RETURN
    END
    ${Ethernet_Ports_Check}=   Get Variable Value       ${tl.gnbs[0].dus[0].fhgws[0].Ethernet_Ports}    None
    Run keyword If     '${Ethernet_Ports_Check}' != 'None'     Check Ethernet_Up

Check Ethernet_Up
    [Documentation]   this keyword is used to check if all Ethernet are up in FHGW
    IF   ${FHGW_Exist} == False
        Log     -->Testline doesn't have FHGW, skip FHGW related checking!
        RETURN    ${TRUE}
    END
    ssh.Connect to    hostname=${FHGW_IP}    username=${FHGW_USERNAME}    password=${FHGW_PASSWORD}    alias=FHGW
    ${connection} =    ssh.get connection by alias    alias=FHGW
    Log   --> Start to check if Ethernet config in FHGW[...]
    ${result}    Split String    ${FHGW_Ethernet_Ports}   ,
    ${length}=    get length    ${result}
    FOR    ${n}    IN RANGE      ${length}
        ${channel}    Call Method    ${connection}    invoke_shell
        BuiltIn.Sleep    3s
        Call Method    ${channel}    send
        ...    docker exec sonic-cli show int st |grep Ethernet${result[${n}]}|awk '{print$8}'\n
        BuiltIn.Sleep   3s
        ${output}    Call Method    ${channel}    recv    ${65536+${n}}
        ${output}    Convert To String    ${output}
        ${output}=   Get Line    ${output}    -4
        ${Up_Flag}=    Run Keyword And Return Status    Should Contain    ${output}    up
        Run Keyword If   '${Up_Flag}'=='False'    run keywords    Call Method     ${channel}    send
        ...    docker exec sonic-cli sudo config interface startup Ethernet${result[${n}]}\n
        ...    AND    BuiltIn.Sleep   3s
        Call Method    ${channel}    close
    END

Get eCpriMasterClockState
    [Documentation]  check if eCpriMasterClockState is ok
    IF   ${FHGW_Exist} == False
        Log     -->Testline doesn't have FHGW, skip FHGW related checking!
        RETURN
    END
    run keyword and ignore error    ssh.disconnect    connection=FHGW
    ssh.Connect to    hostname=${FHGW_IP}    username=${FHGW_USERNAME}    password=${FHGW_PASSWORD}    alias=FHGW
    ${connection} =    ssh.get connection by alias    alias=FHGW
    ${channel}    Call Method    ${connection}    invoke_shell
    BuiltIn.Sleep    3s
    Call Method    ${channel}    send    redis-cli get eCpriMasterClockState\n
    Wait Until Keyword Succeeds  5x   5s  Output pattern matches  ${channel}  MASTER_CLOCK_OK

Collecting RU Logs from FHGW
    IF   ${FHGW_Exist} == False
        Log     -->Testline doesn't have FHGW, skip FHGW related checking!
        RETURN
    END
    ssh.Connect to    hostname=${FHGW_IP}    username=${FHGW_USERNAME}    password=${FHGW_PASSWORD}    alias=FHGW
    ${cmd}            Set Variable   sudo tar zcvf /var/log/RUOAM/ruproxy-1/log/FHGW_RU_log.tgz /var/log/RUOAM/ruproxy-1/log/*
    ssh.execute          command=${cmd}    connection=FHGW    timeout=180s
    ssh.download file    remote_path=/var/log/RUOAM/ruproxy-1/log/FHGW_RU_log.tgz
    ...                  local_path=${LOG_PATH}/fhgw_ruproxy_logs.tgz
    ...                  connection=FHGW
    ${container}         ssh.execute   command=docker ps | grep ruproxy   connection=FHGW    timeout=60s
    ${container_id}      Fetch From Left    ${container}    ${SPACE}
    Run Keyword And Ignore Error    collect_rmod_logs            alias=FHGW
    ...                                                          container_id=${container_id}
    ...                                                          fhgw_ip=${FHGW_IP}
    ...                                                          fhgw_password=${FHGW_PASSWORD}
    ssh.download file    remote_path=/home/toor4nsn/fhgw_ru_snapshot.zip
    ...                  local_path=${LOG_PATH}/fhgw_ru_snapshot.zip
    ...                  connection=FHGW
    [Teardown]           ssh.disconnect    connection=FHGW

Check And Recover mri status on FHGW
    [Documentation]  check mri status on fhgw, if failed then try to restart rumoduleagent to recovery.
    [Arguments]  ${mri}=1
    IF   ${FHGW_Exist} == False
        Log     -->Testline doesn't have FHGW, skip FHGW related checking!
        RETURN
    END
    TRY
        Run Keyword If    '${vDU_build_flag}' == 'True' and '${is_TDD}' == 'False'  Run Keywords
        ...  ssh.Connect to    hostname=${FHGW_IP}    username=${FHGW_USERNAME}    password=${FHGW_PASSWORD}    alias=FHGW
        ...  AND  check_mri_state_on_FHGW_and_print_warning   mri=${mri}  alias=FHGW
    EXCEPT  AS  ${error}
        Log To Console  --> !!!Warning!!! check mri state failed on FHGW due to ${error}
    END
    [Teardown]           Run Keyword And Ignore Error  ssh.disconnect    connection=FHGW

Check mri status on FHGW for Sync In Rinline2
    [Documentation]  check mri status on fhgw for GNSS sync in rinline2 card
    [Arguments]  ${mri}    ${loop_check}=1
    ${result}    Create List    ${True}    ${EMPTY}
    TRY
        IF    '${vDU_build_flag}' == 'True' and '${is_TDD}' == 'False'
            ssh.Connect to    hostname=${FHGW_IP}    username=${FHGW_USERNAME}    password=${FHGW_PASSWORD}    alias=FHGW
            FOR    ${index}    IN RANGE    ${loop_check}
                ${result}    check_mri_state_on_FHGW_for_sync_in_rinline2   mri=${mri}  alias=FHGW
                IF    ${result[0]} == ${True}    BREAK
                IF    ${index} != 0 and ${index} != ${loop_check}-1     BuiltIn.Sleep    60s
            END
        END
    EXCEPT  AS  ${error}
        Log To Console  --> !!!Warning!!! check mri state failed on FHGW due to ${error}
    END
    [Teardown]     Run Keyword And Ignore Error  ssh.disconnect    connection=FHGW
    RETURN       ${result}

Collecting FHGW Snapshot
    [Documentation]    Collect FHGW snapshot and delete the old one
    ssh.Connect To    hostname=${FHGW_IP}    username=${FHGW_USERNAME}    password=${FHGW_PASSWORD}    alias=FHGW
    ssh.Execute    command=sudo rm -r /mnt/symptomreport/Snapshot*    connection=FHGW    timeout=30s
    ${time}    Set Variable    ${timestamp}
    ${cmd}    Set Variable    fhgwcli snapshot save --name ${time}
    ssh.Execute    command=${cmd}    connection=FHGW    timeout=600s
    Log To Console    --> Collecting FHGW Snapshot [...]
    ${cmd}    Set Variable    fhgwcli snapshot list report | grep ${time} | awk 'NR==1 {print $4}'
    FOR    ${i}    IN RANGE    30
        ${FHGW_snap_status}=    ssh.Execute    command=${cmd}    connection=FHGW    timeout=60s
        BuiltIn.Sleep    10s
        IF    '${FHGW_snap_status.strip()}'=='SUCCESS'
            Log To Console    --> FHGW Snapshot Collection [DONE]
            ${cmd}    Set Variable    ls /mnt/symptomreport | grep ${time} | grep -v sha512sum
            ${snapshot_name}=    ssh.Execute    command=${cmd}    connection=FHGW    timeout=60s
            ssh.Download File    remote_path=/mnt/symptomreport/${snapshot_name.strip()}
            ...                  local_path=${LOG_PATH}/FHGW_Snapshot_${time_stamp}.tar
            ...                  connection=FHGW
            BREAK
        END
    END
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=FHGW