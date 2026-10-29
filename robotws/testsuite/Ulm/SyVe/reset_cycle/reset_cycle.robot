*** Settings ***
Documentation   RESET RMODs or BBMODs in a loop, stop if TL doesn't recover

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    String
Library    Collections
Library    Process


Library    taf.sbts.oam.coam.admin                           WITH NAME   admin
Library    ../../resources/Common/python/alarm_handling.py   WITH NAME   alarm
Resource   ../../resources/Common/gnb.robot
Resource   ../../resources/Common/alarm_handling.robot

*** Variables ***
${NODE_ID}  0
${NODE_TYPE}  gnb
${REBOOT_TYPE}    ddal_reboot_graceful
${CMD_PREFIX}    ddal -s
${RU_RESET_COUNT}    5
${BBMOD_RESET_COUNT}    5
&{RU_RESET_COUNTER}
...    0=${RU_RESET_COUNT}
...    1=${RU_RESET_COUNT}
...    2=${RU_RESET_COUNT}
...    3=${RU_RESET_COUNT}
...    4=${RU_RESET_COUNT}
...    5=${RU_RESET_COUNT}
...    6=${RU_RESET_COUNT}
...    7=${RU_RESET_COUNT}
...    8=${RU_RESET_COUNT}
...    9=${RU_RESET_COUNT}
...    10=${RU_RESET_COUNT}
...    11=${RU_RESET_COUNT}
&{BBMOD_RESET_COUNTER}  0=${BBMOD_RESET_COUNT}  1=${BBMOD_RESET_COUNT}  2=${BBMOD_RESET_COUNT}  3=${BBMOD_RESET_COUNT}
${RU_TOTAL_LOOP_COUNTER}  5
${BBMOD_TOTAL_LOOP_COUNTER}  5
${RANDOM_RMOD_RESET_MAX_COUNT}    3


*** Test Cases ***

Reset Rmods
    [Documentation]
    ...   TC resets RMODs in a loop, checks alarms before and after the loop
    ...   stops if RMOD can't recover
    ...   RU_RESET_COUNTER:  how often each RMOD should be resetted RMOD_ID is from testlineconfig
    ...   RU_TOTAL_LOOP_COUNTER: how many reset loops should be done
    ...   e.g. if the RU_RESET_COUNTER for RMOD_ID 0 is 1 ,all other are 10 and RU_TOTAL_LOOP_COUNTER is 3
    ...   in the first cycle all RMODs are resetted, in second and third cycle RMOD_ID 0 is skipped
    [Tags]    Robustness_Reset_Cycle_RMODs

    Collections.Log Dictionary  ${RU_RESET_COUNTER}

    FOR  ${index}  ${_}  IN ENUMERATE  @{tl.${NODE_TYPE}s[${NODE_ID}].dus[0].rus}
        ${i_string}  Convert To String  ${index}
        TRY
           ${counter}=  Collections.Get From Dictionary  ${RU_RESET_COUNTER}  ${i_string}
        EXCEPT
           Log  Index ${index} not defined, set to 0  console=yes
           Collections.Set To Dictionary  ${RU_RESET_COUNTER}  ${i_string}  0
        END
    END
    ${cell_types}  Create List  nr
    gnb.Wait Until Node To Be Onair State For All Cells With Different Technologies  60s   20s   ${NODE_ID}   ${NODE_TYPE}   ${cell_types}
    ${alarms_before}=  alarm_handling.Get All Alarms From Node
    FOR  ${loop_counter}  IN RANGE  ${RU_TOTAL_LOOP_COUNTER}
        Log  Loop_counter: ${loop_counter}  console=yes
        FOR  ${index}  ${item}  IN ENUMERATE  @{tl.${NODE_TYPE}s[${NODE_ID}].dus[0].rus}
            Execute Reset RMOD  ${index}  ${item}
        END
        Sleep  150s
        gnb.Wait Until Node To Be Onair State For All Cells With Different Technologies  600s   20s   ${NODE_ID}   ${NODE_TYPE}   ${cell_types}
    END
   Sleep  30s
   ${alarms_after}=  alarm_handling.Get All Alarms From Node
   alarm.Check For New Alarms  ${alarms_before}  ${alarms_after}

