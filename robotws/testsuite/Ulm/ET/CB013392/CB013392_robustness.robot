*** Settings ***

Documentation
...
...     INTRODUCTION:  CB013392 Measurement Profiles Power Class criterion for CA UEs
...                    The CB013392 introduces the possibility to assign different values of mobility measurement parameters and
...                    power class determination to different UE groups for UL CA.
...
...     TEST SET NAME: CB013392_robustness
...
...     TESTING SCOPE: Combines from CB013392 three TCs into one robustness TC on the TMO testline variant with multiple UEs.
...                    The test descriptions below are separated for each TC, but the automated scripts execute most of the steps in parallel.
...
...     CONTACTS:      MN RAN RD VRF ULM 6 <I_MN_RAN_RD_VRF_ULM_VT6@internal.nsn.com>
...                    Daniel Lammers, Lavanya Schmid
...
...     REFERENCES:
...                [1] Original CB013392 B & C Test Plan: https://collab.ext.net.nokia.com/ui#review:id=919205
...
...      HISTORY:
...                [18.06.2025] - Initial version with SA SCell addition/release (B_B2 + B_B7) and NSA handover (C_B2)

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Resource   ../L2/resources/robot/test_setup.robot
Resource   ../L2/resources/common_keywords.robot
Resource   resources/CB013392_robustness_scenario_modifications.robot
Resource   resources/CB013392_robustness_scenario_verification.robot


Suite Setup     Run Keywords
...             test_setup.Initialize Test Suite
Suite Teardown  Run Keywords
...             common_keywords.Capture Snapshot And Restore Config
Test Teardown   common_keywords.Stop Logs And Collect Traces



*** Variables ***
${pm_reporting_interval}          5min
${relative_json_path}             ../../CB013392/CB013392_robustness.json
${ENABLE_EGATE_CMD_CHECKS}        ${False}        # set to True during test automation preparations and debugging
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***

