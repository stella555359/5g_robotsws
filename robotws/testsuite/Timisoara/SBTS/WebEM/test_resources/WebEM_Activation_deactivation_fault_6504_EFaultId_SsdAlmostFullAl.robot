*** Settings ***
Documentation
    ...  This test case is created to send fault 6504.
    ...  Test will randomly select SMOD from ASIB, ASIL, ASOE, ASIM.
    ...  TC supports SMOD with log partition.
    ...  After sending the fault 6504, within 15 min alarm with fault id 7115/7652 is activated.
    ...  If actCategoryAlarms == true  - alarm 7115; if actCategoryAlarms == false - alarm 7652.
    ...  Alarm is deactivated and the checks are done.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${STARTUP_TIMEOUT}  900  # Timeout for SBTS to recover
${ALARM_TIMEOUT}  900  # Timeout for 6504 to be visible and cleared


*** Keywords ***
TC__WebEM_Activation_deactivation_fault_6504_EFaultId_SsdAlmostFullAl
    [Documentation]
    ...
    ...  [CASE LINK]:  https://jiradc.ext.net.nokia.com/browse/TAT-24491
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 01.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24491 - Initial TAT creation
    ...  - 12.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25370 - Remove BTS_L_ID
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  - 10.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27316 - Fixing alarm verification and delete the dummy file in teardown
    ...  ******************

    Set Tags  CA-WebEM  OWNER-nicolae-marcel.caragel@nokia.com  AUTHOR-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23  FEATURE-CB008390

    Step0: Check Smod And Set Parameters
    Step1: Trigger Fault 6504
    Step2: Check Alarm With Fault 6504 To Appear
    Step3: Cancel Fault 6504
    Step4: Check Alarm With Fault 6504 Is Cleared


Step0: Check Smod And Set Parameters
    Log  \nStep0: Check smod and set parameters.  console=true
    ${act_category_alarms_value}  Get ActCategoryAlarms Value From Infomodel
    Set Test Variable  ${ACT_CATEGORY_ALARMS_VALUE}
    ${smod_l_dn}  Get Random SMOD_L
    ${stored_role}  Get StoredRole From MODULE_L  ${smod_l_dn}
    Set Test Variable  ${STORED_ROLE}
    ${smod_r_dn}  Get SMOD_R Dist_name From SMOD_L  ${smod_l_dn}
    ${smod_r}  Fetch From Right  ${smod_r_dn}  /CABINET_R
    ${smod_r}  Fetch From Right  ${smod_r}  /
    Set Test Variable  ${HW_PATH}  /${smod_r}


Step1: Trigger Fault 6504
    Log  \nStep1: Trigger fault 6504.  console=true
    Open SSH Connection And activate Fault 6504


Step2: Check Alarm With Fault 6504 To Appear
    Log  \nStep2: Check alarm with fault 6504 to appear.  console=true
    Run Keyword If  '${ACT_CATEGORY_ALARMS_VALUE}'=='true'
    ...  Check If Fault Is Present In WebEM  ${FAULT_6504_WITH_ALARM_7115}
    ...  ELSE
    ...  Check If Fault Is Present In WebEM  ${FAULT_6504_WITH_ALARM_7652}


Step3: Cancel Fault 6504
    Log  \nStep3: Cancel fault 6504.  console=true
    Open SSH Connection And deactivate Fault 6504


Step4: Check Alarm With Fault 6504 Is Cleared
    Log  \nStep4: Check alarm with fault 6504 is cleared.  console=true
    Run Keyword If  '${ACT_CATEGORY_ALARMS_VALUE}'=='true'
    ...  Check If Fault Is Cleared In WebEM  ${FAULT_6504_WITH_ALARM_7115}
    ...  ELSE
    ...  Check If Fault Is Cleared In WebEM  ${FAULT_6504_WITH_ALARM_7652}


Get Random SMOD_L
    ${smod_l_list}  Query Infomodel  get list //SMOD_L-*
    ${smod_list}  Create List
    Set Test Variable  ${SMOD_LIST}
    FOR  ${smod}  IN  @{smod_l_list}
        ${check_asib_type}  Run Keyword And Return Status
        ...  Should Contain  ${smod}[productName]  ASIB
        ${check_smod_type}  Run Keyword And Return Status
        ...  Should Match Regexp  ${smod}[productName]  (ASIL|ASOE|ASIM)
        Run Keyword If  ${check_asib_type}
        ...  Check If Smod Contains Log Partition  ${smod}  (A.102|A.203|A.204|M.02)
        ...  ELSE IF  ${check_smod_type}
        ...  Append To List  ${SMOD_LIST}  ${smod}[dist_name]
    END
    ${status_soc_list}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${SMOD_LIST}
    Run Keyword If  ${status_soc_list}==${FALSE}
    ...  Fail  There is no SMOD with log partition.
    ${smod_l_dn}  Evaluate  random.choice(${SMOD_LIST})  random

    [Return]  ${smod_l_dn}


