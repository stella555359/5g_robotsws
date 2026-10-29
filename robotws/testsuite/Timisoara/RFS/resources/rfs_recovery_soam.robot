*** Settings ***
Documentation    Keywords for BTS recovery
...              Resource used by RF Sharing Vrf tribe
...              Author: Alexandru Stamp
...              Contact: alexandru.stamp@nokia.com

Resource          rfs_frame_rfs_common.robot

*** Keywords ***
Trigger Recovery Action RFS SOAM
    [Documentation]  Main KW for triggering Recovery Actions
    [Arguments]  ${REC_ACTION}

    Set Test Variable  ${REC_ACTION}

    Run Keyword If  '${REC_ACTION}' == 'UNLOCK_POTENTIALLY_LOCKED_ELEMENTS'  Unlock Elements Recovery
    Run Keyword If  '${REC_ACTION}' == 'SITE_RESET'  Reset BTS Recovery
    Run Keyword If  '${REC_ACTION}' == 'POWER_RESET'  Power OFF/ON BTS Recovery

Unlock Elements Recovery
    Log  Try BTS Recovery by unlocking potentially locked elements  console=True
    Unlock potentially locked elements  ${alias_list}
    ${recovery_result}=  Run Keyword And Return Status  Check Recovery Status
    Run Keyword If  '${recovery_result}' == 'False'
    ...  Log  BTS Recovery by unlocking elements not succesful! Continuing with Site Reset/Power OFF/ON BTS Recovery  level=ERROR
    ...  ELSE  Run Keywords
    ...  Log  BTS Recovery by unlocking elements succesful!  console=True
    ...  AND  Return From Keyword
    Reset BTS Recovery

Reset BTS Recovery
    Log  Start BTS recovery by using Site Reset (only for classical BTS)  console=True
    ${site_reset_result}=  Run Keyword And Return Status  Site Reset Entities
    Run Keyword If  '${site_reset_result}' == 'False'  Run Keywords
    ...  Log  Site Reset Action Failed  level=ERROR
    ...  AND  Power OFF/ON BTS Recovery
    Sleep  120 seconds  Wait 120 seconds for reset start
    ${availability_result}=  Run Keyword And Return Status  Check Entities Are Available
    Run Keyword If  '${availability_result}' == 'False'  Run Keywords
    ...  Log  BTS Availability Check Failed  level=ERROR
    ...  AND  Power OFF/ON BTS Recovery
    ${recovery_result}=  Run Keyword And Return Status  Check Recovery Status
    Run Keyword If  '${recovery_result}' == 'False'  Run Keywords
    ...  Log  Site Reset Recovery Failed  level=ERROR
    ...  AND  Power OFF/ON BTS Recovery

Power OFF/ON BTS Recovery
    [Documentation]  Helper KW for recovery action
    Log  Start BTS recovery by using Power OFF/ON (only for classical BTS)  console=True
    ${power_result}=  Run Keyword And Return Status  Power OFF Entity SM
    Run Keyword If  '${power_result}' == 'False'  Run Keyword and Continue on Failure  Run Keywords
    ...  Log  Power OFF action failed  level=ERROR
    ...  AND  Fail  Execution ended. Power OFF Recovery Failed
    ${power_result}=  Run Keyword And Return Status  Power ON Entities SM
    Run Keyword If  '${power_result}' == 'False'  Run Keywords
    ...  Log  Power ON action failed  level=ERROR
    ...  AND  Fail  Execution ended. Power ON Recovery Failed
    ${power_recovery_result}=  Run Keyword And Return Status  Check Recovery Status
    Run Keyword If  '${power_recovery_result}' == 'False'  Run Keywords
    ...  Log  Power OFF/ON recovery failed level=ERROR
    ...  AND  Fail  Execution ended. Check Recovery Status Failed
    Run Keyword If  '${REC_ACTION}' == 'SITE_RESET' and '${TAF_CONFIG_MODEL}' == ${False}
    ...  Pass Execution  Reset recovery failed but Power recovery ended successfully

