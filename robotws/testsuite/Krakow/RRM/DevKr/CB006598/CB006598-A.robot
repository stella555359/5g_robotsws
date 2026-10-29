*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         This feature introduces the support of 3GPP Rel-16 SIB2 Parameters for UE measurement relaxation for UE Power Saving.
...         Operator can enable the functionality and set the related parameters accordingly.
...         gNB will broadcast such parameters in SIB2, so that UEs which support this functionality may improve battery duration when in idle mode.
...         The feature can be activated/deactivated by Operator configurable flag.
...
...      == TEST SET NAME ==
...         CB006598 - UE Power Saving: RRM Measurements relaxation in idle
...
...      == TESTING SPLIT ==
...         CB006598-A - UE Power Saving: RRM Measurements relaxation in idle
...
...      == CONTACTS ==
...       - Maciej Madej <maciej.madej@nokia.com>
...       - Konrad Bem <konrad.bem@nokia.com>
...
...      == MAINTAINER ==
...       - Maciej Madej <maciej.madej@nokia.com>
...
...      == REFERENCES ==
...         CB006598 CFAM
...
...      == HISTORY ==
...         [12.01.2023] - TC Create
...         [08.02.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=877558)


Resource    ./resources/CB006598-common_keywords.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run setup

*** Variables ***
${common_timeout}=        100
${LUA_CFG}=               ${CURDIR}/config/egate_2c_TDD_SANSA.lua

*** Test Cases ***
CB006598-A_1 Feature activation
    [Documentation]
    ...    == DESCRIPTION ==
    ...  This test verifies that online modification of NRBTS.NRCELL.actUeRelaxedMeasSA parameter to TRUE activates
    ...  UE RRM measurement relaxation in idle.
    ...  New NIDD parameters for relaxed measurement are configured and used to fill the IE relaxedMeasurement-r16 in SIB2.
    ...  After setting actUeRelaxedMeasSA parameter to TRUE gNB should update SIB2 broadcasting accordingly to
    ...  configured parameters in NRBTS/NRSYSINFO_PROFILE.
    ...
    ...    == Precondition: ==
    ...     - gNB2 classical - real hardware - ASIL + ABIO
    ...     - NR cell is up and connected to AMF1
    ...     - AMF1 simulated
    ...     - UE_1 - Airphone simulator configured for SA mode
    ...     - gNB2 up and running with two SA cells
    ...     - NRCELL-1.actUeRelaxedMeasSA - false
    ...     - NRBTS-1.NRSYSINFO_PROFILE-1 = {
    ...       - lowMobilityEvaluation not configured
    ...       - cellEdgeEvaluation not configured
    ...       - combRelaxedMeasCond = false
    ...       - highPrioMeasRelax = false
    ...       }
    ...    NRCELL-1 administrativeState is UNLOCKED.
    ...    SIB2 is broadcasted without relaxedMeasurement-r16.
    ...
    ...    == Postconditions ==
    ...    NRCELL-1 administrativeState is UNLOCKED.
    ...    NRCELL-1 actUeRelaxedMeasSA parameter is TRUE
    ...    SIB2 is broadcasted with relaxedMeasurement-r16.
    ...    gNB not restarted.
    ...
    ...    == TESTING TOOLS ==
    ...      AirPhone, EPCSIM, UTE
    ...
    ...    == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AZQU radio modules
    ...
    ...    == REQUIREMENTS COVERAGE ==
    ...      REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_19116
    ...
    ...    == REQUIRED LOGS ==
    ...      NR-RRC
    ...
    ...    == CONTACTS ==
    ...     - Maciej Madej <maciej.madej@nokia.com>
    ...     - Konrad Bem <konrad.bem@nokia.com>
    ...
    ...    == REFERENCES ==
    ...       Related CFAM US:
    ...       -  User scenario CB006598#1 CB006598 feature activation
    ...
    ...    == HISTORY ==
    ...       [24.01.2023] - TC Create
    ...       [08.02.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=877558)


    [Setup]  Prepare test environment A_1
    [Tags]  A_1

    Verify that eNB parameter is set to expected value  NRCELL-1  actUeRelaxedMeasSA  false  bts_id=1
    Block NRCELL-1
    Set common verifier to: relaxedMeasurement-r16 is present
    EXPECT FLOW: NRCELL_2_1 NR-RRC SystemInformation without relaxedMeasurement-r16
    Unblock NRCELL-1
    FAIL FLOW: NRCELL_2_1 NR-RRC SystemInformation without relaxedMeasurement-r16

    EXPECT FLOW: NRCELL_2_1 NR-RRC SystemInformation with relaxedMeasurement-r16
    Set NRCELL-1.actUeRelaxedMeasSA to true
    PASS FLOW: NRCELL_2_1 NR-RRC SystemInformation with relaxedMeasurement-r16

    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16.s-SearchDeltaP-r16 is set to 'dB9'
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16.t-SearchDeltaP-r16 is set to 's120'
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdP-r16 is set to 15
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdQ-r16 is set to 1
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.combineRelaxedMeasCondition-r16 is not present
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.highPriorityMeasRelax-r16 is not present

    Verify that eNB parameter is set to expected value   NRCELL-1  administrativeState  Unlocked  bts_id=1
    Verify that eNB parameter is set to expected value   NRCELL-1  actUeRelaxedMeasSA  true  bts_id=1


    [Teardown]  Basic cleanup