Check If Smod Contains Log Partition
    [Arguments]  ${smod}  ${product_code_metch}

    ${check_product_code}  Run Keyword And Return Status
    ...  Should Match Regexp  ${smod}[productCode]  ${product_code_metch}
    Run Keyword If  ${check_product_code}
    ...  Append To List  ${SMOD_LIST}  ${smod}[dist_name]


Get ActCategoryAlarms Value From Infomodel
    ${parametr_name}  Convert To String  actCategoryAlarms
    ${parameter_object}  Query Infomodel  get object /MRBTS-1/RAT-1//MNL_A-1/MNLENT_A-1/FMCADM_A-1
    ${parameter_object_value_string}  Convert To String  ${parameter_object.${parametr_name}}
    ${parameter_object_lower}  Convert To Lowercase  ${parameter_object_value_string}
    [Return]  ${parameter_object_lower}


Open SSH Connection And ${activate_deactivate} Fault 6504
    Open Connection To Primary Core
    Run Keyword If  '${STORED_ROLE}'=='Idle'
    ...  Open Connection To Secondary Core
    SSHLibrary.Set Client Configuration  prompt=>
    SSHLibrary.Write  cd /ffs/run/logs
    SSHLibrary.Read Until Prompt
    Run Keyword If  '${activate_deactivate}'=='activate'
    ...  Run Keywords
    ...  SSHLibrary.Write  fallocate -l 990M test.txt
    ...  AND
    ...  SSHLibrary.Read Until Prompt
    ...  AND
    ...  SSHLibrary.Close Connection
    ...  ELSE IF  '${activate_deactivate}'=='deactivate'
    ...  Run Keywords
    ...  SSHLibrary.Write  rm test.txt
    ...  AND
    ...  SSHLibrary.Read Until Prompt
    ...  AND
    ...  SSHLibrary.Close Connection


Check If Fault Is Present In WebEM
    [Arguments]  ${fault_dict}

    Log  Check alarm with fault ${fault_dict}[fault_id] to appear in WebEM.  console=true
    ${fault_params}  Get String With Alarm Parameters  ${fault_dict}
    ${fault_params}  Catenate  ${fault_params},  hwPath="${HW_PATH}"
    ${status_alarm_webem}  Run Keyword And Return Status
    ...  Assert Alarm Active  ${fault_params}  timeout=${ALARM_TIMEOUT}
    Run Keyword If  ${status_alarm_webem}
    ...  Log  Fault ${fault_dict}[fault_id] with alarm ${fault_dict}[alarm_id] has been activated in WebEM. [OK]  console=true
    ...  ELSE
    ...  Fail  Fault ${fault_dict}[fault_id] with alarm ${fault_dict}[alarm_id] did not activate. [NOK]


Check If Fault Is Cleared In WebEM
    [Arguments]  ${fault_dict}

    Log  Check alarm with fault ${fault_dict}[fault_id] to be cleared in WebEM.  console=true
    ${fault_params}  Get String With Alarm Parameters  ${fault_dict}
    ${fault_params}  Catenate  ${fault_params},  hwPath="${HW_PATH}"
    ${status_alarm_webem}  Run Keyword And Return Status
    ...  Assert Alarm Inactive  ${fault_params}  timeout=${ALARM_TIMEOUT}
    Run Keyword If  ${status_alarm_webem}
    ...  Log  Fault ${fault_dict}[fault_id] with alarm ${fault_dict}[alarm_id] has been deactivated in WebEM. [OK]  console=true
    ...  ELSE
    ...  Fail  Fault ${fault_dict}[fault_id] with alarm ${fault_dict}[alarm_id] did not deactivate. [NOK]


TC Setup
    Common Test Setup  tc_name=WebEM__Activation_deactivation_fault_6504


TC Teardown
    Run Keyword If Test Failed
    ...  Open SSH Connection And deactivate Fault 6504
    Common Test Teardown
