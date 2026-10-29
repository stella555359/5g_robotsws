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
...                    Lavanya Schmid, Daniel Lammers, Nikolay Shkulepov, Hardy Kress
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
...                [07.11.2025] - Migration to TMO


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
${relative_json_path}             ../../CB013392/CB013392-C/CB013392_C_B7.json
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***

CB013392_C_B7_TC01_NSA_IAF_activation_during_InterMeNB_HO_initiated_IntraSgNB_addition_by_target_MeNB_with_MeNB_power_coordination
    [Documentation]
    ...  DESCRIPTION:
    ...  This user scenario extends the user scenario “USCB008127-CD#B9” (5G_RAN_USR_RRM_22347) and describes how measurements are configured
    ...  at the UE using the selected measurement profile during MeNB-initiated Inter-MeNB Intra-SgNB Intra-DU PSCell change with consideration of
    ...  MeNB power coordination.
    ...  Note: A2 measurement configuration is done for both A2 for mobility and A2 for SgNB release.
    ...
    ...    USCB008127-CD#B9:
    ...      This user scenario describes how UE is configured with required intra-frequency measurements (A2/A3/A5) using selected measurement
    ...      profile during inter-MeNB handover with PSCell change(same SgNB).
    ...  Note: A2 measurement configuration is both for release and for triggering inter-frequency measurements.
    ...
    ...  PRECONDITION:
    ...  • Intra-freq (for example 5GC002177/1094/1095) measurements are supported
    ...  • Inter-MeNB mobility is supported (5GC000574)
    ...  • Target PSCell's freq band is nX
    ...
    ...  CB013392 related configuration:
    ...  • CB008127 feature is enabled for NSA and CB013392-C is activated to support MeNB power coordination in power class determination
    ...  • There are two measurement profile mappings defined
    ...    - NRMEASPR_MA_NSA-1 with ue-PowerClass2 criterion and NRMEASPR_IAF-1 profile pointed and higher priority defined in NRCELL
    ...    - NRMEASPR_MA_NSA-2 with ue-PowerClass3 criterion and NRMEASPR_IAF-2 profile pointed and lower priority defined in NRCELL
    ...  • Measurement profiles NRMEASPR_IAF-1 and NRMEASPR_IAF-2 are configured with different values
    ...  • SgNB addition is supported for Inter-MeNB handover with change in SCG configuration.
    ...  • supportedBandListNR contains power classes as follows:
    ...  • (band nX, power class 2)
    ...  Note: Power class 2 and 3 are just examples. Other power classes might be used on purpose of the test.
    ...
    ...  5GC000574 related configuration (5G_RAN_USR_RRM_1064):
    ...  • One carrier frequency with at least one 5G cell
    ...  • Two 4G MeNB with at least one cell in each with the coverage overlapping with 5G cell.
    ...  • Available X2-C link between LTE eNBs (Source & Target MeNB) and gNB (SgNB).
    ...  • 5G cell in "OnAir" state.
    ...  • UE context (with NSA 3x bearer) is already added to 5G NB with UL/DL data transfer ongoing (Refer 5GC000570 feature for more details)
    ...  • Feature control parameter for 5GC000574 shall be set as enabled
    ...
    ...  TRIGGER:
    ...  • SgNB receives SgNBAdditionRequest from the Target MeNB
    ...  Note: Decision to perform the mobility is taken on the LTE side.
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
    ...    • Prepare inter MeNB handover initiated PSCell change using ue_enb_endc_param (to set the target cell as it is inter-MeNB) and using
    ...      egate command ue_ho
    ...    Expected:
    ...    • MeNB handover is done
    ...    • SgNB is added to the target (handed-over) MeNB
    ...    • NRMEASPR_IAF-2 based on power class 3 is selected as the measurement profile (due to effective power limitation of p_max_nr=23dBm
    ...      from target MeNB eventhough the nX has pc2 as per UE capabilities)
    ...
    ...  Step 3:
    ...    Description:
    ...    • Start DL/UL user data traffic on the UE
    ...    Expected:
    ...    • DL and UL data transfer is realized for the UE.
    ...
    ...  POSTCONDITION:  Intra-Freq A2 and A3/A5 measurements are activated at the UE and Inter-MeNB handover is performed.
    ...       A2 measurement configuration is done for both A2 for mobility and A2 for SgNB release.

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
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_26756
    ...
    ...  REQUIRED LOGS:  EGATE Console logs, PM Counters
    ...
    ...  CONTACTS:       I_MN_RAN_RD_VRF_ULM_VT6@internal.nsn.com
    ...
    ...  REFERENCES:     see "Documentation" part above
    ...  HISTORY:        Review Closed https://collab.ext.net.nokia.com/ui#review:id=919205
    common_keywords.Run Test Scenario
    Verify CB013392_C_B7_TC01_NSA_IAF_activation_during_InterMeNB_HO_initiated_IntraSgNB_addition_by_target_MeNB_with_MeNB_power_coordination
    tracing.Check For Errors In Syslog


*** Keywords ***
Offline_Verification
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the "*** Keywords ***" line
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable
    ...    /home/ute/logs/CB013392_C_B7/2025-11-06T14-11-59-F/CB013392_C_B7/SBTS00_ENB_9999_251105_000005/20251106_141233
    set suite variable  ${configuration_directory}    ${result_base_dir}/Configs
    set suite variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    Verify CB013392_C_B7_TC01_NSA_IAF_activation_during_InterMeNB_HO_initiated_IntraSgNB_addition_by_target_MeNB_with_MeNB_power_coordination
