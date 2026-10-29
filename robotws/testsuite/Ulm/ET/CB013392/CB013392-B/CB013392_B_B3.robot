*** Settings ***

Documentation
...
...     INTRODUCTION:  CB013392-B SA power limitation consideration for DL CA Power Class determination
...                    The CB013392 introduces the possibility to assign different values of mobility measurement parameters by adding
...                    the effective band combination power class calculation in DL CA with effective power limitation consideration
...
...     TEST SET NAME: CB013392_B_SA_Effective_Power_Limitation_based_Power_Class_determination_DL_CA
...
...     TESTING SCOPE: covers CB013392-B subfeature
...
...     CONTACTS:      MN RAN RD VRF ULM 6 <I_MN_RAN_RD_VRF_ULM_VT6@internal.nsn.com>
...                    Lavanya Schmid, Daniel Lammers, Nikolay Shkulepov
...
...     REFERENCES:
...                [1] CB013392 CFAM: https://gates.nsn-net.net/view/00025ee1#o=0
...                [2] CB013392 FTS: https://nokia.sharepoint.com/:w:/r/sites/mn-ran-productization
...                                  /RAN%20Productization%20WoW/_layouts/15/Doc.aspx?
...                                  sourcedoc=%7BBAAAD487-C383-43D5-A997-72C86F89DD95%7D&file
...                                  =CB013392_Feature_Test_Strategy.docx&action=default&mobileredirect=true&wdsle=0
...                [3] Review Session in Collaborator: https://collab.ext.net.nokia.com/ui#review:id=915811
...
...      HISTORY:
...                [01.08.2024] - Initial version
...                [04.09.2024] - Created Test Plan
...                [01.10.2024] - Review Closed https://collab.ext.net.nokia.com/ui#review:id=919205
...                [17.10.2024] - Test Script finished
...                [18.07.2025] - Move to TMO test line

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Resource   ../../L2/resources/robot/test_setup.robot
Resource   ../../L2/resources/common_keywords.robot
Resource   ../../L2/resources/robot/tracing.robot
Resource   resources/CB013392_scenario_modifications.robot
Resource   resources/CB013392_scenario_verification.robot


Suite Setup     test_setup.Initialize Test Suite
Suite Teardown  common_keywords.Capture Snapshot And Restore Config
Test Teardown   common_keywords.Stop Logs And Collect Traces



*** Variables ***
${pm_reporting_interval}          5min
${relative_json_path}             ../../CB013392/CB013392-B/CB013392_B_B3.json
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***

