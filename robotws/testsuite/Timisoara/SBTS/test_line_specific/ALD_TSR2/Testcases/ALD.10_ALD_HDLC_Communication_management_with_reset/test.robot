*** Settings ***
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/common.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/alarms.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/ald.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.10_ALD_HDLC_Communication_management_with_reset
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to test HDLC communication management with reset procedure.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  *****************
...  12.11.2018 - Test case creation - https://jira3.int.net.nokia.com/browse/TAT-12961
...  12.12.2018 - https://jira3.int.net.nokia.com/browse/TAT-13576 - Added keyword: Find EndpointDN with Rmod
...  12.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-14560
...  02.05.2019 - https://jira3.int.net.nokia.com/browse/TAT-13910
...  03.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-15283
...  29.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18916
...  26.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21274
...  13.08.2021 - https://jira3.int.net.nokia.com/browse/TAT-21667
...  14.09.2021 - https://jira3.int.net.nokia.com/browse/TAT-21875
...  19.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-15 - Adaptation to CNI-61110
...  06.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-36 - Switch to hran_frame_sbts_siso resource
...  09.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-87 - adaptation to CNI-64298
...  21.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-95 - Add timeout in step 8
...  21.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-157 - Adaptation to CNI-82119 and migration from hran_ta to robotlte repository
...  09.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-524 - HDLC Communication management with reset fix after PR724851 closer
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***


*** Keywords ***
ALD.10_ALD_HDLC_Communication_management_with_reset

	ALD.10_ALD_HDLC_Communication_management_with_reset.Test_Step.0 Check If ALDs Are In Configuration
    ALD.10_ALD_HDLC_Communication_management_with_reset.Test_Step.1 HDLC switching OFF
    ALD.10_ALD_HDLC_Communication_management_with_reset.Test_Step.2 FEG calculation
    ALD.10_ALD_HDLC_Communication_management_with_reset.Test_Step.3 Checking alarms
    ALD.10_ALD_HDLC_Communication_management_with_reset.Test_Step.4 BTS reset
    ALD.10_ALD_HDLC_Communication_management_with_reset.Test_Step.5 FEG calculation
    ALD.10_ALD_HDLC_Communication_management_with_reset.Test_Step.6 Alarm Check after BTS reset
    ALD.10_ALD_HDLC_Communication_management_with_reset.Test_Step.7 HDLC switching ON
    ALD.10_ALD_HDLC_Communication_management_with_reset.Test_Step.8 Checking alarms
    ALD.10_ALD_HDLC_Communication_management_with_reset.Test_Step.9 FEG calculation
    ALD.10_ALD_HDLC_Communication_management_with_reset.Test_Step.10 Checking ALDs State

ALD.10_ALD_HDLC_Communication_management_with_reset.Test_Step.0 Check If ALDs Are In Configuration
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Set Test Variable  ${COMMISSIONING_PATH}  /home/ute/testline_configuration/${TESTLINE_NAME}/node1/SCF_01_${RELEASE}.xml
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Run Keyword If  ${num_of_MHAs}==${0} and ${num_of_RETs}==${0}
    ...  Fail  msg=There is no at least one ALD in configuration
    Log  You have ${num_of_MHAs} MHAs and ${num_of_RETs} RETs in configuration  console=${True}
    Make HDLC Settings Backup

ALD.10_ALD_HDLC_Communication_management_with_reset.Test_Step.1 HDLC switching OFF
    [Documentation]  Test step which switching off HDLC on selected ANTL and RSL.
    Log to console    \n========================================
    Log  Step: 1 HDLC switching Off  console=${True}
    Log to console    ========================================
    Allow Fault In Watchdog  faultID=4142  #fault_name: 3GPP/AISG communication administratively disabled
    HDLC Switching OFF
    Sleep  120s

ALD.10_ALD_HDLC_Communication_management_with_reset.Test_Step.${n} FEG calculation
    [Documentation]  This keyword is checking if front end gain is calculated properly.
    Log to console    \n========================================
    Log  Step: ${n} FEG calculation  console=${True}
    Log to console    ========================================
    Check FEG On Antl Without MHA
    Check FEG On Antl With MHA

ALD.10_ALD_HDLC_Communication_management_with_reset.Test_Step.3 Checking alarms
    [Documentation]  Check active alarms on BTS.
    Log to console    \n========================================
    Log  Step: 3 Checking alarms  console=${True}
    Log to console    ========================================
    Find Source of Reported 4142 Faults
    Get Alarm Source 4142
    Check Alarm 4142

