*** Settings ***
Resource        ../../common_resources/ca_FM_general.robot

*** Variables ***
${RMOD_SN}                                                            # [OPTIONAL] RMOD module serial number.
${RF_FAULT}              1164                                         # RF fault that tiggeres RMOD faut.
${RECOVERY_TIMEOUT}      600                                          # Timeout for SBTS recovery after test.
${NETACT_TIMEOUT}        90                                           # Timeout for fault reporting in Netact.
${EXPECTED_ALARM_ID}     7115                                         # Tested alarm id that will be checked by test.
${EXPECTED_ALARM_NAME}   BASE STATION INFORMATION                     # Tested alarm name that will be checked by test.
${SEVERITY}              Minor                                        # Tested severity that will be checked by test.
${EXPECTED_FAULT_ID}     1933                                         # Tested fault id that will be checked by test.
${EXPECTED_FAULT_NAME}   Cooling fan broken                           # Tested fault name that will be checked by test.
${TOGGLING_FAULT_ID}     4026                                         # Tested fault id that will be checked by test in case of toggling.
${TOGGLING_FAULT_NAME}   Toggling: Cooling fan broken                 # Tested fault name that will be checked by test in case of toggling.
&{VALIDATE}              -validateBeforePreactivationForLTE=true      # Mandatory to be set on true. Netact parmeter, used for provisioning.

*** Keywords ***
TC__FM__Suppression_of_toggling_radio_alarm
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21645
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The scope of this test case is to check two radio toggling scenarios with fault 1933 cooling fan broken:
    ...  1) Toggling triggered after first alarm occurrence, then toggling cleared before alarm clearance,
    ...  2) Toggling triggered after two alarm occurrences, then alarm cleared before toggling is cleared.
    ...
    ...  History of changes
    ...  ******************
    ...  - 23.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21645 - Initial TAT creation
    ...  - 21.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22709 - Remove /home/ute/robotlte
    ...  - 27.10.2022 - https://jira3.ext.net.nokia.com/browse/TAT-23929 - Fix for multiple keywords
    ...  - 15.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24220 - Test fail since FXDB it is connected to ABIA Slave
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 12.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25370 - Remove BTS_L_ID
    ...  - 29.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25476 - Replace Login to User with Open connection to primary core
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  *******************

    Set Tags    CA-FM    OWNER-laura.craciunel@nokia.com    AUTHOR-laura.craciunel@nokia.com    MAINTAINER-laura.craciunel@nokia.com
    ...    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    SW-SBTS21

    Step0: Test Preparation
    Step1: Clear Toggling List
    Step2: Configure Alarm Toggling
    Step3: Toggling 1: Trigger Radio Alarm
    Step4: Toggling 1: Clear Radio Alarm
    Step5: Reconfigure Alarm Toggling
    Step6: No Toggling: Trigger Radio Alarm
    Step7: No Toggling: Clear Radio Alarm
    Step8: Toggling 2: Trigger and Clear Radio Alarm Again
    Step9: Final Recovery and Checkpoint

