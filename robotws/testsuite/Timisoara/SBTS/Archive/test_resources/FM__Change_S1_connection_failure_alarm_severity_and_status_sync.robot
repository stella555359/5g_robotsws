*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
${LNMME_IP_0}         10.55.192.6
${LNMME_IP_1}         10.37.3.18

*** Keywords ***
TC__FM__Change_S1_connection_failure_alarm_severity_and_status_sync
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-21648
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   Test checks alarm synchronization between BTS and Netact.
    ...   Few delta's with corect and incorrect MME's IP are provisioned to see if
    ...   alarms appear, disappear, change its severity both on admin and NA.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  -  24.09.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21648 - TAT to adapt the test from docker to HRAN_TA
    ...  -  01.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22577 - ta_netact_* libary replacement with taf.nms.netact
    ...  -  07.06.2022 - https://jira3.ext.net.nokia.com/browse/TAT-23166 - MME IP fix
    ...  -  29.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24118 - Test fail since it use predefined MRBTS id and not LNBTS id
    ...  -  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  -  12.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25224 - Test fails at KW Check Netact alarm severity
    ...  -  25.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25417 - Use Admin Get MRBTS ID and Admin Get LNBTS ID from sbts_admin
    ...  -  18.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26003 - Test fail due MME harcoded IPs
    ...  -  06.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26772 - Option to disable alarm check on MantaRay
    ...  ******************

    Set Tags    CA-FM    OWNER-lucian.ciurel@nokia.com    AUTHOR-valentin.suru@nokia.com   MAINTAINER-valentin.suru@nokia.com
    ...    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    SW-SBTS20

    Step1: Check SBTS state
    Step2: Provision cleaning scf and activate S1flex
    Step3: Provision scf with LNMME-0 and LNMME-1
    Step4: Change IP address for LNMME-1 for dummy and check alarms
    Step5: Change IP address for LNMME-0 for dummy and check alarms
    Step6: Provision scf with correct IP addres for LNMME-0
    Step7: Provision scf with correct IP addres for LNMME-1
    Step8: Final Recovery and Checkpoint

Step1: Check SBTS state
    [Documentation]  Compare WebEM and Netact alarms
    Log To Console    Step1: Check SBTS state
    Compare alarms in Netact and WebEM

Step2: Provision cleaning scf and activate S1flex
    [Documentation]  Acts1flex=true provision. Remove all MME's except LN-MME-0. See test requirenments.
    Log To Console    Step2: Provision cleaning plan and activate S1flex
    ${MRBTS}  Admin Get BTS ID
    ${LNBTS}  Admin Get LNBTS ID
    Set test variable  ${MRBTS}
    Set test variable  ${LNBTS}
    Log  MRBTS ID is: ${MRBTS}; LNBTS ID is: ${LNBTS}  console=${TRUE}
    Get current scf file  ${BTS Files}  ${MRBTS}_backup.xml
    Apply cleaning scf and activate S1flex
    Check SBTS
    Log To Console    All MME's except LN-MME-0 should be removed    console=true

Step3: Provision scf with LNMME-0 and LNMME-1
    [Documentation]  Send plan with LNMME-0 and LNMME-1. S1 link should be available from both MME's.
    Log To Console    Step3: Provision Plan with LNMME-0 and LNMME-1
    Apply scf with LNMME-0 and LNMME-1
    Check SBTS

Step4: Change IP address for LNMME-1 for dummy and check alarms
    [Documentation]  Send plan with dummy IP addres for LNMME-1.
    ...              Fault 6202 shoul be visible with severity=major both on netact and admin
    Log To Console    Step4: Change IP address for LNMME-1 for dummy and check alarms
    Change LNMME IP address    LNMME-1    5.10.15.5
    Wait Until Keyword Succeeds  10min  5s  Assert Alarm Active    faultId=6202, severity=Major, destinationIPAddr=5.10.15.5    timeout=120
    Log To Console    Fault 6202 with major severity is active for LNMME-1 [OK]
    Check Alarm in Netact   flag=True  fault_id=6202  destIP_address=5.10.15.5  severity=Major
    Compare alarms in Netact and WebEM

