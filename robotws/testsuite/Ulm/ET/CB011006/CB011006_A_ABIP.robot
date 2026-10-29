*** Settings ***

Documentation
...
...     INTRODUCTION:  CB011006 "50 MHz FDD cell bandwidth"
...                    The CB011006 feature covers the following RUs from MADE2 family: AHEGG, AHEGHA.
...                    RUs from MADE2 family don't require a carrier split.
...
...     TEST SET NAME: CB011006_50MHz_FDD_Cell_Bandwidth
...
...     TESTING SCOPE: covers CB011006-A and CB011006-B subfeatures
...
...     CONTACTS:      Ulm SQD 68 <I_MN_5GSC_SW_ENG_ULM_SQD_68@internal.nsn.com>
...
...     REFERENCES:
...                [1] CB011006 CFAM: https://gates.nsn-net.net/view/000275a1#o=0
...                [2] CB011006 FTS: https://nokia.sharepoint.com/:w:/s/mn-ran-productization/RAN%20Productization%20WoW/
...                                  ESl1oF-gWj1HuPHQCpkZV6ABIrBIFPEcOh3GjtkWfQCg9Q?e=iOrxPI&wdOrigin=TEAMS-ELECTRON.p2p.
...                                  bim&wdExp=TEAMS-CONTROL&wdhostclicktime=1687878372863&web=1
...                [3] Review Session in Collaborator: https://collab.ext.net.nokia.com/ui#review:id=895245
...
...      HISTORY:
...                [05.10.2023] - Initial version

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    ../resources/SQD68/pmc_analysis.py    WITH NAME  validation

Resource   ../L2/resources/robot/test_setup.robot
Resource   ../L2/resources/common_keywords.robot
Resource   ../L2/resources/robot/tracing.robot
Resource   ../CB011006/resources/CB011006_scenario_modifications.robot
Resource   ../CB011006/resources/CB011006_scenario_validations.robot


Suite Setup     Run Keywords
...             test_setup.Initialize Test Suite                        AND
...             validation.Prepare For PM Counter Testing
Suite Teardown  Run Keywords
...             common_keywords.Capture Snapshot And Restore Config     AND
...             validation.Finalise PM Counter Testing
Test Teardown   common_keywords.Stop Logs And Collect Traces



*** Variables ***
${num_slots_per_frame}            ${20}
${pm_reporting_interval}          5min
${relative_json_path}             ../../CB011006/CB011006_A.json
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***

CB011006_A_MUE_Calls
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    [Documentation]
    ...  DESCRIPTION: This an aggregation of CB011006_A_MUE_NSA_Call_on_ABIO and CB011006_A_MUE_SA_Call_on_ABIO test cases
    ...  PRECONDITION: see aggregated TCs
    ...  POSTCONDITION: see aggregated TCs
    ...  TESTING TOOLS: see aggregated TCs
    ...  TEST ENVIRONMENT: see aggregated TCs
    ...  REQUIRED LOGS: see aggregated TCs
    ...  CONTACTS: see aggregated TCs
    ...  REFERENCES: see aggregated TCs
    ...  HISTORY: [06.10.2023] - Reviewed, https://collab.ext.net.nokia.com/ui#review:id=895245
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    common_keywords.Run Test Scenario
    CB011006_scenario_validations.Verify CB011006_A_MUE_Calls
    tracing.Check For Errors In Syslog


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
*** Keywords ***
Offline_Verification
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the "*** Keywords ***" line
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable    /home/ute/test_repository/CB011006_A_ABIP/SBTS00_ENB_9999_240128_000007/20240129_084002
    Set Suite Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Suite Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    CB011006_scenario_validations.Verify CB011006_A_MUE_NSA_Call_on_ABIO
    CB011006_scenario_validations.Verify CB011006_A_MUE_SA_Call_on_ABIO



