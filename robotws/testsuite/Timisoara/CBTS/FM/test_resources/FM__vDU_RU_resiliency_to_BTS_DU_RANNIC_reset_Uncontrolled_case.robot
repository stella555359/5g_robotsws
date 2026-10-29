*** Settings ***
Documentation
...  This TC is created to reset RANNIC and to verify all RMODs uptime
...  First, actRuResetResiliency and uncntrldResetMplaneBreakTime values are set.
...  RMODs uptime are saved before trigger.
...  RANNIC reset is triggered with openshift command.
...  RMODs uptime are saved after trigger.
...  Uptimes are compared to be correct at the end of the test.

Resource  ../../common_resources/vdu_frame.robot
Resource  ../../common_resources/cbts_general.robot
Library   ../../common_resources/python_resources/snapshot_operations.py


*** Variables ***
${DC}  ${TRUE}  #Configuration type
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir
${ALARM_TIMEOUT}  300  # Alarm timeout [in seconds]


*** Keywords ***
TC__FM__vDU_RU_resiliency_to_BTS_DU_RANNIC_reset_Uncontrolled_case
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28692
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  03.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28692 - Initial TAT creation
    ...  15.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29023 - Enhancement for fault check
    ...  09.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29831 - Change method of connecting to RMOD and retrieving pod and container name
    ...  ******************

    Set Tags  CA-FM  OWNER-alina.cret@nokia.com  AUTHOR-anna.beke@nokia.com  GROUP_IN_CHARGE-NB I&V TIM4  FEATURE-CB010846  SW-25R2


    Step 0: TC Preconditions
    Step 1: Trigger RANNIC Reset On CBTS
    Step 2: Check Fault In RawAlarmHistory


Step 0: TC Preconditions
    Log  \nStep 0: TC Preconditions  console=true

    Set Alarms Dictionaries
    Log  Change actRuResetResiliency and uncntrldResetMplaneBreakTime if needed  console=true
    ${actRuResetResiliency_value}  VDU Get Parameter Value  actRuResetResiliency  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    IF  '${actRuResetResiliency_value}' != 'true'
        Change specific parameter for vDU  actRuResetResiliency  true  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    END
    ${uncntrldResetMplaneBreakTime_value}  VDU Get Parameter Value  uncntrldResetMplaneBreakTime  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    IF  '${uncntrldResetMplaneBreakTime_value}' != '420'
        Change specific parameter for vDU  uncntrldResetMplaneBreakTime  420  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    END

    ${rmods_list}  Create List
    ${rmods}  vdu.Get Rmods Status
    ${all_rmods_ips}  Get All RMODs IPs from vDU
    FOR  ${current_rmod}  IN  @{rmods}
         ${active_sw_build}  Split String  ${current_rmod}[active_sw_build]  .
         ${rmod_user}  ${rmod_password}  Get User And Password For RMOD  ${active_sw_build}[1]  ${current_rmod}[product_name]
         ${rmod_ip}  Get Ip For RMOD  ${current_rmod}[serial_number]  ${rmod_user}  ${rmod_password}  ${all_rmods_ips}  dc=${DC}
         Remove Values From List  ${all_rmods_ips}  ${rmod_ip}
         ${before_uptime}  Get RMOD Uptime  ${rmod_ip}  ${rmod_user}  ${rmod_password}  ${current_rmod}[serial_number]  ${DC}
         ${rmod_dictionary}  Create Dictionary   rmod_type=${current_rmod}[product_name]
         ...                                     serial_number=${current_rmod}[serial_number]
         ...                                     ip=${rmod_ip}
         ...                                     user=${rmod_user}
         ...                                     password=${rmod_password}
         ...                                     before_uptime=${before_uptime}
         Append To List  ${rmods_list}  ${rmod_dictionary}
    END
    Set Test Variable  ${RMODS_LIST}

    ${test_start_time}  Get Time from vDU POD
    Set Test Variable  ${TEST_START_TIME}


