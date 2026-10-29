*** Settings ***

Documentation
...
...     INTRODUCTION:  CB013715
...
...     TEST SET NAME: CB013715
...
...     TESTING SCOPE: covers CB013715-C subfeatures
...
...     CONTACTS: Ch SAMSON
...
...     REFERENCES:
...                [1] CB013715 CFAM: https://gates.nsn-net.net/view/00025ee1#o=17403&hlt

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    ArchiveLibrary
Library    resources/python/AreBlankedPrbNotUsed.py    WITH NAME    AreBlankedPrbNotUsed

# Resources taf
Resource      taf/ul/ettf/main.robot

# resources TRF
Resource   resources/TARF/robot/Test-Suite-Setup-Resources-Keywords.robot
Resource   resources/TARF/robot/apUDPlog.robot
Resource   resources/TARF/robot/testcase-Keywords.robot

# Resources CB013715
Resource   ./CB013715-FDD_initial_commissioning.robot
Resource   ./CB013715_initial_commissioning.robot
Resource   ./CB013715_scenario_modifications.robot
Resource   ./CB013715_scenario_validations.robot

# Variables taf
Variables     taf/ul/ettf/logging/policies.py
Variables     taf/ul/ettf/log_analysis/policies.py

# Variables TARF
Variables     resources/TARF/python/logging_policy.py

# test variables
Variables     ./CB013715_variables-NSA-10MHz-Config1.yaml

Suite Setup       Suite Setup Feature-Common      test_dictParam=${dictParam}
Suite Teardown    Suite Teardown Feature-Common
Test Setup        Test Setup for Feature-Common
Test Teardown     Test Teardown for Feature-Common

*** Variables ***
${FeatureId}                                                        CB013715
${SUITE_DEBUG_MODE}                                                 ${False}

${TestSharkTool}                                                    MC_SHARK

&{dictParam}                                                        w_Basic_Call_to_Setup_Wtsemu=${True}
...                                                                 w_enable_sherpa_Traces=False
...                                                                 w_check_9890_using_sherpa=False
...                                                                 w_GetTtiTrace=True
...                                                                 w_convert_TtiPcap_to_excelCsv=False
...                                                                 w_GetL1L2Bip=False
...                                                                 w_generic_capture=True
...                                                                 w_CaptureCORE=${False}
...                                                                 w_CaptureL1L2=${False}
...                                                                 w_CaptureCPRT=${True}
...                                                                 w_ue_detach=False
...                                                                 w_GetBtsLog=True
...                                                                 w_DISPLAY_ue_stats_nr_15min=False

# capture Time setting
&{CAPTURE}                                                          GetTtiTraceTime=1s
...                                                                 Getl1l2TraceTime=1s
...                                                                 GetSherpaTraceTime=1s
...                                                                 GetTtiTraceNumOfEvent=5000

${relative_json_path}       ../../../../CB013715/CB013715-C-PM-v2.json
${REINIT_GNB}               true
${LuaFileToUsed_path}       ${EMPTY}
${num_slots_per_frame}      ${20}
${pm_reporting_interval}    5min

${cqiDciCssAl1HR}           ${130}
${cqiDciCssAl2HR}           ${110}
${cqiDciCssAl4HR}           ${100}
${cqiDciCssAl8HR}           ${50}

${cqiDciCssAl1}             ${101}
${cqiDciCssAl2}             ${69}
${cqiDciCssAl4}             ${33}
${cqiDciCssAl8}             ${10}

${LOGGING_POLICY}=           NO_TRAFFIC_NO_SNAPSHOT_NO_INFOMODEL_LOGS_POLICY

*** Test Cases ***

# MY_SKIP_REPORT : no Test report to Reporting Portal
# ALWAYS_REPORT : report Test Passed or Test Failed status to Reporting Portal
# SKIP_SCOUT_REPORT
CB013715_SR_C_7_B_1_NSA_10MHz_Configuration_1
    [Tags]   CRT    FDD    10MHz    13715_C_PM    NSA    MY_SKIP_REPORT
    [Documentation]
    ...  DESCRIPTION:
    ...
    ...  PRECONDITION:
    ...
    ...  POSTCONDITION:
    ...             No test specific postcondition
    ...
    ...  TESTING TOOLS:
    ...             TTI Traces Decoder (tti-dec)
    ...
    ...  TEST ENVIRONMENT:
    ...             HARDWARE ID:
    ...                 1x gNB: (ASIL, ABIO, AMIA)
    ...                 Simulated RRH: AHLOA
    ...                 Airphone: ASIL + ABIO
    ...                 WTS 5G Core Simulator
    ...                 UTE Cloud Topology:
    ...                   - CLOUD_5G_I_MP_AP_LO + VARIANT SANSA_FS_ECPRI_CMWV_FDD_GMC
    ...                 UEs that support 90MHz and 80MHz band
    ...
    ...  REQUIREMENTS COVERAGE:
    ...             REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_30133
    ...                                    5G_RAN_USR_RRM_30120
    ...                                    5G_RAN_USR_RRM_30121
    ...                                    5G_RAN_USR_RRM_30134
    ...
    ...  REQUIRED LOGS:
    ...             PM Counters
    ...             TTI Traces
    ...
    ...  CONTACTS:
    ...
    ...  REFERENCES:
    ...             CFAM User Scenario: https://gates.nsn-net.net/view/00025ee1#o=17411&hlt
    ...
    ...  HISTORY:
    ...             [07.17.2025] - Created TestCase

   Run Test Scenario
   Set test variable    @{dl_dtx_threshold}    0.1
   Set test variable    @{ul_dtx_threshold}    0.1
   Generate verdict on scenario_1_FDD_DSS_W_BL
   Prepare Variables for PMC Validation    scenario=scenario_1_FDD_DSS_W_BL
   Verify PMC values with nb of scenario equal to 1 with scenario_1_FDD_DSS_W_BL

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

*** Keywords ***
CB013715_A_template_test_NSA_FDD_TESTS
    [Tags]   FDD   15MHz    13715_C    SKIP_REPORT    SKIP_SCOUT_REPORT
    Pass Execution    Test Passed

