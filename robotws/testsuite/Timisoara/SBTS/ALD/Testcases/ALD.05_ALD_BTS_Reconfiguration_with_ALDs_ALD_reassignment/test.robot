*** Settings ***
Resource    ../../resources/common.robot
Resource    ../../resources/alarms.robot
Resource    ../../resources/ald.robot
Resource    ../../resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.05_ALD_BTS_Reconfiguration_with_ALDs_ALD_reassignment
...  AUTHORS:       damian.sliwinski@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to check reconfiguration MHA and RET procedure.
...  The new antenna lines to be set in the test are defined in external JSON file, a path for which needs
...  to be provided as TC parameter `${DELTA_JSON}`.
...  The default path is `ALD.05_ALD_BTS_Reconfiguration_with_ALDs_ALD_reassignment/json/${TESTLINE_NAME}_reassignment.json`.
...  Example for single MHA and RET
...  [
...    {
...        "distName":"MRBTS-5004/EQM-1/HWTOP-1/LOGLINK-3",
...        "operation":"update",
...        "parameters":[
...            {
...                "parameterName":"secondEndpointDN",
...                "operation":"update",
...                "value":"MRBTS-5004/EQM-1/APEQM-1/RMOD-1/ANTL-4"
...            }
...        ]
...    },
...    {
...        "distName":"MRBTS-5004/EQM-1/APEQM-1/ALD-3/RETU-1",
...        "operation":"update",
...        "parameters":[
...            {
...                "parameterName":"antlDNList",
...                "operation":"update",
...                "value":"MRBTS-5004/EQM-1/APEQM-1/RMOD-2/ANTL-8"
...            }
...        ]
...    }
...  ]
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  10.12.2018 - Test Case creation
...  12.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-14560
...  03.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-15283
...  02.11.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-30 - adaptation to CNI-61110
...  22.11.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-6 - changing approach to MHA reassignment
...  06.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-36 - Switch to hran_frame_sbts_siso resource
...  22.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-160 - Adaptation to CNI-82119 and migration from hran_ta to robotlte repository
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
ALD.05_ALD_BTS_Reconfiguration_with_ALDs_ALD_reassignment

	ALD.05_ALD_BTS_Reconfiguration_with_ALDs_ALD_reassignment.Test_Step.0 Check If ALDs Are In Configuration
    ALD.05_ALD_BTS_Reconfiguration_with_ALDs_ALD_reassignment.Test_Step.1 Reconfigure RET and MHA
    ALD.05_ALD_BTS_Reconfiguration_with_ALDs_ALD_reassignment.Test_Step.2 Checking States And Alarms
    ALD.05_ALD_BTS_Reconfiguration_with_ALDs_ALD_reassignment.Test_Step.3 FEG calculation

ALD.05_ALD_BTS_Reconfiguration_with_ALDs_ALD_reassignment.Test_Step.0 Check If ALDs Are In Configuration
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Set Test Variable  ${COMMISSIONING_PATH}  /home/ute/testline_configuration/${TESTLINE_NAME}/node1/SCF_01_${RELEASE}.xml
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    IF  ${num_of_MHAs}==${0} and ${num_of_RETs}==${0}  Fail  msg=There is no at least one ALD in configuration
    Log  You have ${num_of_MHAs} MHAs and ${num_of_RETs} RETs in configuration  console=${True}
    Set Test Variable  ${DELTA_JSON}  ${CURDIR}/json/${TESTLINE_NAME}_reassignment.json

ALD.05_ALD_BTS_Reconfiguration_with_ALDs_ALD_reassignment.Test_Step.1 Reconfigure RET and MHA
    [Documentation]  Reconfigure RET and MHA via json file.
    Log to console    \n========================================
    Log  Step: 1 Reconfigure RET and MHA  console=${True}
    Log to console    ========================================
    Wait Until Keyword Succeeds  3x  30s  admin.perform delta recommissioning  ${DELTA_JSON}
    ...  ${SKIP_PARAMETER_RELATION_ERRORS}  ${SHOULD_ACTIVATE}  timeout=600
    Log  Delta recommissioning for reconfigure RET and MHA successful  console=${true}
    Sleep  10s

ALD.05_ALD_BTS_Reconfiguration_with_ALDs_ALD_reassignment.Test_Step.2 Checking States And Alarms
    [Documentation]
    ...  1. Check if all SMODs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    ...  2. Check if all RMODs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    ...  3. Check if all ALDs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    ...  4. Check if BTS have expected state: proceduralState=OnAir, blockingState=Unblocked.
    ...  5. Check if all cells are on air.
    ...  6. Check active alarms on BTS.
    Log to console    \n========================================
    Log  Step: 2 Checking states and alarms on BTS  console=${True}
    Log to console    ========================================
	Check SMODs State  ${SMOD_expected_states}
	Check RMODs State  ${RMOD_expected_states}
	Check ALDs State  ${ALD_expected_states}
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Check If Unexpected Alarms Are Raised  ${skip_fault}

ALD.05_ALD_BTS_Reconfiguration_with_ALDs_ALD_reassignment.Test_Step.3 FEG calculation
    [Documentation]  This keyword is checking if front end gain is calculated properly.
    Log to console    \n========================================
    Log  Step: 2 FEG calculation  console=${True}
    Log to console    ========================================
    Check FEG On Antl Without MHA
    Check FEG On Antl With MHA

ALD.05_ALD_BTS_Reconfiguration_with_ALDs_ALD_reassignment.Test Specific Teardown
    [Documentation]  Test teardown which restores original configuration settings.
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Log  Restoring original configuration settings.  console=${True}
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

ALD.05_ALD_BTS_Reconfiguration_with_ALDs_ALD_reassignment.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keywords  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    ...  AND  ALD.05_ALD_BTS_Reconfiguration_with_ALDs_ALD_reassignment.Test Specific Teardown
