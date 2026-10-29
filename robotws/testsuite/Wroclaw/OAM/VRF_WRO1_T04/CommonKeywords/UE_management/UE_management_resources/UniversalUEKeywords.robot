*** Settings ***
Documentation    Suite description

Library     Collections
Library     String
Library     UniversalUEKeywords.py
Library     taf.transport.ssh    WITH NAME    csn

*** Variables ***
${iperf3_file}      ${CURDIR}/iperf3.txt

*** Keywords ***
Return UE ip
    [Arguments]     ${UE_serial_number}    ${session}=cpc
    ${is_askey}=    Check if UE is Askey    ${UE_serial_number}     ${session}
    ${ue_ip}=   run keyword if  ${is_askey}!=True
    ...     Get IP  ${UE_serial_number}    ${session}
    ...     ELSE
    ...     Get Askey IP and set route    ${session}
    [Return]    ${ue_ip}

Get UE ip
    [Arguments]     ${UE_serial_number}    ${session}=cpc
    ${ue_ip}=   Get IP  ${UE_serial_number}    ${session}
    [Return]    ${ue_ip}

Wait until UE has IP
    [Arguments]     ${UE_serial_number}    ${session}=cpc
    ${ue_ip}=   Get UE ip  ${UE_serial_number}  ${session}
    should not be empty  ${ue_ip}

Loop over COM ports to attach UEs
    [Arguments]     ${UE_serial_number}     ${list_of_ttyS}    ${session}=cpc
    ${com_port}=    Set variable
    FOR  ${ttyS}  IN  @{list_of_ttyS}
#        ${attach_command}=    Catenate    echo -ne 'AT+CGATT=1\r' > ${ttyS}
        ${has_ip}=  Check if UE has IP  ${UE_serial_number}
#        run keyword if  ${has_ip}==False
#        ...     Send att command     ${ttyS}     ${attach_command}
        ${result}=  Run keyword and return status    Wait Until Keyword Succeeds  25 sec  5 sec
        ...                                          Wait until UE has IP  ${UE_serial_number}     ${session}
        ${ue_ip}=   run keyword if  ${result}
        ...     Return UE ip  ${UE_serial_number}    ${session}
        ${com_port}=    Set variable    ${ttyS}
        Exit for loop if    ${result}
    END
    Should not be true  '${ue_ip}'=='None'
    Log To Console    \n--> INFO: UE ${UE_serial_number} successfuly attached
    [Return]    ${ue_ip}    ${com_port}

Loop over COM ports to check UE IP
    [Arguments]     ${UE_serial_number}    ${session}=cpc
    ${com_port}=    Set variable
    ${has_ip}=  Check if UE has IP  ${UE_serial_number}
    ${result}=  Run keyword and return status    Wait Until Keyword Succeeds  25 sec  5 sec
        ...                                          Wait until UE has IP  ${UE_serial_number}     ${session}
    ${ue_ip}=   run keyword if  ${result}
        ...     Return UE ip  ${UE_serial_number}    ${session}
    Should not be true  '${ue_ip}'=='None'
    Log To Console    \n--> INFO: UE ${UE_serial_number} successfuly attached
    [Return]    ${ue_ip}    ${com_port}

Send att command
    [Arguments]     ${ttyS}     ${att_command}    ${session}=cpc
    log to console  Sending attach command to ${ttyS}
    csn.send_command    ${att_command}    connection=${session}  timeout=5
    sleep   15s
    csn.send_command    ${att_command}    connection=${session}  timeout=5
    sleep   15s

Check if iperf3 exists on UE
    [Arguments]     ${UE_serial_number}     ${session}=cpc
    csn.send_command     adb -s ${UE_serial_number} shell ls -la /data/local/tmp    connection=${session}
    ${ls}=     csn.read_output   connection=${session}
    ${is_iperf}=    Run keyword and return status   Should contain any  ${ls}     iperf3
    [Return]    ${is_iperf}

Check if iperf-android exists on UE
    [Arguments]     ${UE_serial_number}     ${session}=cpc
    csn.send_command     adb -s ${UE_serial_number} shell ls -la /data/local/tmp    connection=${session}
    ${ls}=     csn.read_output   connection=${session}
    ${is_iperf}=    Run keyword and return status   Should contain any  ${ls}     iperf-android
    [Return]    ${is_iperf}

Check if iperf exists on UEPC
    [Arguments]    ${session}=cpc
    ${ls}=    csn.execute    ls -la /cygdrive/c/iperf  connection=${session}
    ${is_iperf}=    Run keyword and return status   Should contain any  ${ls}     iperf
    [Return]    ${is_iperf}

Upload Iperf3 to UE
    [Documentation]     The purpose of moving file in this keyword is to remove .txt extension from iperf create binary file
    [Arguments]     ${UE_serial_number}     ${session}=cpc
    ${ls}=  csn.execute     ls -la /tmp     connection=${session}
    ${is_iperf_on_uepc}=    Run keyword and return status   Should contain any  ${ls}     iperf3
    Run keyword if  ${is_iperf_on_uepc}!=True
    ...     csn.upload_file     ${iperf3_file}    /home/wro5goam     connection=${session}   timeout=10
    csn.execute    adb -s ${UE_serial_number} shell mkdir /data/local/tmp   connection=${session}
    csn.execute    adb -s ${UE_serial_number} push iperf3 /data/local/tmp   connection=${session}
    csn.execute    adb -s ${UE_serial_number} shell chmod 777 /data/local/tmp/iperf3   connection=${session}