Reset BBMODs
    [Documentation]
    ...   TC resets BBMODs in a loop, checks alarms before and after the loop
    ...   stops if BBMOD can't recover
    ...   BBMOD_RESET_COUNTER:  how often each BBMOD should be resetted BBMOD_ID is from testlineconfig
    ...   BBMOD_TOTAL_LOOP_COUNTER: how many reset loops should be done
    ...   e.g. if the BBMOD_RESET_COUNTER for BBMOD_ID 0 is 1 ,all other are 10 and BBMOD_TOTAL_LOOP_COUNTER is 3
    ...   in the first cycle all BBMODs are resetted, in second and third cycle BBMOD_ID 0 is skipped
    [Tags]    Robustness_Reset_Cycle_BBMODs

    Collections.Log Dictionary  ${BBMOD_RESET_COUNTER}

    Set Test Variable  ${cu_ip}    ${tl.${NODE_TYPE}s[${NODE_ID}].dus[0].airscale.common_units[0].lmp_connection.addr}
    Set Test Variable  ${cu_user}  ${tl.${NODE_TYPE}s[${NODE_ID}].dus[0].airscale.common_units[0].lmp_connection.username}
    Set Test Variable  ${cu_pass}  ${tl.${NODE_TYPE}s[${NODE_ID}].dus[0].airscale.common_units[0].lmp_connection.password}
    @{used_BBMODs}  Get IPs For Reachable BBMODs

    FOR  ${index}  ${_}  IN ENUMERATE  @{used_BBMODs}
        ${i_string}  Convert To String  ${index}
        TRY
           ${counter}=  Collections.Get From Dictionary  ${BBMOD_RESET_COUNTER}  ${i_string}
        EXCEPT
           Log  Index ${index} not defined, set to 0  console=yes
           Collections.Set To Dictionary  ${BBMOD_RESET_COUNTER}  ${i_string}  0
        END
    END
    ${cell_types}  Create List  nr
    gnb.Wait Until Node To Be Onair State For All Cells With Different Technologies  60s   20s   ${NODE_ID}   ${NODE_TYPE}   ${cell_types}
    ${alarms_before}=  alarm_handling.Get All Alarms From Node  with_historic=${false}
    FOR  ${loop_counter}  IN RANGE  ${BBMOD_TOTAL_LOOP_COUNTER}
        Log  Loop_counter: ${loop_counter}  console=yes
        FOR  ${index}  ${item}  IN ENUMERATE  @{used_BBMODs}
            Execute Reset BBMOD  ${index}  ${item}

        END
        Reset Random RMODs During BBMOD Reset
        Sleep  150s
        gnb.Wait Until Node To Be Onair State For All Cells With Different Technologies  600s   20s   ${NODE_ID}   ${NODE_TYPE}   ${cell_types}
    END
    Sleep  30s
    ${alarms_after}=  alarm_handling.Get All Alarms From Node  with_historic=${false}
    alarm.Check For New Alarms  ${alarms_before}  ${alarms_after}


*** Keywords ***
Get IPv6 Prefix From Hostname
    ${result}=    Process.Run Process  sshpass -p ${cu_pass} ssh ${cu_user}@${cu_ip} \" getent ahosts fct \"  shell=True
    @{lines}=     Split To Lines    ${result.stdout}
    FOR    ${line}    IN    @{lines}
        ${fields}=    Split String    ${line}
        IF    ':' in '${fields}[0]'
            @{splitted}=  Split String From Right  ${fields}[0]  :  1
            RETURN    ${splitted[0]}
        END
    END
    Fail    No IPv6 address found for fct

Get IPs For Reachable BBMODs
    ${prefix}=    Get IPv6 Prefix From Hostname
    @{ips}=    Create List
    # All possible BBMODs in SRAN
    ...    0101
    ...    0201
    ...    0301
    ...    0401
    ...    1101
    ...    1201
    ...    1301
    ...    1401

    @{reachable}=    Create List
    FOR    ${ip}    IN    @{ips}
        ${full_ip}=    Catenate    SEPARATOR=:    ${prefix}    ${ip}
        ${result}=     Process.Run Process  sshpass -p ${cu_pass} ssh ${cu_user}@${cu_ip} \"ping -6 -c 1 -W 1 ${full_ip}\"  shell=True
        IF    ${result.rc} == 0    Append To List    ${reachable}    ${full_ip}
    END
    RETURN    ${reachable}

