*** Settings ***

Documentation
...
...     INTRODUCTION:  CB013392-A Measurement Profiles Power Class criterion for CA UEs
...                    The CB013392 introduces the possibility to assign different values
...                    of mobility measurement parameters and Power Class determination
...                    to different UE groups for UL CA
...
...     TEST SET NAME: CB013392_A_SA_Power_Class_determination_UL_CA
...
...     TESTING SCOPE: covers CB013392-A subfeature
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
...                [3] Review Session in Collaborator: https://collab.ext.net.nokia.com/ui#review:id=925245
...
...      HISTORY:
...                [06.12.2024] - Created Test Plan for UPD002
...                [20.12.2024] - Review Closed https://collab.ext.net.nokia.com/ui#review:id=925245
...                [11.06.2025] - Move to TMO test line
...
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
${relative_json_path}             ../../CB013392/CB013392-A/CB013392_A_B6.json
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***
CB013392_A_B6_TC01_measurement_profile_selection_due_to_effective_power_limitation_with_pMaxNROwnCell_without_CA
     [Documentation]
     ...  DESCRIPTION:
     ...    USCB013392-A#B6:
     ...    'Measurement profile reselection based on the effective power class without Carrier Aggregation when pMaxNROwnCell parameter is used'
     ...    This user scenario describes the behavior of gNB when Power Control returns the effective power limitation that is different from the
     ...    power class reported by the UE in UE capabilities. It may happen because the NRCELL is configured with pMaxNROwnCell parameter set to
     ...    the lower value than the power class reported in UE capabilities. This scenario is applicable in 5G SA mode, when no Carrier Aggregation
     ...    is used.
     ...
     ...  PRECONDITION:
     ...    - Carrier Aggregation is not active
     ...    - A2/A3/A5 intra-freq measurements are supported (for example 5GC000704, 5GC000708 are enabled)
     ...    - NRCELL.pMaxNROwnCell is set to lower value than power capability reported by UE,
     ...      e.g. if UE reports pc2 (26 dBm), then pMaxNROwnCell shall be set to pc3 (23 dBm)
     ...    - PCell's band is n41
     ...
     ...    CB013392 related configuration:
     ...        - CB008127 feature is enabled for SA and CB013392-A is activated (actMeasurementProfReselForCA = 'pcInSaUlCaSupported')
     ...        - There are two measurement profile mappings defined
     ...            - NRMEASPR_MA_SA-1 with ue-PowerClass2 criterion and NRMEASPR_IAF-1 profile pointed and higher priority defined in NRCELL
     ...            - NRMEASPR_MA_SA-2 with ue-PowerClass3 criterion and NRMEASPR_IAF-2 profile pointed and lower priority defined in NRCELL
     ...        - Measurement profiles NRMEASPR_IAF-1 and NRMEASPR_IAF-2 are configured with different values
     ...
     ...    UE Capabilities:
     ...      - UE capabilities as received from UE in the message “RRC:UE Capability Information” (IE
     ...        UE-NR-Capability->RF-Parameters) contains supportedBandListNR band n41 with power class 2
     ...
     ...    Trigger:
     ...      - Initial Context Setup (F1AP: UeContextSetupResponse)
     ...
     ...  TEST STEPS:
     ...    Step 1:
     ...       Description: Register UE to 5G n41 TDD cell.
     ...       Expected:    - Determined effective power class is pc3
     ...                    - NRMEASPR_IAF-2 is selected as the Intra frequency A3/A5 and A2 measurement profile
     ...                    Rational: The effective power class is lower than the power class reported by the UE power capabilities (pc2),
     ...                    because the power class supported by the cell (NRCELL.pMaxNROwnCell) is pc3.
     ...
     ...    Step 2:
     ...       Description: Start DL and UL user data traffic on UE
     ...       Expected:    Data transfer is realized for the UE via PCell.
     ...
     ...  POSTCONDITION:   5G UE is attached to PCell (in case of handover it is target PCell) and reportconfigNR for intra-freq A3/A5 and A2
     ...                   (mobility and redirection) measurements is set according to the NRMEASPR_IAF-2).
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
     ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_29742
     ...
     ...  REQUIRED LOGS:  EGATE Console logs, PM Counters
     ...
     ...  CONTACTS:       Daniel Lammers
     ...  REFERENCES:     see "Documentation" part at the top of the file
     ...  HISTORY:        Review Closed https://collab.ext.net.nokia.com/ui#review:id=925245
     common_keywords.Run Test Scenario
     CB013392_scenario_verification.Verify CB013392_A_B6_TC01_meas_profile_selection_due_to_effective_power_limitation_with_pMaxNROwnCell_without_CA
     tracing.Check For Errors In Syslog



*** Keywords ***
Offline_Verification
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the "*** Keywords ***" line
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=  Set Variable  /home/ute/logs/CB013392_A_B6/2025-02-18T11-15-42-P/CB013392_A_B6/SBTS00_ENB_9999_250217_000010/20250218_111626
    Set Suite Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Suite Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    CB013392_scenario_verification.Verify CB013392_A_B6_TC01_meas_profile_selection_due_to_effective_power_limitation_with_pMaxNROwnCell_without_CA
