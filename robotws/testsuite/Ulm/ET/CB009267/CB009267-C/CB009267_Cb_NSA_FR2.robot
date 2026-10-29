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
...           [5G_PM_1777] Counter to count the number of UEs that have various number of SCells activated in DL and UL for NSA
...
...           [5G_PM_1746] Counter to identify when SCell scheduling suspension has occured due to UE overheating for NSA
...           [5G_PM_1825] Counter to identify when NSA SCell in scheduling suspension state recovers and recommences scheduling
...
...           [5G_PM_1857] Counter to identify when SCell deactivation due to low Buffer has occurred for NSA
...           [5G_PM_1853] Counter to identify when SCell deactivation has occurred due to SCell overheating for NSA
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
${relative_json_path}       ../../CB009267/CB009267-C/CB009267_Cb_NSA_FR2.json
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***

CB009267_5G_PM_1777_FR2
    [Documentation]
     ...  DESCRIPTION:       verification of the number of UEs that have x SCells activated in DL and UL for NSA
     ...                     - Details: 5G_UP_ALG_11885 and 5G_UP_5320
     ...                     - New PM Counters: PSCELL_UE_[0..7]_ACT_SCELL_DL_NSA and PSCELL_UE_[0..3]_ACT_SCELL_UL_NSA
     ...                     - PI ID: M55316C15063-M55316C15074
     ...
     ...  PRECONDITION:      actCarAgPmCount is set to ON
     ...                     FR2 Cells are onAir
     ...
     ...  TEST STEPS:
     ...                     Step 1:
     ...                        Description: NSA MUE Call
     ...                        Expected: user data is correctly transferred over PCell and SCell(s) for all UEs
     ...
     ...  POSTCONDITION:     the above mentioned PM Counters are correctly pegged
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
     ...       REQUIREMENTS IN SCOPE: 5G_PM_1777
     ...
     ...  REQUIRED LOGS:     PM Counters and TTI Traces
     ...
     ...  CONTACTS:      I_MN_RAN_RD_VRF_ULM_VT6@internal.nsn.com
     ...
     ...  REFERENCES:    CFAM User Scenario: https://gates.nsn-net.net/view/000254c4#o=606&hlt
     ...
     ...  HISTORY:
     ...                 [21.03.2024] - Created TP
     ...                 [20.03.2024] - Approved by https://collab.ext.net.nokia.com/ui#review:id=896722, review closed
     ...                 [22.03.2024] - Test scripts finished at commit: 014d85592b19cddfe7468069e750d16e02ce8df6
    [Tags]   CRT
    common_keywords.Run Test Scenario
    CB009267_scenario_validations.Verify CB009267_5G_PM_1777_FR2
    tracing.Check For Errors In Syslog


CB009267_5G_PM_1746_FR2
    [Documentation]
     ...  DESCRIPTION:       verification of the number of SCell scheduling is suspended due to UE overheating for NSA
     ...                     - Details: 5G_UP_8099 and 5G_UP_ALG_21870
     ...                     - New PM Counters: SCELL_UL_SUSPEND_UEOVHT_NSA and SCELL_DL_SUSPEND_UEOVHT_NSA
     ...                     - PI ID: M55316C15045-M55316C15046
     ...
     ...  PRECONDITION:      actCarAgPmCount is set to ON
     ...                     FR2 Cells are onAir
     ...  TEST STEPS:
     ...                     Step 1:
     ...                        Description: NSA MUE Call in CA
     ...                        Expected: user data is correctly transferred over PCell and SCell(s) for all UEs
     ...                     Step 2:
     ...                        Description: UEs report CQI0
     ...                        Expected: gNB stops DL/UL scheduling, instead of SCell deactivation to recover from the overheating status
     ...
     ...  POSTCONDITION:     the above mentioned PM Counters are correctly pegged
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
     ...       REQUIREMENTS IN SCOPE: 5G_PM_1746
     ...
     ...  REQUIRED LOGS:     PM Counters and TTI Traces
     ...
     ...  CONTACTS:      I_MN_RAN_RD_VRF_ULM_VT6@internal.nsn.com
     ...
     ...  REFERENCES:    CFAM User Scenario: https://gates.nsn-net.net/view/000254c4#o=690&hlt
     ...
     ...  HISTORY:
     ...                 [21.02.2024] - Created TP
     ...                 [20.03.2024] - Approved by https://collab.ext.net.nokia.com/ui#review:id=896722, review closed
     ...                 [22.03.2024] - Test scripts finished at commit: 014d85592b19cddfe7468069e750d16e02ce8df6
     ...                 [26.08.2024] - Automation finished
    [Tags]   CRT
    common_keywords.Run Test Scenario
    CB009267_scenario_validations.Verify CB009267_5G_PM_1746_FR2
    tracing.Check For Errors In Syslog


