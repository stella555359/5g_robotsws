*** Settings ***
Resource    ../../resources/common.robot
Resource    ../../resources/alarms.robot
Resource    ../../resources/ald.robot
Resource    ../../resources/fac.robot
Resource    ../../resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.20_ALD_RET_No_Connection_To_Unit
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this TC is to check if BTS behaviour is correct in case of losing connection to AISG 2.0
...  RET unexpectedly. Flexi Automation Controller is being used in this TC.
...  IMPORTANT NOTE:
...  For this test case to work it is required to use specific name convention for FAC outlets assigned to RETs:
...  RET_*ret_description* in interfaces.yaml configuration file.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  *****************
...  06.04.2018 https://jira3.int.net.nokia.com/browse/TAT-9544 - test file initial creation
...  12.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-14560
...  11.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-3 - migration to TAF
...  25.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-21 - adaptation to CNI-61110
...  06.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-36 - Switch to hran_frame_sbts_siso resource
...  26.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-134 - Increase sleep in step4
...  13.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-203 - add KW "Get Software Version" into TC Setup and variable
...                                                                 release into coam.Setup Admin
...  15.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-224 - Adaptation to CNI-82119 and migration from hran_ta to robotlte repository
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
ALD.20_ALD_RET_No_Connection_To_Unit

	ALD.20_ALD_RET_No_Connection_To_Unit.Test_Step.0 Check If ALDs Are In Configuration
    ALD.20_ALD_RET_No_Connection_To_Unit.Test_Step.1 Switch DC Off
    ALD.20_ALD_RET_No_Connection_To_Unit.Test_Step.2 Check alarms and ALDs states
    ALD.20_ALD_RET_No_Connection_To_Unit.Test_Step.3 Switch DC On
    ALD.20_ALD_RET_No_Connection_To_Unit.Test_Step.4 Check alarms and ALDs states

ALD.20_ALD_RET_No_Connection_To_Unit.Test_Step.0 Check If ALDs Are In Configuration
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Set Test Variable  ${FAC_CONFIG_FILE_PATH}  /home/ute/testline_configuration/${TESTLINE_NAME}/interfaces.yaml
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${num_of_RETs}
    Set Test Variable  ${ALD_R_RETs}
    ${RET_FAC_interfaces}=  Get ALD Interfaces  ALD_type=RET
    Set Test Variable  ${RET_FAC_interfaces}
    IF  ${RET_FAC_interfaces}==[]  Fail  msg=You have no FAC device configured under /home/ute/testline_configuration/${TESTLINE_NAME}/interfaces.yaml
    Set Test Variable  ${FAC_PC_IP}  ${my_fac1['IP']}
    Set Test Variable  ${FAC_PORT}  ${my_fac1['PORT']}
    IF  ${num_of_RETs}==${0}  Fail  msg=There is no at least one expected RET in configuration
    Log  You have ${num_of_RETs} RETs in configuration  console=${True}
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=putty.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=powershell.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=cmd.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=python.exe
    Connect To PC And Start FAC Agent  ${FAC_PC_IP}  ${FAC_PORT}

ALD.20_ALD_RET_No_Connection_To_Unit.Test_Step.1 Switch DC ${type}
    [Documentation]  Disabling all DC outlets for RETs.
    Log to console    \n========================================
    Log  Step: 1 Switch DC ${type}  console=${True}
    Log to console    ========================================
    Allow Fault In Watchdog  faultID=10  #fault_name: No connection to unit
    Switch DC Using FAC  ${type}  ${RET_FAC_interfaces}
    Log  \nWaiting 3 minutes  console=${True}
    Sleep  180s

ALD.20_ALD_RET_No_Connection_To_Unit.Test_Step.2 Check alarms and ALDs states
    [Documentation]
    ...    1. Check if fault 10 is visible.
    ...    2. Check if expected ALDs achieve state: availabilityStatus=not installed, operationalState=disabled.
    Log to console    \n========================================
    Log  Step: 2 Check alarms and ALDs states  console=${True}
    Log to console    ========================================
    ${alarms}=  admin.get active alarms
    ${source_active_10}=  Create List
    FOR  ${i}  IN  @{alarms}
        IF  ${i['faultId']}==10
            Append To List  ${source_active_10}  ${i['configObjectName']}
            Log  Fault 10 is reported on source: ${i.configObjectName}    console=${True}
        END
    END
    ${num_of_active_10}=  Get Length  ${source_active_10}
    ${num_of_active_10}=  Convert To Number  ${num_of_active_10}
    ${num_of_RETs}=  Convert To Number  ${num_of_RETs}
    Should Be Equal As Numbers  ${num_of_active_10}  ${num_of_RETs}
    FOR  ${ret}  IN  @{ALD_R_RETs}
        Check Dedicated ALD State  ${ret}  ${ALD_expected_state_notInstalled}
    END

ALD.20_ALD_RET_No_Connection_To_Unit.Test_Step.3 Switch DC ${type}
    [Documentation]
    ...    1. Disabling all DC outlets for RETs.
    ...    2. Check if expected ALDs achieve state: administrativeState=unlocked, operationalState=enabled.
    Log to console    \n========================================
    Log  Step: 3 Switch DC ${type}  console=${True}
    Log to console    ========================================
    Switch DC Using FAC  ${type}  ${RET_FAC_interfaces}
    Log  \nWaiting 90 seconds  console=${True}
    Wait Until Keyword Succeeds  3min  30s  Check ALDs State  ${ALD_expected_states}
    Sleep  10s
    Disallow Fault In Watchdog  faultID=10  #fault_name: No connection to unit

ALD.20_ALD_RET_No_Connection_To_Unit.Test_Step.4 Check alarms and ALDs states
    [Documentation]
    ...    1. Check if fault 10 is still visible.
    ...    2. Check if all ALDs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    ...    3. Check if other unexpected faults are visible.
    Log to console    \n========================================
    Log  Step: 4 Check alarms and ALDs states  console=${True}
    Log to console    ========================================
    ${status}=  Run Keyword And Return Status  admin.assert alarm active  faultID=10
    IF  ${status}
        Fail  msg=Fault 10 was not cleared
    ELSE
        Log  Fault 10 is not reported anymore  console=${True}
    END
    Check ALDs State  ${ALD_expected_states}
    Check If Unexpected Alarms Are Raised  ${skip_fault}

ALD.20_ALD_RET_No_Connection_To_Unit.Test Specific Teardown
    [Documentation]
    ...   1. Switching FAC outlets on as a precaution.
    ...   2. Checking states on ALDs.
    Log  \nSwitching FAC outlets on as a precaution.  console=${True}
    Switch DC Using FAC  On  ${RET_FAC_interfaces}
    Check ALDs State  ${ALD_expected_states}
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=putty.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=powershell.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=cmd.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=python.exe

ALD.20_ALD_RET_No_Connection_To_Unit.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keywords
    ...  ALD.20_ALD_RET_No_Connection_To_Unit.Test Specific Teardown
    ...  AND  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
