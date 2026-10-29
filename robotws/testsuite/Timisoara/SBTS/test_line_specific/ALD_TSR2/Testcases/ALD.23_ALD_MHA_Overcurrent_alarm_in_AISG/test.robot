*** Settings ***
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/common.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/alarms.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/ald.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/fac.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this TC is to check if BTS behaviour is correct in case report 1836 alarm when MHA is in AISG mode.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  *****************
...  07.01.2021 - test creation
...  10.09.2021 - https://jira3.int.net.nokia.com/browse/TAT-21840
...  25.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-17 - adaptation to CNI-61110
...  06.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-36 - Switch to hran_frame_sbts_siso resource
...  10.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-89 - fix teardown + add ca_ald_resource.Check If NLWG Cells Are Onair
...  13.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-203 - add KW "Get Software Version" into TC Setup and variable
...                                                                 release into coam.Setup Admin
...  12.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-219 - add KW "Common step trigger" due to BIT CS4.3 Enable Sleeping Cell
...  04.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-237 - Adaptation to CNI-82119 and migration from hran_ta to robotlte repository
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***


*** Keywords ***
ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG

	ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test_Step.0 Test Preparation
    ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test_Step.1 Generate Fault 1836
    ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test_Step.2 Check Alarms And MHA State
    ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test_Step.3 FEG Calculation With Recovery
    ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test_Step.4 Radio Lock/Unlock
    ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test_Step.5 FEG Calculation With Recovery
    ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test_Step.6 Check Alarms And MHA State
    ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test_Step.7 Clear Fault Conditions
    ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test_Step.8 Radio Reset
    ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test_Step.9 FEG Calculation Without Recovery
    ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test_Step.10 Check Alarms After Removing Fault Conditions

ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test_Step.0 Test Preparation
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Set Test Variable  ${FAC_CONFIG_FILE_PATH}  /home/ute/testline_configuration/${TESTLINE_NAME}/interfaces.yaml
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${ALD_R_MHAs}
    Run Keyword If  ${ALD_R_MHAs}==${0}
    ...  Fail  msg=You have no MHA in configuration
    Log  You have ${num_of_MHAs} MHAs in configuration  console=${True}
    ${ANTL_distName}=  Get ANTL_A Full DistName String  ${ANTL_A}
    Set Test Variable  ${ANTL_distName}
    ${OC_FAC_interface}=  Get ALD Interfaces  ALD_type=${OC_INTERFACE}
    Set Test Variable  ${OC_FAC_interface}
    Set Test Variable  ${FAC_PC_IP}  ${my_fac1['IP']}
    Set Test Variable  ${FAC_PORT}  ${my_fac1['PORT']}
    ${ALD}  ${lna_dist_names}  Get Affected LNAs And MHAs  ${ANTL_distName}
    Set Test Variable  ${ALD}
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=putty.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=powershell.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=cmd.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=python.exe
    Connect To PC And Start FAC Agent  ${FAC_PC_IP}  ${FAC_PORT}

ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test_Step.1 Generate Fault 1836
    [Documentation]  Generate Fault 1836.
    Log to console    \n========================================
    Log  Step: 1 Generating Fault 1836 - overcurrent  console=${True}
    Log to console    ========================================
    Allow Fault In Watchdog  faultID=1836  #fault_name: Antenna line failure
    Switch DC Using FAC  On  ${OC_FAC_interface}
    Log  \nWaiting 3 minutes  console=${True}
    Sleep  180s

ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test_Step.${n} Check Alarms And MHA State
    [Documentation]  Checking if expected alarms are present and if ALDs states are correct.
    Log to console    \n========================================
    Log  Step: ${n} Check Alarms And MHA State  console=${True}
    Log to console    ========================================
    ${alarms}=  admin.get active alarms
    ${alarm_info}=  Run Keyword And Return Status  admin.assert alarm active  faultId=1836
    Run Keyword If  not ${alarm_info}  Fail  msg=There is no expected faultId 1836
    ${source_active_1836}=  Create List
    FOR  ${i}  IN  @{alarms}
        Run Keyword If  ${i['faultId']}==1836  Run Keywords
        ...  Append To List  ${source_active_1836}  ${i['configObjectName']}
        ...  AND
        ...  Log  Fault 1836 is reported on source: ${i.configObjectName}    console=${True}
    END
    Check Dedicated ALD State  ${ALD}  ${ALD_expected_state_powerOff}

ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test_Step.${n} FEG Calculation With Recovery
    [Documentation]  This keyword is checking if front end gain is calculated properly.
    Log to console    \n========================================
    Log  Step: ${n} FEG Calculation  console=${True}
    Log to console    ========================================
    Check FEG On ANTL Where Is Loglink With Recovery

ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test_Step.4 Radio Lock/Unlock
    [Documentation]  Afected radio lock unlock procedure.
    Log to console    \n========================================
    Log  Step: 4 Radio Lock/Unlock  console=${True}
    Log to console    ========================================
    ${RMOD_A_distName}  ${ignore}=  Split String From Right  ${ANTL_distName}  separator=/  max_split=1
    ${RMOD_A_to_RMOD_R}=  Mapping RMOD_A To RMOD_R
    ${RMOD_R_distName}=  Get From Dictionary  ${RMOD_A_to_RMOD_R}  ${RMOD_A_distName}
    ${rmod}=  Should Match Regexp  ${RMOD_R_distName}  RMOD_R-\\d+
    Log  Locking ${rmod}  console=${true}
    admin.lock  ${RMOD_R_distName}  timeout=240
    Sleep  40s
    Log  Unlocking ${rmod}  console=${true}
    admin.unlock  ${RMOD_R_distName}  timeout=240
