*** Settings ***
Resource        ../../common_resources/ca_FM_general.robot

*** Variables ***
${RMOD_SN}                           EA173437460                           #Mandatory, FRGY RMOD module serial number
${ALLOCATION_TIME_FOR_ABNORMAL}      600000                                #in milisecond  600000 = 10min
${ALLOCATION_TIME_FOR_CRITICAL}      300000                                #in milisecond  300000 = 5min
@{EXIT_STRINGS}                      Sleeping for ${ALLOCATION_TIME_FOR_ABNORMAL} ms.    Sleeping for ${ALLOCATION_TIME_FOR_CRITICAL} ms.
${RECOVERY_TIMEOUT}                  300s
${ALARM_APPEARANCE_TIMEOUT}          300s
${PROMPT_APPEARANCE_TIMEOUT}         300s

*** Keywords ***
TC__FM__Radio_memory_abnormal_and_critical_threshold_via_NA
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21652
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This TC is created to perform parameter recommissioning with the given value, check memory level and check alarms.
    ...  First, SBTS is checked and should be OnAir, alarms on WebEM and Netact should be the same and on the given RMOD are opened 2 connections.
    ...  In Step2, OMP file name on RMOD is obtained, criticalthreshold and varianthreshold are,
    ...  also, obtained from there and parameter recommissioning is performed.
    ...  In Step3, the memory level is check.
    ...  Also, are evaluated the following values: half_memory_of_critical, memory_for_allocation_for_abnormal_threshold,
    ...  memory_for_allocation_for_critical_threshold
    ...  and difference (memory_for_allocation_for_critical_threshold - memory_for_allocation_for_abnormal_threshold)
    ...  Also, exceeding Critical level will generate alarm specifying that memory consumption has exceeded Critical level.
    ...  If the level of memory compsumpion decrease below Critical threshold then alarm for Abnormal threshold should rise.
    ...  In Step4, alarm 7116 with fault 4330 Critical threshold is checked to be displayed on WebEM and Netact.
    ...  In Step5, alarm 7115 with fault 4329 Abnormal threshold is checked to be displayed on WebEM and Netact.
    ...  In Step6, is performed paramater recommissioning with the inital value, alarms are checked and should be cleared, SBTS should also be OnAir.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 23.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21652 - Initial TAT creation
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters

    Set Tags    CA-FM    OWNER-lucian.ciurel@nokia.com    AUTHOR-cosmina.rebenciuc@nokia.com
    ...    MAINTAINER-cosmina.rebenciuc@nokia.com    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    SW-SBTS00

    Step0: Get requiered values and open connections
    Step1: Checks status before test
    Step2: Test preparation and performing parameter recommissioning
    Step3: Check actual level free memory and start trigger Critical Threshold
    Step4: Critical threshold alarm check
    Step5: Abnormal threshold alarm check
    Step6: Final Recovery and Checkpoint

Step0: Get requiered values and open connections
    Log  Step0: Get requiered values and open connections  console=true
    Radio Module Setup
    ${bts_id}=  Admin Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}

Radio Module Setup
    ${rmod_object}=  Run Keyword If  '${RMOD_SN}' != ''  Get radio module object by serial number  ${RMOD_SN}
    ...  ELSE
    ...  Fail  msg=RMOD SN is not given. [NOK]
    ${rmod}=  Set variable  ${rmod_object}
    Log To Console  \n Selected Radio is: RMOD_A-${selected_rmod}  console=True
    Log To Console  \n Selected RMOD_L is: ${rmod}
    Set Test Variable  ${RMOD_IP}  ${rmod.ipAddress}
    ${rmod_1_module_name}    Get From Dictionary    ${rmod}    productName
    Set Test Variable  ${RMOD_1_MODULE_NAME}  ${rmod_1_module_name}
    SSHLibrary.Close All Connections
    Open connection to RMOD  first_connection
    Open connection to RMOD  second_connection