CB013392_B_B3_TC01_IntragNB_A1_DL_SCell_change_to_DL_SCell_CA
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    [Documentation]
    ...  DESCRIPTION:
    ...    This user scenario extends the user scenario “USCB013392-A#B3” and describes how measurements are reconfigured at the UE using
    ...    the selected measurement profile during the SCell change when target is DL only SCell and effective power limitation is considered in
    ...    power class determination
    ...
    ...    USCB013392-A#B3:
    ...      This user scenario extends the user scenario “USCB008127-HS#B3” (5G_RAN_USR_RRM_23772) and describes how measurements are
    ...      reconfigured at the UE using the selected measurement profile during the SCell change.
    ...
    ...  PRECONDITION:
    ...  • CA relation is configured between PCell (NRCELL-3, band n41 TDD) and
    ...    SCell-1 (NRCELL-8, band n25 FDD, DL only) and SCell-2 (NRCELL-4, band n41 TDD, DL only)
    ...    - NRCELL-3/NRREL-1 points to NRCELL-8
    ...    - NRCELL-3/NRREL-2 points to NRCELL-4
    ...  • CB013392-B is activated ('NRBTS.actMeasurementProfReselForCA' = pcInSaUlAndDlCaSupported)
    ...  • Intra-freq (for example 5GC000704/708) and inter-freq (for example 5GC000706) measurements are supported
    ...
    ...  CB013392-A#B3 related configuration:
    ...  • UE is connected to NRCELL-3 (PCell) and NRCELL-8 (DL only SCell-1)
    ...    - Measurement based SCell addition is setup (5GC001765 and related features)
    ...  • Intra-freq measurements are supported (for example 5GC000704/5GC000708 are enabled)
    ...
    ...  CB013392 related configuration:
    ...  • There are two measurement profile mappings defined
    ...    - NRMEASPR_MA_SA-1 with ue-PowerClass2 criterion and NRMEASPR_IAF-1 profile pointed and higher priority defined in NRCELL-3
    ...    - NRMEASPR_MA_SA-2 with ue-PowerClass3 criterion and NRMEASPR_IAF-2 profile pointed and lower priority defined in NRCELL-3
    ...  • Measurement profiles NRMEASPR_IAF-1 and NRMEASPR_IAF-2 are configured with different values
    ...
    ...  5GC000704 IFHO-B#B8 related configuration (5G_RAN_USR_RRM_1413):
    ...  • gNB up and running
    ...  • 5G UE/Airphone up and running
    ...  • Initial context is setup successfully and UE has been configured for measurement event A5.
    ...  • Criteria for the configured measurement event A5 is met.
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
    ...  UE Capabilities:
    ...  • UE capabilities as received from UE in the message “RRC:UE Capability Information” (IE “UE-NR-Capability->RF-Parameters) has following:
    ...    - supportedBandListNR contains three bands (n25 and n41) having power classes as follows:
    ...      - (band n25, power class 3)
    ...      - (band n41, power class 2)
    ...  • supportedBandCombinationList contains following:
    ...    - band combination {band n25, band n41, power class 2}
    ...    - band combination {band n41, band n41, power class 3}
    ...
    ...  Note: Power class 2 and 3 are just examples. Other power classes might be used on purpose of the test. The only goal is to capture that
    ...        power class of the band combination before SCell change and after SCell change are different.
    ...
    ...  TRIGGER:
    ...  • SCell-1 change to SCell-2 procedure starts.
    ...
    ...  TEST STEPS:
    ...  Step 1:
    ...    Description:
    ...    • Register UE to 5G n41 TDD (pc2) cell
    ...
    ...    Expected:
    ...    • UE is successfully registered
    ...    • Mapping MO 'NRMEASPR_MA_SA-1' is selected and 'NRBTS/NRMEASPR/NRMEASPR_IAF-1' is selected as the Intra-Freq measurement profile for
    ...      the UE as the UE power class for the band combination of n41(PCell) is pc2
    ...    • ReportconfigNr of Intra-Freq A3/A5 and A2 are present in the measConfig.reportConfigToAddModList with the same ReportConfigId as the
    ...      one used in the UE for these reportConfigNrs
    ...      - The IE 'ReportConfigNr.EventTriggerConfig.eventA2' for the MeasObject corresponding to serving cell frequency is filled using
    ...       'NRBTS/NRMEASPR/NRMEASPR_IAF-1.a2MeashoSsbRsrp'.
    ...        The IE 'ReportConfigNr.EventTriggerConfig.eventA2' for the MeasObject corresponding to serving cell frequency is filled using
    ...       'NRBTS/ NRMEASPR/NRMEASPR_IAF-1.a2MeasRedirectSsbRsrp'
    ...      - 'ReportConfigNr.EventTriggerConfig.eventA3' for the MeasObject corresponding to PCell is filled using
    ...        'NRBTS/ NRMEASPR/NRMEASPR_IAF-1. a3MeasSsbRsrp'
    ...      - 'ReportConfigNr.EventTriggerConfig.eventA5' for the MeasObject corresponding to PCell is filled using
    ...        'NRBTS/ NRMEASPR/NRMEASPR_IAF-1. a5MeasSsbRsrp'
    ...
    ...  Step 2:
    ...    Description:
    ...    • A1 measurement report is triggered from UE that has a threshold value higher than a1ThresholdSCellAddSsbRsrpFDD leading to
    ...      FDD SCELL addition.  This trigger is done using "ue_measurement_send_nr" EGATE command.
    ...    Expected:
    ...    • FDD Scell (n25) gets added for DL only
    ...    • Power class 2 is retained
    ...
    ...  Step 3:
    ...    Description:
    ...    • A1 measurement report is triggered from UE that has a threshold value higher than a1ThresholdSCellAddSsbRsrpTDD leading to
    ...      TDD SCELL addition.  This trigger is done using "ue_measurement_send_nr" EGATE command.
    ...    Expected:
    ...    • UE is now served by TDD SCell(n41) for DL only.  FDD SCell(n25) is removed.
    ...    • Mapping MO 'NRMEASPR_MA_SA-2' is selected and 'NRBTS/NRMEASPR/NRMEASPR_IAF-2' is selected as the Intra-Freq measurement profile
    ...      for the UE as the UE power class for the band combination of n41(PCell) + n41(SCell-2) is pc3
    ...    • ReportconfigNr of Intra-Freq A3/A5 and A2 are present in the measConfig.reportConfigToAddModList with the same ReportConfigId as
    ...      the one used in the UE for these reportConfigNrs
    ...      - The IE 'ReportConfigNr.EventTriggerConfig.eventA2' for the MeasObject corresponding to serving cell frequency is filled using
    ...       'NRBTS/NRMEASPR/NRMEASPR_IAF-2.a2MeashoSsbRsrp'.
    ...       The IE 'ReportConfigNr.EventTriggerConfig.eventA2' for the MeasObject corresponding to serving cell frequency is filled using
    ...       'NRBTS/ NRMEASPR/NRMEASPR_IAF-2.a2MeasRedirectSsbRsrp'
    ...      - 'ReportConfigNr.EventTriggerConfig.eventA3' for the MeasObject corresponding to PCell is filled using
    ...        'NRBTS/ NRMEASPR/NRMEASPR_IAF-2. a3MeasSsbRsrp'
    ...      - 'ReportConfigNr.EventTriggerConfig.eventA5' for the MeasObject corresponding to PCell is filled using
    ...        'NRBTS/ NRMEASPR/NRMEASPR_IAF-2. a5MeasSsbRsrp'
    ...
    ...  Step 4:
    ...    Description:
    ...    • Start DL user data traffic on UE#1
    ...
    ...    Expected:
    ...    • DL data transfer is realized for the UE via both cells
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
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_26748
    ...
    ...  REQUIRED LOGS:  EGATE Console logs, PM Counters
    ...
    ...  CONTACTS:       Daniel Lammers
    ...  REFERENCES:     see "Documentation" part above
    ...  HISTORY:        Review Closed https://collab.ext.net.nokia.com/ui#review:id=919205
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    common_keywords.Run Test Scenario
    CB013392_scenario_verification.Verify CB013392_B_B3_TC01_IntragNB_A1_DL_SCell_change_to_DL_SCell_CA
    tracing.Check For Errors In Syslog


*** Keywords ***
Offline_Verification
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the "*** Keywords ***" line
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    ${result_base_dir}=   Set Variable
    ...    /home/ute/logs/CB013392_B_B3/2025-07-18T07-30-47-F/CB013392_B_B3/SBTS00_ENB_9999_250717_000007/20250718_073133
    test_setup.Read Test Configuration From JSON File
    Set Suite Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Suite Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    CB013392_scenario_verification.Verify CB013392_B_B3_TC01_IntragNB_A1_DL_SCell_change_to_DL_SCell_CA