Execute Reset RMOD
    [Arguments]   ${index}  ${item}
    ${i_string}  Convert To String  ${index}
    ${counter}=  Collections.Get From Dictionary  ${RU_RESET_COUNTER}  ${i_string}
    Log  Actual Reset Counter For pdu ${i_string}: ${counter}  console=yes
    IF  ${counter} == 0
        Log  Reset Counter is 0, continue  console=yes
        RETURN
    END
    Collections.Set To Dictionary  ${RU_RESET_COUNTER}  ${i_string}  ${${counter}-1}
    ${pdu_alias}     pdu.Setup Pdu   ${item.pdu_port.pdu}
    ${port_status}   pdu.Get Port Status   port=${item.pdu_port.port_no}   pdu_device=${pdu_alias}
    Log  Pdu port ${item.pdu_port.port_no} Status:${port_status}  console=yes
    Log  Switch off Port ${item.pdu_port.port_no}  console=yes
    pdu.Power Off  port=${item.pdu_port.port_no}   pdu_device=${pdu_alias}
    sleep  10s
    ${port_status}   pdu.Get Port Status   port=${item.pdu_port.port_no}   pdu_device=${pdu_alias}
    Log  Pdu port ${item.pdu_port.port_no} Status:${port_status}  console=yes
    pdu.Power On  port=${item.pdu_port.port_no}   pdu_device=${pdu_alias}
    Log  Switch on Port ${item.pdu_port.port_no}  console=yes
    ${port_status}   pdu.Get Port Status   port=${item.pdu_port.port_no}   pdu_device=${pdu_alias}
    Log  Pdu port ${item.pdu_port.port_no} Status:${port_status}  console=yes

Execute Reset BBMOD
    [Arguments]  ${index}  ${item}

    ${i_string}  Convert To String  ${index}
    ${counter}=  Collections.Get From Dictionary  ${BBMOD_RESET_COUNTER}  ${i_string}
    Log  Actual Reset Counter For BBMOD ${i_string}: ${counter}  console=yes
    IF  ${counter} == 0
        Log  Reset Counter For BBMOD ${i_string} is 0, continue  console=yes
        RETURN
    END
    Collections.Set To Dictionary  ${BBMOD_RESET_COUNTER}  ${i_string}  ${${counter}-1}
    IF    '${REBOOT_TYPE}' == 'ddal_reboot_rapid'
        ${reboot_cmd}=    Set Variable    ${CMD_PREFIX} ddal_reboot_rapid
    ELSE IF    '${REBOOT_TYPE}' == 'ddal_reboot_graceful'
        ${reboot_cmd}=    Set Variable    ${CMD_PREFIX} ddal_reboot_graceful
    ELSE IF    '${REBOOT_TYPE}' == 'ddal_reboot_immediate'
        ${reboot_cmd}=    Set Variable    ${CMD_PREFIX} ddal_reboot_immediate
    ELSE
        Fail    Unknown reboot type: ${REBOOT_TYPE}. Valid options: ddal_reboot_rapid, ddal_reboot_graceful, ddal_reboot_immediate
    END
    ${r}  Process.Run Process  sshpass -p ${cu_pass} ssh ${cu_user}@${cu_ip} "ssh ${item} ${reboot_cmd} "  stderr=/tmp/b  shell=True
    Log  -->:Status Reboot BBMOD ${index} with IP ${item} using '${reboot_cmd}': ${r.rc}  console=yes

Reset Random RMODs During BBMOD Reset
    [Documentation]    Randomly selects and resets RMODs (without duplicates) during BBMOD reset
    ${num_rmods}=    Get Length    ${tl.${NODE_TYPE}s[${NODE_ID}].dus[0].rus}

    ${reset_count}=    Set Variable    4

    ${selected_indexes}=    Evaluate    random.sample(range(${num_rmods}), ${reset_count})    modules=random

    Log    Randomly resetting RMOD at index ${selected_indexes} during BBMOD reset    console=yes

    FOR    ${random_index}    IN    @{selected_indexes}
            ${item}    Set Variable    ${tl.${NODE_TYPE}s[${NODE_ID}].dus[0].rus}[${random_index}]
            ${pdu_alias}     pdu.Setup Pdu   ${item.pdu_port.pdu}
            ${port_list}    Create List    ${item.pdu_port.port_no}
            pdu.Reset Ports  ports=@{port_list}   pdu_device=${pdu_alias}
            Sleep    15s
            ${port_status}   pdu.Get Port Status   port=${item.pdu_port.port_no}   pdu_device=${pdu_alias}
            Log  Pdu port ${item.pdu_port.port_no} Status:${port_status}  console=yes
    END
