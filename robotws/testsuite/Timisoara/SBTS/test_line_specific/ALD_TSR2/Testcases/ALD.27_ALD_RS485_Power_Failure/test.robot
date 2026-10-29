*** Settings ***
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/common.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/alarms.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/ald.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/fac.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.27_ALD_RS485_Power_Failure
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this TC is to check if BTS behaviour is correct in case report 4069 alarm.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  *****************
...  10.12.2020 - test creation
...  24.08.2021 - https://jira3.int.net.nokia.com/browse/TAT-21765
...  03.11.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-31 - adaptation to CNI-61110
...  06.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-36 - Switch to hran_frame_sbts_siso resource
...  08.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-84 - adaptation to CNI-64298
...  13.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-203 - add KW "Get Software Version" into TC Setup and variable
...                                                                 release into coam.Setup Admin
...  12.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-219 - add KW "Common step trigger" due to BIT CS4.3 Enable Sleeping Cell
...  08.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-241 - Adaptation to CNI-82119 and migration from hran_ta to robotlte repository
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***


*** Keywords ***
ALD.27_ALD_RS485_Power_Failure

	ALD.27_ALD_RS485_Power_Failure.Test_Step.0 Test Preparation
    ALD.27_ALD_RS485_Power_Failure.Test_Step.1 Generate Fault 4069
    ALD.27_ALD_RS485_Power_Failure.Test_Step.2 Check alarms and ALDs states
    ALD.27_ALD_RS485_Power_Failure.Test_Step.3 Radio Reset
    ALD.27_ALD_RS485_Power_Failure.Test_Step.4 Check alarms and ALDs states
    ALD.27_ALD_RS485_Power_Failure.Test_Step.5 Clear Fault Conditions
    ALD.27_ALD_RS485_Power_Failure.Test_Step.6 Radio Lock/Unlock
    ALD.27_ALD_RS485_Power_Failure.Test_Step.7 Check Alarms After Removing Fault Conditions
    ALD.27_ALD_RS485_Power_Failure.Test_Step.8 FEG calculation

ALD.27_ALD_RS485_Power_Failure.Test_Step.0 Test Preparation
    [Documentation]  Test step which checking if RETs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Set Test Variable  ${COMMISSIONING_PATH}  /home/ute/testline_configuration/${TESTLINE_NAME}/node1/SCF_01_${RELEASE}.xml
    Set Test Variable  ${FAC_CONFIG_FILE_PATH}  /home/ute/testline_configuration/${TESTLINE_NAME}/interfaces.yaml
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${num_of_RETs}
    Set Test Variable  ${ALD_R_RETs}
    ${RS485_FAC_interfaces}=  Get ALD Interfaces  ALD_type=${RS485_FAILURE}
    Set Test Variable  ${RS485_FAC_interfaces}
    Run Keyword If  ${RS485_FAC_interfaces}==[]
    ...  Fail  msg=You have no FAC device configured under /home/ute/testline_configuration/${TESTLINE_NAME}/interfaces.yaml
    Set Test Variable  ${FAC_PC_IP}  ${my_fac1['IP']}
    Set Test Variable  ${FAC_PORT}  ${my_fac1['PORT']}
    Run Keyword If  ${num_of_RETs}==${0}
    ...  Fail  msg=There is no at least one expected RET in configuration
    Log  You have ${num_of_RETs} RETs in configuration  console=${True}
    ${RSL_DN}=  Get RSL_A Full DistName String  ${RMOD_A}
    Set Test Variable  ${RSL_DN}
    ${RETU}  ${ALD}  Get RETU and ALDs Affected By Fault 4069  ${RSL_DN}
    Set Test Variable  ${ALD}
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=putty.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=powershell.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=cmd.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=python.exe
    Connect To PC And Start FAC Agent  ${FAC_PC_IP}  ${FAC_PORT}

ALD.27_ALD_RS485_Power_Failure.Test_Step.1 Generate Fault 4069
    [Documentation]  Generate Fault 4069.
    Log to console    \n========================================
    Log  Step: 1 Generating Fault 4069  console=${True}
    Log to console    ========================================
    Allow Fault In Watchdog  faultID=4069  #fault_name: ALD Port power failure
    Switch DC Using FAC  Off  ${RS485_FAC_interfaces}
    Log  \nWaiting 1 minute  console=${True}
    Sleep  60s

ALD.27_ALD_RS485_Power_Failure.Test_Step.${n} Check alarms and ALDs states
    [Documentation]
    ...    1. Check if fault 4069 is visible.
    ...    2. Check if expected ALDs achieve state: availabilityStatus=power off, operationalState=disabled.
    Log to console    \n========================================
    Log  Step: ${n} Check alarms and ALDs states  console=${True}
    Log to console    ========================================
    ${alarms}=  admin.get active alarms
    ${source_active_4069}=  Create List
    FOR  ${i}  IN  @{alarms}
        Run Keyword If  ${i['faultId']}==4069  Run Keywords
        ...  Append To List  ${source_active_4069}  ${i['configObjectName']}
        ...  AND
        ...  Log  Fault 4069 is reported on source: ${i.configObjectName}  console=${True}
    END
    FOR  ${ald_dn}  IN  @{ALD}
        Check Dedicated ALD State  ${ald_dn}  ${ALD_expected_state_powerOff}
    END

