*** Settings ***
Documentation   This is a Robot Test Suite to initialize the UEs.
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library     taf.ul.messaging.mtk      WITH NAME    mtk
Library    OperatingSystem
Library    String
Library    Collections
Library    Telnet
Library    taf.ue

Resource    ../../resources/Common/testline.robot
Resource    ../../resources/Common/gnb.robot
Resource    ../../resources/Common/tcpdump.robot
Resource    ../../resources/Common/util.robot
Resource    ../../resources/Common/git_handling.robot
Resource    ../resources/syve_testline.robot
Resource    ../resources/attenuator.robot
Resource    ../resources/Mediatek.robot


*** Variables ***
${LOGS}              X2-C_S1-C_IFs
${OFF_VALUE}         ${110}


*** Test Cases ***
UE_Initialization
    [Documentation]    Initialization of the UEs
    [Tags]             UE_Initialization
    [Setup]            Prepare TL for Testing
    [Teardown]         Perform Postconditions
    Reboot And Detach All UEs
    Run Keyword And Ignore Error    Set Pre Attenuation Values


*** Keywords ***
Prepare TL for Testing
    Log To Console    ${\n}INFO: Prepare TL for Testing.
    testline.Set Console Output
    git_handling.Save Current Workspace Info
    testline.Create Test Suite Log Folders
    syve_testline.Save Current Loads
    testline.Check TL Infos
    testline.Create Testcase Log Directory
    Log Variables
    Start The Following Logs


Perform Postconditions
    Log To Console    ${\n}INFO: Start Teardown
    Stop The Following Logs
    ${resultTestDir}=    testline.Get Testcase Log Directory
    ${num_of_ues}=    Get Length    ${tl.ues}
    FOR    ${i}    IN RANGE    ${0}    ${num_of_ues}
        ${ueType}=    testline.Get UE type    ue_id=${i}
        IF    '${ueType}'=='qualcomm'    Collect Pyro Logs    ue_id=${i}
    END
    connect.Disconnect All Available Ssh Connections


Reboot and detach all UEs
    attenuator.Set Attenuator to Max Value
    ${num_of_ues}=    Get length    ${tl.ues}
    FOR    ${i}    IN RANGE    ${0}    ${num_of_ues}
        ${ueType}=    testline.Get UE type    ue_id=${i}
        Log To Console    ${\n}INFO: UE Type of UE_${i+1} is ${ueType}.

        IF   '${ueType}'=='qualcomm'
            Run Keyword And Ignore Error     Power Cycle Qualcomm UE And Wait For Reconnection    ue_id=${i}
            Log To Console    ${\n}INFO: Wait 15s Until The Ethernet Interface Is Stable.
            Sleep    15s
            Run Keyword And Ignore Error     Detach AT UE    ue_id=${i}
        ELSE IF    '${ueType}'=='mediatek'
            Reboot MTK UE    ue_id=${i}
            Detach UE    ue_id=${i}
        ELSE
            Log To Console    \nUE type ${ueType} is not supported.
        END
    END


Power Cycle Qualcomm UE And Wait For Reconnection
    [Arguments]    ${ue_id}=${0}    ${time_interval}=10    ${timeout}=${240}
    Log To Console    ${\n}INFO: Power cycle qualcomm UE_${ue_id+1}.
    ${pdu}         Set Variable    ${tl.ues[${ue_id}].pdu_port.pdu}
    ${pdu_port}    Set Variable    ${tl.ues[${ue_id}].pdu_port.port_no}
    testline.PDU power reset    ${pdu}    ${pdu_port}    time_interval=${time_interval}
    Wait Until Keyword Succeeds    ${timeout}    5 sec    UE Device Should Be Available    ue_id=${ue_id}
    Log To Console    ${\n}INFO: Qualcomm UE_${ue_id+1} is reconnected.


Reboot MTK UE
    [Arguments]    ${ue_id}
    Log To Console    ${\n}INFO: Mediatek ADB reboot UE_${ue_id+1}.
    Mediatek.Mediatek ADB reboot    ue_id=${ue_id}


Detach UE
    [Arguments]    ${ue_id}
    Log To Console    ${\n}INFO: Setup UE_${ue_id+1} has started.
    Run Keyword And Ignore Error     taf.ue.Require UE    UE_${ue_id+1}    capabilities=REAL_UE
    Log To Console    ${\n}INFO: Setup UE_${ue_id+1} is finished.
    Log To Console    ${\n}INFO: Detach UE_${ue_id+1} has started.
    Run Keyword And Ignore Error     taf.ue.Detach Ue    UE_${ue_id+1}
    Log To Console    ${\n}INFO: Detach UE_${ue_id+1} is finished.