Step5: Change IP address for LNMME-0 for dummy and check alarms
    [Documentation]  Send plan with dummy IP addres for LNMME-0.
    ...              Fault 6202 should be visible with severity=Critical for LNMME-1 (changed form major)
    ...              and with severity=Major for LNMME-0 both on netact and admin
    Log To Console    Step5: Change IP address for LNMME-0 for dummy and check alarms
    Change LNMME IP address    LNMME-0    6.6.6.6
    Wait Until Keyword Succeeds  10min  5s  Assert Alarm Active    faultId=6202, severity=Critical, destinationIPAddr=5.10.15.5    timeout=120
    Log To Console    Fault 6202 with critical severity is active for LNMME-1 [OK]
    Wait Until Keyword Succeeds  10min  5s  Assert Alarm Active    faultId=6202, severity=Major, destinationIPAddr=6.6.6.6    timeout=120
    Log To Console    Fault 6202 with major severity is active for LNMME-0 [OK]
    Check Alarm in Netact   flag=True  fault_id=6202  destIP_address=5.10.15.5  severity=Critical
    Check Alarm in Netact   flag=True  fault_id=6202  destIP_address=6.6.6.6  severity=Major
    Compare alarms in Netact and WebEM

Step6: Provision scf with correct IP addres for LNMME-0
    [Documentation]  Provision scf with correct IP addres for LNMME-0.
    ...              Fault 6202 should be cleared for LNMME-0 both on Netact and admin
    ...              Fault 6202 shuld change severity to Major for LNMME-1
    Log To Console    Step6: Provision scf with correct IP addres for LNMME-0
    Change LNMME IP address    LNMME-0    ${LNMME_IP_0}
    Wait Until Keyword Succeeds  10min  5s  Assert Alarm Active    faultId=6202, severity=Major, destinationIPAddr=5.10.15.5    timeout=120
    Check Alarm in Netact   flag=True  fault_id=6202  destIP_address=5.10.15.5  severity=Major
    ${status}=   Run Keyword And Return Status   Assert Alarm Active  faultId=6202, destinationIPAddr=6.6.6.6    timeout=60
    Should be true  '${status}' == 'False'
    Check Alarm in Netact   flag=False  fault_id=6202  destIP_address=6.6.6.6  severity=Major
    Log To Console    Fault 6202 with major severity is active for LNMME-1 and cleared for LNMME-0 [OK]
    Compare alarms in Netact and WebEM

Step7: Provision scf with correct IP addres for LNMME-1
    [Documentation]  Provision scf with correct IP addres for LNMME-1. S1 link should be available from both MME's
    Log To Console    Step7: Provision scf with correct IP addres for LNMME-1
    Change LNMME IP address    LNMME-1    ${LNMME_IP_1}
    Wait Until Keyword Succeeds  10min  30s
    ...  Assert Alarm Inactive  faultId=6202, alarmId=7107, faultName="Transport layer connection failure in S1 interface"  timeout=180
    Wait Until Keyword Succeeds  10min  30s    Check Netact Inactive Alarm    faultId=6202
    Check SBTS

Step8: Final Recovery and Checkpoint
    [Documentation]  Provision backup scf file and check SBTS
    Log To Console    Step8: Final Recovery and Checkpoint
    Recommissioning with backup scf


Check SBTS
    ${status}  Run keyword and return status
    ...  Wait Until Keyword Succeeds  5x  1min  Check All Cells    ${OnAirDone_}    ${Enabled_}    ${Active_}
    Run keyword if  ${status}
    ...  Log  All cells are onAir [OK].  console=true
    ...  ELSE
    ...  Set test failed  All cells are not onAir [NOK].

    Check if unexpected alarms are present
    Compare alarms in Netact and WebEM