Check if UE has IP
    [Arguments]     ${UE_serial_number}    ${session}=cpc
    Log To Console    \n--> INFO: Checking if UE: ${UE_serial_number} has IP
    ${regexp}=    Catenate   192\\.168\\.[0-9]{1,3}\\.[0-9]{1,3}
    ${regexp_VoNR}=    Catenate   10\\.42\\.[0-9]{1,3}\\.[0-9]{1,3}
    csn.send_command     adb -s ${UE_serial_number} shell ip a    connection=${session}
    ${ip}=     csn.read_output   connection=${session}
    ${check}=   Get Regexp Matches     ${ip}    ${regexp}
    ${is_empty}=     Run Keyword And Return Status    Should Not Be Empty    ${check}
    ${ue_ip}=       Run Keyword If        ${is_empty}==True
    ...     Get Regexp Matches     ${ip}    ${regexp}
    ...     ELSE
    ...     Get Regexp Matches     ${ip}    ${regexp_VoNR}
    ${result}=  run keyword and return status   Should not be empty     ${ue_ip}
    run keyword if  ${result}==True
    ...     log to console  UE: ${UE_serial_number} already has assigned IP: ${ue_ip}[0]. Skipping
    [Return]    ${result}

Check if UE is Askey
    [Arguments]     ${UE_serial_number}     ${session}=cpc
    csn.send_command     adb -s ${UE_serial_number} shell uname -a    connection=${session}
    ${system_info}=     csn.read_output   connection=${session}
    ${contains}=    evaluate    "sdxprairie" in """${system_info}"""
    [Return]    ${contains}

Get IP
    [Arguments]     ${UE_serial_number}     ${session}=cpc
    ${regexp}=    Catenate   192\\.168\\.[0-9]{1,3}\\.[0-9]{1,3}
    ${regexp_VoNR}=    Catenate   10\\.42\\.[0-9]{1,3}\\.[0-9]{1,3}
    csn.send_command     adb -s ${UE_serial_number} shell ip a    connection=${session}
    ${ip}=     csn.read_output   connection=${session}
    ${check}=   Get Regexp Matches     ${ip}    ${regexp}
    ${is_empty}=     Run Keyword And Return Status    Should Not Be Empty    ${check}
    ${ue_ip}=       Run Keyword If        ${is_empty}==True
    ...     Get Regexp Matches     ${ip}    ${regexp}
    ...     ELSE
    ...     Get Regexp Matches     ${ip}    ${regexp_VoNR}
    [Return]    ${ue_ip}[0]

Get Askey IP and set route
    [Arguments]     ${session}=cpc
    ${regexp}=    Catenate   192\\.168\\.[0-9]{1,3}\\.[0-9]{1,3}
    ${ips}=   csn.execute     ipconfig   connection=${session}
    ${ue_ip}=   Get Regexp Matches     ${ips}    ${regexp}
    ${result}=  csn.execute     route add ${APPS_NETWORK_IF} mask 255.255.255.255 ${ue_ip}[1]    connection=${session}
    Sleep   5
    [Return]    ${ue_ip}[0]

Get Askey IP from iperf output
    [Arguments]     ${UE_serial_number}     ${session}=cpc
    ${regexp}=    Catenate   192\\.168\\.[0-9]{1,3}\\.[0-9]{1,3}
    ${pid}=     Listen for UL throughput on appserver   5432    iperf
    Start UL throughput on UE   ${UE_serial_number}     ${APPS_NETWORK_IF}   5432   iperf   ${TPUT}    5  cpc
    Kill iperf on appserver     ${pid}
    csn.download_file    remote_path=/tmp/iperf_UL_5432.txt
    ...                  local_path=${OUTPUT DIR}/iperf_UL_5432.txt
    ...                  connection=appserver
    ${ip_line}=     get_line_with_askey_ip  ${OUTPUT DIR}/iperf_UL_5432.txt
    ${ue_ip}=   Get Regexp Matches     ${ip_line}    ${regexp}
    [Return]    ${ue_ip}[0]

Kill iperf on windows
    [Arguments]     ${session}=cpc
    csn.execute     taskkill /F /IM iperf.exe    connection=${session}
    csn.execute     taskkill /F /IM nohup.exe    connection=${session}

Verify if UE is up
    [Arguments]     ${UE_serial_number}     ${session}=cpc
    ${ues}=   csn.execute     adb devices
    Should contain  ${ues}     ${UE_serial_number}

Create UL iperf command for askey
    [Arguments]     ${UE_serial_number}     ${session}=cpc
    ${regexp}=    Catenate   192\\.168\\.[0-9]{1,3}\\.[0-9]{1,3}
    ${ips}=   csn.execute     ipconfig   connection=${session}
    ${ue_ip}=   Get Regexp Matches     ${ips}    ${regexp}
    ${command}=     set variable    /cygdrive/c/iperf/iperf.exe -u -B ${ue_ip}[1]
    [Return]    ${command}