Step0: Test Preparation
    Log  Step0: Test Preparation.  console=true
    Log  Prepare testcase variables.  console=true
    ${enb_release}=  Fetch From Left  ${active SW version}  _
    Set Test Variable  ${ENB_RELEASE}  ${enb_release}
    Set Test Variable  ${PLMN}  PLMN-PLMN
    ${bts_id}=  Get ENB Id
    Set Test Variable  ${ENB_ID}  ${bts_id}
    Create Directory  ${BTSFiles}/results
    ${results_file}=  Set Variable  ${BTSFiles}/results
    Set Test Variable  ${RESULTS}  ${results_file}
    Log  Get path to test plans.  console=true
    Set Test Variable  ${TEST_DATA_FILES}  ${CURDIR}/test_plans/FM__Suppression_of_toggling_radio_alarm
    Log  Export configuration from Netact.  console=true
    Export Configuration  local_dir=${RESULTS}  file_name=${ENB_ID}_full_backup.xml  operation_type=actual
    Log  Prepare and import all plans from directory for test.  console=true
    Prepare and Import All Plans From Directory
    Log  Collect current SCF for backup purpose.   console=true
    coam.get_current_scf_file  local_dir_path=${BTS Files}  file_name=backup_scf.xml
    ${is_rmod_defined} =  Run Keyword And Return Status  Should Not Be Empty  ${RMOD_SN}
    ${TESTED_RMOD} =  Run Keyword If  ${is_rmod_defined}  Get Chosen RMOD Object  ELSE  Get Default RMOD Object
    Set Test Variable  ${TESTED_RMOD}
    Log  RMOD distName is: ${TESTED_RMOD.dist_name}.  console=true
    Log  RMOD IP is: ${TESTED_RMOD.ipAddress}.  console=true
    Set Test Variable  ${RMOD_IP}  ${TESTED_RMOD.ipAddress}
    ${smod_l}=  Query Infomodel  get object ${TESTED_RMOD.masterAgentDN}
    Run Keyword If  '${smod_l.ipAddress}'== '192.168.255.1'
    ...   Set Test Variable  ${SIDE}  1
    ...   ELSE
    ...   Set Test Variable  ${SIDE}  2

Step1: Clear Toggling List
    Log  Step1: Clear Toggling List.  console=true
    ${provision_status}=  Run Keyword And Return Status
    ...  netact.Provision Plan  plan_name=${ENB_ID}_plan_1
    ...                         dist_names=${MRBTS_DN}
    ...                         create_backup_plan=false
    ...                         provisioning_operation=activate
    ...                         parameters=${VALIDATE}
    Run Keyword If  ${provision_status}
    ...  Log  Plan was provisioned.  console=true
    ...  ELSE
    ...  Set test restriction  Plan provisioning failed.
    Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Check If Alarms From WebEM and NetAct Are The Same
    Admin Check Active Alarms TAF

Step2: Configure Alarm Toggling
    Log  Step2: Configure Alarm Toggling.  console=true
    ${provision_status}=  Run Keyword And Return Status
    ...  netact.Provision Plan  plan_name=${ENB_ID}_plan_2
    ...                         dist_names=${MRBTS_DN}
    ...                         create_backup_plan=false
    ...                         provisioning_operation=activate
    ...                         parameters=${VALIDATE}
    netact.Delete Plan  plan_name=${ENB_ID}_plan_2
    Run Keyword If  ${provision_status}
    ...  Log  Plan was provisioned.  console=true
    ...  ELSE
    ...  Fail  Plan provisioning failed.
    Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Check If Alarms From WebEM and NetAct Are The Same
    Admin Check Active Alarms TAF

Step3: Toggling 1: Trigger Radio Alarm
    Log  Step3: Toggling 1: Trigger Radio Alarm.  console=true
    Trigger Radio Fault  sendFault ${RF_FAULT} 0 0 0 0 0
    ${fault_4026}=  Run Keyword And Return Status  Assert Alarm Active
    ...  alarmId=7115, faultId=4026, alarmName="BASE STATION INFORMATION", faultName="Toggling: Cooling fan broken (1933)"
    ...  timeout=60
    Run Keyword If  ${fault_4026}
    ...  Log  Fault 4026 "Toggling: Cooling fan broken (1933)" is active [OK].  console=true
    ...  ELSE
    ...  Fail  msg=Fault 4026 "Toggling: Cooling fan broken (1933)" was not active [NOK].
    Sleep  ${NETACT_TIMEOUT}s
    ${check_fault_na}=  Run Keyword And Return Status
    ...  Check additional information for given alarm and fault  ${TOGGLING_FAULT_ID}
    ...                                                          ${TOGGLING_FAULT_NAME}
    ...                                                          ${EXPECTED_ALARM_ID}
    ...                                                          ${EXPECTED_ALARM_NAME}
    ...                                                          ${SEVERITY}
    Run Keyword If  ${check_fault_na}
    ...  Log  Given alarm and fault fields is active in NA [OK].  console=true
    ...  ELSE
    ...  FAIL  msg=Given alarm and fault fields is not active in NA [NOK].
    Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Check If Alarms From WebEM and NetAct Are The Same

