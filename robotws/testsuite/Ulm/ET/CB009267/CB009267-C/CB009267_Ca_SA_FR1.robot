*** Settings ***
Documentation
...
...     INTRODUCTION:  CB009267 "NR Carrier Aggregation Counters"
...                    This feature introduces CA related PM counters.
...
...     TEST SET NAME: CB009267_Carrier_Aggregation_Counters_SA
...
...     TESTING SCOPE: covers CB009267-Ca for the following User Scenarios:
...
...         [5G_PM_1772] Counter to count the number of UEs that have various number of SCells activated in DL and UL for SA
...
...        *[5G_PM_1738] Counter to identify when SCell scheduling suspension has occurred due to bad Radio Link quality for SA
...         [5G_PM_1739] Counter to identify when SCell scheduling suspension has occurred due to interaction with other non-CA eligible DRBs for SA
...        *[5G_PM_1741] Counter to identify when SCell scheduling suspension has occurred due to Measurement GAP for SA
...         [5G_PM_1744] Counter to identify when SCell scheduling suspension has occurred due to UE overheating for SA
...         [5G_PM_1813] Counter to identify when SCell or PCell scheduling suspension has occurred due to too low split TX power for SA
...         [5G_PM_1816] Counter to identify when SCell or PCell scheduling suspension has occurred due to NACK Flood state for SA
...        *[5G_PM_1823] Counter to identify when SA SCell in scheduling suspension state recovers and recommences scheduling
...        *[5G_PM_1824] Counter to identify when SA SCell in scheduling suspension state is deactivated or released
...
...        *[5G_PM_1751] Counter to identify when SCell deactivation has occurred due to SCell Inactivity Deactivation Timer for SA
...        *[5G_PM_1754] Counter to identify when buffer based SCell deactivation has occurred due to Bad RL quality for SA
...         [5G_PM_1755] Counter to identify when SCell deactivation has occurred due to UE overheating for SA
...         [5G_PM_1855] Counter to identify when SCell deactivation due to low Buffer has occurred for SA
...         [5G_PM_1851] Counter to identify when SCell deactivation has occurred due to SCell overheating for SA
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
${pm_reporting_interval}    5min
${relative_json_path}       ../../CB009267/CB009267-C/CB009267_Ca_SA_FR1.json
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***

CB009267_5G_PM_1772_FR1
    [Documentation]
     ...  DESCRIPTION:       verification of the number of UEs that have x SCells activated in DL and UL for SA both FR1 and FR2
     ...                     - Details: 5G_PM_1631
     ...                     - New PM Counters: PSCELL_UE_[0..7]_ACT_SCELL_DL_SA and PSCELL_UE_[0..3]_ACT_SCELL_UL_SA
     ...                     - PI ID: M55316C15030-M55316C15041
     ...
     ...  PRECONDITION:      actCarAgPmCount is set to TRUE
     ...                     FR1 Cells are onAir
     ...  TEST STEPS:
     ...                     Step 1:
     ...                        Description: SA MUE Call in CA
     ...                        Expected: gNB calculates internal counters for actual (current) number of CA users maintained in the cell,
     ...                                  separately for PCell UEs and SCell UEs, with differentiation on number of activated SCells
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
     ...       REQUIREMENTS IN SCOPE: 5G_PM_1772
     ...
     ...  REQUIRED LOGS:     PM Counters and TTI Traces
     ...
     ...  CONTACTS:      I_MN_RAN_RD_VRF_ULM_VT6@internal.nsn.com
     ...
     ...  REFERENCES:    CFAM User Scenario: https://gates.nsn-net.net/view/000254c4#o=593&hlt
     ...
     ...  HISTORY:
     ...                 [21.02.2024] - Created TP
     ...                 [20.03.2024] - Approved by https://collab.ext.net.nokia.com/ui#review:id=896722, review closed
     ...                 [22.03.2024] - Test scripts finished at commit: 014d85592b19cddfe7468069e750d16e02ce8df6
    [Tags]   CRT
    common_keywords.Run Test Scenario
    CB009267_scenario_validations.Verify CB009267_5G_PM_1772_FR1
    tracing.Check For Errors In Syslog


