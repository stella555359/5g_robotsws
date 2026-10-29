*** Settings ***
Resource    ../../resources/common.robot
Resource    ../../resources/alarms.robot
Resource    ../../resources/ald.robot
Resource    ../../resources/fac.robot
Resource    ../../resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.26_ALD_MHA_Below_Current
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this TC is to check if BTS behaviour is correct in case report 1835 alarm.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  *****************
...  14.01.2021 - test creation
...  09.09.2021 - https://jira3.int.net.nokia.com/browse/TAT-21800
...  25.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-22 - adaptation to CNI-61110 and usage of ca_ald_resource
...  06.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-36 - Switch to hran_frame_sbts_siso resource
...  08.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-106
...  13.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-203 - add KW "Get Software Version" into TC Setup and variable
...                                                                 release into coam.Setup Admin
...  12.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-219 - add KW "Common step trigger" due to BIT CS4.3 Enable Sleeping Cell
...  09.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-243 - Adaptation to CNI-82119 and migration from hran_ta to robotlte repository
...  29.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-500 - Modify TC: Automated__ALD__MHA Below Current alarm for FEG calculation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
ALD.26_ALD_MHA_Below_Current

	ALD.26_ALD_MHA_Below_Current.Test_Step.0 Test Preconditions
    ALD.26_ALD_MHA_Below_Current.Test_Step.1 Generate Fault 1835
    ALD.26_ALD_MHA_Below_Current.Test_Step.2 Check Alarms And MHA State
    ALD.26_ALD_MHA_Below_Current.Test_Step.3 FEG Calculation
    ALD.26_ALD_MHA_Below_Current.Test_Step.4 Clear Fault Conditions
    ALD.26_ALD_MHA_Below_Current.Test_Step.5 RMOD Lock/Unlock
    ALD.26_ALD_MHA_Below_Current.Test_Step.6 FEG Calculation
    ALD.26_ALD_MHA_Below_Current.Test_Step.7 Check Alarms After Remove Fault Conditions

ALD.26_ALD_MHA_Below_Current.Test_Step.0 Test Preconditions
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Set Test Variable  ${COMMISSIONING_PATH}  /home/ute/testline_configuration/${TESTLINE_NAME}/node1/SCF_01_${RELEASE}.xml
    Set Test Variable  ${COMMISSIONING_PATH_CWA}  /home/ute/testline_configuration/${TESTLINE_NAME}/node1/SCF_CWA.xml
    Set Test Variable  ${FAC_CONFIG_FILE_PATH}  /home/ute/testline_configuration/${TESTLINE_NAME}/interfaces.yaml
    ${BELOW_FAC_interface}=  Get ALD Interfaces  ALD_type=${BELOW_INTERFACE}
    Set Test Variable  ${BELOW_FAC_interface}
    IF  ${BELOW_FAC_interface}==[]  Fail  You have no FAC device configured under /home/ute/testline_configuration/${TESTLINE_NAME}/interfaces.yaml
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

ALD.26_ALD_MHA_Below_Current.Test_Step.1 Generate Fault 1835
    [Documentation]  Generate Fault 1835.
    Log to console    \n========================================
    Log  Step: 1 Genereting Fault 1835 - above currnet  console=${True}
    Log to console    ========================================
    Allow Fault In Watchdog  faultID=1835  #fault_name: Mast Head Amplifier fault below current window
    Switch DC Using FAC  Off  ${BELOW_FAC_interface}
    Log  \nWaiting 3 minutes  console=${True}
    Sleep  180s

ALD.26_ALD_MHA_Below_Current.Test_Step.2 Check Alarms And MHA State
    [Documentation]
    ...    1. Check if fault 1835 is visible.
    ...    2. Check if expected ALDs achieve state: availabilityStatus=failed, operationalState=disabled.
    Log to console    \n================================================
    Log   Step: 2 Check alarms and ALDs states  console=${True}
    Log to console    ================================================
    ${alarms}=  admin.get active alarms
    ${alarm_info}=  Run Keyword And Return Status  admin.assert alarm active  faultId=1835
    IF  not ${alarm_info}  Fail  msg=There is no expected faultId 1835
    ${source_active_1835}=  Create List
    FOR  ${i}  IN  @{alarms}
        IF  ${i['faultId']}==1835
            Append To List  ${source_active_1835}  ${i['configObjectName']}
            Log  Fault 1835 is reported on source: ${i.configObjectName}    console=${True}
        END
    END
    Check Dedicated ALD State  ${ALD}  ${ALD_expected_state_failed}

