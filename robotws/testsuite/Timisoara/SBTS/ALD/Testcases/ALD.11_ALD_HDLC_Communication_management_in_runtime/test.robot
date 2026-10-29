*** Settings ***
Resource    ../../resources/common.robot
Resource    ../../resources/alarms.robot
Resource    ../../resources/ald.robot
Resource    ../../resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.11_ALD_HDLC_Communication_management_in_runtime
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to check DC voltage managment procedure.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  *****************
...  14.07.2017 - https://jira3.int.net.nokia.com/browse/TAT-7131 - New TC available
...  02.11.2018 - https://jira3.int.net.nokia.com/browse/TAT-11150 - Whole TC changed
...  12.12.2018 - https://jira3.int.net.nokia.com/browse/TAT-13576 - Added keyword: Find EndpointDN with Rmod
...  12.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-14560
...  30.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-13910
...  03.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-15283
...  08.09.2021 - https://jira3.int.net.nokia.com/browse/TAT-21874
...  06.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-36 - Switch to hran_frame_sbts_siso resource
...  21.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-158 - Adaptation to CNI-82119 and migration from hran_ta to robotlte repository
...  28.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-231 - Add recovery action as BTS Reset Site in Test Specific Teardown
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
ALD.11_ALD_HDLC_Communication_management_in_runtime

	ALD.11_ALD_HDLC_Communication_management_in_runtime.Test_Step.0 Check If ALDs Are In Configuration
    ALD.11_ALD_HDLC_Communication_management_in_runtime.Test_Step.1 HDLC switching OFF
    ALD.11_ALD_HDLC_Communication_management_in_runtime.Test_Step.2 FEG calculation
    ALD.11_ALD_HDLC_Communication_management_in_runtime.Test_Step.3 Checking alarms
    ALD.11_ALD_HDLC_Communication_management_in_runtime.Test_Step.4 Checking ALDs State
    ALD.11_ALD_HDLC_Communication_management_in_runtime.Test_Step.5 HDLC switching ON
    ALD.11_ALD_HDLC_Communication_management_in_runtime.Test_Step.6 FEG calculation
    ALD.11_ALD_HDLC_Communication_management_in_runtime.Test_Step.7 Alarm Check after HDLC ON
    ALD.11_ALD_HDLC_Communication_management_in_runtime.Test_Step.8 Checking ALDs State

ALD.11_ALD_HDLC_Communication_management_in_runtime.Test_Step.0 Check If ALDs Are In Configuration
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Set Test Variable  ${COMMISSIONING_PATH}  /home/ute/testline_configuration/${TESTLINE_NAME}/node1/SCF_01_${RELEASE}.xml
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    IF  ${num_of_MHAs}==${0} and ${num_of_RETs}==${0}  Fail  msg=There is no at least one ALD in configuration
    Log  You have ${num_of_MHAs} MHAs and ${num_of_RETs} RETs in configuration  console=${True}
    Make HDLC Settings Backup

ALD.11_ALD_HDLC_Communication_management_in_runtime.Test_Step.1 HDLC switching OFF
    [Documentation]  Test step which switching off HDLC on selected ANTL and RSL.
    Log to console    \n========================================
    Log  Step: 1 HDLC switching Off  console=${True}
    Log to console    ========================================
    Allow Fault In Watchdog  faultID=4142  #fault_name: 3GPP/AISG communication administratively disabled
    HDLC Switching OFF
    Sleep  120s

ALD.11_ALD_HDLC_Communication_management_in_runtime.Test_Step.3 Checking alarms
    [Documentation]  Check active alarms on BTS.
    Log to console    \n========================================
    Log  Step: 3 Checking alarms  console=${True}
    Log to console    ========================================
    Find Source of Reported 4142 Faults
    Get Alarm Source 4142
    Check Alarm 4142

ALD.11_ALD_HDLC_Communication_management_in_runtime.Test_Step.4 Checking ALDs State
    [Documentation]  Check if all ALDs achieve expected state: availabilityStatus=off line, operationalState=disabled.
    Log to console    \n========================================
    Log  Step: 4 Checking ALDs State  console=${True}
    Log to console    ========================================
    Check ALDs State  ${ALD_expected_state_offline}

ALD.11_ALD_HDLC_Communication_management_in_runtime.Test_Step.5 HDLC switching ON
    [Documentation]  Test step which switching on HDLC on selected ANTL and RSL.
    Log to console    \n========================================
    Log  Step: 4 HDLC switching ON  console=${True}
    Log to console    ========================================
    HDLC Switching ON
    Sleep  120s

ALD.11_ALD_HDLC_Communication_management_in_runtime.Test_Step.${n} FEG calculation
    [Documentation]  This keyword is checking if front end gain is calculated properly.
    Log to console    \n========================================
    Log  Step: ${n} FEG calculation  console=${True}
    Log to console    ========================================
    Check FEG On Antl Without MHA
    Check FEG On Antl With MHA

ALD.11_ALD_HDLC_Communication_management_in_runtime.Test_Step.7 Alarm Check after HDLC ON
    [Documentation]  Test step which switching ON HDLC on selected ANTL and RSL.
    Log to console    \n========================================
    Log  Step: 6 Alarm Check after HDLC ON  console=${True}
    Log to console    ========================================
    Disallow Fault In Watchdog  faultID=4142  #fault_name: 3GPP/AISG communication administratively disabled
    ${status_4142}=  Run Keyword And Return Status  admin.assert alarm active  faultId=4142
    IF  ${status_4142}
        Fail  msg=Fault 4142 was not cleared
    ELSE
        Log  Fault 4142 is not reported  console=${True}
    END
    ${status_10}=  Run Keyword And Return Status  admin.assert alarm active  faultId=10
    IF  ${status_10}
        Fail  msg=Fault 10 was not cleared
    ELSE
        Log  Fault 10 is not reported  console=${True}
    END

ALD.11_ALD_HDLC_Communication_management_in_runtime.Test_Step.8 Checking ALDs State
    [Documentation]  Check if all ALDs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    Log to console    \n========================================
    Log  Step: 7 Checking ALDs State   console=${True}
    Log to console    ========================================
	Check ALDs State  ${ALD_expected_states}
    Check If Unexpected Alarms Are Raised  ${skip_fault}

ALD.11_ALD_HDLC_Communication_management_in_runtime.Test Specific Teardown
    [Documentation]  Test teardown which restores HDLC settings and executes reset site if needed.
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Log  \nRestoring HDLC settings  console=${True}
    Restore HDLC Settings
    ${ALD_status}=  Run Keyword And Return Status  Check ALDs State  ${ALD_expected_states}
    IF  not ${ALD_status}
        Log To Console  BTS Reset site...
        Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
        Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
        Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB	    ...
	    admin.reset site  timeout=700
        Check SMODs State  ${SMOD_expected_states}
	    Check RMODs State  ${RMOD_expected_states}
	    Check ALDs State  ${ALD_expected_states}
        common.Check BTS State  ${BTS_expected_states}
        Check If NLWG Cells Are OnAir
        Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
        Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
        Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    ELSE IF  ${ALD_status}
        Check If NLWG Cells Are OnAir
    END
    admin.teardown admin  alias=${ute_admin_alias}

ALD.11_ALD_HDLC_Communication_management_in_runtime.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keyword  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    Run Keyword If Test Failed  ALD.11_ALD_HDLC_Communication_management_in_runtime.Test Specific Teardown