Step4: Toggling 1: Clear Radio Alarm
    Log  Step4: Toggling 1: Clear Radio Alarm.  console=true
    Trigger Radio Fault  sendFault ${RF_FAULT} 0 0 1 0 0
    ${fault_4026}=  Run Keyword And Return Status  Assert Alarm Inactive
    ...  alarmId=7115, faultId=4026, alarmName="BASE STATION INFORMATION", faultName="Toggling: Cooling fan broken (1933)"
    ...  timeout=360
    Run Keyword If  ${fault_4026}
    ...  Log  Fault 4026 "Toggling: Cooling fan broken (1933)" was cancelled [OK].  console=true
    ...  ELSE
    ...  Fail  msg=Fault 4026 "Toggling: Cooling fan broken (1933)" is still active [NOK].
    Sleep  ${NETACT_TIMEOUT}s
    ${check_fault_na}=  Run Keyword And Return Status
    ...  Check additional information for given alarm and fault  ${TOGGLING_FAULT_ID}
    ...                                                          ${TOGGLING_FAULT_NAME}
    ...                                                          ${EXPECTED_ALARM_ID}
    ...                                                          ${EXPECTED_ALARM_NAME}
    ...                                                          ${SEVERITY}
    Run Keyword If  ${check_fault_na}
    ...  FAIL  msg=Given alarm and fault fields is active in NA [NOK].
    ...  ELSE
    ...  Log  Given alarm and fault fields is not active in NA [OK].  console=true
    Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Check If Alarms From WebEM and NetAct Are The Same
    Admin Check Active Alarms TAF

Step5: Reconfigure Alarm Toggling
    Log  Step5: Reconfigure Alarm Toggling.  console=true
    ${provision_status}=  Run Keyword And Return Status
    ...  netact.Provision Plan  plan_name=${ENB_ID}_plan_3
    ...                         dist_names=${MRBTS_DN}
    ...                         create_backup_plan=false
    ...                         provisioning_operation=activate
    ...                         parameters=${VALIDATE}
    netact.Delete Plan  plan_name=${ENB_ID}_plan_3
    Run Keyword If  ${provision_status}
    ...  Log  Plan was provisioned.  console=true
    ...  ELSE
    ...  Fail  Plan provisioning failed.
    Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Check If Alarms From WebEM and NetAct Are The Same
    Admin Check Active Alarms TAF

Step6: No Toggling: Trigger Radio Alarm
    Log  Step6: No Toggling: Trigger Radio Alarm.  console=true
    Trigger Radio Fault  sendFault ${RF_FAULT} 0 0 0 0 0
    ${fault_1933}=  Run Keyword And Return Status  Assert Alarm Active
    ...  alarmId=7115, faultId=1933, alarmName="BASE STATION INFORMATION", faultName="Cooling fan broken"
    ...  timeout=60
    Run Keyword If  ${fault_1933}
    ...  Log  Fault 1933 "Cooling fan broken" is active [OK].  console=true
    ...  ELSE
    ...  Fail  msg=Fault 1933 "Cooling fan broken" was not active [NOK].
    Sleep  ${NETACT_TIMEOUT}s
    ${check_fault_na}=  Run Keyword And Return Status
    ...  Check additional information for given alarm and fault  ${EXPECTED_FAULT_ID}
    ...                                                          ${EXPECTED_FAULT_NAME}
    ...                                                          ${EXPECTED_ALARM_ID}
    ...                                                          ${EXPECTED_ALARM_NAME}
    ...                                                          ${SEVERITY}
    Run Keyword If  ${check_fault_na}
    ...  Log  Given alarm and fault fields is active in NA [OK].  console=true
    ...  ELSE
    ...  FAIL  msg=Given alarm and fault fields is not active in NA [NOK].
    Check If Alarms From WebEM and NetAct Are The Same

