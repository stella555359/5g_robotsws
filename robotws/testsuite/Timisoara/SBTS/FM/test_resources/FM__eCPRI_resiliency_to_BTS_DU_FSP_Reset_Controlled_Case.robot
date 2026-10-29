*** Settings ***
Documentation
    ...  The feature is activated by setting the parameter actRuResetResiliency to true
    ...  and changing the parameter cntrldResetMplaneBreakTime to minimum value of range.
    ...  After the BBMOD reset the SBTS should be fully on-air.
    ...  The RMOD should not reset, so the condition is that the uptime found must be less than 10 minutes.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ALARM_TIMEOUT}  300  # Timeout for alarm to appear in WebEM
${NETACT_TIMEOUT}  300  # Timeout for alarm to appear in Netact
${RECOVERY_TIMEOUT}  600  # Timeout for SBTS to become on-air


*** Keywords ***
TC__FM__eCPRI_resiliency_to_BTS_DU_FSP_Reset_Controlled_Case
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28079
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  24.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28079 - Initial TAT creation
    ...  11.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28214 - Improved BBMOD selection
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  18.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28372 - Replace bbmod crash with bbmod reset
    ...  14.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28614 - Test fails when changing parameter
    ...  15.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29023 - Enhancement for fault check
    ...  ******************

    Set Tags  CA-FM  OWNER-alina.cret@nokia.com  AUTHOR-cosmina.rebenciuc@nokia.com  MAINTAINER-cosmina.rebenciuc@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS25R1  FEATURE-CB010846

    Step0: Set Test Preconditions
    Step1: Activate feature
    Step2: Reset BBMOD
    Step3: Checking RMOD reset status via SSH
    Step4: Check Alarms In RAW Alarms History


Step0: Set Test Preconditions
    Log  \nStep0: Set Test Preconditions  console=true
    ${cablinks}  Get Parameters For All  cablink
    ${cablink_ecpri_list}  Create List

    FOR  ${cablink}  IN  @{cablinks}
      IF  'eCpri' in '${cablink}[linkSpeed]'  Append To List  ${cablink_ecpri_list}  ${cablink}
    END

    ${ecpri_cablink}  Evaluate  random.choice(${cablink_ecpri_list})  random

    Log  Test will reset bbmod: ${ecpri_cablink}[firstEndpointDN]  console=true
    Log  Test will check reset on rmod: ${ecpri_cablink}[secondEndpointDN]  console=true

    Set Test Variable  ${CONNECTED_RMOD_DN}  ${ecpri_cablink}[secondEndpointDN]
    Set Test Variable  ${RESET_BBMOD_DN}  ${ecpri_cablink}[firstEndpointDN]
    ${current_date_time_raw}  Get BTS Time In UTC Format  %Y-%b-%d %H:%M:%S
    Set Test Variable  ${TEST_START_TIME}  ${current_date_time_raw}


Step1: Activate feature
    Log  \nStep1: Activate feature  console=true
    Change FEATCADM Parameter  actRuResetResiliency  true
    Log  Feature CB010846 has been activated successfully.  console=true
    Log  Checking and changing cntrldResetMplaneBreakTime parameter  console=true
    ${break_time_value}  Set Variable If  '${ENB_BRANCH}' >= 'SBTS25R2'  220  180
    Change FEATCADM Parameter  cntrldResetMplaneBreakTime  ${break_time_value}


Step2: Reset BBMOD
    Log  \nStep2: Reset BBMOD  console=true
    Reset Unit  ${RESET_BBMOD_DN}  Warm  timeout=300
    Assert Every  BBMOD  operationalState=${ENABLED}  timeout=600

Step3: Checking RMOD reset status via SSH
    Log  \nStep3: Checking RMOD reset status via SSH  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  20  Check Modules And Cells
    ${rmod_measurements}  Get Rmod Measurements By Id  ${CONNECTED_RMOD_DN}
    ${rmod_uptime}  Set Variable  ${rmod_measurements}[uptime][seconds]
    IF  '${rmod_uptime}' < '600'
    ...  Log  RMOD(${CONNECTED_RMOD_DN}) reset was not performed. [OK]  console=true
    ...  ELSE
    ...  Fail  RMOD(${CONNECTED_RMOD_DN}) reset was performed during BBMOD (${RESET_BBMOD_DN}) reset.


Step4: Check Alarms In RAW Alarms History
    Log  \nStep4: Check Alarms In RAW Alarms History  console=true
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


Deactivate Feature
    Log  Deactivate Feature will be performed  console=true
    Change FEATCADM Parameter  actRuResetResiliency  false


TC Setup
    Common Test Setup
    Setup NetAct


TC Teardown
    Deactivate Feature
    Teardown NetAct
    Common Test Teardown