CB013392_B_B2_TC01_IntragNB_A1_SCell_addition_DL_CA
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    [Documentation]
    ...  DESCRIPTION:
    ...    This user scenario describes the successful UE configuration during Carrier Aggregation setup. A1 or A4 MR based SCell addition
    ...    is triggered. This user scenario extends the behavior described in USCB013392-A#B2 and introduces consideration of effective power
    ...    limitation.
    ...    USCB013392-A#B2:
    ...      This user scenario describes the successful UE configuration of the UL Carrier Aggregation for single UE with 2 aggregated carriers.
    ...      A1 or A4 MR based SCell addition is triggered.  This user scenario modifies the behavior described in USCB008127-HS#B2
    ...      (5G_RAN_USR_RRM_23753) and introduces usage of power class criterion in UL CA.
    ...
    ...  PRECONDITION:
    ...  • CB013392-B is activated ('NRBTS.actMeasurementProfReselForCA' = pcInSaUlAndDlCaSupported)
    ...  • Intra-frequency A2/A3/A5 measurement are supported (for example 5GC000704/708) and configured at the UE using selected measurement
    ...    profile (NRMEASPR_IAF-1) as the UE is ue-PowerClass2 in the PCell (band n41).
    ...  • Measurement based SCell addition is setup (5GC001765 and related features or CB006733)
    ...
    ...  5GC000704 IFHO-B#B8 related configuration (5G_RAN_USR_RRM_1413):
    ...  • gNB up and running
    ...  • 5GUE/Airphone up and running
    ...  • Initial context is setup successfully and UE has been configured for measurement event A5.
    ...  • Criteria for the configured measurement event A5 is met.
    ...
    ...  5GC001765 related configuration (5G_RAN_USR_16016):
    ...  • CA relation configured between PCell and SCell
    ...  - 5GC001390: FDD cell contains the NRREL object referring to the FR1-TDD cell with scellAdditionMethod parameter set to 1 (covBasedA1).
    ...  • SCell Addition for Inter band CA based on serving cell UE measurement A1 (5GC001765) is enabled using
    ...    MRBTS/NRBTS/actMeasBasedSCellAddition.
    ...  • SCell Addition related parameters for A1 measurement are configured through O&M parameters for the FDD cell.
    ...  - NRBTS/NRCELL/a1MeasSCellAddEnabled
    ...  - NRBTS/NRCELL/a1MeasSCellAddSsbRsrp or NRBTS/NRCELL/a1MeasSCellAddSsbRsrq
    ...
    ...  UE Capabilities:
    ...  • UE capabilities as received from UE in the message “RRC:UE Capability Information” (IE “UE-NR-Capability->RF-Parameters) has following:
    ...    - supportedBandListNR contains two bands (n25 and n41) having power classes as follows:
    ...      - (band n25, power class 3)
    ...      - (band n41, power class 2)
    ...  • supportedBandCombinationList contains {band n25, band n41}
    ...    - (bandCombination n25 & n41, power class 3)
    ...
    ...  • Note: See 3GPP 38.101 Table 6.2.1-1: UE Power Class for the possible UE capabilities according to the band.
    ...  • Note 2: Power class 2 and 3 are just examples. Other power classes might be used on purpose of the test. The only goal is to capture
    ...            that power class for a single band and power class for the band combination are different.
    ...
    ...  TRIGGER:
    ...  • Measurement based SCell addition procedure starts
    ...
    ...  TEST STEPS:
    ...  Step 1:
    ...    Description:
    ...    • Register UEs to 5G n41 TDD (pc2) cell
    ...    Expected:
    ...    • UEs are successfully registered
    ...
    ...  Step 2:
    ...    Description:
    ...    • Trigger SCell addition via A1 measurement using "ue_measurement_send_nr" EGATE command. UEs support power class 3 for the band
    ...      combination n41 and n25
    ...    Expected:
    ...    • SCell is added successfully for DL.
    ...    • Measurement profile NRMEASPR_IAF-2 (pc3) is selected as the Intra frequency A3/A5 and A2 measurement profile for these UEs.
    ...    • RRC reconfiguration message is verified if the measurement configuration for the events are set as per the measurement profile
    ...    • reportConfigNr in “measConfig. reportConfigToAddModList" for intra-Freq A3/A5 and A2 (mobility and redirection) in RRCReconfiguration
    ...      message are set according to the selected measurement profile (NRMEASPR_IAF-2) as follows.
    ...      - The IE 'ReportConfigNr.EventTriggerConfig.eventA2' for the MeasObject corresponding to serving cell frequency is filled using
    ...        'NRBTS/NRMEASPR/NRMEASPR_IAF-2.a2MeashoSsbRsrp'. The IE 'ReportConfigNr.EventTriggerConfig.eventA2' for the MeasObject corresponding
    ...        to serving cell frequency is filled using 'NRBTS/ NRMEASPR/NRMEASPR_IAF-2.a2MeasRedirectSsbRsrp'
    ...      - 'ReportConfigNr.EventTriggerConfig.eventA3' for the MeasObject corresponding to PCell is filled using
    ...        'NRBTS/ NRMEASPR/NRMEASPR_IAF-2. a3MeasSsbRsrp'
    ...      - 'ReportConfigNr.EventTriggerConfig.eventA5' for the MeasObject corresponding to PCell is filled using
    ...        'NRBTS/NRMEASPR/NRMEASPR_IAF-2. a5MeasSsbRsrp'
    ...
    ...  Step 3:
    ...    Description:
    ...    • Start DL & UL user data traffic on UEs
    ...    Expected:
    ...    • UL and DL data transfer is realized for the UEs via both cells
    ...
    ...  POSTCONDITION:   UEs are configured with TDD cell as PCell and FDD cell as SCell.
    ...
    ...  TESTING TOOLS:
    ...    - No specific tools needed
    ...
    ...  TEST ENVIRONMENT:
    ...      HARDWARE ID:
    ...             1x gNB: ASIL / ABIO
    ...             Airphone: ASIL / ABIO
    ...             WTS 5G Core Simulator
    ...             UTE Cloud Topology:  CLOUD_5G_I_LOO_AP_LOOO + VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_26747
    ...
    ...  REQUIRED LOGS:  EGATE Console logs, PM Counters
    ...
    ...  CONTACTS:       Daniel Lammers
    ...  REFERENCES:     see "Documentation" part above
    ...  HISTORY:        Review Closed https://collab.ext.net.nokia.com/ui#review:id=919205
    common_keywords.Run Test Scenario
    CB013392_robustness_scenario_verification.Verify CB013392_B_B2_TC01_IntragNB_A1_SCell_addition_DL_CA


