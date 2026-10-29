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
...                [07.02.2024] - Test Script finished


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
${relative_json_path}             ../../CB013392/CB013392-C/CB013392_C_B8.json
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***

CB013392_C_B8_TC01_NSA_IAF_activation_after_A1_with_MeNB_power_coordination
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    [Documentation]
    ...  DESCRIPTION:
    ...  This user scenario extends the user scenario “USCB008127-CD#B4” (5G_RAN_USR_RRM_21039) and describes how measurements are configured
    ...  at the UE using the selected measurement profile upon reception of A1 measurement report with consideration of MeNB power coordination.
    ...
    ...    USCB008127-CD#B4:
    ...      This user scenario describes the SgNB behaviour, when a UE on NSA 3x call (without SRB3), sends A1 measurement report and therefore
    ...      A2 measurement is configured using selected measurement profile for NSA.
    ...    Note: A2 measurement configuration is both for release and for triggering inter-frequency measurements.
    ...
    ...  PRECONDITION:
    ...  • Intra-freq (for example 5GC002177/1094/1095/2199) measurements are supported
    ...  • PSCell's freq band is nX
    ...
    ...  CB013392 related configuration:
    ...  • CB008127 feature is enabled for NSA and CB013392-C is activated to support MeNB power coordination in power class determination
    ...  • There are two measurement profile mappings defined
    ...    - NRMEASPR_MA_NSA-1 with ue-PowerClass2 criterion and NRMEASPR_IAF-1 profile pointed and higher priority defined in NRCELL
    ...    - NRMEASPR_MA_NSA-2 with ue-PowerClass3 criterion and NRMEASPR_IAF-2 profile pointed and lower priority defined in NRCELL
    ...  • Measurement profiles NRMEASPR_IAF-1 and NRMEASPR_IAF-2 are configured with different values
    ...  • A1 event is configured with rsrpCombined or rsrqCombined criterion
    ...  • supportedBandListNR contains power classes as follows:
    ...    - (band nX, power class 2)
    ...  Note: Power class 2 and 3 are just examples. Other power classes might be used on purpose of the test.
    ...
    ...  TRIGGER:
    ...  • A1 measurement report is received at SgNB
    ...
    ...  TEST STEPS:
    ...  Step 1:
    ...    Description:
    ...    • Attach UE to the MeNB and initiate EN-DC SgNB addition.
    ...    Expected:
    ...    • UE is attached to MeNB and SgNB.
    ...    • NRMEASPR_IAF-2 based on power class 3 is selected as the measurement profile (due to effective power limitation of p_max_nr=23dBm
    ...      from target MeNB eventhough the nX has pc2 as per UE capabilities)
    ...
    ...  Step 2:
    ...    Description:
    ...    • Trigger UE to send A2 meas report by fulfilling the value configured at RSRP criterion.  This trigger is done using
    ...      "ue_measurement_send_nr" EGATE command.
    ...    Expected:
    ...    • A2 meas event is triggered
    ...    • A2 is removed
    ...    • A1 meas event is activated
    ...
    ...  Step 3:
    ...    Description:
    ...    • Trigger UE to send A1 meas report by fulfilling the value configured at RSRP criterion.  This trigger is done using
    ...      "ue_measurement_send_nr" EGATE command.
    ...    Expected:
    ...    • gNB also checks rsrq that shall be fulfilled upon which A1 event is triggered
    ...    • A1 is removed
    ...    • NRMEASPR_IAF-2 measurement profile is retained
    ...
    ...  Step 4:
    ...    Description:
    ...    • Start DL/UL user data traffic on the UE
    ...    Expected:
    ...    • DL and UL data transfer is realized for the UE.
    ...
    ...  TESTING TOOLS:
    ...    - No specific tools needed
    ...
    ...  TEST ENVIRONMENT:
    ...      HARDWARE ID:
    ...             1x gNB: ASIL / ABIO
    ...             Airphone: ASIL / ABIO
    ...             WTS 5G Core Simulator
    ...             UTE Cloud Topology: CLOUD_5G_I_LO_AP_LO + VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_26757
    ...
    ...  REQUIRED LOGS:  EGATE Console logs, PM Counters
    ...
    ...  CONTACTS:       see "Documentation" part above
    ...  REFERENCES:     see "Documentation" part above
    ...  HISTORY:        Review Closed https://collab.ext.net.nokia.com/ui#review:id=919205
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    common_keywords.Run Test Scenario
    CB013392_scenario_verification.Verify CB013392_C_B8_TC01_NSA_IAF_activation_after_A1_with_MeNB_power_coordination
    tracing.Check For Errors In Syslog


*** Keywords ***
Offline_Verification
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the "*** Keywords ***" line
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable    /home/ute/DEVELOPMENT/robotws/CB013392_C_B8/SBTS00_ENB_9999_240418_000007/20240418_141155
    set suite variable  ${configuration_directory}    ${result_base_dir}/Configs
    set suite variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    # Verify CB013392_C_B8_TC01_NSA_IAF_activation_after_A1_with_MeNB_power_coordination