CB006598-A_2 Feature deactivation
    [Documentation]
    ...    == DESCRIPTION ==
    ...  This test verifies that online modification of NRBTS.NRCELL.actUeRelaxedMeasSA parameter to FALSE deactivates
    ...  UE RRM measurement relaxation in idle.
    ...  New NIDD parameters for relaxed measurement are configured and used to fill the IE relaxedMeasurement-r16 in SIB2.
    ...  After setting actUeRelaxedMeasSA parameter to FALSE gNB should update SIB2 broadcasting without
    ...  configured parameters in NRBTS/NRSYSINFO_PROFILE.
    ...
    ...    == Precondition: ==
    ...     - gNB2 classical - real hardware - ASIL + ABIO
    ...     - NR cell is up and connected to AMF1
    ...     - AMF1 simulated
    ...     - UE_1 - Airphone simulator configured for SA mode
    ...     - gNB2 up and running with two SA cells
    ...     - NRCELL-1.actUeRelaxedMeasSA - true
    ...     - NRBTS-1.NRSYSINFO_PROFILE-1 = {
    ...      - cellEdgeEvaluation = {
    ...        - sSearchThreshP = 15
    ...        - sSearchThreshQ = 1
    ...        }
    ...      - lowMobilityEvaluation = {
    ...        - sSearchDeltaP = dB9
    ...        - tSearchDeltaP = s120
    ...        }
    ...      }
    ...    NRCELL-1 administrativeState is UNLOCKED.
    ...    SIB2 is broadcasted with relaxedMeasurement-r16.
    ...
    ...    == Postconditions ==
    ...    NRCELL-1 administrativeState is UNLOCKED.
    ...    NRCELL-1 actUeRelaxedMeasSA parameter is FALSE
    ...    SIB2 is broadcasted without relaxedMeasurement-r16.
    ...    gNB not restarted.
    ...
    ...    == TESTING TOOLS ==
    ...      AirPhone, EPCSIM, UTE
    ...
    ...    == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AZQU radio modules
    ...
    ...    == REQUIREMENTS COVERAGE ==
    ...      REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_19145
    ...
    ...    == REQUIRED LOGS ==
    ...      NR-RRC
    ...
    ...    == CONTACTS ==
    ...     - Maciej Madej <maciej.madej@nokia.com>
    ...     - Konrad Bem <konrad.bem@nokia.com>
    ...
    ...    == REFERENCES ==
    ...       Related CFAM US:
    ...       -  User scenario CB006598#2 CB006598 feature deactivation
    ...
    ...    == HISTORY ==
    ...       [24.01.2023] - TC Create
    ...       [08.02.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=877558)


    [Setup]  Prepare test environment A_2
    [Tags]  A_2

    Verify that eNB parameter is set to expected value   NRCELL-1  administrativeState  Unlocked  bts_id=1
    Verify that eNB parameter is set to expected value   NRCELL-1  actUeRelaxedMeasSA  true  bts_id=1

    Block NRCELL-1
    Set common verifier to: relaxedMeasurement-r16 is present
    EXPECT FLOW: NRCELL_2_1 NR-RRC SystemInformation with relaxedMeasurement-r16
    Unblock NRCELL-1
    PASS FLOW: NRCELL_2_1 NR-RRC SystemInformation with relaxedMeasurement-r16

    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16.s-SearchDeltaP-r16 is set to 'dB9'
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16.t-SearchDeltaP-r16 is set to 's120'
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdP-r16 is set to 15
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdQ-r16 is set to 1
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.combineRelaxedMeasCondition-r16 is not present
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.highPriorityMeasRelax-r16 is not present

    Set common verifier to: relaxedMeasurement-r16 is not present
    EXPECT FLOW: NRCELL_2_1 NR-RRC SystemInformation without relaxedMeasurement-r16
    Set NRCELL-1.actUeRelaxedMeasSA to false
    PASS FLOW: NRCELL_2_1 NR-RRC SystemInformation without relaxedMeasurement-r16

    Verify that eNB parameter is set to expected value   NRCELL-1  administrativeState  Unlocked  bts_id=1
    Verify that eNB parameter is set to expected value   NRCELL-1  actUeRelaxedMeasSA  false  bts_id=1

    [Teardown]  Basic cleanup

CB006598-A_3 NIDD parameter lowMobilityEvaluation online change
    [Documentation]
    ...    == DESCRIPTION ==
    ...  This test verifies that online modification of NRBTS/NRSYSINFO_PROFILE.lowMobilityEvaluation is taken into account.
    ...  After addition/removal of lowMobilityEvaluation structure gNB should update SIB2 broadcasting accordingly to
    ...  configured parameters.
    ...
    ...    == Precondition: ==
    ...     - gNB2 classical - real hardware - ASIL + ABIO
    ...     - NR cell is up and connected to AMF1
    ...     - AMF1 simulated
    ...     - UE_1 - Airphone simulator configured for SA mode
    ...     - gNB2 up and running with two SA cells
    ...     - NRCELL-1.actUeRelaxedMeasSA = true
    ...     - NRBTS-1.NRSYSINFO_PROFILE-1 = {
    ...      - highPrioMeasRelax = false
    ...      - combRelaxedMeasCond = false
    ...      - cellEdgeEvaluation-r16 = {
    ...        - sSearchThreshP = 15
    ...        - sSearchThreshQ = 1
    ...        }
    ...      }
    ...
    ...    == Postconditions ==
    ...     - SIB2 is broadcasted without lowMobilityEvaluation structure.
    ...
    ...    == TESTING TOOLS ==
    ...      AirPhone, EPCSIM, UTE
    ...
    ...    == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...    == REQUIREMENTS COVERAGE ==
    ...      REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_19116, 5G_RAN_USR_RRM_19146
    ...
    ...    == REQUIRED LOGS ==
    ...      NR-RRC
    ...
    ...    == CONTACTS ==
    ...     - Maciej Madej <maciej.madej@nokia.com>
    ...
    ...    == REFERENCES ==
    ...       Related CFAM US:
    ...       -  User scenario CB006598#3 NIDD parameter lowMobilityEvaluation online change
    ...
    ...    == HISTORY ==
    ...       [11.05.2022] - TC Create
    ...       [08.02.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=877558)


    [Setup]  Prepare test environment A_3
    [Tags]  A_3

    Verify that eNB parameter is set to expected value   NRCELL-1  administrativeState  Unlocked  bts_id=1
    Verify that eNB parameter is set to expected value   NRCELL-1  actUeRelaxedMeasSA  true  bts_id=1

    Block NRCELL-1
    Set common verifier to: relaxedMeasurement-r16 is present and lowMobilityEvaluation-r16 is not present
    EXPECT FLOW: NRCELL_2_1 NR-RRC SystemInformation without lowMobilityEvaluation-r16
    Unblock NRCELL-1
    PASS FLOW: NRCELL_2_1 NR-RRC SystemInformation without lowMobilityEvaluation-r16

    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16 is not present
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdP-r16 is set to 15
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdQ-r16 is set to 1
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.combineRelaxedMeasCondition-r16 is not present
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.highPriorityMeasRelax-r16 is not present

    Set common verifier to: relaxedMeasurement-r16 is present and lowMobilityEvaluation-r16 is present
    EXPECT FLOW: NRCELL_2_1 NR-RRC SystemInformation with lowMobilityEvaluation-r16
    Configure    ${lowMobilityEvaluation}    name=lowMobilityEvaluation_Config
    PASS FLOW: NRCELL_2_1 NR-RRC SystemInformation with lowMobilityEvaluation-r16

    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16.s-SearchDeltaP-r16 is set to 'dB9'
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16.t-SearchDeltaP-r16 is set to 's120'
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdP-r16 is set to 15
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdQ-r16 is set to 1
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.combineRelaxedMeasCondition-r16 is not present
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.highPriorityMeasRelax-r16 is not present

    Set common verifier to: relaxedMeasurement-r16 is present and lowMobilityEvaluation-r16 is not present
    EXPECT FLOW: NRCELL_2_1 NR-RRC SystemInformation without lowMobilityEvaluation-r16
    Deconfigure    name=lowMobilityEvaluation_Config
    PASS FLOW: NRCELL_2_1 NR-RRC SystemInformation without lowMobilityEvaluation-r16

    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16 is not present
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdP-r16 is set to 15
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdQ-r16 is set to 1
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.combineRelaxedMeasCondition-r16 is not present
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.highPriorityMeasRelax-r16 is not present

    Verify that eNB parameter is set to expected value   NRCELL-1  administrativeState  Unlocked  bts_id=1

    [Teardown]  Basic cleanup

