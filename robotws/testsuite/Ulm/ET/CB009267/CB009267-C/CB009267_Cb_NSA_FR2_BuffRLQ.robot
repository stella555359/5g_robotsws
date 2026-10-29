*** Settings ***

Documentation
...
...     INTRODUCTION:  CB009267 "NR Carrier Aggregation Counters"
...                    This feature introduces CA related PM counters.
...
...     TEST SET NAME: CB009267_Carrier_Aggregation_Counters_NSA
...
...     TESTING SCOPE: covers CB009267-Cb for the following User Scenarios:
...
...           [5G_PM_1826] Counter to identify when NSA SCell in scheduling suspension state is deactivated or released
...
...     CONTACTS:      I_MN_RAN_RD_VRF_ULM_VT6@internal.nsn.com
...
...     REFERENCES:
...                [1] CB009267 CFAM: https://gates.nsn-net.net/view/00027824#o=0
...                [2] CB009267 FTS: https://nokia.sharepoint.com/:w:/r/sites/mn-ran-productization/RAN%20Productization%20WoW/
...                                  Shared%20Documents/6.%20Feature%20Documents/CB009200-CB009299/CB009267/FTS/
...                                  CB009267-HL_FTS%20.docx?d=wc02886907afc4600b9a90de36332f261&csf=1&web=1&e=nNAY4w
...                [3] Review Session in Collaborator: https://collab.ext.net.nokia.com/ui#review:id=896722
...
...      HISTORY:
...                [11.03.2024] - Initial version



#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    ../../resources/SQD68/pmc_analysis.py    WITH NAME  validation

Resource   ../../L2/resources/robot/test_setup.robot
Resource   ../../L2/resources/common_keywords.robot
Resource   ../../L2/resources/robot/tracing.robot
Resource   resources/CB009267_scenario_modifications.robot
Resource   resources/CB009267_scenario_validations.robot


Suite Setup     Run Keywords
...             test_setup.Initialize Test Suite                        AND
...             validation.Prepare For PM Counter Testing
Suite Teardown  Run Keywords
...             common_keywords.Capture Snapshot And Restore Config     AND
...             validation.Finalise PM Counter Testing
Test Teardown   common_keywords.Stop Logs And Collect Traces



*** Variables ***
${num_slots_per_frame}      ${20}
${pm_reporting_interval}    5min
${relative_json_path}       ../../CB009267/CB009267-C/CB009267_Cb_NSA_FR2_BuffRLQ.json
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***
CB009267_5G_PM_1826_FR2
    [Documentation]
     ...  DESCRIPTION:       verification of the number times FR1 NSA SCell (UL or DL) which was in scheduling suspension state
     ...                     is deactivated or released
     ...                     - New PM Counters: SCELL_SUSP_DEACT_REL_NSA (IMPORTANT: PM Counter is updated on the PCell)
     ...                     - PI ID: M55316C15052
     ...
     ...  PRECONDITION:      actCarAgPmCount is set to TRUE
     ...                     FR2 Cells are onAir
     ...  TEST STEPS:
     ...                     Step 1:
     ...                        Description: repeat test cases CB009267_5G_PM_1746
     ...                        Expected: either DL or UL SCell is suspended
     ...                     Step 2:
     ...                        Description: do not send non-zero CQIs
     ...                        Expected: Scheduling suspension state is not recovered in time and the SCell is deactivated or released
     ...
     ...  POSTCONDITION:     the above mentioned PM Counters are correctly pegged on PCell
     ...
     ...  TESTING TOOLS:     TTI Traces Decoder (tti-dec)
     ...
     ...  TEST ENVIRONMENT:
     ...               HARDWARE ID:
     ...                     1x gNB: ASIL / ABIO
     ...                     Airphone: ASIL / ABIO
     ...                     WTS 5G Core Simulator
     ...                     UTE Cloud Topology: CLOUD_5G_I_LO_AP_LO + VARIANT_PRIVATE_NSA_FS_ECPRI_MMWV_TDD_4CC_CA
     ...
     ...  REQUIREMENTS COVERAGE:
     ...       REQUIREMENTS IN SCOPE: 5G_PM_1826
     ...
     ...  REQUIRED LOGS:     PM Counters and TTI Traces
     ...
     ...  CONTACTS:      I_MN_RAN_RD_VRF_ULM_VT6@internal.nsn.com
     ...
     ...  REFERENCES:    CFAM User Scenario: https://gates.nsn-net.net/view/000254c4#o=685&hlt
     ...
     ...  HISTORY:
     ...                 [21.02.2024] - Created TP
     ...                 [20.03.2024] - Approved by https://collab.ext.net.nokia.com/ui#review:id=896722, review closed
     ...                 [22.03.2024] - Test scripts finished at commit: 014d85592b19cddfe7468069e750d16e02ce8df6
    [Tags]   CRT
    common_keywords.Run Test Scenario
    CB009267_scenario_validations.Verify CB009267_5G_PM_1826_FR2
    tracing.Check For Errors In Syslog

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

*** Keywords ***
Offline_Verification
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable    /home/ute/test_repository/20230206_173251
    Set Suite Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Suite Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    CB009267_scenario_validations.Verify CB009267_5G_PM_1826_FR2