# Below TC's are not any more executed and moved to Keyword section to reduce git pipeline time, bring them back by moving them to Test Cases section
CB011006_A_MUE_SA_Call
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    [Documentation]
    ...  DESCRIPTION: This Test Case verifies the multiple UEs attach/data transfer with the setup of FDD cell
    ...               with 50MHz bandwidth followed by system information transmission
    ...  PRECONDITION:
    ...    - Multiple UEs support 50 MHz
    ...    - gNB RF unit supports CPRI interface.
    ...    - EQM.APEQM.RMOD.legacyWideCarrierMode = false
    ...    - gNB supports classical SA deployment CPRI interface on ABIO baseband
    ...    - gNB is configured with at least one FDD cell in band n7 with 50MHz bandwidth:
    ...        - NRCELL.NRCELL_FDD.chBwDl = '50MHz'
    ...        - NRCELL.NRCELL_FDD.chBwUl = '50MHz'
    ...    - Long PUCCH: NRCELL.pucchModeSelect = longPucch
    ...
    ...  TEST STEPS:
    ...    Step 1:
    ...       Description: register 10 SA UEs
    ...       Expected: all the UEs are successfully registered
    ...    Step 2:
    ...       Description: start DL/UL user data traffic on all the UEs
    ...       Expected: UEs reach high throughput both DL and UL
    ...
    ...  POSTCONDITION:
    ...    - Data transfer is possible in DL and UL direction with expected throughput.
    ...
    ...  TESTING TOOLS:
    ...    - TTI Traces Decoder (tti-dec)
    ...
    ...  TEST ENVIRONMENT:
    ...      HARDWARE ID:
    ...             1x gNB: ASIM / ABIP
    ...             Simulated RRH: AHEGG, AHEGHA
    ...             Airphone: ASIL / ABIO
    ...             WTS 5G Core Simulator
    ...             UTE Cloud Topology: CLOUD_5G_I_MP_AP_LO + VARIANT_SANSA_FS_CPRI_CMWV_FDD
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_22186, CB_FIM_41640
    ...
    ...  REQUIRED LOGS:  TTI Traces, PM Counters
    ...
    ...  CONTACTS:      Nikolay Shkulepov (Nokia) <nikolay.shkulepov@nokia.com>
    ...
    ...  REFERENCES:    CFAM for CB011006: https://gates.nsn-net.net/view/000275a1#o=0
    ...                 5G User Scenario of CB011006-A#B3: https://gates.nsn-net.net/view/000275a1#o=460&hlt
    ...
    ...  HISTORY:       [07.09.2023] - Created TC
    ...                 [06.10.2023] - Reviewed, https://collab.ext.net.nokia.com/ui#review:id=895245
    ...                 [06.10.2023] - Test finished at commit 4c32bb4e8159f5967b0b7a95d7fb604b95bf9815
    ...                 [06.10.2023] - Review closed
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    [Tags]  CRT
    Run Test Scenario
    Verify CB011006_A_MUE_SA_Call_on_ABIO


CB011006_A_MUE_NSA_Call
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    [Documentation]
    ...  DESCRIPTION: This Test Case verifies multiple UEs attach/data transfer in NSA mode with the setup of FDD cell
    ...               with 50MHz bandwidth followed by system information transmission.
    ...  PRECONDITION:
    ...    - Multiple UEs support 50 MHz
    ...    - gNB RF unit supports CPRI interface.
    ...    - EQM.APEQM.RMOD.legacyWideCarrierMode = false
    ...    - gNB supports NSA deployment CPRI interface on ABIO baseband
    ...    - Available X2-C link between LTE eNB (MeNB) and gNB (SgNB)
    ...    - gNB is configured with at least one FDD cell in band n7 with 50MHz bandwidth:
    ...        - NRCELL.NRCELL_FDD.chBwDl = '50MHz'
    ...        - NRCELL.NRCELL_FDD.chBwUl = '50MHz'
    ...    - Long PUCCH: NRCELL.pucchModeSelect = longPucch
    ...
    ...  TEST STEPS:
    ...    Step 1:
    ...       Description: attach 10 NSA UEs
    ...       Expected: all the UEs are successfully attached
    ...    Step 2:
    ...       Description: start DL/UL user data traffic on all the UEs
    ...       Expected: high throughput both DL and UL can be reached
    ...
    ...  POSTCONDITION:
    ...    - Data transfer is possible in DL and UL direction with expected throughput.
    ...
    ...  TESTING TOOLS:
    ...    - TTI Traces Decoder (tti-dec)
    ...
    ...  TEST ENVIRONMENT:
    ...      HARDWARE ID:
    ...             1x gNB: ASIM / ABIP
    ...             Simulated RRH: AHEGG, AHEGHA
    ...             Airphone: ASIL / ABIO
    ...             WTS 5G Core Simulator
    ...             UTE Cloud Topology: CLOUD_5G_I_MP_AP_LO + VARIANT_SANSA_FS_CPRI_CMWV_FDD
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_22423, CB_FIM_41641
    ...
    ...  REQUIRED LOGS:  TTI Traces, PM Counters
    ...
    ...  CONTACTS:      Nikolay Shkulepov (Nokia) <nikolay.shkulepov@nokia.com>
    ...
    ...  REFERENCES:    CFAM for CB011006: https://gates.nsn-net.net/view/000275a1#o=0
    ...                 5G User Scenario of CB011006-A#B4: https://gates.nsn-net.net/view/000275a1#o=461&hlt
    ...
    ...  HISTORY:       [07.09.2023] - Created TC
    ...                 [06.10.2023] - Reviewed, https://collab.ext.net.nokia.com/ui#review:id=895245
    ...                 [06.10.2023] - Test finished at commit 4c32bb4e8159f5967b0b7a95d7fb604b95bf9815
    ...                 [06.10.2023] - Review closed
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    [Tags]  CRT
    Run Test Scenario
    Verify CB011006_A_MUE_NSA_Call_on_ABIO