CB006598-A_4 NIDD parameter cellEdgeEvaluation online change
    [Documentation]
    ...    == DESCRIPTION ==
    ...  This test verifies that online modification of NRBTS/NRSYSINFO_PROFILE.cellEdgeEvaluation is taken into account.
    ...  After addition/removal of cellEdgeEvaluation structure gNB should update SIB2 broadcasting accordingly to
    ...  configured parameters.
    ...
    ...    == Precondition: ==
    ...    - gNB2 classical - real hardware - ASIL + ABIO
    ...    - NR cell is up and connected to AMF1
    ...    - AMF1 simulated
    ...    - UE_1 - Airphone simulator configured for SA mode
    ...    - gNB2 up and running with two SA cells
    ...    - NRCELL-1.actUeRelaxedMeasSA = true
    ...    - NRBTS-1.NRSYSINFO_PROFILE-1 = {
    ...      - highPrioMeasRelax = false
    ...      - combRelaxedMeasCond = false
    ...      - lowMobilityEvaluation = {
    ...        - sSearchDeltaP = dB9
    ...        - tSearchDeltaP = s120
    ...        }
    ...      }
    ...
    ...    == Postconditions ==
    ...     - SIB2 is broadcasted without cellEdgeEvaluation structure.
    ...
    ...    == TESTING TOOLS ==
    ...      AirPhone, EPCSIM, UTE
    ...
    ...    == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...    == REQUIREMENTS COVERAGE ==
    ...      REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_19116, 5G_RAN_USR_RRM_19146
    ...
    ...    == REQUIRED LOGS ==
    ...      NR-RRC
    ...
    ...    == CONTACTS ==
    ...     - Maciej Madej <maciej.madej@nokia.com>
    ...
    ...    == REFERENCES ==
    ...       Related CFAM US:
    ...       -  User scenario CB006598#3 NIDD parameter lowMobilityEvaluation online change
    ...       -  User scenario CB006598#1 CB006598 feature activation
    ...
    ...    == HISTORY ==
    ...       [11.05.2022] - TC Create
    ...       [08.02.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=877558)


    [Setup]  Prepare test environment A_4
    [Tags]  A_4

    Verify that eNB parameter is set to expected value   NRCELL-1  administrativeState  Unlocked  bts_id=1
    Verify that eNB parameter is set to expected value   NRCELL-1  actUeRelaxedMeasSA  true  bts_id=1

    Block NRCELL-1
    Set common verifier to: relaxedMeasurement-r16 is present and cellEdgeEvaluation-r16 is not present
    EXPECT FLOW: NRCELL_2_1 NR-RRC SystemInformation without cellEdgeEvaluation-r16
    Unblock NRCELL-1
    PASS FLOW: NRCELL_2_1 NR-RRC SystemInformation without cellEdgeEvaluation-r16

    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16.s-SearchDeltaP-r16 is set to 'dB9'
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16.t-SearchDeltaP-r16 is set to 's120'
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16 is not present
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.combineRelaxedMeasCondition-r16 is not present
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.highPriorityMeasRelax-r16 is not present

    Set common verifier to: relaxedMeasurement-r16 is present and cellEdgeEvaluation-r16 is present
    EXPECT FLOW: NRCELL_2_1 NR-RRC SystemInformation with cellEdgeEvaluation-r16
    Configure    ${cellEdgeEvaluation}    name=cellEdgeEvaluation_Config
    PASS FLOW: NRCELL_2_1 NR-RRC SystemInformation with cellEdgeEvaluation-r16

    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16.s-SearchDeltaP-r16 is set to 'dB9'
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16.t-SearchDeltaP-r16 is set to 's120'
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdP-r16 is set to 15
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdQ-r16 is set to 1
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.combineRelaxedMeasCondition-r16 is not present
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.highPriorityMeasRelax-r16 is not present

    Set common verifier to: relaxedMeasurement-r16 is present and cellEdgeEvaluation-r16 is not present
    EXPECT FLOW: NRCELL_2_1 NR-RRC SystemInformation without cellEdgeEvaluation-r16
    Deconfigure    name=cellEdgeEvaluation_Config
    PASS FLOW: NRCELL_2_1 NR-RRC SystemInformation without cellEdgeEvaluation-r16

    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16.s-SearchDeltaP-r16 is set to 'dB9'
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16.t-SearchDeltaP-r16 is set to 's120'
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16 is not present
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.combineRelaxedMeasCondition-r16 is not present
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.highPriorityMeasRelax-r16 is not present

    Verify that eNB parameter is set to expected value   NRCELL-1  administrativeState  Unlocked  bts_id=1

    [Teardown]  Basic cleanup


