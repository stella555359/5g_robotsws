*** Settings ***
Resource    ../../resources/common.robot
Resource    ../../resources/alarms.robot
Resource    ../../resources/ald.robot
Resource    ../../resources/fac.robot
Resource    ../../resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.25_ALD_MHA_Above_Current
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this TC is to check if BTS behaviour is correct in case report 1834 alarm.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  *****************
...  21.01.2019 - test creation
...  4.04.2019  - final version
...  9.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-16851
...  08.12.2020 - https://jira3.int.net.nokia.com/browse/TAT-20073
...  24.08.2021 - https://jira3.int.net.nokia.com/browse/TAT-21766
...  03.11.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-29 - adaptation to CNI-61110
...  06.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-36 - Switch to hran_frame_sbts_siso resource
...  13.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-203 - add KW "Get Software Version" into TC Setup and variable
...                                                                 release into coam.Setup Admin
...  12.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-219 - add KW "Common step trigger" due to BIT CS4.3 Enable Sleeping Cell
...  09.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-242 - Adaptation to CNI-82119 and migration from hran_ta to robotlte repository
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
ALD.25_ALD_MHA_Above_Current

	ALD.25_ALD_MHA_Above_Current.Test_Step.0 Test Preconditions
    ALD.25_ALD_MHA_Above_Current.Test_Step.1 Generate Fault 1834
    ALD.25_ALD_MHA_Above_Current.Test_Step.2 Check Alarms And MHA State
    ALD.25_ALD_MHA_Above_Current.Test_Step.3 FEG Calculation
    ALD.25_ALD_MHA_Above_Current.Test_Step.4 Clear Fault Conditions
    ALD.25_ALD_MHA_Above_Current.Test_Step.5 FEG Calculation
    ALD.25_ALD_MHA_Above_Current.Test_Step.6 Check Alarms After Remove Fault Conditions

ALD.25_ALD_MHA_Above_Current.Test_Step.0 Test Preconditions
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Set Test Variable  ${COMMISSIONING_PATH}  /home/ute/testline_configuration/${TESTLINE_NAME}/node1/SCF_01_${RELEASE}.xml
    Set Test Variable  ${COMMISSIONING_PATH_CWA}  /home/ute/testline_configuration/${TESTLINE_NAME}/node1/SCF_CWA.xml
    Set Test Variable  ${FAC_CONFIG_FILE_PATH}  /home/ute/testline_configuration/${TESTLINE_NAME}/interfaces.yaml
    ${ABOVE_FAC_interface}=  Get ALD Interfaces  ALD_type=${ABOVE_INTERFACE}
    Set Test Variable  ${ABOVE_FAC_interface}
    IF  ${ABOVE_FAC_interface}==[]  Fail  You have no FAC device configured under /home/ute/testline_configuration/${TESTLINE_NAME}/interfaces.yaml
    Set Test Variable  ${FAC_PC_IP}  ${my_fac1['IP']}
    Set Test Variable  ${FAC_PORT}  ${my_fac1['PORT']}
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Log  Recommissioning for CWA configuration  console=${true}
    admin.perform commissioning  ${MRBTS_ID}  ${COMMISSIONING_PATH_CWA}  ${SKIP_PARAMETER_RELATION_ERRORS}  ${SHOULD_ACTIVATE}  timeout=600
	Check SMODs State  ${SMOD_expected_states}
	Check RMODs State  ${RMOD_expected_states}
	Check ALDs State  ${ALD_expected_states}
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    ${ANTL_A_FULL_DN}=  Get ANTL_A Full DistName String  ${ANTL_A}
    Set Test Variable  ${ANTL_A_FULL_DN}
    ${ALD}  ${lna_dist_names}  Get Affected LNAs And MHAs  ${ANTL_A_FULL_DN}
    Set Test Variable  ${ALD}
    ${ALD_R_to_ALD_A}=  Mapping ALD_R To ALD_A
    ${ALD_A_FULL_DN}=  Get From Dictionary  ${ALD_R_to_ALD_A}  ${ALD}
    Set Test Variable  ${ALD_A_FULL_DN}
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=putty.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=powershell.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=cmd.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=python.exe
    Connect To PC And Start FAC Agent  ${FAC_PC_IP}  ${FAC_PORT}