Open connection to RMOD
    [Arguments]  ${connection}
    Log  Open ${connection} to RMOD  console=true
    SSHLibrary.Open connection  192.168.255.129  alias=${connection}  prompt=>
    SSHLibrary.Login  toor4nsn  oZPS0POrRieRtu
    ${output}=  SSHLibrary.Execute Command  lxc-ls --active
    @{node_list}=  Split To Lines  ${output}
    FOR  ${node}  IN  @{node_list}
      Execute ssh command  lxc-attach -n ${node}
      ${output}=  Execute ssh command  arp -an ${RMOD_IP} | grep -v incomplete
      ${status}=  Run keyword and return status  Should contain  ${output}  ? (${RMOD_IP})
      Run keyword If  ${status}
      ...  Run keywords  Execute ssh command  telnet ${RMOD_IP} 2323  AND  Exit for loop
      ...  ELSE
      ...  Execute ssh command  exit
    END
    Log  ${connection} to RMOD was opened.  console=true

Execute ssh command
    [Arguments]  ${command}
    SSHLibrary.Write  ${command}
    ${output}=  SSHLibrary.Read until prompt
    [Return]  ${output}

Get radio module object by serial number
    [Arguments]  ${RMOD_serial_number}
    ${rmod_r_obj}=  Query Infomodel  get object //RMOD_R-* is [serialNumber=${RMOD_serial_number}]
    ${rmod_r_scf}=  Query Infomodel  get object ${rmod_r_obj.dist_name}/CONF_REF-1
    ${rmod_r_scf}=  Query Infomodel  get object ${rmod_r_scf.distName}
    ${selected_rmod}=  Fetch From Right  ${rmod_r_scf.dist_name}  RMOD_A-
    Set Test Variable  ${SELECTED_RMOD}  ${selected_rmod}
    ${ref_obj}=  Query Infomodel  get object ${rmod_r_obj.dist_name}/REF-*
    ${rmod_l_obj}=  Query Infomodel  get object ${ref_obj.distName}
    [Return]  ${rmod_l_obj}

Step1: Checks status before test
    Log  Step1: Checks status before test  console=true
    Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Check If Alarms From WebEM and NetAct Are The Same

Step2: Test preparation and performing parameter recommissioning
    Log  Step2: Test preparation and performing parameter recommissioning  console=true
    Active OMP verification
    Get CriticalThreshold and variantSpecificModifier
    Perform Parameter Recommissioning  MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${SELECTED_RMOD}  radioMemAbnormalThreshold  update  0

    ${fault_4330}  Catenate  SEPARATOR=${SPACE}  faultId=4330,
    ...                                          faultName="Radio memory consumption exceeds critical threshold"
    ${fault_4329}  Catenate  SEPARATOR=${SPACE}  faultId=4329,
    ...                                          faultName="Radio memory consumption exceeds abnormal threshold"
    Set Test Variable  ${FAULT_4330}
    Set Test Variable  ${FAULT_4329}

Active OMP verification
    [Documentation]  This KW is created to get the OMP file name from RMOD.
    SSHLibrary.Switch connection  first_connection
    ${output}=  Execute ssh command  flash -a
    ${output1}=  Get Lines Containing String  ${output}  ACTIVE FILE LIST in flash database
    ${active_OMP_file_name}    Get Regexp Matches    ${output1}  OMP\\d
    ${number OMP}    Get length    ${active_OMP_file_name}
    Should Be Equal As Integers    1    ${number OMP}
    ${active_OMP_file_name}    Get From List    ${active_OMP_file_name}    0
    Set Test Variable    ${ACTIVE_OMP_FILE_NAME}  ${active_OMP_file_name}

Get CriticalThreshold and VariantSpecificModifier
    [Documentation]  This KW is created to get criticalThreshold and variantSpecificModifier from the OMP file.
    ${output}=  Execute ssh command    flash -f ${ACTIVE_OMP_FILE_NAME} ${ACTIVE_OMP_FILE_NAME}_tmp
    ${write_command}=  SShLibrary.Write  cat /ram/${ACTIVE_OMP_FILE_NAME}_tmp
    Sleep  60s  Waiting for output to be displayed.
    ${file}=  SShLibrary.Read
    ${file_content}=  Remove String  ${file}  rtose@gaia>
    ${element_structure}    Parse XML    ${file_content}
    ${HW}=  Get Element  ${element_structure}  .//HW
    ${modules}=  Get Elements  ${HW}  .//module
    FOR  ${module}  IN  @{modules}
      ${name}=  Get Element Attribute  ${module}  name
      Run Keyword If  '${name}'=='${RMOD_1_MODULE_NAME}'
      ...  Run keywords  Get element attribute for the given module  ${module}  AND  exit for loop
      ...  ELSE
      ...  Continue for loop
    END
    ${commonFor}=  Get Element  ${HW}  .//commonFor
    ${generation}=  Get Elements  ${commonFor}  .//generation
    FOR  ${item}  IN  @{generation}
      ${base_Name}=  Get Element Attribute  ${item}  baseName
      Run keyword If  '${base_Name}'=='${BASE_NAME_FIRST}'
      ...  Run keywords  Get criticalThreshold and variantSpecificModifier values from given path  ${item}  AND  Exit for loop
      ...  ELSE
      ...  Continue for loop
    END
    Execute ssh command   rm /ram/${ACTIVE_OMP_FILE_NAME}_tmp