CB006598-A_5 NIDD parameter combRelaxedMeasCond and highPrioMeasRelax online change
    [Documentation]
    ...    == DESCRIPTION ==
    ...  This test verifies that online modification of NRBTS/NRSYSINFO_PROFILE.combRelaxedMeasCond  is taken into account.
    ...  After setting combineRelaxedMeasCondition and highPrioMeasRelax to true gNB should broadcast
    ...  combineRelaxedMeasCondition-r16 and highPriorityMeasRelax-r16 IEs in SIB2.
    ...
    ...    == Precondition: ==
    ...    - gNB2 classical - real hardware - ASIL + ABIO
    ...    - NR cell is up and connected to AMF1
    ...    - AMF1 simulated
    ...    - UE_1 - Airphone simulator configured for SA mode
    ...    - gNB2 up and running with two SA cells
    ...    - NRCELL-1.actUeRelaxedMeasSA = true
    ...    - NRBTS-1.NRSYSINFO_PROFILE-1 = {
    ...      - highPrioMeasRelax = false
    ...      - combRelaxedMeasCond = false
    ...      - cellEdgeEvaluation = {
    ...        - sSearchThreshP = 15
    ...        - sSearchThreshQ = 1
    ...        }
    ...      - lowMobilityEvaluation = {
    ...        - sSearchDeltaP = dB9
    ...        - tSearchDeltaP = s120
    ...        }
    ...      }
    ...
    ...    == Postconditions ==
    ...     - SIB2 is broadcasted without combineRelaxedMeasCondition-r16 and highPriorityMeasRelax-r16 IEs.
    ...
    ...    == TESTING TOOLS ==
    ...      AirPhone, EPCSIM, UTE
    ...
    ...    == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...    == REQUIREMENTS COVERAGE ==
    ...      REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_19116, 5G_RAN_USR_RRM_19146
    ...
    ...    == REQUIRED LOGS ==
    ...      NR-RRC
    ...
    ...    == CONTACTS ==
    ...     - Maciej Madej <maciej.madej@nokia.com>
    ...
    ...    == REFERENCES ==
    ...       Related CFAM US:
    ...       -  User scenario CB006598#3 NIDD parameter lowMobilityEvaluation online change
    ...       -  User scenario CB006598#1 CB006598 feature activation
    ...
    ...    == HISTORY ==
    ...       [11.05.2022] - TC Create
    ...       [08.02.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=877558)


    [Setup]  Prepare test environment A_5
    [Tags]  A_5

    Verify that eNB parameter is set to expected value   NRCELL-1  administrativeState  Unlocked  bts_id=1
    Verify that eNB parameter is set to expected value   NRCELL-1  actUeRelaxedMeasSA  true  bts_id=1

    Block NRCELL-1
    Set common verifier to: relaxedMeasurement-r16 is present
    EXPECT FLOW: NRCELL_2_1 NR-RRC SystemInformation without combineRelaxedMeasCondition-r16 and highPriorityMeasRelax-r16
    Unblock NRCELL-1
    PASS FLOW: NRCELL_2_1 NR-RRC SystemInformation without combineRelaxedMeasCondition-r16 and highPriorityMeasRelax-r16

    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16.s-SearchDeltaP-r16 is set to 'dB9'
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16.t-SearchDeltaP-r16 is set to 's120'
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdP-r16 is set to 15
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdQ-r16 is set to 1
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.combineRelaxedMeasCondition-r16 is not present
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.highPriorityMeasRelax-r16 is not present

    Set common verifier to: relaxedMeasurement-r16 is present and combineRelaxedMeasCondition-r16 is present
    EXPECT FLOW: NRCELL_2_1 NR-RRC SystemInformation with combineRelaxedMeasCondition-r16
    Set NRSYSINFO_PROFILE-1.combRelaxedMeasCond to true
    PASS FLOW: NRCELL_2_1 NR-RRC SystemInformation with combineRelaxedMeasCondition-r16

    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16.s-SearchDeltaP-r16 is set to 'dB9'
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16.t-SearchDeltaP-r16 is set to 's120'
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdP-r16 is set to 15
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdQ-r16 is set to 1
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.combineRelaxedMeasCondition-r16 is present
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.highPriorityMeasRelax-r16 is not present

    Set common verifier to: relaxedMeasurement-r16 is present and highPriorityMeasRelax-r16 is present
    EXPECT FLOW: NRCELL_2_1 NR-RRC SystemInformation with highPriorityMeasRelax-r16
    Set NRSYSINFO_PROFILE-1.highPrioMeasRelax to true
    PASS FLOW: NRCELL_2_1 NR-RRC SystemInformation with highPriorityMeasRelax-r16

    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16.s-SearchDeltaP-r16 is set to 'dB9'
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16.t-SearchDeltaP-r16 is set to 's120'
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdP-r16 is set to 15
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdQ-r16 is set to 1
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.combineRelaxedMeasCondition-r16 is present
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.highPriorityMeasRelax-r16 is present

    Set common verifier to: relaxedMeasurement-r16 is present and highPriorityMeasRelax-r16 is not present
    EXPECT FLOW: NRCELL_2_1 NR-RRC SystemInformation without highPriorityMeasRelax-r16
    Set NRSYSINFO_PROFILE-1.highPrioMeasRelax to false
    PASS FLOW: NRCELL_2_1 NR-RRC SystemInformation without highPriorityMeasRelax-r16

    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16.s-SearchDeltaP-r16 is set to 'dB9'
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16.t-SearchDeltaP-r16 is set to 's120'
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdP-r16 is set to 15
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdQ-r16 is set to 1
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.combineRelaxedMeasCondition-r16 is present
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.highPriorityMeasRelax-r16 is not present

    Set common verifier to: relaxedMeasurement-r16 is present and combineRelaxedMeasCondition-r16 is not present
    EXPECT FLOW: NRCELL_2_1 NR-RRC SystemInformation without combineRelaxedMeasCondition-r16
    Set NRSYSINFO_PROFILE-1.combRelaxedMeasCond to false
    PASS FLOW: NRCELL_2_1 NR-RRC SystemInformation without combineRelaxedMeasCondition-r16

    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16.s-SearchDeltaP-r16 is set to 'dB9'
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16.t-SearchDeltaP-r16 is set to 's120'
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdP-r16 is set to 15
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdQ-r16 is set to 1
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.combineRelaxedMeasCondition-r16 is not present
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.highPriorityMeasRelax-r16 is not present

    Verify that eNB parameter is set to expected value   NRCELL-1  administrativeState  Unlocked  bts_id=1

    [Teardown]  Basic cleanup