CB013392_B_B7_TC01_IntragNB_A2_SCell_release_DL_CA
    [Documentation]
    ...  DESCRIPTION:
    ...    This user scenario extends the behavior of USCB013392-A#B5 and describes the successful UE configuration
    ...    during full Intra-gNB DL Carrier Aggregation release. Intra-gNB SCell release is triggered for all the SCells. This scenario describes
    ...    how measurement profile is reselected for the new non-CA setup, with Power Class criterion allowed.
    ...
    ...    USCB013392-A#B5:
    ...      This user scenario describes the successful UE mobility measurements reconfiguration during Intra-gNB UL SCell release.
    ...
    ...  PRECONDITION:
    ...  • UEs are connected to PCell (NRCELL-1, band n41) and SCell (NRCELL-2, band n25)
    ...  • Intra-gNB Carrier Aggregation is supported (for example 5GC001390, 5GC001765 or CB006733)
    ...  • Intra-freq (for example 5GC000704/708) measurements are supported
    ...
    ...  CB013392 related configuration:
    ...  • CB008127 feature is enabled for SA and CB013392-B is activated to support power class criterion determination based on
    ...    effective power limitation in DL CA (pcInSaUlAndDlCaSupported)
    ...  • There are two measurement profile mappings defined
    ...    - NRMEASPR_MA_SA-1 with ue-PowerClass2 criterion and NRMEASPR_IAF-1 profile pointed and higher priority defined in NRCELL-1
    ...    - NRMEASPR_MA_SA-2 with ue-PowerClass3 criterion and NRMEASPR_IAF-2 profile pointed and lower priority defined in NRCELL-1
    ...  • Measurement profiles NRMEASPR_IAF-1 and NRMEASPR_IAF-2 are configured with different values
    ...
    ...  5GC001765 related configuration (5G_RAN_USR_16016):
    ...  • CA relation configured between PCell and SCell
    ...    - 5GC001390: FDD cell contains the NRREL object referring to the FR1-TDD cell with scellAdditionMethod parameter set to 1 (covBasedA1).
    ...  • SCell Addition for Inter band CA based on serving cell UE measurement A1 (5GC001765) is enabled using
    ...    MRBTS/NRBTS/actMeasBasedSCellAddition.
    ...  • SCell Addition related parameters for A1 measurement are configured through O&M parameters for the FDD cell.
    ...    - NRBTS/NRCELL/a1MeasSCellAddEnabled
    ...    - NRBTS/NRCELL/a1MeasSCellAddSsbRsrp or NRBTS/NRCELL/a1MeasSCellAddSsbRsrq
    ...
    ...  5GC000704 IFHO-B#B8 related configuration (5G_RAN_USR_RRM_1413):
    ...  • gNB up and running
    ...  • 5GUE/Airphone up and running
    ...  • Initial context is setup successfully and UE has been configured for measurement event A5.
    ...  • Criteria for the configured measurement event A5 is met.
    ...
    ...  UE Capabilities:
    ...  • UE capabilities as received from UE in the message “RRC:UE Capability Information” (IE “UE-NR-Capability->RF-Parameters) has following:
    ...    - supportedBandListNR contains two bands (n25 and n41) having power classes as follows:
    ...      - (band n25, power class 3)
    ...      - (band n41, power class 2)
    ...    - supportedBandCombinationList contains {band n25, band n41}
    ...      - (bandCombination n25 & n41, power class 3)
    ...
    ...  Note: See 3GPP 38.101 Table 6.2.1-1: UE Power Class for the possible UE capabilities according to the band.
    ...
    ...  Note 2: Power class 2 and 3 are just examples. Other power classes might be used on purpose of the test. The only goal is to capture
    ...          that power class for a single band and power class for the band combination are different
    ...
    ...  TRIGGER:
    ...  • Intra-gNB SCell release trigger is received at gNB
    ...
    ...  TEST STEPS:
    ...  Step 1:
    ...    Description:
    ...        • Register UEs to 5G n41 TDD (pc2) cell
    ...    Expected:
    ...        • UEs are successfully registered.
    ...
    ...  Step 2:
    ...    Description:
    ...        • UEs are triggered to send RRC with A1 measurement report to gNB using "ue_measurement_send_nr" EGATE command to add SCell.
    ...    Expected:
    ...        • FDD SCell (n25) is successfully added.
    ...        • UEs are now served by PCell (n41) and SCell (n25) for DL.
    ...        • Mapping MO 'NRMEASPR_MA_SA-2' is selected and 'NRBTS/NRMEASPR/NRMEASPR_IAF-2' is selected as the Intra-Freq measurement profile
    ...          for the UEs as the UE power class for the band combination of n41(PCell) + n25(SCell) is pc3
    ...        • ReportconfigNr of Intra-Freq A3/A5 and A2 are present in the measConfig.reportConfigToAddModList with the same ReportConfigId
    ...          as the one used in the UEs for these reportConfigNrs
    ...          - The IE 'ReportConfigNr.EventTriggerConfig.eventA2' for the MeasObject corresponding to serving cell frequency is filled using
    ...            'NRBTS/NRMEASPR/NRMEASPR_IAF-2.a2MeashoSsbRsrp'.
    ...            The IE 'ReportConfigNr.EventTriggerConfig.eventA2' for the MeasObject corresponding to serving cell frequency is filled using
    ...            'NRBTS/ NRMEASPR/NRMEASPR_IAF-2.a2MeasRedirectSsbRsrp'
    ...          - 'ReportConfigNr.EventTriggerConfig.eventA3' for the MeasObject corresponding to PCell is filled using
    ...            'NRBTS/ NRMEASPR/NRMEASPR_IAF-2. a3MeasSsbRsrp'
    ...          - 'ReportConfigNr.EventTriggerConfig.eventA5' for the MeasObject corresponding to PCell is filled using
    ...            'NRBTS/ NRMEASPR/NRMEASPR_IAF-2. a5MeasSsbRsrp'
    ...
    ...  Step 3:
    ...    Description:
    ...        • Trigger SCell release request via A2 MR using "ue_measurement_send_nr" EGATE command
    ...    Expected:
    ...        • SCell (n25) is released successfully
    ...        • UEs are now served by PCell (n41) only, whose power class is pc2
    ...        • Mapping MO 'NRMEASPR_MA_SA-1' is selected and 'NRBTS/NRMEASPR/NRMEASPR_IAF-1' is selected as the Intra-Freq measurement profile
    ...          for the UEs
    ...        • ReportconfigNr of Intra-Freq A3/A5 and A2 are present in the measConfig.reportConfigToAddModList with the same ReportConfigId
    ...          as the one used in the UEs for these reportConfigNrs
    ...          - The IE 'ReportConfigNr.EventTriggerConfig.eventA2' for the MeasObject corresponding to serving cell frequency is filled using
    ...           'NRBTS/NRMEASPR/NRMEASPR_IAF-1.a2MeashoSsbRsrp'.
    ...            The IE 'ReportConfigNr.EventTriggerConfig.eventA2' for the MeasObject corresponding to serving cell frequency is filled using
    ...           'NRBTS/ NRMEASPR/NRMEASPR_IAF-1.a2MeasRedirectSsbRsrp'
    ...          - 'ReportConfigNr.EventTriggerConfig.eventA3' for the MeasObject corresponding to PCell is filled using
    ...            'NRBTS/ NRMEASPR/NRMEASPR_IAF-1. a3MeasSsbRsrp'
    ...          - 'ReportConfigNr.EventTriggerConfig.eventA5' for the MeasObject corresponding to PCell is filled using
    ...            'NRBTS/ NRMEASPR/NRMEASPR_IAF-1. a5MeasSsbRsrp'
    ...
    ...  Step 4:
    ...    Description:
    ...        • Start DL and UL user data traffic on UEs
    ...    Expected:
    ...        • Data transfer is realized for the UEs via PCell only
    ...
    ...  POSTCONDITION:   UEs are configured with PCell only.
    ...
    ...  TESTING TOOLS:
    ...    - No specific tools needed
    ...
    ...  TEST ENVIRONMENT:
    ...      HARDWARE ID:
    ...             1x gNB: ASIL / ABIO
    ...             Airphone: ASIL / ABIO
    ...             WTS 5G Core Simulator
    ...             UTE Cloud Topology:  CLOUD_5G_I_LOO_AP_LOOO + VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_26868
    ...
    ...  REQUIRED LOGS:  EGATE Console logs, PM Counters
    ...
    ...  CONTACTS:       Daniel Lammers
    ...  REFERENCES:     see "Documentation" part above
    ...  HISTORY:        Review Closed https://collab.ext.net.nokia.com/ui#review:id=919205
    common_keywords.Run Test Scenario
    CB013392_robustness_scenario_verification.Verify CB013392_B_B7_TC01_IntragNB_A2_SCell_release_DL_CA