Step7: No Toggling: Clear Radio Alarm
    Log  Step7: No Toggling: Clear Radio Alarm.  console=true
    Trigger Radio Fault  sendFault ${RF_FAULT} 0 0 1 0 0
    ${fault_1933_cancel}=  Run Keyword And Return Status  Assert Alarm Inactive
    ...  alarmId=7115, faultId=1933, alarmName="BASE STATION INFORMATION", faultName="Cooling fan broken"
    ...  timeout=360
    Run Keyword If  ${fault_1933_cancel}
    ...  Log  Fault 1933 "Cooling fan broken" was cancelled [OK].  console=true
    ...  ELSE
    ...  Fail  msg=Fault 1933 "Cooling fan broken" is still active [NOK].
    Sleep  ${NETACT_TIMEOUT}s
    ${check_fault_na}=  Run Keyword And Return Status
    ...  Check additional information for given alarm and fault  ${EXPECTED_FAULT_ID}
    ...                                                          ${EXPECTED_FAULT_NAME}
    ...                                                          ${EXPECTED_ALARM_ID}
    ...                                                          ${EXPECTED_ALARM_NAME}
    ...                                                          ${SEVERITY}
    Run Keyword If  ${check_fault_na}
    ...  FAIL  msg=Given alarm and fault fields is active in NA [NOK].
    ...  ELSE
    ...  Log  Given alarm and fault fields is not active in NA [OK].  console=true
    Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Check If Alarms From WebEM and NetAct Are The Same
    Admin Check Active Alarms TAF

Step8: Toggling 2: Trigger and Clear Radio Alarm Again
    Log  Step8: Toggling 2: Trigger and Clear Radio Alarm Again.  console=true
    Trigger Radio Fault  sendFault ${RF_FAULT} 0 0 0 0 0
    Sleep   10
    Trigger Radio Fault  sendFault ${RF_FAULT} 0 0 1 0 0
    Sleep   10
    Trigger Radio Fault  sendFault ${RF_FAULT} 0 0 0 0 0
    Sleep   10
    Trigger Radio Fault  sendFault ${RF_FAULT} 0 0 1 0 0
    Sleep   10
    Trigger Radio Fault  sendFault ${RF_FAULT} 0 0 0 0 0
    Sleep   10
    Trigger Radio Fault  sendFault ${RF_FAULT} 0 0 1 0 0
    ${fault_4026}=  Run Keyword And Return Status  Assert Alarm Active
    ...  alarmId=7115, faultId=4026, alarmName="BASE STATION INFORMATION", faultName="Toggling: Cooling fan broken (1933)"
    ...  timeout=60
    Run Keyword If  ${fault_4026}
    ...  Log  Fault 4026 "Toggling: Cooling fan broken (1933)" is active [OK].  console=true
    ...  ELSE
    ...  Fail  msg=Fault 4026 "Toggling: Cooling fan broken (1933)" was not active [NOK].
    Sleep  ${NETACT_TIMEOUT}s
    ${check_fault_na}=  Run Keyword And Return Status
    ...  Check additional information for given alarm and fault  ${TOGGLING_FAULT_ID}
    ...                                                          ${TOGGLING_FAULT_NAME}
    ...                                                          ${EXPECTED_ALARM_ID}
    ...                                                          ${EXPECTED_ALARM_NAME}
    ...                                                          ${SEVERITY}
    Run Keyword If  ${check_fault_na}
    ...  Log  Given alarm and fault fields is active in NA [OK].  console=true
    ...  ELSE
    ...  FAIL  msg=Given alarm and fault fields is not active in NA [NOK].
    Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Check If Alarms From WebEM and NetAct Are The Same
    ${fault_4026}=  Run Keyword And Return Status  Assert Alarm Inactive
    ...  alarmId=7115, faultId=4026, alarmName="BASE STATION INFORMATION", faultName="Toggling: Cooling fan broken (1933)"
    ...  timeout=360
    Run Keyword If  ${fault_4026}
    ...  Log  Fault 4026 "Toggling: Cooling fan broken (1933)" was cancelled [OK].  console=true
    ...  ELSE
    ...  Fail  msg=Fault 4026 "Toggling: Cooling fan broken (1933)" is still active [NOK].