CB006598-A_6 Configuration of two different NRSYSINFO_PROFILEs
    [Documentation]
    ...    == DESCRIPTION ==
    ...  This test verifies that modification of two different NRSYSINFO_PROFILEs for two SA cells are taken into account
    ...  and SIB2 messages broadcaster from cells are set according to set parameters.
    ...
    ...    == Precondition: ==
    ...    - gNB2 classical - real hardware - ASIL + ABIO
    ...    - NR cell is up and connected to AMF1
    ...    - AMF1 simulated
    ...    - UE_1 - Airphone simulator configured for SA mode
    ...    - gNB2 up and running with two SA cells
    ...    - NRCELL-1.actUeRelaxedMeasSA = true
    ...    - NRCELL-2.actUeRelaxedMeasSA = true
    ...    - NRCELL-1.nrSysInfoProfileDN	= MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1
    ...    - NRCELL-2.nrSysInfoProfileDN	= MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-2
    ...    - NRBTS-1.NRSYSINFO_PROFILE-1 = {
    ...      - cellEdgeEvaluation = {
    ...        - sSearchThreshP = 15
    ...        - sSearchThreshQ = 1
    ...        }
    ...      - lowMobilityEvaluation = {
    ...        - sSearchDeltaP = dB9
    ...        - tSearchDeltaP = s120
    ...        }
    ...      }
    ...    - NRBTS-1.NRSYSINFO_PROFILE-2 = {
    ...      - highPrioMeasRelax = false
    ...      - combRelaxedMeasCond = false
    ...      - lowMobilityEvaluation = {
    ...        - sSearchDeltaP = dB3
    ...        - tSearchDeltaP = s5
    ...        }
    ...      - cellEdgeEvaluation = {
    ...        - sSearchThreshP = 20
    ...        - sSearchThreshQ = 2
    ...        }
    ...      }
    ...
    ...    == Postconditions ==
    ...     - NRCELL-1 and NRCELL-2 SIB2 are broadcasted with combineRelaxedMeasCondition-r16 and highPriorityMeasRelax-r16 IEs.
    ...
    ...    == TESTING TOOLS ==
    ...      AirPhone, EPCSIM, UTE
    ...
    ...    == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...    == REQUIREMENTS COVERAGE ==
    ...      REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_19116, 5G_RAN_USR_RRM_19146
    ...
    ...    == REQUIRED LOGS ==
    ...      NR-RRC
    ...
    ...    == CONTACTS ==
    ...     - Maciej Madej <maciej.madej@nokia.com>
    ...
    ...    == REFERENCES ==
    ...       Related CFAM US:
    ...       -  User scenario CB006598#3 NIDD parameter lowMobilityEvaluation online change
    ...       -  User scenario CB006598#1 CB006598 feature activation
    ...
    ...    == HISTORY ==
    ...       [11.05.2022] - TC Create
    ...       [08.02.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=877558)


    [Setup]  Prepare test environment A_6
    [Tags]  A_6

    Verify that eNB parameter is set to expected value   NRCELL-1  administrativeState  Unlocked  bts_id=1
    Verify that eNB parameter is set to expected value   NRCELL-2  administrativeState  Unlocked  bts_id=1

    Set common verifier to: relaxedMeasurement-r16 is present
    EXPECT FLOW: NRCELL_2_1 NR-RRC SystemInformation with relaxedMeasurement-r16
    Set NRCELL-1.actUeRelaxedMeasSA to true
    PASS FLOW: NRCELL_2_1 NR-RRC SystemInformation with relaxedMeasurement-r16

    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16.s-SearchDeltaP-r16 is set to 'dB9'
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.lowMobilityEvaluation-r16.t-SearchDeltaP-r16 is set to 's120'
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdP-r16 is set to 15
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdQ-r16 is set to 1
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.combineRelaxedMeasCondition-r16 is not present
    Verify that in SIB2 broadcasted by NRCELL-1 relaxedMeasurement-r16.highPriorityMeasRelax-r16 is not present

    EXPECT FLOW: NRCELL_2_2 NR-RRC SystemInformation with relaxedMeasurement-r16
    Set NRCELL-2.actUeRelaxedMeasSA to true
    PASS FLOW: NRCELL_2_2 NR-RRC SystemInformation with relaxedMeasurement-r16

    Verify that in SIB2 broadcasted by NRCELL-2 relaxedMeasurement-r16.lowMobilityEvaluation-r16.s-SearchDeltaP-r16 is set to 'dB3'
    Verify that in SIB2 broadcasted by NRCELL-2 relaxedMeasurement-r16.lowMobilityEvaluation-r16.t-SearchDeltaP-r16 is set to 's5'
    Verify that in SIB2 broadcasted by NRCELL-2 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdP-r16 is set to 20
    Verify that in SIB2 broadcasted by NRCELL-2 relaxedMeasurement-r16.cellEdgeEvaluation-r16.s-SearchThresholdQ-r16 is set to 2
    Verify that in SIB2 broadcasted by NRCELL-2 relaxedMeasurement-r16.combineRelaxedMeasCondition-r16 is not present
    Verify that in SIB2 broadcasted by NRCELL-2 relaxedMeasurement-r16.highPriorityMeasRelax-r16 is not present

    Set common verifier to: relaxedMeasurement-r16 is not present
    EXPECT FLOW: NRCELL_2_1 NR-RRC SystemInformation without relaxedMeasurement-r16
    Set NRCELL-1.actUeRelaxedMeasSA to false
    PASS FLOW: NRCELL_2_1 NR-RRC SystemInformation without relaxedMeasurement-r16

    EXPECT FLOW: NRCELL_2_2 NR-RRC SystemInformation without relaxedMeasurement-r16
    Set NRCELL-2.actUeRelaxedMeasSA to false
    PASS FLOW: NRCELL_2_2 NR-RRC SystemInformation without relaxedMeasurement-r16

    Verify that eNB parameter is set to expected value   NRCELL-1  administrativeState  Unlocked  bts_id=1
    Verify that eNB parameter is set to expected value   NRCELL-2  administrativeState  Unlocked  bts_id=1

    [Teardown]  Basic cleanup


