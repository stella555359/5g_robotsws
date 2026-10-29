*** Settings ***

Documentation
...
...     INTRODUCTION:  CB013392-C NSA MeNB powerCoordination-FR1 consideration in Power Class determination
...                    The CB013392-C introduces the possibility to assign different values
...                    of measurement profiles and power class determinaiton by considering NSA MeNB power
...                    coordination
...
...     TEST SET NAME: CB013392_C_NSA_MeNB_powerCoordination_FR1_Power_Class_determination
...
...     TESTING SCOPE: covers CB013392-C subfeature
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
...                [17.01.2025] - Test Script finished
...                [17.10.2025] - Migration to TMO


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
${relative_json_path}             ../../CB013392/CB013392-C/CB013392_C_B10.json
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***

CB013392_C_B10_TC01_NSA_A4_IEF_activation_upon_a4RetryTimer_with_MeNB_power_coordination
    [Documentation]
    ...  DESCRIPTION:
    ...  This user scenario extends the user scenario “USCB008127-CD#B6” (5G_RAN_USR_RRM_21025) and describes how A4 Inter-Freq measurement for
    ...  higher mobility to higher priority NR frequency is configured at the UE using the measurement profile selected with consideration of MeNB
    ...  power coordination upon a4RetryTimer expiry.
    ...
    ...    USCB008127-CD#B6:
    ...    This user scenario describes how Inter-Freq A4 measurements for mobility to higher priority NR frequency are activated at the UE on an
    ...    NSA 3X call (without SRB3) using the selected measurement profile when 'a4RetryTimer' expires.
    ...
    ...  PRECONDITION:
    ...  • CB008127 feature is enabled for NSA and CB013392-C is activated to support MeNB power coordination in power class determination
    ...  • There are two measurement profile mappings defined
    ...    - NRMEASPR_MA_NSA-1 with ue-PowerClass2 criterion and NRMEASPR_IEF-1 profile pointed and higher priority defined in NRCELL for NRHOIF-X
    ...    - NRMEASPR_MA_NSA-2 with ue-PowerClass3 criterion and NRMEASPR_IEF-2 profile pointed and lower priority defined in NRCELL for NRHOIF-X
    ...  • Measurement profiles NRMEASPR_IEF-1 and NRMEASPR_IEF-2 are configured with different values
    ...  • supportedBandListNR contains power classes as follows:
    ...    - (band n41, power class 2)
    ...    - (band n71, power class 2)
    ...  • PSCell's freq band is n41
    ...  • A4 inter-freq measurement for mobility to higher priority NR frequency is enabled with CB007517 (actHigherPrioFreqHo)
    ...  • A4 measurement management is configured in PSCell (a4PeriodicMeasControlNSA)
    ...
    ...  Adapted CB008127 related configuration:
    ...  • CB008127 feature is enabled by setting 'NRBTS.actMeasurementProfile' to 'NSA' or 'SA+NSA'
    ...  • The mapping MO, 'NRMEASPR_MA_NSA-1', is configured as with pcCapabilityList is set to (n71, ue-PowerClass2')
    ...  • The mapping MO, 'NRMEASPR_MA_NSA-2', is configured as with pcCapabilityList is set to (n71, ue-PowerClass3')
    ...  • Measurement profile is configured for Inter-Freq measurements.
    ...    - 'NRBTS/NRMEAS_PROFILE' is configured with two instances of 'NRMEASPR_IEF':
    ...      - NRBTS/ NRMEAS_PROFILE/NRMEASPR_IEF-1
    ...        - a4MeasHigherPrioFreqSsbRsrp is configured with values different than at NRHOIF level.
    ...      - NRBTS/ NRMEAS_PROFILE/NRMEASPR_IEF-2
    ...        - a4MeasHigherPrioFreqSsbRsrp is configured with values different than at NRHOIF level.
    ...
    ...  TRIGGER:
    ...  • A4RetryTimer expiration in NSA
    ...
    ...  TEST STEPS:
    ...  Step 1:
    ...    Description:
    ...    • Attach UE to the MeNB and initiate EN-DC SgNB addition.
    ...    Expected:
    ...    • UE is attached to MeNB and SgNB
    ...    • SgNB starts a4RetryTimer
    ...
    ...  Step 2:
    ...    Description:
    ...    • A4RetryTimer expires
    ...    Expected:
    ...    • NRMEASPR_IEF-1 is selected as the measurement profile (due to target frequency with pc2) for Inter-Freq A4 measurements
    ...      Rational: MeNB power coordination doesn't matter. For IEF is always the UE capability-based power class for the target frequency used
    ...
    ...  Step 3:
    ...    Description:
    ...    • Start DL/UL user data traffic on the UE
    ...    Expected:
    ...    • DL and UL data transfer is realized for the UE.
    ...
    ...  POSTCONDITION:  Inter-Freq A4 measurements are activated at the UE
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
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_26759
    ...
    ...  REQUIRED LOGS:  EGATE Console logs, PM Counters
    ...
    ...  CONTACTS:       I_MN_RAN_RD_VRF_ULM_VT6@internal.nsn.com
    ...
    ...  REFERENCES:     see "Documentation" part above
    ...  HISTORY:        Review Closed https://collab.ext.net.nokia.com/ui#review:id=919205
    common_keywords.Run Test Scenario
    Verify CB013392_C_B10_TC01_NSA_A4_IEF_activation_upon_a4RetryTimer_with_MeNB_power_coordination
    tracing.Check For Errors In Syslog


CB013392_C_B10_TC02_ALT3_NSA_A4_IEF_activation_upon_A1_mobility_to_preferred_NR_layer_meas_report_with_MeNB_power_coordination
    [Documentation]
    ...  DESCRIPTION:
    ...  If A1 measurement for mobility to preferred NR layer is enabled and respective measurement report is received, then
    ...  A4 inter-freq measurement for mobility to higher priority NR frequency is configured as a result, based on measurement profiles settings.
    ...
    ...  PRECONDITION:
    ...  Additional precondition to Main scenario: A1 for mobility to preferred NR layer is configured with CB009205 feature
    ...
    ...  CB009205 related configuration:
    ...  • 5GUE/Airphone is in RRC Connected state at MeNB
    ...  • Inter-frequency mobility is enabled (NRBTS.actInterFreqIntraGnbMobilityNsa is set to 'true' or
    ...    NRBTS.actInterFreqInterGnbMobilityNsa is set to 'true')
    ...  • 5GUE supports inter-freq measurement and eventA measurement
    ...  • CB0009205 feature is activated in the gNB for NSA (NRBTS. actA1HoPrefNrLayer = 2 or 3 (corresponding respectively to NSA, SA+NSA))
    ...  • RSRP parameters for A1 measurement for steering UE to preferred NR layer are configured in
    ...    NRBTS/NRCELL (a1MeasHOPrefNrLayerEnabled=rsrp, a1MeashoPrefNrLayerSsbRsrp. a1HysteresisSsbRsrp,
    ...    a1MeashoPrefNrLayerSsbRsrp.a1ThresholdhoSsbRsrp, a1MeashoPrefNrLayerSsbRsrp. a1TimeToTriggerhoSsbRsrp)
    ...  • NRCELL.a4MeasHigherPrioFreqMaxReact is configured
    ...
    ...  TRIGGER:
    ...  • A1 for mobility to preferred NR layer measurement report is received at SgNB via X2AP: RRC Transfer
    ...
    ...  TEST STEPS:
    ...  Step 1:
    ...    Description:
    ...    • Attach UE to the MeNB and initiate EN-DC SgNB addition.
    ...    Expected:
    ...    • UE is attached to MeNB and SgNB
    ...
    ...  Step 2:
    ...    Description:
    ...    • Trigger UE to send A1 meas report. This trigger is done using "ue_measurement_send_nr" EGATE command.
    ...    Expected:
    ...    • NRMEASPR_IEF-1 is selected as the measurement profile (due to target frequency with pc2) for Inter-Freq A4 measurements
    ...      Rational: MeNB power coordination doesn't matter. For IEF is always the UE capability-based power class for the target frequency used
    ...
    ...  Step 3:
    ...    Description:
    ...    • Start DL/UL user data traffic on the UE
    ...    Expected:
    ...    • DL and UL data transfer is realized for the UE.
    ...
    ...  POSTCONDITION:  Inter-Freq A4 measurements are activated at the UE
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
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_27528
    ...
    ...  REQUIRED LOGS:  EGATE Console logs, PM Counters
    ...
    ...  CONTACTS:       I_MN_RAN_RD_VRF_ULM_VT6@internal.nsn.com
    ...
    ...  REFERENCES:     see "Documentation" part above
    ...  HISTORY:        Review Closed https://collab.ext.net.nokia.com/ui#review:id=919205
    common_keywords.Run Test Scenario
    Verify CB013392_C_B10_TC02_ALT3_NSA_A4_IEF_activation_upon_A1_mobility_to_preferred_NR_layer_meas_report_with_MeNB_power_coordination
    tracing.Check For Errors In Syslog


*** Keywords ***
Offline_Verification
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the "*** Keywords ***" line
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable
    ...    /home/ute/logs/CB013392_C_B10/2025-10-16T10-44-46-F/CB013392_C_B10/SBTS00_ENB_9999_251015_000009/20251016_104521
    set suite variable  ${configuration_directory}    ${result_base_dir}/Configs
    set suite variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    Verify CB013392_C_B10_TC01_NSA_A4_IEF_activation_upon_a4RetryTimer_with_MeNB_power_coordination