#    Added 'False' argument to keyword 'Check if NLWG Cells Are OnAir'. This skips the GSM cells availability status check
    Check If NLWG Cells Are OnAir  False
    Set Test Variable  ${RMOD_R_distName}

ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test_Step.7 Clear Fault Conditions
    [Documentation]  Clear Fault 1836 Conditions.
    Log to console    \n========================================
    Log  Step: 7 Clearing Fault 1836 - overcurrent  console=${True}
    Log to console    ========================================
    Switch DC Using FAC  Off  ${OC_FAC_interface}
    Log  \nWaiting 2 minutes  console=${True}
    Sleep  120s

ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test_Step.8 Radio Reset
    [Documentation]  Afected radio reset procedure.
    Log to console    \n========================================
    Log  Step: 8 Radio Reset  console=${True}
    Log to console    ========================================
    ${rmod}=  Should Match Regexp  ${RMOD_R_distName}  RMOD_R-\\d+
    Log  Reseting ${rmod}  console=${true}
    admin.reset unit  ${RMOD_R_distName}  reset_type=Hard  timeout=600
    Check If NLWG Cells Are OnAir
    Log  Checking ALD state after ${rmod} reset:
    Check ALDs State  ${ALD_expected_states}
    Disallow Fault In Watchdog  faultID=1836  #fault_name: Antenna line failure

ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test_Step.9 FEG Calculation Without Recovery
    [Documentation]  This keyword is checking if front end gain is calculated properly.
    Log to console    \n========================================
    Log  Step: 9 FEG Calculation  console=${True}
    Log to console    ========================================
    Check FEG On Antl Without MHA
    Check FEG On Antl With MHA

ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test_Step.10 Check Alarms After Removing Fault Conditions
    [Documentation]  Checking if expected alarms are present and if ALDs states are correct.
    Log to console    \n========================================
    Log  Step: 10 Check Alarms After Removing Fault Conditions  console=${True}
    Log to console    ========================================
    ${alarm_info}=  Run Keyword And Return Status  admin.assert alarm active  faultId=1836
    Run Keyword If  ${alarm_info}  Fail  msg=There is still faultId 1836 raised
    ...  ELSE  Log  FaultId 1836 has been cleared  console=${True}
    Check ALDs State  ${ALD_expected_states}
    Check If Unexpected Alarms Are Raised  ${skip_fault}

ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test Specific Teardown
    [Documentation]
    ...   1. Switching FAC outlets on as a precaution.
    ...   2. Reseting afected RMOD.
    ...   3. Checking cells.
    Log  \nSwitching FAC outlets on as a precaution  console=${True}
    Switch DC Using FAC  Off  ${OC_FAC_interface}
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    ${RMOD_A_distName}  ${ignore}=  Split String From Right  ${ANTL_distName}  separator=/  max_split=1
    ${RMOD_A_to_RMOD_R}=  Mapping RMOD_A To RMOD_R
    ${RMOD_R_distName}=  Get From Dictionary  ${RMOD_A_to_RMOD_R}  ${RMOD_A_distName}
    ${rmod}=  Should Match Regexp  ${RMOD_R_distName}  RMOD_R-\\d+
    Log  Reseting ${rmod}  console=${true}
    admin.reset unit  ${RMOD_R_distName}  reset_type=Hard  timeout=600
    Check If NLWG Cells Are OnAir
    admin.teardown admin  alias=${ute_admin_alias}
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=putty.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=powershell.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=cmd.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=python.exe

ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keyword  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    Run Keyword If Test Failed  ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test Specific Teardown