CB006598-A_7 NIDD rules verification and parameter configuration
    [Tags]    A_7    MANUAL    SKIPRUN
    [Documentation]
    ...    == DESCRIPTION ==
    ...  This test verifies that online modification of NRBTS.NRCELL.actUeRelaxedMeasSA parameter to TRUE activates
    ...  UE RRM measurement relaxation in idle.
    ...  New NIDD parameters for relaxed measurement are configured and used to fill the IE relaxedMeasurement-r16 in SIB2.
    ...  After setting actUeRelaxedMeasSA parameter to TRUE gNB should update SIB2 broadcasting accordingly to
    ...  configured parameters in NRBTS/NRSYSINFO_PROFILE.
    ...
    ...  TEST DESCRIPTION
    ...    SubTest 1: Activate CB006598 feature with parameters lowMobilityEvaluation and cellEdgeEvaluation not set
    ...    1. NRCELL-1 has parameter nrSysInfoProfileDN set to MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1
    ...    2. Parameters lowMobilityEvaluation and cellEdgeEvaluation are not set on NRSYSINFO_PROFILE-1
    ...    3. User sets actUeRelaxedMeasSA to TRUE in Web Element Manager on NRCELL-1
    ...    4. System refuse to set parameter with error message:
    ...    "Whenever NRCELL-1.actUeRelaxedMeasSA (value: true) is equal to true, it is required that
    ...    NRSYSINFO_PROFILE.cellEdgeEvaluation.sSearchThreshP shall be configured for the referenced NRSYSINFO_PROFILE
    ...    or NRSYSINFO_PROFILE.lowMobilityEvaluation.sSearchDeltaP and NRSYSINFO_PROFILE.lowMobilityEvaluation.tSearchDeltaP
    ...    shall be configured for the referenced NRSYSINFO_PROFILE"
    ...
    ...    SubTest 2: Activate CB006598 feature with parameter lowMobilityEvaluation set and cellEdgeEvaluation not set
    ...    1. NRCELL-1 has parameter nrSysInfoProfileDN set to MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1
    ...    2. Parameters lowMobilityEvaluation are set and cellEdgeEvaluation are not set on NRSYSINFO_PROFILE-1
    ...    3. User sets actUeRelaxedMeasSA to TRUE in Web Element Manager on NRCELL-1
    ...    4. System accept to set parameters without error message
    ...
    ...    SubTest 3: Activate CB006598 feature with parameter lowMobilityEvaluation not set and cellEdgeEvaluation set
    ...    1. NRCELL-1 has parameter nrSysInfoProfileDN set to MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1
    ...    2. Parameters lowMobilityEvaluation are not set and cellEdgeEvaluation are set on NRSYSINFO_PROFILE-1
    ...    3. User sets actUeRelaxedMeasSA to TRUE in Web Element Manager on NRCELL-1
    ...    4. System accept to set parameters without error message
    ...
    ...    SubTest 4: Activate CB006598 feature with parameter lowMobilityEvaluation not set and cellEdgeEvaluation set
    ...    1. NRCELL-1 has parameter nrSysInfoProfileDN set to MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1
    ...    2. Parameter cellEdgeEvaluation is set to value not in range [0,31]
    ...    3. System refuse to set parameter with error message
    ...
    ...    SubTest 5: Online change of parameters lowMobilityEvaluation and cellEdgeEvaluation
    ...    1. NRCELL-1 has parameter nrSysInfoProfileDN set to MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1
    ...    2. User changes parameter cellEdgeEvaluation value
    ...    3. System accept to set parameter without error message
    ...    4. User changes parameters lowMobilityEvaluation value
    ...    5. System accept to set parameters without error message
    ...    6. User changes parameter cellEdgeEvaluation to empty value
    ...    7. System accept to set parameters without error message
    ...    8. User changes parameters lowMobilityEvaluation to empty values
    ...    9. System refuse to set parameters with error message
    ...    10. User changes parameter cellEdgeEvaluation to corect value
    ...    11. System accept to set parameters without error message
    ...    12. User changes parameters lowMobilityEvaluation to empty values
    ...    13. System accept to set parameters without error message
    ...    14. User changes parameter cellEdgeEvaluation to empty value
    ...    15. System refuse to set parameters with error message
    ...
    ...    SubTest 6: Deactivate CB006598 feature with parameters set
    ...    1. NRCELL-1 has parameter nrSysInfoProfileDN set to MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1
    ...    2. Parameters lowMobilityEvaluation and cellEdgeEvaluation are set on NRSYSINFO_PROFILE-1
    ...    3. User sets actUeRelaxedMeasSA to FALSE in Web Element Manager on NRCELL-1
    ...    4. System accept to set parameters without error message
    ...    5. Parameters lowMobilityEvaluation and cellEdgeEvaluation are set on NRSYSINFO_PROFILE-1
    ...
    ...    SubTest 7: Deactivate CB006598 feature with parameters not set
    ...    1. NRCELL-1 has parameter nrSysInfoProfileDN set to MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1
    ...    2. Parameters lowMobilityEvaluation are set and cellEdgeEvaluation are set on NRSYSINFO_PROFILE-1
    ...    3. User in one transation sets parameters lowMobilityEvaluation and cellEdgeEvaluation to empty values on
    ...    NRSYSINFO_PROFILE-1 and sets actUeRelaxedMeasSA to FALSE in Web Element Manager on NRCELL-1
    ...    4. System accept to set parameters without error message
    ...    5. Parameters lowMobilityEvaluation and cellEdgeEvaluation are not set on NRSYSINFO_PROFILE-1
    ...
    ...    == Precondition: ==
    ...     - gNB2 classical - real hardware - ASIL + ABIO
    ...     - NR cell is up and connected to AMF1
    ...     - AMF1 simulated
    ...     - UE_1 - Airphone simulator configured for SA mode
    ...     - gNB2 up and running with two SA cells
    ...     - NRCELL-1.actUeRelaxedMeasSA - false
    ...     - NRBTS-1.NRSYSINFO_PROFILE-1 = {
    ...       - lowMobilityEvaluation.sSearchDeltaP = not set
    ...       - lowMobilityEvaluation.tSearchDeltaP = not set
    ...       - cellEdgeEvaluation.sSearchThreshP = not set
    ...       - combRelaxedMeasCond = false
    ...       - highPrioMeasRelax = false
    ...       }
    ...    NRCELL-1 administrativeState is UNLOCKED.
    ...    SIB2 is broadcasted without relaxedMeasurement-r16.
    ...
    ...    == Postconditions ==
    ...    NRCELL-1 administrativeState is UNLOCKED.
    ...    NRCELL-1 actUeRelaxedMeasSA parameter is TRUE
    ...    SIB2 is broadcasted with relaxedMeasurement-r16.
    ...    gNB not restarted.
    ...
    ...    == TESTING TOOLS ==
    ...      AirPhone, EPCSIM, UTE
    ...
    ...    == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AZQU radio modules
    ...
    ...    == REQUIREMENTS COVERAGE ==
    ...      REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_19116,5G_RAN_USR_RRM_19145, 5G_RAN_USR_RRM_19146
    ...
    ...    == REQUIRED LOGS ==
    ...      NR-RRC
    ...
    ...    == CONTACTS ==
    ...     - Maciej Madej <maciej.madej@nokia.com>
    ...     - Konrad Bem <konrad.bem@nokia.com>
    ...
    ...    == REFERENCES ==
    ...       Related CFAM US:
    ...       -  User scenario CB006598#1 CB006598 feature activation
    ...       -  User scenario CB006598#2 CB006598 feature deactivation
    ...       -  User scenario CB006598#3 NIDD parameter lowMobilityEvaluation online change
    ...
    ...    == HISTORY ==
    ...       [06.02.2023] - TC Create
    ...       [08.02.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=877558)

    No Operation