ALD.27_ALD_RS485_Power_Failure.Test_Step.3 Radio Reset
    [Documentation]  Afected radio reset procedure.
    Log to console    \n========================================
    Log  Step: 3 Radio Reset  console=${True}
    Log to console    ========================================
    ${RMOD_A_distName}  ${ignore}=  Split String From Right  ${RSL_DN}  separator=/  max_split=1
    ${RMOD_A_to_RMOD_R}=  Mapping RMOD_A To RMOD_R
    ${RMOD_R_distName}=  Get From Dictionary  ${RMOD_A_to_RMOD_R}  ${RMOD_A_distName}
    ${rmod}=  Should Match Regexp  ${RMOD_R_distName}  RMOD_R-\\d+
    Log  Reseting ${rmod}  console=${true}
    admin.reset unit  ${RMOD_R_distName}  reset_type=Hard  timeout=600
    Check If NLWG Cells Are OnAir
    Set Test Variable  ${RMOD_R_distName}

ALD.27_ALD_RS485_Power_Failure.Test_Step.5 Clear Fault Conditions
    [Documentation]  Clear Fault 4069 Conditions.
    Log to console    \n========================================
    Log  Step: 5 Clearing Fault 4069 - RS485 power failure  console=${True}
    Log to console    ========================================
    Switch DC Using FAC  On  ${RS485_FAC_interfaces}
    Log  \nWaiting 2 minutes  console=${True}
    Sleep  120s

ALD.27_ALD_RS485_Power_Failure.Test_Step.6 Radio Lock/Unlock
    [Documentation]  Afected radio lock unlock procedure.
    Log to console    \n========================================
    Log  Step: 6 Radio Lock/Unlock  console=${True}
    Log to console    ========================================
    ${rmod}=  Should Match Regexp  ${RMOD_R_distName}  RMOD_R-\\d+
    Log  Locking ${rmod}  console=${true}
    admin.lock  ${RMOD_R_distName}  timeout=240
    Sleep  40s
    Log  Unlocking ${rmod}  console=${true}
    admin.unlock  ${RMOD_R_distName}  timeout=240
    Wait Until Keyword Succeeds  4min  30s  Check State on GNCELs  availabilityStatus  None
    Check If NLWG Cells Are OnAir
    Check ALDs State  ${ALD_expected_states}
    Disallow Fault In Watchdog  faultID=4069  #fault_name: ALD Port power failure

ALD.27_ALD_RS485_Power_Failure.Test_Step.7 Check Alarms After Removing Fault Conditions
    [Documentation]
    ...    1. Check if fault 4069 is still visible.
    ...    2. Check if other unexpected faults are visible.
    ...    3. Check if all ALDs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    Log to console    \n========================================
    Log  Step: 10 Check Alarms After Removing Fault Conditions  console=${True}
    Log to console    ========================================
    ${alarm_info}=  Run Keyword And Return Status  admin.assert alarm active  faultId=4069
    Run Keyword If  ${alarm_info}  Fail  msg=There is still faultId 4069 raised
    ...  ELSE  Log  FaultId 4069 has been cleared  console=${True}
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    Check ALDs State  ${ALD_expected_states}

ALD.27_ALD_RS485_Power_Failure.Test_Step.8 FEG calculation
    [Documentation]  This keyword is checking if front end gain is calculated properly.
    Log to console    \n========================================
    Log  Step: 8 FEG calculation  console=${True}
    Log to console    ========================================
    Check FEG On Antl Without MHA
    Check FEG On Antl With MHA

ALD.27_ALD_RS485_Power_Failure.Test Specific Teardown
    [Documentation]
    ...   1. Switching FAC outlets on as a precaution.
    ...   2. Locking/unlocking afected RMOD.
    ...   3. Checking cells.
    ...   4. Checking ALDs state.
    Log  \nSwitching FAC outlets on as a precaution.  console=${True}
    Switch DC Using FAC  On  ${RS485_FAC_interfaces}
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    ${RMOD_A_distName}  ${ignore}=  Split String From Right  ${RSL_DN}  separator=/  max_split=1
    ${RMOD_A_to_RMOD_R}=  Mapping RMOD_A To RMOD_R
    ${RMOD_R_distName}=  Get From Dictionary  ${RMOD_A_to_RMOD_R}  ${RMOD_A_distName}
    ${rmod}=  Should Match Regexp  ${RMOD_R_distName}  RMOD_R-\\d+
    Log  Locking ${rmod}  console=${true}
    admin.lock  ${RMOD_R_distName}  timeout=240
    Sleep  40s
    Log  Unlocking ${rmod}  console=${true}
    admin.unlock  ${RMOD_R_distName}  timeout=240
    Check If NLWG Cells Are OnAir
    Check ALDs State  ${ALD_expected_states}
    admin.teardown admin  alias=${ute_admin_alias}
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=putty.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=powershell.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=cmd.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=python.exe

ALD.27_ALD_RS485_Power_Failure.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keyword  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    Run Keyword If Test Failed  ALD.27_ALD_RS485_Power_Failure.Test Specific Teardown
