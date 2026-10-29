*** Settings ***
Documentation
    ...  The feature is activated by setting the parameter ActForce(Unit)AutoReset to true,
    ...  setting the parameter actRuResetResiliency to true
    ...  and changing the parameter uncntrldResetMplaneBreakTime to 420.
    ...  This test should be executed on a SMOD from this list 'ASOF','ASOG','ASOE','ASOH' that has a CPRI/eCPRI RMOD connected to it
    ...  and 4G/5G RAT mapped there.
    ...  The SMOD should also have a variant of L1Software that corresponds to the one found on the SW_NODE object.
    ...  The L1SOC trigger will be performed 3 times.
    ...  Alarm of SoC reset should appear after each fault trigger.
    ...  After that, the SMOD reset will be performed and the SBTS should be fully on-air at the end.
    ...  The RMOD should not reset, meaning the uptime must be less than 10 minutes.
    ...  At the end of the test, alarms in the range 4241-4247 should be checked in the RawAlarmHistory file.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ALARM_TIMEOUT}  300  # Timeout for alarm to appear in WebEM
${RECOVERY_TIMEOUT}  600  # Timeout for SBTS to become on-air


*** Keywords ***
TC__FM__RU_Resiliency_to_BTS_DU_L1Soc_Reset_Uncontrolled_ASOx
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28617
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  07.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28617 - Initial TAT creation
    ...  15.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29023 - Enhancement for fault check
    ...  ******************

    Set Tags  CA-FM  OWNER-alina.cret@nokia.com  AUTHOR-cosmina.rebenciuc@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  SW-SBTS25R2  FEATURE-CB010846-SR-D

    Step0: Set Test Preconditions
    Step1: Activate feature
    Step2: Trigger L1SOC reset
    Step3: Check If RMOD Is Resetting
    Step4: Trigger L1SOC reset
    Step5: Check If RMOD Is Resetting
    Step6: Trigger L1SOC reset
    Step7: Check If RMOD Is Resetting
    Step8: Check Alarm In RawAlarmHistory


Step0: Set Test Preconditions
    Log  \nStep0: Set Test Preconditions  console=true

    IF  '${ENB_BRANCH}' < 'SBTS25R2'
    ...  Fail  Active software is ${ENB_BRANCH}. The test is supported on software versions equal to or higher than 25R2.

    Run Keyword If  '${SMOD1}[HW_TYPE]' not in ['ASOF','ASOG','ASOE','ASOH']
    ...  Fail  SMOD is ${SMOD1}[HW_TYPE]. The test should be performed on an SBTS configured with the SMOD pattern - ASOx.

    ${cablinks}  Get Parameters For All  cablink
    ${cablink_ecpri_list}  Create List
    FOR  ${cablink}  IN  @{cablinks}
        Run Keyword If  'eCpri' in '${cablink}[linkSpeed]' or 'Cpri' in '${cablink}[linkSpeed]'
        ...  Append To List  ${cablink_ecpri_list}  ${cablink}
    END

    ${rmods}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmods}
        ${rmod_cells}  Get Cell Mapping By Module Id  ${rmod}[id]
        ${lte_nr_cells_rmod}  ${status_cells_rmod}  Verify Cells Mapped On RMOD  ${rmod_cells}
        Continue For Loop If  '${status_cells_rmod}'=='${FALSE}'
        Set Test Variable  ${RMOD_DN}  ${rmod}[id]
        Exit For Loop
    END

    FOR  ${cablink}  IN  @{cablink_ecpri_list}
        Continue For Loop If  '${cablink}[secondEndpointDN]'!='${RMOD_DN}'
        Set Test Variable  ${SMOD_R_DN}  ${cablink}[firstEndpointDN]
        Exit For Loop
    END

    ${ref_object}  coam.Get Parameters  ${SMOD_R_DN}/POWERGROUP_R-1/REF-1
    ${smod_l_dn}  Fetch From Left  ${ref_object}[distName]  /BOARD
    Set Test Variable  ${SMOD_L_DN}  ${smod_l_dn}

    Set SOC Position Which Has L1 Process
    ${smod_position}  Get Module Vertical Position  ${SMOD_R_DN}
    Set Test Variable  ${SMOD_POSITION}
    ${stored_role}  Get StoredRole From MODULE_L  ${smod_L_DN}
    Set Test Variable  ${STORED_ROLE}  ${stored_role}

    ${current_date_time_raw}  Get BTS Time In UTC Format  %Y-%b-%d %H:%M:%S
    Set Test Variable  ${TEST_START_TIME}  ${current_date_time_raw}


Step1: Activate feature
    Log  \nStep1: Activate feature  console=true
    Change FEATCADM Parameter  actRuResetResiliency  true
    Change FEATCADM Parameter  uncntrldResetMplaneBreakTime  420
    Log  Feature CB010846-SR-D has been activated successfully.  console=true


Step${index}: Trigger L1SOC reset
    Log  \nStep${index}: Trigger L1SOC reset  console=true
    Trigger L1SOC Reset On smod
    Verify Alarm To Become Active In WebEM  ${FAULT_2087_SOC_AUTO_RST}


Step${index}: Check If RMOD Is Resetting
    Log  \nStep${index}: Check If RMOD Is Resetting  console=true
    Check If RMOD Is Resetting