ALD.25_ALD_MHA_Above_Current.Test_Step.1 Generate Fault 1834
    [Documentation]  Generate Fault 1834.
    Log to console    \n========================================
    Log  Step: 1 Genereting Fault 1834 - above currnet  console=${True}
    Log to console    ========================================
    Allow Fault In Watchdog  faultID=1834  #fault_name: Mast Head Amplifier fault above current window
    Switch DC Using FAC  On  ${ABOVE_FAC_interface}
    Set Parameter Under ANTL Object  ${ANTL_A_FULL_DN}  cwaThreshold  120
    Log  \nWaiting 3 minutes  console=${True}
    Sleep  180s

ALD.25_ALD_MHA_Above_Current.Test_Step.2 Check Alarms And MHA State
    [Documentation]
    ...    1. Check if fault 1834 is visible.
    ...    2. Check if expected ALDs achieve state: availabilityStatus=degraded, operationalState=enabled.
    Log to console    \n================================================
    Log   Step: 2 Check alarms and ALDs states  console=${True}
    Log to console    ================================================
    ${alarms}=  admin.get active alarms
    ${alarm_info}=  Run Keyword And Return Status  admin.assert alarm active  faultId=1834
    IF  not ${alarm_info}  Fail  msg=There is no expected faultId 1834
    ${source_active_1834}=  Create List
    FOR  ${i}  IN  @{alarms}
        IF  ${i['faultId']}==1834
            Append To List  ${source_active_1834}  ${i['configObjectName']}
            Log  Fault 1834 is reported on source: ${i.configObjectName}    console=${True}
        END
    END
    Check Dedicated ALD State  ${ALD}  ${ALD_expected_state_degraded}

ALD.25_ALD_MHA_Above_Current.Test_Step.${n} FEG Calculation
    [Documentation]  This keyword is checking if front end gain is calculated properly.
    Log to console    \n================================================
    Log   Step: ${n} FEG calculation  console=${True}
    Log to console    ================================================
    Check FEG On Antl Without MHA
    Check FEG On Antl With MHA

ALD.25_ALD_MHA_Above_Current.Test_Step.4 Clear Fault Conditions
    [Documentation]  Clear Fault 1834 Conditions.
    Log to console    \n========================================
    Log  Step: 4 Clear Fault 1834 Conditions  console=${True}
    Log to console    ========================================
    Switch DC Using FAC  Off  ${ABOVE_FAC_interface}
    Set Parameter Under ANTL Object  ${ANTL_A_FULL_DN}  cwaThreshold  400
    Log  \nWaiting 1 minute  console=${True}
    Sleep  60s
    Disallow Fault In Watchdog  faultID=1834  #fault_name: Mast Head Amplifier fault above current window

ALD.25_ALD_MHA_Above_Current.Test_Step.6 Check Alarms After Remove Fault Conditions
    [Documentation]
    ...    1. Check if fault 1834 is still visible.
    ...    2. Check if other unexpected faults are visible.
    ...    3. Check if all ALDs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    Log to console    \n================================================
    Log  Step: 6 Check Alarms After Remove Fault Conditions  console=${True}
    Log to console    ================================================
    ${alarm_info}=  Run Keyword And Return Status  admin.assert alarm active  faultId=1834
    IF  ${alarm_info}
        Fail  msg=There is still faultId 1834 raised
    ELSE
        Log  FaultId 1834 has been cleared  console=${True}
    END
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    Check ALDs State  ${ALD_expected_states}

ALD.25_ALD_MHA_Above_Current.Test Specific Teardown
    [Documentation]
    ...   1. Switching FAC outlets on as a precaution.
    ...   2. Restoring original configuration settings.
    ...   3. Checking states on SMODs, RMODs, ALDs.
    ...   4. Checking cells.
    Log  \nSwitching FAC outlets on as a precaution.  console=${True}
    Switch DC Using FAC  Off  ${ABOVE_FAC_interface}
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Log  \nRestoring original configuration settings  console=${True}
    admin.perform commissioning  ${MRBTS_ID}  ${COMMISSIONING_PATH}  ${skip_parameter_relation_errors}  ${SHOULD_ACTIVATE}  timeout=600
	Check SMODs State  ${SMOD_expected_states}
	Check RMODs State  ${RMOD_expected_states}
	Check ALDs State  ${ALD_expected_states}
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    admin.teardown admin  alias=${ute_admin_alias}
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=putty.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=powershell.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=cmd.exe
    Run Keyword And Ignore Error  Kill Active Process On PC If Exist  ${FAC_PC_IP}  ${FAC_PC_LOGIN}  ${FAC_PC_PASS}  process=python.exe

ALD.25_ALD_MHA_Above_Current.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keywords  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    ...  AND  ALD.25_ALD_MHA_Above_Current.Test Specific Teardown