Check if unexpected alarms are present
    ${fault_list}  Create list
    ${active_alarms}  coam.Get active alarms
    FOR  ${alarm}  IN  @{active_alarms}
        ${faultId}  Convert to string  ${alarm}[faultId]
        ${fault_dict}  Create dictionary  faultId=${faultId}  faultName=${alarm}[faultName]
        Append to list  ${fault_list}  ${fault_dict}
    END
    FOR  ${fault}  IN  @{fault_list}
        Check if active fault is present in ignored alarm list  ${GLOBALLY_IGNORED_ALARMS}  ${fault}
    END

Check if active fault is present in ignored alarm list
    [Arguments]   ${alarms_list}  ${fault}
    FOR  ${alarm}  IN  @{alarms_list}
        ${fault_id_status}  Run keyword and return status  Should be equal as strings  ${fault}[faultId]  ${alarm}[faultId]
        ${fault_name_status}  Run keyword and return status  Should contain  ${fault}[faultName]  ${alarm}[faultName]
        Run keyword if  ${fault_id_status} and ${fault_name_status}
        ...  Return from keyword
    END
    Set test restriction  Unexpected fault: ${fault}[faultId], ${fault}[faultName].

Compare alarms in Netact and WebEM
    Run keyword if    ${NE3SADAPT}
    ...  Wait Until Keyword Succeeds  10x  30s  Check If Alarms From WebEM and NetAct Are The Same
    ...  ELSE
    ...  Log  SBTS is not connected to NetAct and alarm comparison with WebEM is not possible.  console=true

Check Netact Inactive Alarm
    [Arguments]  ${faultId}
    Run Keyword If    '${DISABLE_NETACT_CHECK}' == 'True'
    ...    Run Keywords
    ...    Log  Netact check is disabled, check will be skipped.  console=true
    ...    AND
    ...    Return From Keyword
    ${faultId_int}    Convert To Integer  ${faultId}
    ${netact_alarms}  netact.get_alarms  dist_name=${MRBTS_DN}
    ${netact_alarms_ids}  Get ids from netact alarms  ${netact_alarms}
    List Should Not Contain Value	 ${netact_alarms_ids}  ${faultId_int}

Apply cleaning scf and activate S1flex
    ${lnmme_list}    Get Parameters For All    LNMME
    ${lnmme_str}=    Convert to string    ${lnmme_list}
    ${delta_id}  Set variable  1
    Create Delta  ${delta_id}
    Append Managed Object To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}  update  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}  actS1Flex  enabled  ${delta_id}
    FOR  ${id}  IN RANGE  1  5
      ${match_status}    Run keyword and return status    Should contain    ${lnmme_str}    LNMME_R-${id}
      Run Keyword If  ${match_status}
    ...  Append Managed Object To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/LNMME-${id}  delete  ${delta_id}
    END
    Get Delta  ${delta_id}
    Save Delta  ${BTS Files}/delta.json  delta_id=${delta_id}
    Log  Performing delta recommissioning with cleaning plan and S1flex enabled ...  console=${TRUE}
    Perform Delta Recommissioning  ${BTS Files}/delta.json  skip_parameter_relation_errors=True
    Remove delta  ${delta_id}
    Remove File  ${BTS Files}/delta.json

Apply scf with LNMME-0 and LNMME-1
    ${delta_id}  Set variable  1
    Create Delta  ${delta_id}
    Append Managed Object To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/LNMME-0  update  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/LNMME-0  ipAddrPrim  ${LNMME_IP_0}  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/LNMME-0  transportNwId  0  ${delta_id}
    Append Managed Object To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/LNMME-1  create  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/LNMME-1  administrativeState  unlocked  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/LNMME-1  ipAddrPrim  ${LNMME_IP_1}  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/LNMME-1  mmeRatSupport  Wideband-LTE  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/LNMME-1  transportNwId  0  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS Files}/delta.json  delta_id=${delta_id}
    Log  Performing delta recommissioning with LNMME-0 and LNMME-1 ...  console=${TRUE}
    Perform Delta Recommissioning  ${BTS Files}/delta.json  skip_parameter_relation_errors=True
    Remove delta  ${delta_id}
    Remove File  ${BTS Files}/delta.json