ALD.10_ALD_HDLC_Communication_management_with_reset.Test_Step.4 BTS reset
    [Documentation]  BTS reset site and check states.
    Log to console    \n========================================
    Log  Step: 4 BTS reset  console=${True}
    Log to console    ========================================
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    admin.reset site  timeout=700
    Check SMODs State  ${SMOD_expected_states}
    Check RMODs State  ${RMOD_expected_states}
    Check ALDs State  ${ALD_expected_state_offline}
    common.Check BTS State  ${BTS_expected_states}
    Sleep    30s

ALD.10_ALD_HDLC_Communication_management_with_reset.Test_Step.6 Alarm Check after BTS reset
    [Documentation]  Check active alarms on BTS.
    Log to console    \n========================================
    Log  Step: 6 Alarm Check after BTS reset  console=${True}
    Log to console    ========================================
    Find Source of Reported 4142 Faults
    Get Alarm Source 4142
    ${alarm_sources}=  Set Variable  ${ALDS_SOURCES}
    ${alarm_sources}=  Remove Duplicates  ${alarm_sources}
    Sort List  ${source_active_4142}
    Sort List  ${alarm_sources}
    ${verdict}  Run Keyword And Ignore Error  Lists Should Be Equal  ${SOURCE_ACTIVE_4142}  ${alarm_sources}
    Run keyword If  '${verdict[0]}'== 'PASS'
    ...  Log  \n---- Fault 4142 sources are properly reported after BTS reset   console=${True}
    ...  ELSE
    ...  Fail   msg=Fault 4142 sources are not properly reported after BTS reset

ALD.10_ALD_HDLC_Communication_management_with_reset.Test_Step.7 HDLC switching ON
    [Documentation]  Test step which switching on HDLC on selected ANTL and RSL.
    Log to console    \n========================================
    Log  Step: 7 HDLC switching On  console=${True}
    Log to console    ========================================
    HDLC Switching ON
    Sleep  180s
    Check If NLWG Cells Are OnAir
    Disallow Fault In Watchdog  faultID=4142  #fault_name: 3GPP/AISG communication administratively disabled
    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB

ALD.10_ALD_HDLC_Communication_management_with_reset.Test_Step.8 Checking alarms
    [Documentation]  Check active alarms on BTS.
    Log to console    \n========================================
    Log  Step: 8 Checking alarms  console=${True}
    Log to console    ========================================
    ${status_4142}=  Run Keyword And Return Status  admin.assert alarm active  faultId=4142
    Run Keyword If  ${status_4142}  Fail  msg=Fault 4142 was not cleared
    ...  ELSE  Log  Fault 4142 is not reported  console=${True}
    ${status_10}=  Run Keyword And Return Status  admin.assert alarm active  faultId=10
    Run Keyword If  ${status_10}  Fail  msg=Fault 10 was not cleared
    ...  ELSE  Log  Fault 10 is not reported  console=${True}

ALD.10_ALD_HDLC_Communication_management_with_reset.Test_Step.10 Checking ALDs State
    [Documentation]  Check if all ALDs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    Log to console    \n========================================
    Log  Step: 10 Checking ALDs State   console=${True}
    Log to console    ========================================
	Check ALDs State  ${ALD_expected_states}
    Check If Unexpected Alarms Are Raised  ${skip_fault}

ALD.10_ALD_HDLC_Communication_management_with_reset.Test Specific Teardown
    [Documentation]  Test teardown which restores HDLC settings and executes reset site if needed.
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Log  \nRestoring HDLC settings  console=${True}
    Restore HDLC Settings
    ${ALD_status}=  Run Keyword And Return Status  Check ALDs State  ${ALD_expected_states}
    Run Keyword If  not ${ALD_status}  Run Keywords  Log To Console  BTS Reset site...
    ...  AND  Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    ...  AND  Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    ...  AND  Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB	    ...
	...  AND  admin.reset site  timeout=700
    ...  AND  Check SMODs State  ${SMOD_expected_states}
	...  AND  Check RMODs State  ${RMOD_expected_states}
	...  AND  Check ALDs State  ${ALD_expected_states}
    ...  AND  common.Check BTS State  ${BTS_expected_states}
    ...  AND  Check If NLWG Cells Are OnAir
    ...  AND  Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    ...  AND  Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    ...  AND  Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    ...  ELSE IF  ${ALD_status}  Run Keyword  Check If NLWG Cells Are OnAir
    admin.teardown admin  alias=${ute_admin_alias}

ALD.10_ALD_HDLC_Communication_management_with_reset.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keyword  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    Run Keyword If Test Failed  ALD.10_ALD_HDLC_Communication_management_with_reset.Test Specific Teardown