CB006598-A_8 Modification of nrSysInfoProfileDN
    [Tags]    A_8    MANUAL    SKIPRUN
    [Documentation]
    ...    == DESCRIPTION ==
    ...  This test verifies online modification of NRBTS.NRCELL.nrSysInfoProfileDN parameter to various
    ...  NRBTS.NRSYSINFO_PROFILE
    ...  New NIDD parameters for relaxed measurement are configured and used to fill the IE relaxedMeasurement-r16 in SIB2.
    ...  After setting nrSysInfoProfileDN to various NRSYSINFO_PROFILE gNB should update SIB2 broadcasting accordingly to
    ...  configured parameters in that NRBTS/NRSYSINFO_PROFILE.
    ...
    ...  TEST DESCRIPTION
    ...    1. User sets NRCELL-1 parameter nrSysInfoProfileDN to MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-2
    ...    2. SIB2 is broadcasting accordingly to configured parameters in NRBTS/NRSYSINFO_PROFILE-2
    ...    3. User sets NRCELL-1 parameter nrSysInfoProfileDN to MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-3
    ...    4. SIB2 is broadcasting accordingly to configured parameters in NRBTS/NRSYSINFO_PROFILE-3
    ...    5. User sets NRCELL-1 parameter nrSysInfoProfileDN to MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1
    ...    6. SIB2 is broadcasting accordingly to configured parameters in NRBTS/NRSYSINFO_PROFILE-1
    ...
    ...    == Precondition: ==
    ...     - gNB2 classical - real hardware - ASIL + ABIO
    ...     - NR cell is up and connected to AMF1
    ...     - AMF1 simulated
    ...     - UE_1 - Airphone simulator configured for SA mode
    ...     - gNB2 up and running with two SA cells
    ...     - NRCELL-1.actUeRelaxedMeasSA - true
    ...     - NRBTS-1.NRSYSINFO_PROFILE-1 = {
    ...       - lowMobilityEvaluation.sSearchDeltaP = db9
    ...       - lowMobilityEvaluation.tSearchDeltaP = s120
    ...       - cellEdgeEvaluation.sSearchThreshP = 15
    ...       - cellEdgeEvaluation.sSearchThreshQ = 1
    ...       - combRelaxedMeasCond = false
    ...       - highPrioMeasRelax = false
    ...       }
    ...     - NRBTS-1.NRSYSINFO_PROFILE-2 = {
    ...       - lowMobilityEvaluation.sSearchDeltaP = sb6
    ...       - lowMobilityEvaluation.tSearchDeltaP = s60
    ...       - cellEdgeEvaluation.sSearchThreshP = not set
    ...       - cellEdgeEvaluation.sSearchThreshQ = not set
    ...       - combRelaxedMeasCond = false
    ...       - highPrioMeasRelax = false
    ...       }
    ...     - NRBTS-1.NRSYSINFO_PROFILE-3 = {
    ...       - lowMobilityEvaluation.sSearchDeltaP = not set
    ...       - lowMobilityEvaluation.tSearchDeltaP = not set
    ...       - cellEdgeEvaluation.sSearchThreshP = 20
    ...       - cellEdgeEvaluation.sSearchThreshQ = 2
    ...       - combRelaxedMeasCond = false
    ...       - highPrioMeasRelax = false
    ...       }
    ...    NRCELL-1 administrativeState is UNLOCKED.
    ...    SIB2 is broadcasted with relaxedMeasurement-r16.
    ...
    ...    == Postconditions ==
    ...    NRCELL-1 administrativeState is UNLOCKED.
    ...    NRCELL-1 actUeRelaxedMeasSA parameter is TRUE
    ...    SIB2 is broadcasted with relaxedMeasurement-r16.
    ...    gNB not restarted.
    ...
    ...    == TESTING TOOLS ==
    ...      AirPhone, EPCSIM, UTE
    ...
    ...    == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AZQU radio modules
    ...
    ...    == REQUIREMENTS COVERAGE ==
    ...      REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_19116,5G_RAN_USR_RRM_19145, 5G_RAN_USR_RRM_19146
    ...
    ...    == REQUIRED LOGS ==
    ...      NR-RRC
    ...
    ...    == CONTACTS ==
    ...     - Maciej Madej <maciej.madej@nokia.com>
    ...     - Konrad Bem <konrad.bem@nokia.com>
    ...
    ...    == REFERENCES ==
    ...       Related CFAM US:
    ...       -  User scenario CB006598#1 CB006598 feature activation
    ...       -  User scenario CB006598#2 CB006598 feature deactivation
    ...       -  User scenario CB006598#3 NIDD parameter lowMobilityEvaluation online change
    ...
    ...    == HISTORY ==
    ...       [13.02.2023] - TC Create
    ...       [08.02.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=877558)
    ...

    No Operation


