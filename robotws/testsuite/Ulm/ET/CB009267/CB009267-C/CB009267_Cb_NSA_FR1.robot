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
...           [5G_PM_1743] Counter to identify when SCell scheduling suspension has occured due to bad Radio Link quality for NSA
...           [5G_PM_1746] Counter to identify when SCell scheduling suspension has occured due to UE overheating for NSA
...          *[5G_PM_1747] Counter to identify when SCell scheduling suspension has occured due to Measurement GAP for NSA
...           [5G_PM_1814] Counter to identify when SCell or PSCell scheduling suspension has occurred due to too low split TX power for NSA
...           [5G_PM_1815] Counter to identify when SCell or PSCell scheduling suspension has occurred due to NACK Flood state for NSA
...          *[5G_PM_1825] Counter to identify when NSA SCell in scheduling suspension state recovers and recommences scheduling
...          *[5G_PM_1826] Counter to identify when NSA SCell in scheduling suspension state is deactivated or released
...
...          *[5G_PM_1758] Counter to identify when SCell deactivation has occured due to SCell Inactivity Deactivation Timer for NSA
...          *[5G_PM_1761] Counter to identify when buffer based SCell deactivation has occurred due to Bad RL quality for NSA
...           [5G_PM_1760] Counter to identify when SCell deactivation has occured due to UE overheating for NSA
...           [5G_PM_1857] Counter to identify when SCell deactivation due to low Buffer has occurred for NSA
...           [5G_PM_1853] Counter to identify when SCell deactivation has occurred due to SCell overheating for NSA
...
...      *) FTS meeting agreement to cover this User Scenario in ST only
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
...                [01.02.2024] - Initial version

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
${relative_json_path}       ../../CB009267/CB009267-C/CB009267_Cb_NSA_FR1.json
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}



*** Test Cases ***

CB009267_5G_PM_1777_FR1
    [Documentation]
     ...  DESCRIPTION:       verification of the number of UEs that have x SCells activated in DL for NSA (no CA in UL on FR1)
     ...                     - Details: 5G_UP_ALG_11885 and 5G_UP_5320
     ...                     - New PM Counters: PSCELL_UE_[0..7]_ACT_SCELL_DL_NSA
     ...                     - PI ID: M55316C15063-M55316C15070
     ...
     ...  PRECONDITION:      actCarAgPmCount is set to TRUE
     ...                     FR1 Cells are onAir
     ...  TEST STEPS:
     ...                     Step 1:
     ...                        Description: NSA MUE Call in DL CA
     ...                        Expected: user data is correctly transferred over PSCell and SCell(s) for all UEs
     ...
     ...  POSTCONDITION:     some of the above mentioned PM Counters are correctly pegged
     ...
     ...  TESTING TOOLS:     TTI Traces Decoder (tti-dec)
     ...
     ...  TEST ENVIRONMENT:
     ...               HARDWARE ID:
     ...                     1x gNB: ASIL / ABIO
     ...                     Airphone: ASIL / ABIO
     ...                     WTS 5G Core Simulator
     ...                     UTE Cloud Topology: CLOUD_5G_I_LO_AP_LO + VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ
     ...
     ...  REQUIREMENTS COVERAGE:
     ...       REQUIREMENTS IN SCOPE: 5G_PM_1777
     ...
     ...  REQUIRED LOGS:     PM Counters and TTI Traces
     ...
     ...  CONTACTS:      I_MN_RAN_RD_VRF_ULM_VT6@internal.nsn.com
     ...
     ...  REFERENCES:    CFAM User Scenario: https://gates.nsn-net.net/view/000254c4#o=596&hlt
     ...
     ...  HISTORY:
     ...                 [21.02.2024] - Created TP
     ...                 [20.03.2024] - Approved by https://collab.ext.net.nokia.com/ui#review:id=896722, review closed
     ...                 [22.03.2024] - Test scripts finished at commit: 014d85592b19cddfe7468069e750d16e02ce8df6
    [Tags]   CRT
    common_keywords.Run Test Scenario
    CB009267_scenario_validations.Verify CB009267_5G_PM_1777_FR1
    tracing.Check For Errors In Syslog


