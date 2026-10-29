*** Settings ***
Resource    ../../resources/common.robot
Resource    ../../resources/alarms.robot
Resource    ../../resources/ald.robot
Resource    ../../resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to check removing ALD procedure.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  23.11.2018 - Test Case creation
...  21.12.2918 - https://jira3.int.net.nokia.com/browse/TAT-13778
...  12.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-14560
...  03.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-15283
...  28.07.2021 - https://jira3.int.net.nokia.com/browse/TAT-21668
...  06.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-36 - Switch to hran_frame_sbts_siso resource
...  09.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-86 - Test Specific Teardown failure
...  05.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-144 - Adaptation to CNI-82119 and migration from hran_ta to robotlte repository
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal

	ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal.Test_Step.0 Check If ALDs Are In Configuration
    ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal.Test_Step.1 Remove RET device
    ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal.Test_Step.2 Remove MHA device
    ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal.Test_Step.3 FEG calculation
    ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal.Test_Step.4 Checking ALDs State

ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal.Test_Step.0 Check If ALDs Are In Configuration
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Set Test Variable  ${COMMISSIONING_PATH}  /home/ute/testline_configuration/${TESTLINE_NAME}/node1/SCF_01_${RELEASE}.xml
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${num_of_RETs}
    Set Test Variable  ${num_of_MHAs}
    Set Test Variable  ${ALD_R_RETs}
    Set Test Variable  ${ALD_R_MHAs}
    IF  ${num_of_MHAs}==${0} and ${num_of_RETs}==${0}  Fail  msg=There is no at least one ALD in configuration
    Log  You have ${num_of_MHAs} MHAs and ${num_of_RETs} RETs in configuration  console=${True}

ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal.Test_Step.1 Remove ${type} device
    [Documentation]  Test step which removing one ${type} from configuration.
    Log to console    \n========================================
    Log  Step: 1 Remove ${type} device  console=${True}
    Log to console    ========================================
    IF  ${num_of_RETs} != ${0}
        ${chosen_RET}  Select Random RET  ${ALD_R_RETs}
    ELSE
        Log  There is no ${type} in configuration  console=${True}
    END
    IF  ${num_of_RETs} != ${0}  Create Delta Remove For Selected ALD  ${chosen_RET}  deviceType=${type}

ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal.Test_Step.2 Remove ${type} device
    [Documentation]  Test step which removing one ${type} from configuration.
    Log to console    \n========================================
    Log  Step: 2 Remove ${type} device  console=${True}
    Log to console    ========================================
    IF  ${num_of_MHAs} != ${0}
        ${chosen_MHA}  Select Random MHA  ${ALD_R_MHAs}
    ELSE
        Log  There is no ${type} in configuration  console=${True}
    END
    IF  ${num_of_MHAs} != ${0}  Create Delta Remove For Selected ALD  ${chosen_MHA}  deviceType=${type}

ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal.Test_Step.3 FEG calculation
    [Documentation]  This keyword is checking if front end gain is calculated properly.
    Log to console    \n========================================
    Log  Step: 3 FEG calculation  console=${True}
    Log to console    ========================================
    Check FEG On Antl Without MHA
    Check FEG On Antl With MHA

ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal.Test_Step.4 Checking ALDs State
    [Documentation]  Check if all ALDs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    Log to console    \n========================================
    Log  Step: 4 Checking ALDs State  console=${True}
    Log to console    ========================================
	Check ALDs State  ${ALD_expected_states}
    Check If NLWG Cells Are OnAir
    Check If Unexpected Alarms Are Raised  ${skip_fault}

ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal.Test Specific Teardown
    [Documentation]  Test teardown which restores original configuration settings.
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

ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keywords  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    ...  AND  ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal.Test Specific Teardown
