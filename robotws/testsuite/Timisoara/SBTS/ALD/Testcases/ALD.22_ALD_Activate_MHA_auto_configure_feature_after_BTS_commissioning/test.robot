*** Settings ***
Resource    ../../resources/common.robot
Resource    ../../resources/alarms.robot
Resource    ../../resources/ald.robot
Resource    ../../resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.22_ALD_Activate_MHA_auto_configure_feature_after_BTS_commissioning
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to check if the BTS can auto configure the MHAs that support AISG 2.0
...  when the LTE2403 feature flag is turned on after BTS commissioning.
...
...  Feature LTE2404 works only with single band MHA.
...
...  +----------+--------------+--------------------------------------+
...  | MHA Name | Product Code | Description                          |
...  +----------+--------------+--------------------------------------+
...  | FLPA     | 473052A      | single band APT700 dual MHA          |
...  +----------+--------------+--------------------------------------+
...  | FLPB     | 473053A      | single band APT700 dual MHA          |
...  +----------+--------------+--------------------------------------+
...  | FLMB     | 472979A      | single band EU800 dual MHA           |
...  +----------+--------------+--------------------------------------+
...  | MDGB     | 473058A      | single band 900 dual MHA             |
...  +----------+--------------+--------------------------------------+
...  | MDDB     | 472980A      | single band 1800 dual MHA            |
...  +----------+--------------+--------------------------------------+
...  | WMHD     | 471443A      | single band 2100 dual MHA            |
...  +----------+--------------+--------------------------------------+
...  | FLHA     | 472105A      | single band 2600 dual MHA            |
...  +----------+--------------+--------------------------------------+
...  | MDGK     | 474318A      | single band 900 dual MHA             |
...  +----------+--------------+--------------------------------------+
...  | MDDK     | 474319A      | single band 1800 dual MHA            |
...  +----------+--------------+--------------------------------------+
...  | WMHK     | 474320A      | single band 2100 dual MHA            |
...  +----------+--------------+--------------------------------------+
...  | FLHK     | 474323A      | single band 2600 dual MHA            |
...  +----------+--------------+--------------------------------------+
...  | FLPK     | 474627A      | single band APT700 dual MHA          |
...  +----------+--------------+--------------------------------------+
...  | FLMK     | 474735A      | single band EU800 dual MHA           |
...  +----------+--------------+--------------------------------------+
...  | MDGA     | CS7299111    | single band 900 dual MHA             |
...  +----------+--------------+--------------------------------------+
...  | MDTB     | 473060A      | single band 850 dual MHA             |
...  +----------+--------------+--------------------------------------+
...
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  *****************
...  11.02.2021 - Test creation
...  25.08.2021 - https://jira3.int.net.nokia.com/browse/TAT-21769
...  03.11.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-32 - adaptation to CNI-61110
...  06.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-36 - Switch to hran_frame_sbts_siso resource
...  13.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-203 - add KW "Get Software Version" into TC Setup and variable
...                                                                 release into coam.Setup Admin
...  12.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-219 - add KW "Common step trigger" due to BIT CS4.3 Enable Sleeping Cell
...  26.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-230 - Adaptation to CNI-82119 and migration from hran_ta to robotlte repository
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
${PATTERN_SINGLEBAND_MHA}  (473052A|473053A|472979A|473058A|472980A|471443A|472105A|474318A|474319A|474320A|474323A|474627A|474735A|CS7299111|473060A)

*** Keywords ***
ALD.22_ALD_Activate_MHA_auto_configure_feature_after_BTS_commissioning

	ALD.22_ALD_Activate_MHA_auto_configure_feature_after_BTS_commissioning.Test_Step.0 Check If Single Band MHAs Are In Configuration
    ALD.22_ALD_Activate_MHA_auto_configure_feature_after_BTS_commissioning.Test_Step.1 Switch On MhaAutoConfig Feature
    ALD.22_ALD_Activate_MHA_auto_configure_feature_after_BTS_commissioning.Test_Step.2 Checking ALDs State