CB009267_5G_PM_1825_FR2
    [Documentation]
     ...  DESCRIPTION:       verification of the number times a FR1 or FR2 NSA SCell (UL or DL) which was in scheduling suspension state
     ...                     recovers and scheduling is restarted for the SCell
     ...                     - New PM Counters: SCELL_SUSP_RECOV_NSA (IMPORTANT: PM Counter is updated on the PCell)
     ...                     - PI ID: M55316C15051
     ...
     ...  PRECONDITION:      actCarAgPmCount is set to TRUE
     ...                     FR2 Cells are onAir
     ...  TEST STEPS:
     ...                     Step 1:
     ...                        Description: repeat test cases CB009267_5G_PM_1746
     ...                        Expected: either DL or UL SCell is suspended
     ...                     Step 2:
     ...                        Description: recover the Scheduling suspension state by sending non-zero CQIs
     ...                        Expected: scheduling is restarted for the SCell
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
     ...       REQUIREMENTS IN SCOPE: 5G_PM_1825
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
     ...                 [09.09.2024] - Automation finished
    [Tags]   CRT
    common_keywords.Run Test Scenario
    CB009267_scenario_validations.Verify CB009267_5G_PM_1825_FR2
    tracing.Check For Errors In Syslog


CB009267_5G_PM_1857_FR2
    [Documentation]
     ...  DESCRIPTION:       verification of the number of times Buffer based SCell deactivated for FR1 NSA
     ...                     - Details: 5G_UP_ALG_26360, 5G_UP_ALG_2738 (for UL), and 5G_UP_ALG_2713 (for DL)
     ...                     - New PM Counters: SCELL_UL_DEACT_LOWBUFFER_NSA and SCELL_DL_DEACT_LOWBUFFER_NSA
     ...                     - PI ID: M55316C15055-M55316C15056
     ...
     ...  PRECONDITION:      actCarAgPmCount is set to TRUE
     ...                     dlScellDeactivationThreshold is set
     ...                     ulScellDeactivationThreshold is set
     ...                     NRBTS.sCellActivationMethod is set to ‘bufferAndRLQualityBased’
     ...                     FR2 Cells are onAir
     ...  TEST STEPS:
     ...                     Step 1:
     ...                        Description: SA MUE Call in CA
     ...                        Expected: user data is correctly transferred over PCell and SCell(s) for all UEs
     ...                     Step 2:
     ...                        Description: low the data rate
     ...                        Expected: deactivation threshold is reached and SCell deactivation is performed
     ...
     ...  POSTCONDITION:     the above mentioned PM Counters are correctly pegged
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
     ...       REQUIREMENTS IN SCOPE: 5G_PM_1857
     ...
     ...  REQUIRED LOGS:     PM Counters and TTI Traces
     ...
     ...  CONTACTS:      I_MN_RAN_RD_VRF_ULM_VT6@internal.nsn.com
     ...
     ...  REFERENCES:    CFAM User Scenario: https://gates.nsn-net.net/view/000254c4#o=685&hlt
     ...
     ...  HISTORY:
     ...                 [18.10.2023] - Created TP
     ...                 [20.11.2023] - Approved by https://collab.ext.net.nokia.com/ui#review:id=896722, review closed
     ...                 [22.11.2023] - Test scripts finished at commit: 014d85592b19cddfe7468069e750d16e02ce8df6
    [Tags]   CRT
    common_keywords.Run Test Scenario
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1857_FR2


CB009267_5G_PM_1853_FR2
    [Documentation]
     ...  DESCRIPTION:       verification of the number of times SCell deactivated has occurred due to SCell in overheating for FR1 NSA
     ...                     - Details: 5G_UP_ALG_21870, 5G_L2_1294, and 5G_UP_ALG_26360 (FR2)
     ...                     - New PM Counters: SCELL_DL_DEACT_SCELLOVHT_NSA and SCELL_UL_DEACT_SCELLOVHT_NSA
     ...                     - PI ID: M55316C15061-M55316C15062
     ...
     ...  PRECONDITION:      actCarAgPmCount is set to TRUE
     ...                     FR2 Cells are onAir
     ...  TEST STEPS:
     ...                     Step 1:
     ...                        Description: SA MUE Call in CA
     ...                        Expected: user data is correctly transferred over PCell and SCell(s) for all UEs
     ...                     Step 2:
     ...                        Description: UEs report CQI0 (overheating) more than value defined by rdActCAOverheatingFilterConst
     ...                        Expected: SCell deactivation is performed
     ...
     ...  POSTCONDITION:     the above mentioned PM Counters are correctly pegged
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
     ...       REQUIREMENTS IN SCOPE: 5G_PM_1853
     ...
     ...  REQUIRED LOGS:     PM Counters and TTI Traces
     ...
     ...  CONTACTS:      I_MN_RAN_RD_VRF_ULM_VT6@internal.nsn.com
     ...
     ...  REFERENCES:    CFAM User Scenario: https://gates.nsn-net.net/view/000254c4#o=685&hlt
     ...
     ...  HISTORY:
     ...                 [18.10.2023] - Created TP
     ...                 [20.11.2023] - Approved by https://collab.ext.net.nokia.com/ui#review:id=896722, review closed
     ...                 [22.11.2023] - Test scripts finished at commit: 014d85592b19cddfe7468069e750d16e02ce8df6
     ...                 [xx.yy.2024] - Automation finished
    [Tags]   CRT
    common_keywords.Run Test Scenario
    CB009267_scenario_validations.Verify CB009267_5G_PM_1853_FR2
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
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1777_FR2
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1746_FR2
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1825_FR2
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1857_FR2
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1853_FR2