Get element attribute for the given module
    [Arguments]  ${module_name}
    ${base_name}=  Get Element Attribute  ${module_name}  baseName
    Set Test Variable  ${BASE_NAME_FIRST}  ${base_name}

Get criticalThreshold and variantSpecificModifier values from given path
    [Arguments]  ${generation_item}
    ${healthMonitoring}=  Get Element  ${generation_item}  .//healthMonitoring
    ${criticalThreshold}=  Get Element Attribute  ${healthMonitoring}  criticalThreshold
    ${variantSpecificModifier}=  Get Element Attribute  ${healthMonitoring}  variantSpecificModifier
    Set Test Variable    ${CRITICAL_THRESHOLD}  ${criticalThreshold}
    Set Test Variable    ${VARIANT_SPECIFIC_MODIFIER}  ${variantSpecificModifier}

Step3: Check actual level free memory and start trigger Critical Threshold
    [Documentation]  This KW is created to check actual level of memory.
    ...  Evaluates half_memory_of_critical, memory_for_allocation_for_abnormal_threshold, memory_for_allocation_for_critical_threshold
    ...  difference (memory_for_allocation_for_critical_threshold - memory_for_allocation_for_abnormal_threshold)
    Log  Step3: Check actual level free memory and start trigger Critical Threshold  console=True
    ${system_stat_output}=  Execute ssh command  sysmon get_system_stat
    ${used_mem_percent_before_test}  Get Regexp Matches  ${system_stat_output}  Used${SPACE}memory${SPACE}\\(percent\\):${SPACE}(?P<value>\\d+)  value
    ${used_mem_percent_before_test}  Convert to integer  ${used_mem_percent_before_test[0]}
    Set Test Variable  ${USER_MEMORY_PERCENT_BEFORE_TEST}  ${used_mem_percent_before_test}
    ${memory_for_allocation_for_critical_threshold}    Count memory for allocation    ${CRITICAL_THRESHOLD}
    ...                                                                               ${VARIANT_SPECIFIC_MODIFIER}
    ...                                                                               ${system_stat_output}
    ...                                                                               100
    #percent, 0-abnormal threshold level , 100-critical threshold level
    ${memory_for_allocation_for_abnormal_threshold}    Count memory for allocation    ${CRITICAL_THRESHOLD}
    ...                                                                               ${VARIANT_SPECIFIC_MODIFIER}
    ...                                                                               ${system_stat_output}
    ...                                                                               0
    #percent, 0-abnormal threshold level , 100-critical threshold level
    ${half_memory_of_critical}    Evaluate    int(${memory_for_allocation_for_critical_threshold}/2)
    ${memory_for_allocation_for_abnormal_threshold}    run keyword if    ${half_memory_of_critical} > ${memory_for_allocation_for_abnormal_threshold}
    ...  Evaluate    int(${memory_for_allocation_for_critical_threshold}-${half_memory_of_critical}+${memory_for_allocation_for_abnormal_threshold})
    ${diff_abnormal_critical}    Evaluate    int(${memory_for_allocation_for_critical_threshold}-${memory_for_allocation_for_abnormal_threshold})
    ${start_time}    Get Current Date    time_zone=local    result_format=%H:%M:%S    increment=02:00:00
    ${output}=  SShLibrary.Write  sysmon allocate ${memory_for_allocation_for_abnormal_threshold} 0 ${ALLOCATION_TIME_FOR_ABNORMAL} 0
    ${out}=  SShLibrary.Read Until  ${EXIT_STRINGS}[0]
    Sleep    5s
    SSHLibrary.Switch connection  second_connection
    ${output}=  SShLibrary.Write  sysmon allocate ${diff_abnormal_critical} 0 ${ALLOCATION_TIME_FOR_CRITICAL} 0
    ${out}=  SShLibrary.Read Until  ${EXIT_STRINGS}[1]