CB009267_5G_PM_1739_FR1
    [Documentation]
     ...  DESCRIPTION:       verification of the number of SCell scheduling is suspended due to interaction with non-CA eligible DRB
     ...                     - Details: 5G_UP_10395 and 5G_UP_ALG_24795
     ...                     - New PM Counters: SCELL_UL_SUSPEND_NELGBLDRB_SA
     ...                     - PI ID: M55316C15006
     ...
     ...  PRECONDITION:      actCarAgPmCount is set to TRUE
     ...                     FR1 Cells are onAir
     ...                     second gNB is simulated for the inter-gNB CA
     ...  TEST STEPS:
     ...                     Step 1:
     ...                        Description: SA MUE Call in CA
     ...                        Expected: user data is correctly transferred over PCell and SCell(s) for all UEs
     ...                     Step 2:
     ...                        Description: Setup non CA eligible DRB
     ...                        Expected: gNB does not schedule the PUSCH in the SCell as long as non-CA eligible bearer exists
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
     ...       REQUIREMENTS IN SCOPE: 5G_PM_1739
     ...
     ...  REQUIRED LOGS:     PM Counters and TTI Traces
     ...
     ...  CONTACTS:      I_MN_RAN_RD_VRF_ULM_VT6@internal.nsn.com
     ...
     ...  REFERENCES:    CFAM User Scenario: https://gates.nsn-net.net/view/000254c4#o=682&hlt
     ...
     ...  HISTORY:
     ...                 [21.02.2024] - Created TP
     ...                 [20.03.2024] - Approved by https://collab.ext.net.nokia.com/ui#review:id=896722, review closed
     ...                 [22.03.2024] - Test scripts finished at commit: 014d85592b19cddfe7468069e750d16e02ce8df6
    [Tags]   CRT
    common_keywords.Run Test Scenario
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1739_FR1


CB009267_5G_PM_1744_FR1
    [Documentation]
     ...  DESCRIPTION:       verification of the number of SCell scheduling is suspended due to UE overheating
     ...                     - Details: 5G_UP_8099 and 5G_UP_ALG_21870
     ...                     - New PM Counters: SCELL_UL_SUSPEND_UEOVHT_SA and SCELL_DL_SUSPEND_UEOVHT_SA
     ...                     - PI ID: M55316C15010-M55316C15011
     ...
     ...  PRECONDITION:      actCarAgPmCount is set to TRUE
     ...                     FR1 Cells are onAir
     ...  TEST STEPS:
     ...                     Step 1:
     ...                        Description: SA MUE Call in CA
     ...                        Expected: user data is correctly transferred over PCell and SCell(s) for all UEs
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
     ...       REQUIREMENTS IN SCOPE: 5G_PM_1744
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
     ...                 [24.07.2024] - Automation finished
    [Tags]   CRT
    common_keywords.Run Test Scenario
    CB009267_scenario_validations.Verify CB009267_5G_PM_1744_FR1
    tracing.Check For Errors In Syslog


CB009267_5G_PM_1813_FR1
    [Documentation]
     ...  DESCRIPTION:       verification of the number of UL SCell or PCell scheduling is suspended due to too low split TX power for FR1 SA
     ...                     - Details: 5G_UP_ALG_14038 and 5G_UP_ALG_24087
     ...                     - New PM Counters: SCELL_UL_SUSPEND_LOWTXPWR_SA and PCELL_UL_SUSPEND_LOWTXPWR_SA
     ...                     - PI ID: M55316C15012-M55316C15013
     ...
     ...  PRECONDITION:      actCarAgPmCount is set to TRUE
     ...                     FR1 Cells are onAir
     ...  TEST STEPS:
     ...                     Step 1:
     ...                        Description: SA MUE Call in CA
     ...                        Expected: user data is correctly transferred over PCell and SCell(s) for all UEs
     ...                     Step 2:
     ...                        Description: Create for a UE on a SCell in UL the condition of too low split TX power
     ...                                     Refer to conditions 1 , Condition 2 and condition 3 in 5G_UP_ALG_14038
     ...                        Expected: UL scheduling is suspended for UE on SCell in UL
     ...                     Step 3:
     ...                        Description: SA MUE Call (FDD + FR1 TDD UL CA )
     ...                        Expected: user data is correctly transferred over PCell and SCell(s) for all UEs
     ...                     Step 4:
     ...                        Description: Create for a UE on a PCell in UL the condition of too low split TX power
     ...                                     Refer to conditions 1 , Condition 2 and condition 3 in 5G_UP_ALG_14038
     ...                        Expected: UL scheduling is suspended for UE on PCell in UL
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
     ...       REQUIREMENTS IN SCOPE: 5G_PM_1813
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
     ...                 [xx.yy.2024] - Automation finished
    [Tags]   CRT
    common_keywords.Run Test Scenario
    CB009267_scenario_validations.Verify CB009267_5G_PM_1813_FR1
    tracing.Check For Errors In Syslog


