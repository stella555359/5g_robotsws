*** Settings ***
Resource    ../../resources/common.robot
Resource    ../../resources/alarms.robot
Resource    ../../resources/ald.robot
Resource    ../../resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.13_ALD_Detect_and_setup_RF_module_reset_with_configured_ALDs
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to check if Antenna Line Devices (MHA/RET) are detected and work properly
...  after radio modules reset procedure.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  *****************
...  30.07.2021 - https://jira3.int.net.nokia.com/browse/TAT-21679
...  19.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-16 - Adaptation to CNI-61110
...  06.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-36 - Switch to hran_frame_sbts_siso resource
...  20.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-151 - Adaptation to CNI-82119 and migration from hran_ta to robotlte repository
...  13.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-223 - Add KW "Check If NLWG Cells Are OnAir" during loop in Test_Step.1
...  22.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-338 - Test case adaptation to CB007184 - FID 4003 on LTE cells
...  13.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28737 - Ignore BTS 10761 in watchdog
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
ALD.13_ALD_Detect_and_setup_RF_module_reset_with_configured_ALDs

	ALD.13_ALD_Detect_and_setup_RF_module_reset_with_configured_ALDs.Test_Step.0 Check If ALDs Are In Configuration
    ALD.13_ALD_Detect_and_setup_RF_module_reset_with_configured_ALDs.Test_Step.1 RF reset procedure with state checking
    ALD.13_ALD_Detect_and_setup_RF_module_reset_with_configured_ALDs.Test_Step.2 FEG calculation

ALD.13_ALD_Detect_and_setup_RF_module_reset_with_configured_ALDs.Test_Step.0 Check If ALDs Are In Configuration
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    IF  ${num_of_MHAs}==${0} and ${num_of_RETs}==${0}  Fail  msg=There is no at least one ALD in configuration
    Log  You have ${num_of_MHAs} MHAs and ${num_of_RETs} RETs in configuration  console=${True}

ALD.13_ALD_Detect_and_setup_RF_module_reset_with_configured_ALDs.Test_Step.1 RF reset procedure with state checking
   [Documentation]
   ...    1. Reset RM module.
   ...    2. Check connection ALD to RM modules.
   ...    3. Check ALD state after RM reset.
    Log to console    \n========================================
    Log  Step: 1 RF reset procedure with state checking  console=${True}
    Log to console    ========================================
    IF  '${MRBTS_ID}' in ['5015', '10761']  Allow Fault In Watchdog  faultID=4003  #fault_name: Transmission path failure
    ${rmod_dist_r}=   admin.get ids for all  RMOD
    FOR  ${rmod_dist}  IN  @{rmod_dist_r}
        ${rmod}=  Should Match Regexp  ${rmod_dist}  RMOD_R-\\d+
        Log  Reseting ${rmod}  console=${true}
        admin.reset unit  ${rmod_dist}  reset_type=Hard  timeout=600
        Check If NLWG Cells Are OnAir
        Log  Checking ALD state after ${rmod} reset:  console=${True}
        Check ALDs State  ${ALD_expected_states}
    END
#    Verify OAM KPI  kpi=kpi51a kpi51b
    IF  '${MRBTS_ID}' in ['5015', '10761']
        Wait For Inactive Fault  faultID=4003  timeout=60 sec
        Disallow Fault In Watchdog  faultID=4003
    END

ALD.13_ALD_Detect_and_setup_RF_module_reset_with_configured_ALDs.Test_Step.2 FEG calculation
    [Documentation]  This keyword is checking if front end gain is calculated properly.
    Log to console    \n========================================
    Log  Step: 2 FEG calculation  console=${True}
    Log to console    ========================================
    Check FEG On Antl Without MHA
    Check FEG On Antl With MHA

ALD.13_ALD_Detect_and_setup_RF_module_reset_with_configured_ALDs.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keyword  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
#    Run Keywords  common.Common Test Teardown
#    ...  AND  Run Keyword And Continue On Failure  Report KPI Results  target=${SPACE}  name=kpi51a  visible_to_db=False
#    ...  value=${all_kpi_deltas_kpi51a}  kpi_type=${SPACE}  unit=seconds  category=Performance
#    ...  description=Manual RU Reset. Start Point: First Cell Down Start Point: Last Cell Up
#    ...  AND  Run Keyword And Continue On Failure  Report KPI Results  target=${SPACE}  name=kpi51b  visible_to_db=False
#    ...  value=${all_kpi_deltas_kpi51b}  kpi_type=${SPACE}  unit=seconds  category=Performance
#    ...  description=Manual RU Reset. Start Point: Last Cell Down Start Point: First Cell Up