Change LNMME IP address
    [Arguments]  ${lnmme}  ${ip_address}
    ${delta_id}  Set variable  1
    Create Delta  ${delta_id}
    Append Managed Object To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/${lnmme}  update  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${MRBTS}/LNBTS-${LNBTS}/${lnmme}  ipAddrPrim  ${ip_address}  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS Files}/delta.json    delta_id=${delta_id}
    Log  Performing delta recommissioning: set IpAddress ${ip_address} for ${lnmme}...  console=${TRUE}
    Perform Delta Recommissioning  ${BTS Files}/delta.json  skip_parameter_relation_errors=True
    Remove delta  ${delta_id}
    Remove File  ${BTS Files}/delta.json

Check Alarm in Netact
    [Arguments]  ${flag}  ${fault_id}  ${destIP_address}  ${severity}
    Run keyword if    ${NE3SADAPT}
    ...  Wait Until Keyword Succeeds  5min  30s  Check Netact alarm severity    ${flag}    ${fault_id}    ${destIP_address}    ${severity}
    ...  ELSE
    ...  Log  SBTS is not connected to NetAct and alarm severity check is not possible.  console=true

Check Netact alarm severity
    [Arguments]     ${flag}  ${fault_id}  ${destIP_address}  ${severity}
    Run Keyword If    '${DISABLE_NETACT_CHECK}' == 'True'
    ...    Run Keywords
    ...    Log  Netact check is disabled, check will be skipped.  console=true
    ...    AND
    ...    Return From Keyword
    ${netact_alarms}  netact.get_alarms  dist_name=${MRBTS_DN}
    FOR  ${na_alarm}  IN  @{netact_alarms}
         ${additional_text3}     Get From Dictionary    ${na_alarm}    additionalText3
         ${check_fault_id}   Run Keyword And Return Status    Should Contain   ${additional_text3}    ${fault_id}
         ${check_destIP_address}   Run Keyword And Return Status    Should Contain   ${additional_text3}    dstIPAddr=${destIP_address}
         ${alarm_severity}     Get From Dictionary    ${na_alarm}    perceivedSeverity
         ${check_alarm_severity}   Run Keyword And Return Status    Should Be Equal As Strings   ${alarm_severity}    ${severity}    ignore_case=True
         ${match}=  Set Variable If  '${check_fault_id}'=='True' and '${check_destIP_address}'=='True' and '${check_alarm_severity}'=='True'
         ...  True
         ...  False
         Exit For Loop If    ${match} == True
    END
    Run keyword if    ${flag}
    ...  Should Be Equal As Strings    ${match}    True
    ...  ELSE
    ...  Should Be Equal As Strings    ${match}    False

Recommissioning with backup scf
    Log  Performing commissioning with backup scf ...  console=${TRUE}
    Perform Commissioning    bts_id=${MRBTS}
    ...                      scf_file=${BTS Files}/${MRBTS}_backup.xml
    ...                      skip_parameter_relation_errors=True
    ...                      should_activate=True
    ...                      timeout=600
    Wait Until Keyword Succeeds  5x   1min    Check SBTS
    Remove File  ${BTS Files}/${MRBTS}_backup.xml

TC Setup
    Common Test Setup
    ${NE3SADAPT}  query infomodel  check //NE3SADAPT-*  allow_negative_result=True
    Set Test Variable  ${NE3SADAPT}
    Run Keyword If  ${NE3SADAPT}
    ...  Setup NetAct

TC Teardown
    Run keyword if test failed
    ...  Recommissioning with backup scf
    Run Keyword If  ${NE3SADAPT}
    ...  Teardown NetAct
    Common Test Teardown