ALD.22_ALD_Activate_MHA_auto_configure_feature_after_BTS_commissioning.Test_Step.0 Check If Single Band MHAs Are In Configuration
    [Documentation]  Test step which checking if MHAs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Set Test Variable  ${COMMISSIONING_PATH_LTE_ONLY}  /home/ute/testline_configuration/${TESTLINE_NAME}/node1/SCF_01_${RELEASE}_LTE_ONLY.xml
    Set Test Variable  ${COMMISSIONING_PATH}  /home/ute/testline_configuration/${TESTLINE_NAME}/node1/SCF_01_${RELEASE}.xml
    ${SCF_exist}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${COMMISSIONING_PATH_LTE_ONLY}
    IF  not ${SCF_exist}  Fail  msg=File /home/ute/testline_configuration/${TESTLINE_NAME}/node1/SCF_01_${RELEASE}_LTE_ONLY.xml not exist
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Log  Activation plan with LTE only...  console=${true}
    admin.perform commissioning  ${MRBTS_ID}  ${COMMISSIONING_PATH_LTE_ONLY}  ${SKIP_PARAMETER_RELATION_ERRORS}  ${SHOULD_ACTIVATE}  timeout=600
	Check SMODs State  ${SMOD_expected_states}
	Check RMODs State  ${RMOD_expected_states}
	Check ALDs State  ${ALD_expected_states}
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    ${ALD_A_to_prodCode_before}=  Mapping MHA ALD_A To ProductCode
    ${ALD_DN_single_MHA_before}=  Detect Single Band MHA Connected To BTS  ${ALD_A_to_prodCode_before}
    ${num_of_single_band_MHAs_before}=  Get Length  ${ALD_DN_single_MHA_before}
    Set Test Variable  ${num_of_single_band_MHAs_before}
    IF  ${num_of_single_band_MHAs_before}==${0}  Fail  msg=There is no at least one single band MHA in configuration
    Log  You have ${num_of_single_band_MHAs_before} single band MHA(s) in configuration  console=${True}
    Set Feature On Expected Value  parameter=actMhaAutoConfig  value=false
    ${ALD_A_ALD_R}=  Mapping ALD_A To ALD_R
    Log  Decommissioning single band MHA(s)  console=${True}
    FOR  ${i}  IN  @{ALD_DN_single_MHA_before}
        ${ALD_R}=  Get From Dictionary  ${ALD_A_ALD_R}  ${i}
        Create Delta Remove For Selected ALD  ${ALD_R}  deviceType=MHA
    END

ALD.22_ALD_Activate_MHA_auto_configure_feature_after_BTS_commissioning.Test_Step.1 Switch On MhaAutoConfig Feature
    [Documentation]  This step enable MhaAutoConfig feature flag.
    Log to console    \n========================================
    Log  Step: 1 Switch On MhaAutoConfig Feature  console=${True}
    Log to console    ========================================
    Set Feature On Expected Value  parameter=actMhaAutoConfig  value=true
    Log  Waiting for auto commissioning of MHAs  console=${true}
    Sleep  10s
    ${ALD_A_to_prodCode_after}=  Mapping MHA ALD_A To ProductCode
    ${ALD_DN_single_MHA_after}=  Detect Single Band MHA Connected To BTS  ${ALD_A_to_prodCode_after}
    ${num_of_single_band_MHAs_after}=  Get Length  ${ALD_DN_single_MHA_after}
    ${status}=  Run Keyword And Return Status  Should Be True  '${num_of_single_band_MHAs_before}'=='${num_of_single_band_MHAs_after}'
    IF  ${status}
        Log  All single band MHAs are commissioned  console=${true}
    ELSE
        Fail  msg=At least one MHA remain uncommissioned
    END

ALD.22_ALD_Activate_MHA_auto_configure_feature_after_BTS_commissioning.Test_Step.2 Checking ALDs State
    [Documentation]
    ...    1. Check if all ALDs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    ...    2. Check if all cells are on air.
    ...    3. Check BTS alarms.
    Log to console    \n========================================
    Log  Step: 2 Checking ALDs State  console=${True}
    Log to console    ========================================
	Check ALDs State  ${ALD_expected_states}
    Check If NLWG Cells Are OnAir
    Check If Unexpected Alarms Are Raised  ${skip_fault}

ALD.22_ALD_Activate_MHA_auto_configure_feature_after_BTS_commissioning.Test Specific Teardown
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
    Set Feature On Expected Value  parameter=actMhaAutoConfig  value=false
    admin.teardown admin  alias=${ute_admin_alias}

ALD.22_ALD_Activate_MHA_auto_configure_feature_after_BTS_commissioning.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keywords
    ...  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    ...  AND  ALD.22_ALD_Activate_MHA_auto_configure_feature_after_BTS_commissioning.Test Specific Teardown