Count memory for allocation
    [Documentation]    This Kw counts memory value for allocation where anomalusThreshold is the level of threshold.
    [Arguments]    ${CRITICAL_THRESHOLD}    ${VARIANT_SPECIFIC_MODIFIER}    ${sysmon_output}   ${anomalousThreshold}
    ${total_memory_value}    Get Regexp Matches   ${sysmon_output}    Total${SPACE}memory:${SPACE}(?P<value>\\d+)    value
    ${total_memory_value}    Convert to integer    ${total_memory_value[0]}
    ${used_memory_value}    Get Regexp Matches    ${sysmon_output}    Used${SPACE}memory:${SPACE}(?P<value>\\d+)    value
    ${used_memory_value}    Convert to integer    ${used_memory_value[0]}
    ${lower_bound_mem_threshold}    Evaluate    int(${total_memory_value}*${VARIANT_SPECIFIC_MODIFIER}/100)    #abnormal threshold of memory
    ${uper_bound_mem_threshold}    Evaluate    int(${total_memory_value}*${CRITICAL_THRESHOLD}/100)           #critical threshold of memory
    ${physical_value_of_anomalusThreshold}    Evaluate
    ...  int((${uper_bound_mem_threshold}-${lower_bound_mem_threshold}) * ${anomalousThreshold}/${100} + ${lower_bound_mem_threshold})
    # (upper bound – lower bound) x threshold% + lower bound
    ${memory_for_allocation}    Evaluate    int(${physical_value_of_anomalusThreshold}-${used_memory_value})
    [Return]    ${memory_for_allocation}

Step4: Critical threshold alarm check
    [Documentation]  This KW is created to check the appearance of alarm 7116 with fault 4330 Critical threshold on WebEM and Netact.
    ...  Also, waits for the prompt to be dispayed after the sysmon allocate command is finished on the second_connection on RMOD.
    Log  Step4: Critical threshold alarm check  console=true
    Log  Checking if alarm 7116 with fault 4330 Critical threshold is displayed  console=True
    ${fault_4330_status}=  run keyword and return status  Assert Alarm Active  parameters=${FAULT_4330}  timeout=300
    Run Keyword if  ${fault_4330_status}
    ...  Log  Fault 4330 with alarm "7116 Radio memory consumption exceeds critical threshold" occured [OK]  console=true
    ...  ELSE
    ...  Set Test Failed  Fault 4330 with alarm "7116 Radio memory consumption exceeds critical threshold didn't occur [NOK]
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  15s  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    ${check_fault_4330}=  Run keyword and Return Status  Wait Until Keyword Succeeds  ${ALARM_APPEARANCE_TIMEOUT}  15s
    ...  Check additional information for given alarm and fault  4330
    ...                                                          Radio memory consumption exceeds critical threshold
    ...                                                          7116
    ...                                                          BASE STATION SERVICE PROBLEM
    ...                                                          Major
    Run Keyword If  ${check_fault_4330}
    ...  Log  Given alarm and fault fields are correct in NA, alarm is present in NA [OK].  console=true
    ...  ELSE
    ...  FAIL  Given alarm and fault fields are incorrect in NA or alarm is missing in NA [NOK].
    Check If Alarms From WebEM and NetAct Are The Same
    ${output}=  Wait Until Keyword Succeeds  ${PROMPT_APPEARANCE_TIMEOUT}  15s  SShLibrary.Read until  rtose@gaia>