CB009267_5G_PM_1816_FR1
    [Documentation]
     ...  DESCRIPTION:       verification of the number of UL SCell or PCell scheduling is suspended due to too NACK Flood state
     ...                     - Details: 5G_UP_ALG_22805 and 5G_UP_ALG_3158
     ...                     - New PM Counters: PCELL_UL_SUSPEND_NFD_SA and SCELL_UL_SUSPEND_NFD_SA
     ...                     - PI ID: M55316C15014-M55316C15015
     ...
     ...  PRECONDITION:      actCarAgPmCount is set to TRUE
     ...                     FR1 Cells are onAir
     ...  TEST STEPS:
     ...                     Step 1:
     ...                        Description: SA MUE Call in UL CA
     ...                        Expected: user data is correctly transferred over PCell and SCell(s) for all UEs
     ...                     Step 2:
     ...                        Description: start NACK flood on SCell
     ...                        Expected: UL scheduling over the SCell is suspended
     ...                     Step 3:
     ...                        Description: start NACK flood on PCell
     ...                        Expected: UL scheduling over the PCell is suspended
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
     ...       REQUIREMENTS IN SCOPE: 5G_PM_1816
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
    CB009267_scenario_validations.Verify CB009267_5G_PM_1816_and_1815_FR1
    tracing.Check For Errors In Syslog


CB009267_5G_PM_1755_FR1
    [Documentation]
     ...  DESCRIPTION:       verification of the number of times SCell deactivated has occurred due to UE overheating for FR1 SA
     ...                     - Details: 5G_UP_ALG_11579
     ...                     - New PM Counters: SCELL_DL_DEACT_UEOVHT_SA and SCELL_UL_DEACT_UEOVHT_SA
     ...                     - PI ID: M55316C15025-M55316C15026
     ...
     ...  PRECONDITION:      actCarAgPmCount is set to TRUE
     ...                     FR1 Cells are onAir
     ...
     ...  TEST STEPS:
     ...                     Step 1:
     ...                        Description: SA MUE Call in CA
     ...                        Expected: user data is correctly transferred over PCell and SCell(s) for all UEs
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
     ...       REQUIREMENTS IN SCOPE: 5G_PM_1755
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
    CB009267_scenario_validations.Verify CB009267_5G_PM_1755_FR1
    tracing.Check For Errors In Syslog


CB009267_5G_PM_1855_FR1
    [Documentation]
     ...  DESCRIPTION:       verification of the number of times Buffer based SCell deactivated for FR2 SA
     ...                     - Details: 5G_UP_ALG_26360, 5G_UP_ALG_2738 (for UL), and 5G_UP_ALG_2713 (for DL)
     ...                     - New PM Counters: SCELL_UL_DEACT_LOWBUFFER_SA and SCELL_DL_DEACT_LOWBUFFER_SA
     ...                     - PI ID: M55316C15021-M55316C15022
     ...
     ...  PRECONDITION:      actCarAgPmCount is set to TRUE
     ...                     dlScellDeactivationThreshold is set
     ...                     ulScellDeactivationThreshold is set
     ...                     FR1 Cells are onAir
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
     ...                     UTE Cloud Topology: CLOUD_5G_I_LO_AP_LO + VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ
     ...
     ...  REQUIREMENTS COVERAGE:
     ...       REQUIREMENTS IN SCOPE: 5G_PM_1855
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
    CB009267_scenario_validations.Verify CB009267_5G_PM_1855_FR1
    tracing.Check For Errors In Syslog


CB009267_5G_PM_1851_FR1
    [Documentation]
     ...  DESCRIPTION:       verification of the number of times SCell deactivated has occurred due to SCell in overheating for FR1 SA
     ...                     - Details: 5G_UP_ALG_21870, 5G_L2_1294, and 5G_UP_ALG_26360 (FR2)
     ...                     - New PM Counters: SCELL_DL_DEACT_SCELLOVHT_SA and SCELL_UL_DEACT_SCELLOVHT_SA
     ...                     - PI ID: M55316C15027-M55316C15028
     ...
     ...  PRECONDITION:      actCarAgPmCount is set to TRUE
     ...                     FR1 Cells are onAir
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
     ...                     UTE Cloud Topology: CLOUD_5G_I_LO_AP_LO + VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ
     ...
     ...  REQUIREMENTS COVERAGE:
     ...       REQUIREMENTS IN SCOPE: 5G_PM_1851
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
    CB009267_scenario_validations.Verify CB009267_5G_PM_1851_FR1
    tracing.Check For Errors In Syslog


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

*** Keywords ***
Offline_Verification
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the "*** Keywords ***" line
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable    /home/ute/test_repository/20230206_173251
    Set Suite Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Suite Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1772_FR1
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1739_FR1
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1744_FR1
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1813_FR1
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1816_and_1815_FR1
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1755_FR1
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1855_FR1
#    CB009267_scenario_validations.Verify CB009267_5G_PM_1851_FR1