Detach AT UE
    [Arguments]   ${ue_id}
    Log To Console    ${\n}INFO: Setup UE_${ue_id+1} has started.
    Run Keyword And Ignore Error     taf.ue.Require UE    UE_${ue_id+1}    capabilities=REAL_UE
    Log To Console    ${\n}INFO: Setup UE_${ue_id+1} is finished.
    Sleep    5s
    Log To Console    ${\n}INFO: Detach UE_${ue_id+1} with AT command has started.
    ${pre_status}=    taf.ue.Send At Cmd To Ue    UE_${ue_id+1}    at_cmd=at+cfun?
    Log To Console    ${\n}INFO: UE_${ue_id+1}: Result of at_cmd=at+cfun? is ${pre_status}
    ${pre_status}=    taf.ue.Send At Cmd To Ue    UE_${ue_id+1}    at_cmd=at+cfun=0
    Log To Console    ${\n}INFO: UE_${ue_id+1}: Result of at_cmd=at+cfun=0 is ${pre_status}
    ${pre_status}=    taf.ue.Send At Cmd To Ue    UE_${ue_id+1}    at_cmd=at+cfun?
    Log To Console    ${\n}INFO: UE_${ue_id+1}: Result of at_cmd=at+cfun? is ${pre_status}
    Log To Console    ${\n}INFO: Detach UE_${ue_id+1} with AT command is finished.


Start The Following Logs
    IF    ('X2-C_S1-C_IFs' in '${LOGS}')    tcpdump.Start TCPdump On All ENBs
    Log To Console    ${\n}INFO: Start logs is finished.


Stop The Following Logs
    IF    ('X2-C_S1-C_IFs' in '${LOGS}')    tcpdump.Stop TCPdump On All eNBs


Set Pre Attenuation Values
    Set Test Variable    ${attIP}    ${tl.attenuators[0].ip_addr}
    Set Test Variable    ${PreAtt_path}    /mnt/etfiles/config/entitytests-tools/PzUlm_CRT_TL_configs/preAtt
    ${tl_name}=     testline.Get Testline Name
    ${file}    Get Binary File    ${PreAtt_path}/${tl_name}/preAtt.txt
    @{read}    Create List    ${file}
    ${firstLine}    Get Line    @{read}    0    # Read the number of attenuator ports, which is stated in the first line of the file.
    @{lines}    Split To Lines    @{read}    2    # Get the third line from the file.
    @{preAttValues}    Split String    @{lines}    # Inser the values from the third line into a list.
    Set Test Variable    @{preAttValues}
    Set Test Variable    ${firstLine}
    Open Connection    ${attIP}    23
    Login    USER 8    ${EMPTY}    UserName:    ${EMPTY}
    Set Prompt    Radio Rack\>    True
    ${port_length}=    Set Variable If
    ...    '${firstLine}'=='16-16'    16
    ...    '${firstLine}'=='32-32'    32
    FOR    ${port}    IN RANGE    0    ${port_length}
        Execute Command    PREATT ${port+1} ${preAttValues}[${port}]
    END
    ${output}=    Write    PREATT
    Log To Console    ${output}


Get Ue Alias
    [Documentation]
    ...    |  ue_id | the ID of UE, Integer or String |
    ...
    ...    *Return*  ue alias for ute_ue
    [Arguments]    ${ue_id}=0
    ${ue_alias}=    Set Variable    UE_${ue_id}
    RETURN    ${ue_alias}



Collect Pyro Logs
    [Documentation]
    ...    Collect pyro logs from qualcomm test pc.
    ...
    ...    Important: You need to set "server_dir='/cygdrive/c/pyro_server'" in __init__.py
    ...
    ...    |  ue_id     | the ID of UE, Integer or String |
    ...    | target_dir | Logs target directory |
    ...
    [Arguments]    ${ue_id}=0    ${target_dir}=None
    ${resultTestDir}=    IF    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...                  ELSE                             Set Variable    ${target_dir}
    ${testpc_alias}=    connect.Connect to UE PC    ue_id=${ue_id}
    ${local_dir}=  Set Variable  ${resultTestDir}/${testpc_alias}_pyro_logs
    ${logfilelist}=  Create List
    Create Directory    ${local_dir}
    ${log_files}=    Create List    ta_ue_uepc_local.log    ta_uepc_pyro.log
    FOR    ${file}    IN    @{log_files}
        ssh.download_file    remote_path=${tl.ues[${ue_id}].server_dir}/logs/${file}
        ...    local_path=${local_dir}/${file}
        ...    connection=${testpc_alias}
        Append To List  ${logfilelist}  ${local_dir}/${file}
    END
    ${ue_alias}=    Get Ue Alias    ue_id=${ue_id}
    Log    Qualcomm Ue [${ue_alias}] pyro logs are collected into ${local_dir}!    console=${P_console}
    RETURN  ${logfilelist}
    [Teardown]    ssh.disconnect    connection=${testpc_alias}


UE Device Should Be Available
    [Documentation]
    ...    Check if UE Device is connected
    [Arguments]    ${ue_id}=0

    ${testpc_alias}=    connect.Connect to UE PC    ue_id=${ue_id}
    ssh.Send command    adb devices        connection=${testpc_alias}
    ${output}=          ssh.Read output    connection=${testpc_alias}

    Log    ${\n}UE with alias UE_${ue_id} adb devices output: ${output}    console=${P_console}
    Should Contain    ${output}    ${tl.ues[${ue_id}].serial_number}

    [Teardown]          ssh.disconnect     connection=${testpc_alias}