Step 1: Trigger RANNIC Reset On CBTS
    Log  \nStep 1: Trigger RANNIC Reset On CBTS.  console=true

    Log  Delete RANNIC pod and check alarms  console=true
    Open SSH Connection To VDU And Connect To Openshift
    ${pod}  Get Full Name For Pod  ${VDU_CRAN}  ahm
    SSHLibrary.Write  oc delete pod ${pod} -n cran1
    ${output}  SSHLibrary.Read Until Prompt
    Should Contain  ${output}  pod "${pod}" deleted  msg=Pod not deleted correctly. [NOK]
    SSHLibrary.Close Connection

    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  5
    ...  Check If Fault Is Visible In VDU WebEM  ${FAULT_4350}[alarm_id]
    ...                                          ${FAULT_4350}[alarm_name]
    ...                                          ${FAULT_4350}[fault_id]
    ...                                          ${FAULT_4350}[fault_name]
    ...                                          ${FAULT_4350}[severity]

    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  5
    ...  Check If Fault Is Visible In VDU WebEM  ${FAULT_4405}[alarm_id]
    ...                                          ${FAULT_4405}[alarm_name]
    ...                                          ${FAULT_4405}[fault_id]
    ...                                          ${FAULT_4405}[fault_name]
    ...                                          ${FAULT_4405}[severity]
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s  Verify RMODs Parameter From VDU  operational_state  ${ENABLED}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s  Verify RMODs Parameter From VDU  administrative_state  ${UNLOCKED}
    Log  RMOD successfully recovered.  console=true

    Log  Check RMODs uptime after reset.  console=true
    FOR  ${rmod}  IN  @{RMODS_LIST}
        ${after_uptime}  Get RMOD Uptime  ${rmod}[ip]  ${rmod}[user]  ${rmod}[password]  ${rmod}[serial_number]  ${DC}
        IF  '${after_uptime}' < '${rmod}[before_uptime]'
            Fail  Uptime not correct for RMOD with serial number: ${rmod}[serial_number]. [NOK]
        ELSE
            Log  Uptime correct for RMOD with serial number: ${rmod}[serial_number]. [OK]  console=true
            Set To Dictionary  ${rmod}  after_uptime=${after_uptime}
        END
    END
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells From VDU  availability_status=${ONLINE}  operational_state=${ENABLED}

    [Teardown]  SSHLibrary.Close All Connections


Step 2: Check Fault In RawAlarmHistory
    Log  Step 2: Check Fault In RawAlarmHistory  console=true

    ${snapshot_path}  Collect VDU Snapshot
    ${files}  OperatingSystem.List Files In Directory  ${snapshot_path}
    ${extracted}  Extract Snapshot Content  ${snapshot_path}/${files}[0]  fm_fault_history
    Log  ${extracted}  console=true
    ${date}  ${time}  Split string  ${TEST_START_TIME}    T
    ${raw_alarm_file_path}  Catenate  SEPARATOR=/  ${extracted}  rawFaultHistory  rawFaultHistory
    ${raw_alarm_history}  OperatingSystem.Get File  ${raw_alarm_file_path}
    Verify Fault In RawFaultHistory File    ${raw_alarm_history}    4801   Radio Mplane Connection Established  ${date}  ${time}


Set Alarms Dictionaries
    ${FAULT_4350}  Create Dictionary  fault_id=4350
    ...                               fault_name=VNFC autonomous reset as recovery action
    ...                               alarm_id=7101
    ...                               alarm_name=BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION  severity=regex"Warning|warning"
    ${FAULT_4405}  Create Dictionary  fault_id=4405
    ...                               fault_name=No usable time reference available
    ...                               alarm_id=7115
    ...                               alarm_name=BASE STATION INFORMATION  severity=regex"Minor|minor"
    Set Test Variable  ${FAULT_4350}
    Set Test Variable  ${FAULT_4405}


Get RMOD uptime
    [Arguments]  ${rmod_ip}  ${rmod_user}  ${rmod_password}  ${rmod_sn}  ${dc}

    Open SSH Connection To Specific RMOD  ${rmod_ip}  ${rmod_user}  ${rmod_password}  ${rmod_sn}  dc=${DC}
    SSHLibrary.Write  uptime
    ${uptime_output}  SSHLibrary.Read Until Prompt
    ${uptime}  Get Regexp Matches  ${uptime_output}  [0-9]{2}:[0-9]{2}:[0-9]{2}
    Should Not Be Empty  ${uptime}  Coudn't retrieve uptime on RMOD with ip: ${rmod_ip} and serial number: ${rmod_sn}. [NOK]

    RETURN  ${uptime}[0]
    [Teardown]  SSHLibrary.Close Connection


TC Setup
    Common VDU Setup
    Modify Resource Search Order  FM__vDU_RU_resiliency_to_BTS_DU_RANNIC_reset_Uncontrolled_case


TC Teardown
    Common VDU Teardown