CB006598-A_9 Test SIB2 broadcasting after gNB and RMOD reset and RMOD lock-unlock
    [Tags]    A_9    MANUAL    SKIPRUN
    [Documentation]
    ...   == DESCRIPTION ==
    ...  This test verifies that after gNB or RMOD reset, and after RMOD lock/unlock with activated CB006598, SIB2 is correctly broadcasting
    ...  with relaxedMeasurements-r16.
    ...
    ...  TEST DESCRIPTION
    ...    1. Reset RMOD
    ...    2. Verify that SIB2 is broadcasted with relaxedMEasurements-r16.
    ...    3. Lock RMOD
    ...    4. Verify that SIB2 is broadcasted without relaxedMEasurements-r16.
    ...    5. Unlock RMOD
    ...    6. Verify that SIB2 is broadcasted with relaxedMEasurements-r16.
    ...    7. Reset gNB
    ...    8. Wait until cell are online
    ...    9. Verify that SIB2 is broadcasted with relaxedMEasurements-r16.
    ...    10. Repeat steps 1-9 few times
    ...
    ...    == Precondition: ==
    ...     - gNB2 classical - real hardware - ASIL + ABIO
    ...     - NR cell is up and connected to AMF1
    ...     - AMF1 simulated
    ...     - UE_1 - Airphone simulator configured for SA mode
    ...     - gNB2 up and running with two SA cells
    ...     - NRCELL-1.actUeRelaxedMeasSA - true
    ...     - NRBTS-1.NRSYSINFO_PROFILE-1 = {
    ...       - lowMobilityEvaluation.sSearchDeltaP = db9
    ...       - lowMobilityEvaluation.tSearchDeltaP = s120
    ...       - cellEdgeEvaluation.sSearchThreshP = 15
    ...       - cellEdgeEvaluation.sSearchThreshQ = 1
    ...       - combRelaxedMeasCond = false
    ...       - highPrioMeasRelax = false
    ...       }
    ...    NRCELL-1 administrativeState is UNLOCKED.
    ...    SIB2 is broadcasted with relaxedMeasurement-r16.
    ...
    ...    == Postconditions ==
    ...    NRCELL-1 administrativeState is UNLOCKED.
    ...    NRCELL-1 actUeRelaxedMeasSA parameter is TRUE
    ...    SIB2 is broadcasted with relaxedMeasurement-r16.
    ...
    ...    == TESTING TOOLS ==
    ...      AirPhone, EPCSIM, UTE
    ...
    ...    == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AZQU radio modules
    ...
    ...    == REQUIREMENTS COVERAGE ==
    ...      REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_19116,5G_RAN_USR_RRM_19145, 5G_RAN_USR_RRM_19146
    ...
    ...    == REQUIRED LOGS ==
    ...      NR-RRC
    ...
    ...    == CONTACTS ==
    ...     - Maciej Madej <maciej.madej@nokia.com>
    ...     - Konrad Bem <konrad.bem@nokia.com>
    ...
    ...    == REFERENCES ==
    ...       Related CFAM US:
    ...       -  User scenario CB006598#1 CB006598 feature activation
    ...       -  User scenario CB006598#2 CB006598 feature deactivation
    ...       -  User scenario CB006598#3 NIDD parameter lowMobilityEvaluation online change
    ...
    ...    == HISTORY ==
    ...       [13.02.2023] - TC Create
    ...       [08.02.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=877558)

    No Operation
