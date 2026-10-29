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
...                [04.11.2024] - Test Script finished
...                [27.10.2025] - Migration to TMO

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
${relative_json_path}             ../../CB013392/CB013392-B/CB013392_B_B8.json
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***

CB013392_B_B8_TC01_IntragNB_A1_partial_SCell_release_3CC_DL_CA
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    [Documentation]
    ...  DESCRIPTION:
    ...    This user scenario describes the successful UE configuration during partial Intra-gNB SCell release. Intra-gNB SCell release is
    ...    triggered not for all the SCells. This scenario describes how measurement profile is reselected for the new CA setup, with Power Class
    ...    criterion allowed.
    ...
    ...  PRECONDITION:
    ...  • UE is connected to PCell (NRCELL-1, band n41), SCell-1 (NRCELL-2, band n25) and SCell-2 (NRCELL-3, band41)
    ...  • Intra-gNB Carrier Aggregation is supported (for example 5GC001390, 5GC001765 or CB006733)
    ...  • Intra-freq (for example 5GC000704/708) measurements are supported
    ...  CB013392 related configuration:
    ...  • CB008127 feature is enabled for SA and CB013392-B is activated to support power class criterion determination based on
    ...    effective power limitation in DL CA (pcInSaUlAndDlCaSupported)
    ...  • There are two measurement profile mappings defined
    ...    - NRMEASPR_MA_SA-1 with ue-PowerClass2 criterion and NRMEASPR_IAF-1 profile pointed and higher priority defined in NRCELL-1
    ...    - NRMEASPR_MA_SA-2 with ue-PowerClass3 criterion and NRMEASPR_IAF-2 profile pointed and lower priority defined in NRCELL-1
    ...  • Measurement profiles NRMEASPR_IAF-1 and NRMEASPR_IAF-2 are configured with different values
    ...
    ...  5GC000704 IFHO-B#B8 related configuration (5G_RAN_USR_RRM_1413):
    ...  • gNB up and running
    ...  • 5GUE/Airphone up and running
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
    ...    - supportedBandListNR contains bands (n25 and n41) having power classes as follows:
    ...      - (band n25, power class 3)
    ...      - (band n41, power class 2)
    ...
    ...  • supportedBandCombinationList contains {band n25, band n41, band n41}
    ...    - bandCombination n25 & n41 & n41, power class 3
    ...    - bandCombination n41 & n41, power class 2
    ...
    ...  • Note: See 3GPP 38.101 Table 6.2.1-1: UE Power Class for the possible UE capabilities according to the band.
    ...
    ...  Note 2: Power class 2 and 3 are just examples. Other power classes might be used on purpose of the test. The only goal is to capture
    ...          that power class for the single band, first band combination and power class for the second band combination are different.
    ...
    ...  TRIGGER:
    ...  • A1 MR based SCell-1 release trigger
    ...
    ...  TEST STEPS:
    ...  Step 1:
    ...    Description:
    ...    • Register UE to 5G n41 TDD (pc2) cell
    ...    Expected:
    ...    • UE is successfully registered.
    ...
    ...  Step 2:
    ...    Description:
    ...    • UE is triggered to send RRC with A1 measurement report to gNB using "ue_measurement_send_nr" EGATE command and Scells are added.
    ...    Expected:
    ...    • SCell-1 (n25) and SCell-2 (n41) are successfully added.
    ...    • UE is now served by PCell (n41), SCell (n25) and SCell (n41) for DL only.
    ...    • Mapping MO 'NRMEASPR_MA_SA-2' is selected and 'NRBTS/NRMEASPR/NRMEASPR_IAF-2' is selected as the Intra-Freq measurement profile
    ...      for the UE as the UE power class for the band combination of n41(PCell) + n25(SCell-1) + n41(SCell-2) is pc3
    ...    • ReportconfigNr of Intra-Freq A3/A5 and A2 are present in the measConfig.reportConfigToAddModList with the same ReportConfigId as
    ...      the one used in the UE for these reportConfigNrs
    ...      - The IE 'ReportConfigNr.EventTriggerConfig.eventA2' for the MeasObject corresponding to serving cell frequency is filled using
    ...        'NRBTS/NRMEASPR/NRMEASPR_IAF-2.a2MeashoSsbRsrp'.
    ...        The IE 'ReportConfigNr.EventTriggerConfig.eventA2' for the MeasObject corresponding to serving cell frequency is filled using
    ...        'NRBTS/ NRMEASPR/NRMEASPR_IAF-2.a2MeasRedirectSsbRsrp'
    ...      - 'ReportConfigNr.EventTriggerConfig.eventA3' for the MeasObject corresponding to PCell is filled using
    ...        'NRBTS/ NRMEASPR/NRMEASPR_IAF-2. a3MeasSsbRsrp'
    ...      - 'ReportConfigNr.EventTriggerConfig.eventA5' for the MeasObject corresponding to PCell is filled using
    ...        'NRBTS/ NRMEASPR/NRMEASPR_IAF-2. a5MeasSsbRsrp'
    ...
    ...  Step 3:
    ...    Description:
    ...    • Trigger SCell-1 (n25) release request via A2 Measurement Report using "ue_measurement_send_nr" EGATE command
    ...    Expected:
    ...    • SCell-1 (n25) is released successfully
    ...    • UE is now served by PCell (n41) and SCell-2(n41) only
    ...    • Power class for this new CA combination of n41 and n41 (configured as pc2) is still pc3 and hence the measurement profile is retained
    ...      (info: old band combination remains in use and does not change after partial SCell release)
    ...    • Mapping MO 'NRMEASPR_MA_SA-2' is retained and 'NRBTS/NRMEASPR/NRMEASPR_IAF-2' is retained as the
    ...      Intra-Freq measurement profile for the UE
    ...
    ...  Step 4:
    ...    Description:
    ...    • Start DL user data traffic on UE#1
    ...    Expected:
    ...    • DL data transfer is realized for the UE via both cells (PCell and SCell-2)
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
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_26869
    ...
    ...  REQUIRED LOGS:  EGATE Console logs, PM Counters
    ...
    ...  CONTACTS:       Daniel Lammers
    ...  REFERENCES:     see "Documentation" part above
    ...  HISTORY:        Review Closed https://collab.ext.net.nokia.com/ui#review:id=919205
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    common_keywords.Run Test Scenario
    CB013392_scenario_verification.Verify CB013392_B_B8_TC01_IntragNB_A1_partial_SCell_release_3CC_DL_CA
    tracing.Check For Errors In Syslog


*** Keywords ***
Offline_Verification
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the "*** Keywords ***" line
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=  Set Variable   /home/ute/logs/CB013392_B_B8/20241104-065002-F/CB013392_B_B8/SBTS00_ENB_9999_241103_000003/20241104_065024
    Set Suite Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Suite Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    CB013392_scenario_verification.Verify CB013392_B_B8_TC01_IntragNB_A1_partial_SCell_release_3CC_DL_CA
