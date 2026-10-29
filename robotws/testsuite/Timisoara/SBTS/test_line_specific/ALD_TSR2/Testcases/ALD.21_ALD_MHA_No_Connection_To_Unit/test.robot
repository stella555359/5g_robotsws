*** Settings ***
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/common.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/alarms.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/ald.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/fac.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.21_ALD_MHA_No_Connection_To_Unit
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this TC is to check if BTS behaviour is correct in case of losing connection to AISG 2.0
...  MHA unexpectedly. Flexi Automation Controller is being used in this TC.
...  IMPORTANT NOTE:
...  For this test case to work it is required to use specific name convention for FAC outlets assigned to MHAs:
...  MHA_*mha_description* in interfaces.yaml configuration file.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  *****************
...  09.02.2018 https://jira3.int.net.nokia.com/browse/TAT-9119 - test draft creation
...  12.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-14560
...  11.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-3 - migration to TAF
...  25.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-21 - adaptation to CNI-61110
...  06.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-36 - Switch to hran_frame_sbts_siso resource
...  13.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-203 - add KW "Get Software Version" into TC Setup and variable
...                                                                 release into coam.Setup Admin
...  12.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-219 - add KW "Common step trigger" due to BIT CS4.3 Enable Sleeping Cell
...  28.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-228 - Adaptation to CNI-82119 and migration from hran_ta to robotlte repository
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***


*** Keywords ***
ALD.21_ALD_MHA_No_Connection_To_Unit

	ALD.21_ALD_MHA_No_Connection_To_Unit.Test_Step.0 Check If MHAs Are In Configuration
    ALD.21_ALD_MHA_No_Connection_To_Unit.Test_Step.1 Switch DC Off
    ALD.21_ALD_MHA_No_Connection_To_Unit.Test_Step.2 Check alarms and ALDs states
    ALD.21_ALD_MHA_No_Connection_To_Unit.Test_Step.3 Switch DC On
    ALD.21_ALD_MHA_No_Connection_To_Unit.Test_Step.4 Check alarms and ALDs states
    ALD.21_ALD_MHA_No_Connection_To_Unit.Test_Step.5 FEG Calculation

ALD.21_ALD_MHA_No_Connection_To_Unit.Test_Step.0 Check If MHAs Are In Configuration
    [Documentation]  Test step which checking if MHAs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Set Test Variable  ${FAC_CONFIG_FILE_PATH}  /home/ute/testline_configuration/${TESTLINE_NAME}/interfaces.yaml
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${num_of_MHAs}
    Set Test Variable  ${ALD_R_MHAs}
    ${MHA_FAC_interfaces}=  Get ALD Interfaces  ALD_type=MHA
    Set Test Variable  ${MHA_FAC_interfaces}
    Run Keyword If  ${MHA_FAC_interfaces}==[]
    ...  Fail  msg=You have no FAC device configured under /home/ute/testline_configuration/${TESTLINE_NAME}/interfaces.yaml
    Set Test Variable  ${FAC_PC_IP}  ${my_fac1['IP']}
    Set Test Variable  ${FAC_PORT}  ${my_fac1['PORT']}
    Run Keyword If  ${num_of_MHAs}==${0}
    ...  Fail  msg=There is no at least one expected MHA in configuration
    Log  You have ${num_of_MHAs} MHAs in configuration  console=${True}
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=putty.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=powershell.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=cmd.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=python.exe
    Connect To PC And Start FAC Agent  ${FAC_PC_IP}  ${FAC_PORT}

ALD.21_ALD_MHA_No_Connection_To_Unit.Test_Step.1 Switch DC ${type}
    [Documentation]  Disabling all DC outlets for MHAs.
    Log to console    \n========================================
    Log  Step: 1 Switch DC ${type}  console=${True}
    Log to console    ========================================
    Allow Fault In Watchdog  faultID=10  #fault_name: No connection to unit
    Switch DC Using FAC  ${type}  ${MHA_FAC_interfaces}
    Log  \nWaiting 3 minutes  console=${True}
    Sleep  180s

ALD.21_ALD_MHA_No_Connection_To_Unit.Test_Step.2 Check alarms and ALDs states
    [Documentation]
    ...    1. Check if fault 10 is visible.
    ...    2. Check if expected ALDs achieve state: availabilityStatus=not installed, operationalState=disabled.
    Log to console    \n========================================
    Log  Step: 2 Check alarms and ALDs states  console=${True}
    Log to console    ========================================
    ${alarms}=  admin.get active alarms
    ${source_active_10}=  Create List
    FOR  ${i}  IN  @{alarms}
        Run Keyword If  ${i['faultId']}==10  Run Keywords
        ...  Append To List  ${source_active_10}  ${i['configObjectName']}
        ...  AND
        ...  Log  Fault 10 is reported on source: ${i.configObjectName}    console=${True}
    END
    FOR  ${mha}  IN  @{ALD_R_MHAs}
        Check Dedicated ALD State  ${mha}  ${ALD_expected_state_notInstalled}
    END

ALD.21_ALD_MHA_No_Connection_To_Unit.Test_Step.3 Switch DC ${type}
    [Documentation]
    ...    1. Disabling all DC outlets for MHAs.
    ...    2. Check if expected ALDs achieve state: administrativeState=unlocked, operationalState=enabled.
    Log to console    \n========================================
    Log  Step: 3 Switch DC ${type}  console=${True}
    Log to console    ========================================
    Switch DC Using FAC  ${type}  ${MHA_FAC_interfaces}
    Log  \nWaiting 90 seconds  console=${True}
    Wait Until Keyword Succeeds  3min  30s  Check ALDs State  ${ALD_expected_states}
    Sleep  10s
    Disallow Fault In Watchdog  faultID=10  #fault_name: No connection to unit

ALD.21_ALD_MHA_No_Connection_To_Unit.Test_Step.4 Check alarms and ALDs states
    [Documentation]
    ...    1. Check if fault 10 is still visible.
    ...    2. Check if all ALDs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    ...    3. Check if other unexpected faults are visible.
    Log to console    \n========================================
    Log  Step: 4 Check alarms and ALDs states  console=${True}
    Log to console    ========================================
    ${status}=  Run Keyword And Return Status  admin.assert alarm active  faultID=10
    Run Keyword If  ${status}  Fail  msg=Fault 10 was not cleared
    ...  ELSE  Log  Fault 10 is not reported anymore  console=${True}
    Check ALDs State  ${ALD_expected_states}
    Check If Unexpected Alarms Are Raised  ${skip_fault}

ALD.21_ALD_MHA_No_Connection_To_Unit.Test_Step.5 FEG Calculation
    [Documentation]  This keyword is checking if front end gain is calculated properly.
    Log to console    \n================================================
    Log   Step: 5 FEG calculation  console=${True}
    Log to console    ================================================
    Check FEG On Antl Without MHA
    Check FEG On Antl With MHA

ALD.21_ALD_MHA_No_Connection_To_Unit.Test Specific Teardown
    [Documentation]
    ...   1. Switching FAC outlets on as a precaution.
    ...   2. Checking states on ALDs.
    Log  \nSwitching FAC outlets on as a precaution.  console=${True}
    Switch DC Using FAC  On  ${MHA_FAC_interfaces}
    Check ALDs State  ${ALD_expected_states}
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=putty.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=powershell.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=cmd.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=python.exe

ALD.21_ALD_MHA_No_Connection_To_Unit.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keywords
    ...  ALD.21_ALD_MHA_No_Connection_To_Unit.Test Specific Teardown
    ...  AND  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