ALD.26_ALD_MHA_Below_Current.Test_Step.3 FEG Calculation
    [Documentation]  This keyword is checking if front end gain is calculated properly.
    Log to console    \n================================================
    Log   Step: 3 FEG calculation  console=${True}
    Log to console    ================================================
    Check FEG On ANTL Where Is Loglink With Recovery

ALD.26_ALD_MHA_Below_Current.Test_Step.4 Clear Fault Conditions
    [Documentation]  Clear Fault 1835 Conditions.
    Log to console    \n========================================
    Log  Step: 4 Clear Fault 1835 Conditions  console=${True}
    Log to console    ========================================
    Switch DC Using FAC  On  ${BELOW_FAC_interface}
    Log  \nWaiting 30 seconds  console=${True}
    Sleep  30s

ALD.26_ALD_MHA_Below_Current.Test_Step.5 RMOD Lock/Unlock
    [Documentation]  Locking and unlocking every radio modules.
    Log to console    \n========================================
    Log  Step: 5 Locking and unlocking every radio modules  console=${True}
    Log to console    ========================================
    ${rmod_dist_r}=   admin.get ids for all  RMOD
    FOR  ${rmod_dist}  IN  @{rmod_dist_r}
        ${rmod}=  Should Match Regexp  ${rmod_dist}  RMOD_R-\\d+
        Log  Locking ${rmod}  console=${true}
        admin.lock  ${rmod_dist}  timeout=240
        Sleep  30s
        Log  Unlocking ${rmod}  console=${true}
        admin.unlock  ${rmod_dist}  timeout=240
        Check RMODs State  ${RMOD_expected_states}
    END
    Check If NLWG Cells Are OnAir
    Check ALDs State  ${ALD_expected_states}
    Disallow Fault In Watchdog  faultID=1835  #fault_name: Mast Head Amplifier fault below current window

ALD.26_ALD_MHA_Below_Current.Test_Step.6 FEG Calculation
    [Documentation]  This keyword is checking if front end gain is calculated properly.
    Log to console    \n================================================
    Log   Step: 6 FEG calculation  console=${True}
    Log to console    ================================================
    Check FEG On Antl Without MHA
    Check FEG On Antl With MHA

ALD.26_ALD_MHA_Below_Current.Test_Step.7 Check Alarms After Remove Fault Conditions
    [Documentation]
    ...    1. Check if fault 1835 is still visible.
    ...    2. Check if other unexpected faults are visible.
    ...    3. Check if all ALDs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    Log to console    \n================================================
    Log  Step: 7 Check Alarms After Remove Fault Conditions  console=${True}
    Log to console    ================================================
    ${alarm_info}=  Run Keyword And Return Status  admin.assert alarm active  faultId=1835
    IF  ${alarm_info}
        Fail  msg=There is still faultId 1835 raised
    ELSE
        Log  FaultId 1835 has been cleared  console=${True}
    END
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    Check ALDs State  ${ALD_expected_states}

ALD.26_ALD_MHA_Below_Current.Test Specific Teardown
    [Documentation]
    ...   1. Switching FAC outlets on as a precaution.
    ...   2. Restoring original configuration settings.
    ...   3. Checking states on SMODs, RMODs, ALDs.
    ...   4. Checking cells.
    Log  \nSwitching FAC outlets on as a precaution.  console=${True}
    Switch DC Using FAC  On  ${BELOW_FAC_interface}
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Log  \nRestoring original configuration settings  console=${True}
    admin.perform commissioning  ${MRBTS_ID}  ${COMMISSIONING_PATH}  ${SKIP_PARAMETER_RELATION_ERRORS}  ${SHOULD_ACTIVATE}  timeout=600
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

ALD.26_ALD_MHA_Below_Current.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keywords  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    ...  AND  ALD.26_ALD_MHA_Below_Current.Test Specific Teardown