Step9: Final Recovery and Checkpoint
    Log  Step9: Final Recovery and Checkpoint.  console=true
    ${status_provision}=  Run Keyword And Return Status
    ...  netact.Provision Plan  plan_name=${ENB_ID}_plan_1
    ...                         dist_names=${MRBTS_DN}
    ...                         create_backup_plan=false
    ...                         provisioning_operation=activate
    ...                         parameters=${VALIDATE}
    netact.Delete Plan  plan_name=${ENB_ID}_plan_1
    Run Keyword Unless  ${status_provision}  Run Keywords
    ...  Log  Plan provisioning from Netact failed. Recommissioning from WebEM will be performed.  console=true
    ...  AND
    ...  coam.Perform Commissioning   bts_id=${ENB_ID}  scf_file=${BTS Files}/backup_scf.xml  skip_parameter_relation_errors=true  timeout=300
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Check If Alarms From WebEM and NetAct Are The Same
    Admin Check Active Alarms TAF


Get Chosen RMOD Object
    [Documentation]  This KW was created to return tested RM by serial number given.
    ${rmod_r} =  Get Infomodel Object  //RMOD_R-* is [serialNumber=${RMOD_SN}]
    Set Test Variable  ${RMOD_R}  ${rmod_r}
    ${rmod_ref}=  Query Infomodel  get object ${RMOD_R.dist_name}/REF-*
    ${rmod}=  Query Infomodel  get object ${rmod_ref.distName}
    Log  Selected RMOD with serial number ${rmod.serialNumber} is: ${rmod.productName}.  console=true
    [Return]  ${rmod}

Get Default RMOD Object
    [Documentation]  This KW was created to randomly choose tested RM. 5.1 radio modules are filtered out as the is no testing method.
    Log  Serial number is not provided tested RM will be randomly choosen.  console=true
    ${filteredRMODs}=  create list
    ${rmod_r} =  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmod_r}
        run keyword if  '${rmod.l3Protocol}' != 'CPRI_RP1'
        ...  append to list  ${filteredRMODs}  ${rmod}
    END
    ${lenght}=  get length  ${filteredRMODs}
    Log  There are ${lenght} suitable RMs. One of them will be randomly choosen.  console=true
    ${selectedPositionOfRMinArray}=  evaluate  random.randint(0,${lenght}-1)   random
    ${selectedRMOD}=  get from list  ${filteredRMODs}  ${selectedPositionOfRMinArray}
    Log  Selected RMOD: ${selectedRMOD.productName} with serial number: ${selectedRMOD.serialNumber}.  console=true
    Set Test Variable  ${TESTED_RMOD_SN}  ${selectedRMOD.serialNumber}
    ${rmod_r} =  Get Infomodel Object  //RMOD_R-* is [serialNumber=${selectedRMOD.serialNumber}]
    Set Test Variable  ${RMOD_R}  ${rmod_r}
    ${rmod_ref}=  Query Infomodel  get object ${RMOD_R.dist_name}/REF-*
    ${rmod}=  Query Infomodel  get object ${rmod_ref.distName}
    [Return]  ${rmod}

Trigger Radio Fault
    [Documentation]  This keyword triggers FAN fault.
    [Arguments]  ${fault_command}
    Open connection to primary core
    Run Keyword If  '${SIDE}' == '2'
    ...  Open connection to secondary core
    SSHLibrary.Write  lxc-attach -n 0x${SIDE}018
    Sleep  2 sec
    SSHLibrary.Write  telnet ${RMOD_IP} 2323
    Sleep  10 sec
    SSHLibrary.Write  ${fault_command}
    Sleep  2 sec
    SSHLibrary.Write  exit
    Sleep  2 sec
    SSHLibrary.Write  exit

Reset RMOD to clear fault
    Log  Reset RMOD to clear fault due to unseen alarm.  console=true
    coam.Reset unit  ${RMOD_R.dist_name}  timeout=300
    Wait Until Keyword Succeeds  900s  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Check If Alarms From WebEM and NetAct Are The Same
    Admin Check Active Alarms TAF

TC Setup
    Common Test Setup
    Setup NetAct

TC Teardown
    Run Keyword If Test Failed  Run keywords  Step9: Final Recovery and Checkpoint  AND  Reset RMOD to clear fault
    Common Test Teardown
    Teardown NetAct