CB009267_5G_PM_1743_FR1
    [Documentation]
     ...  DESCRIPTION:       verification of for the number of times SCell scheduling is suspended due to bad Radio Link quality for FR1 NSA
     ...                     - Details: 5G_UP_ALG_11885 and 5G_UP_5320
     ...                     - New PM Counters: SCELL_UL_SUSPEND_RLQ_NSA
     ...                     - PI ID: M55316C15042
     ...
     ...  PRECONDITION:      actCarAgPmCount is set to TRUE
     ...                     FR1 Cells are onAir
     ...  TEST STEPS:
     ...                     Step 1:
     ...                        Description: NSA MUE Call
     ...                        Expected: user data is correctly transferred over PSCell and SCell(s) for all UEs
     ...                     Step 2:
     ...                        Description: introduce bad RL quality
     ...                        Expected: SCell scheduling shall be suspended
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
     ...                     UTE Cloud Topology: CLOUD_5G_I_LO_AP_LO + VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ
     ...
     ...  REQUIREMENTS COVERAGE:
     ...       REQUIREMENTS IN SCOPE: 5G_PM_1743
     ...
     ...  REQUIRED LOGS:     PM Counters and TTI Traces
     ...
     ...  CONTACTS:      I_MN_RAN_RD_VRF_ULM_VT6@internal.nsn.com
     ...
     ...  REFERENCES:    CFAM User Scenario: https://gates.nsn-net.net/view/000254c4#o=596&hlt
     ...
     ...  HISTORY:
     ...                 [21.02.2024] - Created TP
     ...                 [20.03.2024] - Approved by https://collab.ext.net.nokia.com/ui#review:id=896722, review closed
     ...                 [22.03.2024] - Test scripts finished at commit: 014d85592b19cddfe7468069e750d16e02ce8df6
    [Tags]   CRT
    common_keywords.Run Test Scenario
    CB009267_scenario_validations.Verify CB009267_5G_PM_1743_FR1
    tracing.Check For Errors In Syslog


CB009267_5G_PM_1746_FR1
    [Documentation]
     ...  DESCRIPTION:       verification of the number of SCell scheduling is suspended due to UE overheating for NSA
     ...                     - Details: 5G_UP_8099 and 5G_UP_ALG_21870
     ...                     - New PM Counters: SCELL_UL_SUSPEND_UEOVHT_NSA and SCELL_DL_SUSPEND_UEOVHT_NSA
     ...                     - PI ID: M55316C15045-M55316C15046
     ...
     ...  PRECONDITION:      actCarAgPmCount is set to TRUE
     ...                     FR1 Cells are onAir
     ...  TEST STEPS:
     ...                     Step 1:
     ...                        Description: NSA MUE Call in CA
     ...                        Expected: user data is correctly transferred over PSCell and SCell(s) for all UEs
     ...                     Step 2:
     ...                        Description: UEs report CQI0 (overheating)
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
     ...                     UTE Cloud Topology: CLOUD_5G_I_LO_AP_LO + VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ
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
     ...                 [12.08.2024] - Automation finished
    [Tags]   CRT
    common_keywords.Run Test Scenario
    CB009267_scenario_validations.Verify CB009267_5G_PM_1746_FR1
    tracing.Check For Errors In Syslog


CB009267_5G_PM_1814_FR1
    [Documentation]
     ...  DESCRIPTION:       verification of the number of UL SCell or PSCell scheduling is suspended due to too low split TX power for FR1 NSA
     ...                     - Details: 5G_UP_ALG_14038 and 5G_UP_ALG_24087
     ...                     - New PM Counters: SCELL_UL_SUSPEND_LOWTXPWR_NSA and PSCELL_UL_SUSPEND_LOWTXPWR_NSA
     ...                     - PI ID: M55316C15047-M55316C15048
     ...
     ...  PRECONDITION:      actCarAgPmCount is set to TRUE
     ...                     FR1 Cells are onAir
     ...  TEST STEPS:
     ...                     Step 1:
     ...                        Description: NSA MUE Call in CA
     ...                        Expected: user data is correctly transferred over PSCell and SCell(s) for all UEs
     ...                     Step 2:
     ...                        Description: for a UE configured with FR1 UL CA, Ul scheduling shall be suspended
     ...                                     for the UE on serving cell in Ul overlapping slots due to too low split TX power.
     ...                                     Refer to conditions 1 , Condition 2 and condition 3 in 5G_UP_ALG_14038
     ...                        Expected: UL scheduling is suspended for UE on SCell in UL overlapping slots
     ...                     Step 3:
     ...                        Description: NSA MUE Call (FDD + FR1 TDD UL CA )
     ...                        Expected: user data is correctly transferred over PSCell and SCell(s) for all UEs
     ...                     Step 4:
     ...                        Description: for a UE configured with FR1 UL CA, UL scheduling shall be suspended
     ...                                     for the UE on serving cell in UL overlapping slots due to too low split TX power.
     ...                                     Refer to conditions 1 , Condition 2 and condition 3 in 5G_UP_ALG_14038
     ...                        Expected: UL scheduling is suspended for UE on PSCell in UL overlapping slots
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
     ...                     UTE Cloud Topology: CLOUD_5G_I_LO_AP_LO + VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ
     ...
     ...  REQUIREMENTS COVERAGE:
     ...       REQUIREMENTS IN SCOPE: 5G_PM_1814
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
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1814_FR1


