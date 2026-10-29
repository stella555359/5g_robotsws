*** Settings ***

Documentation
...
...     INTRODUCTION:  CB013392-E KPI Testing
...                    The CB013392 introduces the possibility to assign different values
...                    of mobility measurement parameters and Power Class determination
...                    to different UE groups for UL CA.  CB013392-E subfeature covers the KPI testing part.
...
...     TEST SET NAME: CB013392_E_KPI
...
...     TESTING SCOPE: covers CB013392-E subfeature
...
...     CONTACTS:      MN RAN RD VRF ULM 6 <I_MN_RAN_RD_VRF_ULM_VT6@internal.nsn.com>
...                    Lavanya Schmid, Daniel Lammers, Nikolay Shkulepov
...
...     REFERENCES:
...                [1] CB013392 CFAM: https://gates.nsn-net.net/view/00025ee1#o=15003
...                [2] CB013392 FTS: https://nokia.sharepoint.com/:w:/r/sites/mn-ran-productization
...                                  /RAN%20Productization%20WoW/_layouts/15/Doc.aspx?
...                                  sourcedoc=%7BBAAAD487-C383-43D5-A997-72C86F89DD95%7D&file
...                                  =CB013392_Feature_Test_Strategy.docx&action=default&mobileredirect=true&wdsle=0
...                [3] Review Session in Collaborator: https://collab.ext.net.nokia.com/ui#review:id=913592
...
...      HISTORY:
...                [16.12.2024] - Initial version
...                [17.12.2024] - Created Test Plan
...                [13.08.2024] - Review Closed https://collab.ext.net.nokia.com/ui#review:id=917117
...                               Note: It is agreed in FOT, not to have a separate collab review for -E sub feature
...                [xx.xx.2024] - Test Script finished

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Resource   ./../../L2/resources/robot/test_setup.robot
Resource   ./../../L2/resources/common_keywords.robot
Resource   ./resources/CB013392_scenario_modifications.robot
Resource   ./resources/CB013392_scenario_verification.robot


Suite Setup     run keywords
...             Initialize Test Suite
Suite Teardown  run keywords
...             Capture Snapshot and restore config
Test Teardown   Stop Logs and Collect Traces



*** Variables ***
${pm_reporting_interval}          5min
${relative_json_path}             ../../CB013392/CB013392-E/CB013392_E_B1_KPI.json



*** Test Cases ***

CB013392_E_B1_TC01_IntragNB_A2_A3_HO
     #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    [Documentation]
    ...  DESCRIPTION: This user scenario describes the general flow of the feature in bad radio conditions to show
    ...               the KPI impact in cell edge situation
    ...  Actors:
    ...      - gNB
    ...      - UE1: high power class UE (higher than pc3 => pc2)
    ...      - UE2: low power class UE (pc3)
    ...      - UE3: low power class UE (pc3)
    ...
    ...  PRECONDITIONS:
    ...      1.    UEs are connected to the cell and configured according to the measurement profiles:
    ...            a.    Profile1 for high power UE1
    ...            b.    Profile2 for low power UE2, event trigger configuration shall be set to trigger mobility
    ...                  to another cell early => RFSP=10 and the respective meas profile is set to have early mobility
    ...            c.    Profile3 for low power UE3, event trigger configuration shall be set to keep UE longer in
    ...                  the cell => RFSP=20 and the respective meas profile is set to have longer mobility
    ...
    ...  TEST STEPS:
    ...    Step 1:
    ...       Description: Register UE#1 to 5G cell (n41).
    ...       Expected:    UE#1 is registed to n41 TDD PCell + n25 FDD SCell.
    ...                    UE#1 (pc2) gets assigned with meas profile IAF-1
    ...
    ...    Step 2:
    ...       Description: Set RFSP index as 10 (same as NRMEASPR_MA_SA-2) via AMF Initial Context Setup and
    ...                    register UE#2 to 5G cell (n41).
    ...       Expected:    UE#2 is registed to n41 TDD PCell + n25 FDD SCell.
    ...                    UE#2 (pc3 + RFSP=10) gets assigned with meas profile IAF-2
    ...
    ...    Step 3:
    ...       Description: Set RFSP index as 20 (same as NRMEASPR_MA_SA-3) via AMF Initial Context Setup and
    ...                    register UE#3 to 5G cell (n41).
    ...       Expected:    UE#3 is registed to n41 TDD PCell + n25 FDD SCell.
    ...                    UE#3 (pc3 + RFSP=20) gets assigned with meas profile IAF-3
    ...
    ...    Step 4:
    ...       Description: Configure BLER testmode and associate with the 3 UEs in order to get the cell edge condition.
    ...       Expected:    All 3 UEs are configured with BLER test mode.
    ...
    ...    Step 5:
    ...       Description: Trigger handover using A2 and A3 measurement events for UE#2 only.
    ...       Expected:    UE#2 is now handed over to n71 FDD.
    ...                    UE#1 and UE#3 stay with TDD PCell(n41) + FDD SCell(n25)
    ...
    ...    Step 6:
    ...       Description: Start DL/UL user data traffic on UE#1, UE#2 and UE#3
    ...       Expected:    DL and UL data transfer is realized for all 3 UEs
    ...
    ...  TESTING TOOLS:
    ...    - No specific tools needed
    ...
    ...  TEST ENVIRONMENT:
    ...      HARDWARE ID:
    ...             1x gNB: ASIL / ABIO
    ...             Airphone: ASIL / ABIO
    ...             WTS 5G Core Simulator
    ...             UTE Cloud Topology:  CLOUD_5G_I_LO_AP_LO + VARIANT_PRIVATE_4S_2CC_FDD_TDD_CA
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_30396
    ...
    ...  REQUIRED LOGS:  EGATE Console logs, PM Counters
    ...
    ...  CONTACTS:       Lavanya Schmid
    ...  REFERENCES:     see "Documentation" part above
    ...  HISTORY:        Review Closed https://collab.ext.net.nokia.com/ui#review:id=917117
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Run Test Scenario
    Verify CB013392_E_B1_TC01_IntragNB_A2_A3_HO


*** Keywords ***
Offline_Verification
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the "*** Keywords ***" line
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration from JSON File
    ${result_base_dir}=    set variable    /home/ute/DEVELOPMENT/robotws/CB013392_E_B1/SBTS00_ENB_9999_240505_000003/20240506_151505
    set suite variable  ${configuration_directory}    ${result_base_dir}/Configs
    set suite variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    # Verify CB013392_E_B1_TC01_IntragNB_A2_A3_HO
