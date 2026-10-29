*** Settings ***

Documentation
...    Author: MN RAN RD VRF ULM 5
...    Contact: OO_MN_RAN_RD_VRF_ULM_5_53245008@internal.nsn.com
...    Description: Test Suite for CB005935 feature Inter band FDD UL CA 2CCs
...    UTE Topology: CLOUD_5G_I_BOO_AP_LOO
...    Variant: VARIANT_PRIVATE_4S_3CC_FDD_CA
...    Reference config feature: USCB005935-* (FDD UL CA 2CCs feature)
...    Test Configuration:
...
...    1. Cells
...
...    cell     | band  |  techn. |   BW (DL/UL)    |  nrarfcn (DL/UL) |     DL MIMO
...    -----------------------------------------------------------------------------------
...    cell_1    |  n71  |  FDD    |    10Mhz        |  126000/135000  |  4x4 or 4x2 CLSM
...    cell_2    |  n66  |  FDD    |    10MHz        |  431040/349000  |  4x4 or 4x2 CLSM
...    cell_3    |  n41  |  TDD    |    60Mhz        |  519000         |  2x2 CLSM
...    cell_4    |  n5   |  FDD    |    10MHz        |  176300/167300  |  4x4 or 4x2 CLSM
...    cell_5    |  n2   |  FDD    |    10MHz        |  392500/376500  |  4x4 or 4x2 CLSM
...    cell_6    |  n41  |  TDD    |    60MHz        |  531960         |  2x2 CLSM
...
...    2. cells CA relations:
...
...    Pcell/Scell |  1  |  2  |  3  |  4  |  5  |  6      CA type
...    ------------------------------------------------   ---------
...    1           |     |     |     |     |     |         --
...    2           |     |     |  X  |  X  |  X* |  X      3F+2T
...    3           |     |     |     |     |     |         --
...    4           |     |     |     |     |  X* |         2F
...    5           |     |     |     |     |     |         --
...    6           |     |     |     |     |     |         --
...    *: refers to sCellOperationalMode = dlAndUl
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    ../resources/SQD68/pmc_analysis.py    WITH NAME  validation

Resource   ../L2/resources/robot/test_setup.robot
Resource   ../L2/resources/common_keywords.robot
Resource   ../L2/resources/robot/tracing.robot
Resource   resources/CB005935_scenario_modifications.robot
Resource   resources/CB005935_scenario_validations.robot


Suite Setup     Run Keywords
...             test_setup.Initialize Test Suite                        AND
...             validation.Prepare For PM Counter Testing
Suite Teardown  Run Keywords
...             common_keywords.Capture Snapshot And Restore Config     AND
...             validation.Finalise PM Counter Testing
Test Teardown   common_keywords.Stop Logs And Collect Traces


*** Variables ***
${pm_reporting_interval}          5min
${relative_json_path}             ../../CB005935/CB005935_BB_B2_and_BB_B3.json
${sCellAdditionMethod}            blind
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***

CB005935-BB-B2_Single_F+F_UL_2CCs_CA_UE_call_with_NACK_flood_triggered
    [Tags]   CRT
    common_keywords.Run Test Scenario
    CB005935_scenario_validations.Generate Verdict On scenario_BB_B2 for CB005935-BB-B2_Single_F+F_UL_2CCs_CA_UE_call_with_NACK_flood_triggered
    tracing.Check For Errors In Syslog


*** Keywords ***
CB005935_BB_B3_Interworking_with_uplink_closed_loop_power_control
    [Tags]   CRT
    common_keywords.Run Test Scenario
    CB005935_scenario_validations.Generate Verdict On scenario_BB_B3 for CB005935_BB_B3_Interworking_with_uplink_closed_loop_power_control
    tracing.Check For Errors In Syslog


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Offline_Verification
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the *** Keywords ***
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable    /home/ute/robotws/CB005935/SBTS00_ENB_9999_230712_000003/20230713_133700
    Set Suite Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Suite Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    CB005935_scenario_validations.Generate Verdict On scenario_BB_B2 for CB005935-BB-B2_Single_F+F_UL_2CCs_CA_UE_call_with_NACK_flood_triggered