CB009267_5G_PM_1815_FR1
    [Documentation]
     ...  DESCRIPTION:       verification of the number of UL SCell or PSCell scheduling is suspended due to too NACK Flood state for FR1 NSA
     ...                     - Details: 5G_UP_ALG_22805 and 5G_UP_ALG_3158
     ...                     - New PM Counters: PSCELL_UL_SUSPEND_NFD_NSA (in the PSCell) and SCELL_UL_SUSPEND_NFD_NSA (in the SCell)
     ...                     - PI ID: M55316C15049-M55316C15050
     ...
     ...  PRECONDITION:      actCarAgPmCount is set to TRUE
     ...                     FR1 Cells are onAir
     ...  TEST STEPS:
     ...                     Step 1:
     ...                        Description: NSA MUE Call in UL CA
     ...                        Expected: user data is correctly transferred over PSCell and SCell(s) for all UEs
     ...                     Step 2:
     ...                        Description: start NACK flood on SCell
     ...                        Expected: UL scheduling over the SCell is suspended
     ...                     Step 3:
     ...                        Description: start NACK flood on PSCell
     ...                        Expected: UL scheduling over the PSCell is suspended
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
     ...                     UTE Cloud Topology: CLOUD_5G_I_LO_AP_LO + VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ
     ...
     ...  REQUIREMENTS COVERAGE:
     ...       REQUIREMENTS IN SCOPE: 5G_PM_1815
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
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1815_FR1


CB009267_5G_PM_1760_FR1
    [Documentation]
     ...  DESCRIPTION:       verification of the number of time SCell deactivation has occurred due to UE overheating for FR1 NSA
     ...                     - Details: 5G_UP_ALG_11579
     ...                     - New PM Counters: SCELL_DL_DEACT_UEOVHT_NSA and SCELL_UL_DEACT_UEOVHT_NSA
     ...                     - PI ID: M55316C15059-M55316C15060
     ...
     ...  PRECONDITION:      actCarAgPmCount is set to TRUE
     ...                     FR1 Cells are onAir
     ...  TEST STEPS:
     ...                     Step 1:
     ...                        Description: NSA MUE Call in CA
     ...                        Expected: user data is correctly transferred over PSCell and SCell(s) for all UEs
     ...                     Step 2:
     ...                        Description: UEs report CQI0 (overheating)
     ...                        Expected: gNB deactivates SCell when UEs do not recover from overheating
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
     ...                     UTE Cloud Topology: CLOUD_5G_I_LO_AP_LO + VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ
     ...
     ...  REQUIREMENTS COVERAGE:
     ...       REQUIREMENTS IN SCOPE: 5G_PM_1760
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
    CB009267_scenario_validations.Verify CB009267_5G_PM_1760_FR1
    tracing.Check For Errors In Syslog


CB009267_5G_PM_1857_FR1
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
     ...                     FR1 Cells are onAir
     ...  TEST STEPS:
     ...                     Step 1:
     ...                        Description: NSA MUE Call in CA
     ...                        Expected: user data is correctly transferred over PSCell and SCell(s) for all UEs
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
     ...                     UTE Cloud Topology: CLOUD_5G_I_LO_AP_LO + VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ
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
    CB009267_scenario_validations.Verify CB009267_5G_PM_1857_FR1
    tracing.Check For Errors In Syslog


CB009267_5G_PM_1853_FR1
    [Documentation]
     ...  DESCRIPTION:       verification of the number of times SCell deactivated has occurred due to SCell in overheating for FR1 NSA
     ...                     - Details: 5G_UP_ALG_21870, 5G_L2_1294, and 5G_UP_ALG_26360 (FR2)
     ...                     - New PM Counters: SCELL_DL_DEACT_SCELLOVHT_NSA and SCELL_UL_DEACT_SCELLOVHT_NSA
     ...                     - PI ID: M55316C15061-M55316C15062
     ...
     ...  PRECONDITION:      actCarAgPmCount is set to TRUE
     ...                     FR1 Cells are onAir
     ...  TEST STEPS:
     ...                     Step 1:
     ...                        Description: NSA MUE Call in CA
     ...                        Expected: user data is correctly transferred over PSCell and SCell(s) for all UEs
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
     ...                     UTE Cloud Topology: CLOUD_5G_I_LO_AP_LO + VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ
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
    CB009267_scenario_validations.Verify CB009267_5G_PM_1853_FR1
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
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1777_FR1
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1743_FR1
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1746_FR1
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1814_FR1
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1815_FR1
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1760_FR1
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1857_FR1
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1853_FR1