Power OFF Entity SM
    [Timeout]  240 sec
    FOR  ${alias}  IN  @{alias_list}

        ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH

        Continue For Loop If  '${alias_tech}' == 'CBTS'

        Log  Start Power OFF ${alias} SM  console=True

        ${SM_PDU_if_name_list}=  Check BTS SMs PDU info definition  ${alias}

        ${status}=  Set BTS SMs PDU port status  ${SM_PDU_if_name_list}  off

        ${alias_pc_ip}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_PC_IP_ADDRESS
        ${alias_tech_ip}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH_IP_ADDRESS

        ${remote_host}=  Set Variable If  '${alias}' == 'Master'  None  ${alias_pc_ip}
        Wait For Target To Be Not Reachable TAF  hostname=${alias_tech_ip}  timeout=300
        ...  remote_host=${remote_host}

        Log  Power OFF ${alias} SM completed  console=True

    END

Power ON Entities SM
    [Timeout]  800 sec
    FOR  ${alias}  IN  @{alias_list}

        ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH

        Continue For Loop If  '${alias_tech}' == 'CBTS'

        Log  Start Power ON ${alias} SM  console=True

        ${SM_PDU_if_name_list}=  Check BTS SMs PDU info definition  ${alias}

        ${status}=  Set BTS SMs PDU port status  ${SM_PDU_if_name_list}  on

        ${alias_pc_ip}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_PC_IP_ADDRESS
        ${alias_tech_ip}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH_IP_ADDRESS

        ${remote_host}=  Set Variable If  '${alias}' == 'Master'  None  ${alias_pc_ip}
        Wait For Target To Be Reachable TAF  hostname=${alias_tech_ip}  timeout=300
        ...  remote_host=${remote_host}

        Log  Power ON ${alias} SM completed  console=True

    END

Site Reset Entities
    FOR  ${alias}  IN  @{alias_list}

        ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH

        Continue For Loop If  '${alias_tech}' == 'CBTS'

        Log  Start Site Reset ${alias} BTS  console=True

        coam.Reset Site  wait_for_reconnection=False  connection=${alias}

    END

Check Entities Are Available
    FOR  ${alias}  IN  @{alias_list}

        ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH

        Continue For Loop If  '${alias_tech}' == 'CBTS'

        ${alias_tech_ip}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH_IP_ADDRESS
        Wait For Target To Be Reachable TAF  hostname=${alias_tech_ip}  timeout=360

    END

Check Recovery Status
    FOR  ${alias}  IN  @{alias_list}

        ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH

        Continue For Loop If  '${alias_tech}' == 'CBTS'

        Log  Check ${alias} BTS status  console=True
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  900  ${alias}

        Log  Check ${alias} Cells State  console=True
        Wait until keyword succeeds  420 sec  15 sec  Wait For Entity Cell State  ${alias}

        Log  Check ${alias} RMs State  console=True
        Wait until keyword succeeds  420 sec  15 sec  Wait For Entity RM State  ${alias}

        Log  ${alias} BTS recovery successfully ended  console=True

    END

Wait For Entity Cell State
    [Arguments]  ${alias}
    ${cell_status_check}  ${BTS_redundancyRole}=  Check Entity Cells State  ${alias}
    Run Keyword If  ${cell_status_check}
    ...  Log  ${alias} cells status check is passed!  console=True
    ...  ELSE
    ...  Fail  ${alias} cells status check is failed!

Wait For Entity RM State
    [Arguments]  ${alias}
    ${RM_status_check}=  Check Entity RMs State  ${alias}
    Run Keyword If  ${RM_status_check}
    ...  Log  ${alias} RMs status check is passed!  console=True
    ...  ELSE
    ...  Fail  ${alias} RMs status check is failed!

Check selected Recovery action
    [Documentation]  Helper KW for recovery action
    Set Test Variable  ${SnapshotTriggerEndTest}  YES
    Run Keyword If  '${REC_ACTION}' == 'SITE_RESET'
    ...  Log  Site Reset Recovery action is selected. In case of failure, Power OFF/ON recovery is triggered  console=TRUE
    ...  ELSE IF  '${REC_ACTION}' == 'POWER_RESET'
    ...  Log  Power OFF/ON Recovery action is selected  console=TRUE
    ...  ELSE
    ...  Fail  Bad REC_ACTION parameter has been given