Step8: Check Alarm In RawAlarmHistory
    Log  \nStep8: Check Alarm In RawAlarmHistory  console=true
    Verify Alarm In RawAlarmHistory File  4801  ${TEST_START_TIME}  alarm_status=active
    ...  additional_fault_name=EFaultId_RadioMplaneConnectionEstablishedAl
    ${expected_faults_raw}  Create List  4241  4242  4243  4244  4246  4247
    FOR  ${fault_id}  IN  @{expected_faults_raw}
       ${fault_status}  Run Keyword And Return Status  Verify Alarm In RawAlarmHistory File  ${fault_id}  ${TEST_START_TIME}  alarm_status=all
       IF  ${fault_status}
         Fail  Alarm with fault ${fault_id} appeared in RawAlarmHistory file - [NOK]
       ELSE
         Log  Alarm with fault ${fault_id} is not present in RawAlarmHistory file - [OK]  console=true
       END
    END


Verify Cells Mapped On RMOD
    [Arguments]  ${rmod_cells}
    ${lte_nr_cells_rmod}  Create List
    FOR  ${cell}  IN  @{rmod_cells}
        ${status_cells}  Run Keyword And Return Status  Should Contain Any  ${cell}  LNCEL  NRCEL
        Run Keyword If  ${status_cells}
        ...  Append To List  ${lte_nr_cells_rmod}  ${cell}
    END
    ${status_cells_rmod}  Run Keyword And Return Status  Should Not Be Empty  ${lte_nr_cells_rmod}

    [Return]  ${lte_nr_cells_rmod}  ${status_cells_rmod}


Set SOC Position Which Has L1 Process
    ${sw_node_l_list}  Query Infomodel  get list ${SMOD_L_DN}/BOARD_L-1/POWER_GROUP_L-*/SOC_L-*/SW_NODE_L-*
    FOR  ${sw_node_obj}  IN  @{sw_node_l_list}
        Continue For Loop If  '${sw_node_obj}[variant]'!='L1Software'
        Set Test Variable  ${SW_NODE_OBJECT}  ${sw_node_obj}
    END
    ${status}  Run Keyword And Return Status  Should Not Be Empty  ${SW_NODE_OBJECT}
    Run Keyword If  ${status}
    ...  Log  SW_NODE object with L1Software variant was found: ${SW_NODE_OBJECT}.  console=true
    ...  ELSE
    ...  Fail  SW_NODE object with L1Software variant was not found. [NOK]

    ${soc_dn}  Fetch From Left  ${SW_NODE_OBJECT}[dist_name]  /SW_NODE_L
    ${soc_position}  Get SOC Position  ${soc_dn}  ${SMOD1}[HW_TYPE]
    Set Test Variable  ${SOC_POSITION}  ${soc_position}


Verify Alarm To Become Active In WebEM
    [Arguments]  ${fault_dict}
    ${fault_params}  Get String With Alarm Parameters  ${fault_dict}
    ${status}  Run Keyword And Return Status
    ...  Assert Alarm Active  parameters=${fault_params}  timeout=${ALARM_TIMEOUT}
    Run Keyword If  ${status}
    ...  Log  Fault 2087 has been detected and is now visible on WebEM.  console=true
    ...  ELSE
    ...  Fail  Fault 2087 has not been detected and is not visible on WebEM. [NOK]


Trigger L1SOC Reset On smod
    Open Connection To Primary Core
    Run Keyword If  '${STORED_ROLE}'=='Idle'
    ...  Open Connection To Secondary Core
    Open Connection To SOC  ${SMOD_POSITION}  ${SOC_POSITION}
    SSHLibrary.Set Client Configuration  prompt=REGEXP:(#|\\~|\\~#)
    SSHLibrary.Write  ps aux | grep l1_application_rt
    ${command_output}  SSHLibrary.Read Until Prompt  strip_prompt=True
    ${lines}  Split To Lines  ${command_output}
    @{string}  Split String  ${lines}[0]
    ${pid}  Set Variable  ${string}[1]
    SSHLibrary.Write  kill -11 ${pid}
    SSHLibrary.Read Until Prompt
    SSHLibrary.Close All Connections


Check If RMOD Is Resetting
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check Modules And Cells
    ${rmod_measurements}  Get Rmod Measurements By Id  ${RMOD_DN}
    ${rmod_uptime}  Set Variable  ${rmod_measurements}[uptime][seconds]
    Run Keyword If  '${rmod_uptime}' < '600'
    ...  Log  RMOD(${RMOD_DN}) reset was not performed. [OK]  console=true
    ...  ELSE
    ...  Fail  RMOD(${RMOD_DN}) reset was performed during smod (${SMOD_R_DN}) reset. [NOK]


Deactivate Feature CB010846_SR_D
    Log  Deactivate Feature will be performed  console=true
    Change FEATCADM Parameter  actRuResetResiliency  false
    Change FEATCADM Parameter  uncntrldResetMplaneBreakTime  0
    Log  Feature CB010846-SR-D has been deactivated successfully.  console=true


TC Setup
    Common Test Setup  tc_name=FM__RU_Resiliency_to_DU_L1Soc_Reset_Uncontrolled_ASOx


TC Teardown
    Deactivate Feature CB010846_SR_D
    Common Test Teardown