Step5: Abnormal threshold alarm check
    [Documentation]  This KW is created to check the appearance of alarm 7115 and fault 4329 Abnormal threshold on WebEM and Netact.
    ...  Also, waits for the prompt to be dispayed after the sysmon allocate command is finished on the first_connection on RMOD.
    Log  Step5: Abnormal threshold alarm check  console=true
    Log  Checking if alarm 7115 and fault 4329 Abnormal threshold is displayed  console=True
    ${fault_4329_status}=  Run Keyword and Return Status  Assert Alarm Active  parameters=${FAULT_4329}  timeout=300
    Run Keyword if  ${fault_4329_status}
    ...  Log  Fault 4329 with alarm "7115 Radio memory consumption exceeds abnormal threshold" occured [OK]  console=true
    ...  ELSE
    ...  Set Test Failed  Fault 4329 with alarm "7115 Radio memory consumption exceeds abnormal threshold didn't occur [NOK]
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  15s  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    ${check_fault_4329}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${ALARM_APPEARANCE_TIMEOUT}  15s
    ...  Check additional information for given alarm and fault  4329
    ...                                                          Radio memory consumption exceeds abnormal threshold
    ...                                                          7115
    ...                                                          BASE STATION INFORMATION
    ...                                                          Minor
    Run Keyword If  ${check_fault_4329}
    ...  Log  Given alarm and fault fields are correct in NA, alarm is present in NA [OK].  console=true
    ...  ELSE
    ...  FAIL  Given alarm and fault fields are incorrect in NA or alarm is missing in NA [NOK].
    Check If Alarms From WebEM and NetAct Are The Same
    SSHLibrary.Switch connection  first_connection
    ${output}=  Wait Until Keyword Succeeds  ${PROMPT_APPEARANCE_TIMEOUT}  15s  SShLibrary.Read until  rtose@gaia>
    Check if memory is released after allocation    ${USER_MEMORY_PERCENT_BEFORE_TEST}

Check if memory is released after allocation
    [Documentation]    This Kw checks if memory is released after allocation.
    [Arguments]    ${USER_MEMORY_PERCENT_BEFORE_TEST}
    Log  Check if memory is released after allocation  console=True
    ${system_stat_output}=  Execute ssh command   sysmon get_system_stat
    ${used_mem_percent_after_test}  Get Regexp Matches  ${system_stat_output}  Used${SPACE}memory${SPACE}\\(percent\\):${SPACE}(?P<value>\\d+)  value
    ${used_mem_percent_after_test}  Convert to integer  ${used_mem_percent_after_test[0]}
    Run Keyword If    ${used_mem_percent_after_test} != ${USER_MEMORY_PERCENT_BEFORE_TEST}    Execute ssh command  reboot
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  15s  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Check If Alarms From WebEM and NetAct Are The Same

Step6: Final Recovery and Checkpoint
    Log  Step6: Final Recovery and Checkpoint  console=true
    Restoring initial value and check alarms

Restoring initial value and check alarms
    Perform Parameter Recommissioning  MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${SELECTED_RMOD}  radioMemAbnormalThreshold  update  50
    Log  Checking if alarm 7115 and fault 4329 Abnormal threshold is cleared.  console=True
    ${fault_4329_status}=  Run Keyword and Return Status  Assert Alarm Inactive  parameters=faultId=4329,
    ...  faultName="Radio memory consumption exceeds abnormal threshold"  timeout=600
    Run Keyword if  ${fault_4329_status}
    ...  Log  Fault 4329 with alarm "7115 Radio memory consumption exceeds abnormal threshold" is cleared [OK]  console=true
    ...  ELSE
    ...  Set Test Failed  Fault 4329 with alarm "7115 Radio memory consumption exceeds abnormal threshold is not cleared [NOK]
    Log  Checking if alarm 7116 and fault 4330 Critical threshold is cleared.  console=True
    ${fault_4330_status}=  Run Keyword and Return Status  Assert Alarm Inactive  parameters=faultId=4330,
    ...  faultName="Radio memory consumption exceeds critical threshold"  timeout=600
    Run Keyword if  ${fault_4330_status}
    ...  Log  Fault 4330 with alarm "7116 Radio memory consumption exceeds critical threshold" is cleared [OK]  console=true
    ...  ELSE
    ...  Set Test Failed  Fault 4330 with alarm "7116 Radio memory consumption exceeds critical threshold is not cleared [NOK]
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  15s  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Sleep  60s  Waiting for alarms to be the same.
    Check If Alarms From WebEM and NetAct Are The Same

TC Setup
    Common Test Setup
    Setup NetAct

TC Teardown
    Run Keyword If Test Failed  Restoring initial value and check alarms
    Common Test Teardown
    Teardown NetAct