CB013392_C_B2_TC01_NSA_IAF_activation_during_SgNB_initiated_IntraSgNB_A2_A3_triggered_PScell_change_with_MeNB_power_coordination
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    [Documentation]
    ...  DESCRIPTION:
    ...  This user scenario extends the user scenario “USCB008127-CD#B3” (5G_RAN_USR_RRM_21040) and describes how measurements are configured
    ...  at the UE using the selected measurement profile during SgNB-initiated Intra-MeNB Intra-SgNB Intra-DU PSCell change with consideration of
    ...  MeNB power coordination.
    ...
    ...  Note: A2 measurement configuration is done for both A2 for mobility and A2 for SgNB release.
    ...
    ...    USCB008127-CD#B3:
    ...      This user scenario describes the SgNB behaviour during intra-DU PS cell change, UE shall be configured with required A2 measurement
    ...      and intra-frequency A3/A5 measurements using selected measurement profile for NSA.
    ...
    ...  PRECONDITION:
    ...   • Intra-freq (for example 5GC002177/1095/1094/2199) measurements are supported
    ...   • Intra-DU PSCell change is supported (5GC002173)
    ...   • Target PSCell's freq band is n41
    ...
    ...  CB013392 related configuration:
    ...  • CB008127 feature is enabled for NSA and CB013392-C is activated to support MeNB power coordination in power class determination
    ...  • There are two measurement profile mappings defined
    ...    - NRMEASPR_MA_NSA-1 with ue-PowerClass2 criterion and NRMEASPR_IAF-1 profile pointed and higher priority defined in NRCELL
    ...    - NRMEASPR_MA_NSA-2 with ue-PowerClass3 criterion and NRMEASPR_IAF-2 profile pointed and lower priority defined in NRCELL
    ...  • Measurement profiles NRMEASPR_IAF-1 and NRMEASPR_IAF-2 are configured with different values
    ...  • supportedBandListNR contains power classes as follows:
    ...    - (band n41, power class 2)
    ...
    ...  Note: Power class 2 and 3 are just examples. Other power classes might be used on purpose of the test.
    ...
    ...  TRIGGER:
    ...  • Intra-DU PSCell change procedure is started once measurement report is received
    ...
    ...  TEST STEPS:
    ...  Step 1:
    ...    Description:
    ...    • Attach UEs to the MeNB and initiate EN-DC SgNB addition.
    ...    Expected:
    ...    • UEs are attached to MeNB and SgNB.
    ...
    ...  Step 2:
    ...    Description:
    ...    • Trigger handover from one PSCell cell to another PScell (n41 with pc2) in SgNB by triggering A2 and then A3 measurement events.
    ...      A2 and A3 triggers are done using "ue_measurement_send_nr" EGATE command.
    ...    Expected:
    ...    • PScell hand over is done.
    ...    • NRMEASPR_IAF-2 based on power class 3 is selected as the measurement profile (due to effective power limitation of p_max_nr=23dBm
    ...      even though the n41 has pc2 as per UE capabilities)
    ...
    ...  Step 3:
    ...    Description:
    ...    • Start DL/UL user data traffic on the UEs.
    ...    Expected:
    ...    • DL and UL data transfer is realized for the UEs.
    ...
    ...  TESTING TOOLS:
    ...    - No specific tools needed
    ...
    ...  TEST ENVIRONMENT:
    ...      HARDWARE ID:
    ...             1x gNB: ASIL / ABIO
    ...             Airphone: ASIL / ABIO
    ...             WTS 5G Core Simulator
    ...             UTE Cloud Topology: CLOUD_5G_I_LOO_AP_LOOO + VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_26751
    ...
    ...  REQUIRED LOGS:  EGATE Console logs, PM Counters
    ...
    ...  CONTACTS:       Daniel Lammers
    ...  REFERENCES:     see "Documentation" part above
    ...  HISTORY:        Review Closed https://collab.ext.net.nokia.com/ui#review:id=919205
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    common_keywords.Run Test Scenario
    CB013392_robustness_scenario_verification.Verify CB013392_C_B2_TC01_NSA_PScell_change_with_MeNB_power_coordination


*** Keywords ***
Offline Verification
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the "*** Keywords ***" line
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable
    ...    /home/ute/logs/CB013392_robustness/2025-06-18T12-55-22-F/CB013392_robustness/SBTS00_ENB_9999_250617_000006/20250618_125556
    Set Suite Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Suite Variable  ${TS_LOG_DIR}    ${result_base_dir}/Logs
    CB013392_robustness_scenario_verification.Verify CB013392_B_B2_TC01_IntragNB_A1_SCell_addition_DL_CA
    CB013392_robustness_scenario_verification.Verify CB013392_B_B7_TC01_IntragNB_A2_SCell_release_DL_CA
    CB013392_robustness_scenario_verification.Verify CB013392_C_B2_TC01_NSA_PScell_change_with_MeNB_power_coordination
