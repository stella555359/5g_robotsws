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
...                [14.10.2024] - Test Script finished
...                [08.10.2024] - Migration to TMO


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
${pm_reporting_interval}          15min
${relative_json_path}             ../../CB013392/CB013392-B/CB013392_B_B1.json
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***

CB013392_B_B1_TC01_IntragNB_blind_SCell_addition_DL_CA_incoming_HO
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    [Documentation]
    ...  DESCRIPTION:
    ...    This user scenario describes the successful UE configuration done during Carrier Aggregation setup. This user scenario modifies
    ...    the behavior described in USCB013392-A#B1 and introduces consideration of effective power limitation in DL only CA power class
    ...    calculation and measurement profile reselection during DL only Carrier Aggregation setup.
    ...
    ...    USCB013392-A#B1:
    ...      This user scenario describes the successful UE configuration of the UL Carrier Aggregation for single UE with 2 aggregated carriers.
    ...      This user scenario modifies the behavior described in USCB008127-HS#B1 (5G_RAN_USR_RRM_23751) and introduces usage of power class
    ...      criterion in UL CA.
    ...
    ...  PRECONDITION:
    ...  • CA relation is configured between PCell (NRCELL-4, band n41) and SCell (NRCELL-8, band n25)
    ...    - NRCELL-4/NRREL-1 points to NRCELL-8
    ...    - NRCELL-4/NRREL-1.sCellAdditionMethod is set to 'blind'
    ...  • Deactivate measurement based SCell addition
    ...    - NRBTS/actMeasBasedSCellAdditionSA is set to 'disabled'
    ...  • Carrier Aggregation is supported (for example 5GC001390 is enabled)
    ...  • A2/A3/A5 intra-freq measurements are supported (for example 5GC000704, 5GC000708 are enabled)
    ...  • In case the scenario is tested after incoming handover, then the respective handover feature must be enabled (5GC000704/706 for Xn HO,
    ...    CB008806 for NG HO, CB008731 for Inter-RAT HO)
    ...
    ...  CB013392 related configuration:
    ...  • CB008127 feature is enabled for SA and CB013392-B is activated to support power class criterion determination based on a
    ...    featureSet in DL CA ('NRBTS.actMeasurementProfReselForCA' = pcInSaUlAndDlCaSupported)
    ...  • There are two measurement profile mappings defined
    ...    - NRMEASPR_MA_SA-1 with ue-PowerClass2 criterion and NRMEASPR_IAF-1 profile pointed and higher priority defined in NRCELL
    ...    - NRMEASPR_MA_SA-2 with ue-PowerClass3 criterion and NRMEASPR_IAF-2 profile pointed and lower priority defined in NRCELL
    ...  • Measurement profiles NRMEASPR_IAF-1 and NRMEASPR_IAF-2 are configured with different values
    ...
    ...  5GC001390 related configuration (5G_RAN_USR_RRM_3357):
    ...  • Inter-band FDD – FR1-TDD CA feature 5GC001390 is activated: carrierAggregationSupportList enumeration parameter is set
    ...    to 2 (ca_Fdd_Fr1Tdd)
    ...
    ...  5GC000704 IFHO-B#B8 (5G_RAN_USR_RRM_1413):
    ...  • gNB up and running
    ...  • 5GUE/Airphone up and running
    ...  • Initial context is setup successfully and UE has been configured for measurement event A5.
    ...  • Criteria for the configured measurement event A5 is met.
    ...
    ...  UE Capabilities:
    ...  • UE capabilities as received from UE in the message “RRC:UE Capability Information” (IE “UE-NR-Capability->RF-Parameters) has following:
    ...    - supportedBandListNR contains two bands (n25 and n41) having power classes as follows:
    ...  • (band n25, power class 3)
    ...  • (band n41, power class 2)
    ...  • supportedBandCombinationList contains {band n25, band n41}
    ...    - (bandCombination n25&n41, power class 3)
    ...
    ...  Note: See 3GPP 38.101 Table 6.2.1-1: UE Power Class for the possible UE capabilities according to the band.
    ...  Note 2: Power class 2 and 3 are just examples. Other power classes might be used on purpose of the test. The only goal is to capture
    ...          that power class for a single band and power class for the band combination are different.
    ...
    ...  TRIGGER:
    ...  • Incoming handover and blind SCell addition procedure starts
    ...
    ...  TEST STEPS:
    ...  Step 1:
    ...    Description:
    ...      • Register UE to 5G n25 FDD cell (NRCELL-7)
    ...    Expected:
    ...      • UE is registered
    ...
    ...  Step 2:
    ...    Description:
    ...      • Trigger handover to NRCELL-4 using A2 and A3 measurement events
    ...    Expected:
    ...      • UE is now handed over to n41 TDD (PCell)
    ...      • Scell (n25 FDD, NRCELL-8) is added. UE supports power class 3 for the band combination n41 and n25
    ...      • Measurement profile NRMEASPR_IAF-2 (pc3) is selected as the Intra frequency A3/A5 and A2 measurement profile for this UE.
    ...      • RRC reconfiguration message is verified if the measurement configuration for the events are set as per the measurement profile
    ...      • reportConfigNr in “measConfig. reportConfigToAddModList" for intra-Freq A3/A5 and A2 (mobility and redirection) in RRCReconfiguration
    ...        message are set according to the selected measurement profile (NRMEASPR_IAF-2) as follows.
    ...        - The IE ‘ReportConfigNr.EventTriggerConfig.eventA2’ for the MeasObject corresponding to serving cell frequency is filled using
    ...          ‘NRBTS/NRMEASPR/NRMEASPR_IAF-2.a2MeashoSsbRsrp’. The IE ‘ReportConfigNr.EventTriggerConfig.eventA2' for the MeasObject
    ...          corresponding to serving cell frequency is filled using ‘NRBTS/ NRMEASPR/NRMEASPR_IAF-2.a2MeasRedirectSsbRsrp’
    ...        - ‘ReportConfigNr.EventTriggerConfig.eventA3’ for the MeasObject corresponding to PCell is filled using ‘NRBTS/
    ...          NRMEASPR/NRMEASPR_IAF-2.a3MeasSsbRsrp’
    ...        - ‘ReportConfigNr.EventTriggerConfig.eventA5’ for the MeasObject corresponding to PCell is filled using ‘NRBTS/
    ...          NRMEASPR/NRMEASPR_IAF-2.a5MeasSsbRsrp’
    ...
    ...  Step 3:
    ...    Description:
    ...      • Start DL user data traffic on UE#1
    ...    Expected:
    ...      • DL data transfer is realized for the UE via both cells.
    ...
    ...  TESTING TOOLS:
    ...    • No specific tools needed
    ...
    ...  TEST ENVIRONMENT:
    ...    • HARDWARE ID:
    ...      - 1x gNB: ASIL / ABIO
    ...      - Airphone: ASIL / ABIO
    ...      - WTS 5G Core Simulator
    ...      - UTE Cloud Topology:  CLOUD_5G_I_LOO_AP_LOOO + VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
    ...
    ...  *REQUIREMENTS COVERAGE:
    ...    • REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_26746
    ...
    ...  REQUIRED LOGS:  EGATE Console logs, PM Counters
    ...
    ...  CONTACTS:       Nikolay Shkulepov
    ...  REFERENCES:     see "Documentation" part above
    ...  HISTORY:        Review Closed https://collab.ext.net.nokia.com/ui#review:id=919205

    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    common_keywords.Run Test Scenario
    CB013392_scenario_verification.Verify CB013392_B_B1_TC01_IntragNB_blind_SCell_addition_DL_CA_incoming_HO
    tracing.Check For Errors In Syslog



*** Keywords ***

Offline_Verification
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the "*** Keywords ***" line
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable    /home/ute/DEVELOPMENT/robotws/CB013392_B_B1/SBTS00_ENB_9999_240418_000007/20240418_141155
    Set Suite Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Suite Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    CB013392_scenario_verification.Verify CB013392_B_B1_TC01_IntragNB_blind_SCell_addition_DL_CA_incoming_HO
