*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB010544: UE power saving: Full flexible setting of Initial BWP respect to PS BWP
...         The feature removes restrictions concerning the feature 5GC000937 allowing PRACH frequency position outside
...         the Power Saving Bandwidth Part (PS-BWP). With this feature, it will be possible to:
...             - Remove RACH configuration at RRC level for the PowerSaving BWP (PS-BWP)
...             - Take into account the implicit BWP switch in case of Beam Failure Recovery if UE active BWP has no RACH configuration (PS-BWP)
...             - Performs a new BWP switch procedure via RRC reconfiguration (different to nominal DCI-based BWP switch used by feature 5GC000937)
...               to the nominal BWP (BWP#1) after the BFR if the RACH config is not present
...             - CP will be able to detect automatically if the RACH config requires to be outside the dedicated BWP
...               (sending the BWP config without RACH-ConfigCommon to UP)
...         Concerning the new RRC reconfiguration for BWP switch:
...             - UP will be able to initiate a BWP switch after BFR depending on the BWP config if RACH-ConfigCommon is not present
...               in the dedicated BWP, send a RRC reconfiguration for BWP switch request to CP-RT
...             - CP will be able to send RRC reconfiguration when receiving the request from UP
...
...      == TEST SET NAME ==
...         CB010544 - UE power saving: Full flexible setting of Initial BWP respect to PS BWP
...
...      == TESTING SPLIT ==
...         CB010544-A Full flexibility setting for initial BWP
...         CB010544-B Feature interaction handling for full flexibility setting for initial BWP
...         CB010544-C OAM update for CNI-100008
...         CB010544-W Capacity and performance for full flexibility setting for initial BWP
...
...      == CONTACTS ==
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...
...      == MAINTAINER ==
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...
...      == REFERENCES ==
...         CB010544 CFAM - https://gates.nsn-net.net/view/00026c2b#o=0
...
...      == HISTORY ==
...         [30.05.2023] - Create Test Suite

Force Tags    CONFIGURED    PY36    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_TDD_SANSA.lua

*** Test Cases ***
CB010544-A-A1_1 Cell configuration with RACH outside Initial BWP
    [Tags]    A-A1_1    MANUAL
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to validate that after configuring RACH outside Initial BWP and feature CB010544 is disabled,
    ...  then alarm on the affected cell is raised with Fault ID 7516: Incorrect cell parameter configuration.
    ...  After activation of CB010544 fault is still visible.
    ...
    ...  TEST DESCRIPTION
    ...
    ...  1. NRCELL-1 is enabled and without alarms
    ...  2. Set NRCELL-1.msg1FrequencyStart to 120 (initial BWP size is 106 PRBs)
    ...  3. Verify that alarm is raised on NRCELL-1 with Fault ID 7516: Incorrect cell parameter configuration
    ...  4. Verify that NRCELL-1 is degraded
    ...  5. Set NRCELL-1.actInitialBWPFlexibility to true
    ...  6. Verify that alarm is still present on NRCELL-1 with Fault ID 7516: Incorrect cell parameter configuration
    ...  7. Verify that NRCELL-1 is degraded
    ...  8. Set NRCELL-1.msg1FrequencyStart to 26
    ...  9. Verify that NRCELL-1 is not degraded and alarm is cleared
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with 2 SA TDD cells (band n78)
    ...  - NRCELL-1.actPowerSavingBWP = true
    ...  - NRCELL-1.actInitialBWPFlexibility = false
    ...  - NRCELL-1.nrarfcn = 636666
    ...  - NRCELL-1.gscnOrSsPbchArfcn = 7853
    ...  - NRCELL-1.msg1FrequencyStart = 26
    ...  - NRCELL-1.cellBwpList =
    ...    - cellBwpId: '0'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-5'     initial BWP - 40MHZ
    ...    - cellBwpId: '1'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-44'    default dedicated BWP - 100MHZ
    ...    - cellBwpId: '2'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-50'    Power Saving BWP - 20MHZ
    ...  - NRCELL-2 - default config
    ...
    ...  == Postconditions ==
    ...  NRCELL-1 is not degraded and without alarms
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with 2 simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_19650;5G_RAN_OP_2624;5G_CP_ARC_ALG_10798;5G_CP_ARC_ALG_6948;
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     - USCB010544-A#4 Alarm raises if the RACH is wrong configured even with Flexibility
    ...
    ...  == HISTORY ==
    ...     [30.05.2022] - TC Create
    ...     [02.06.2023] - TC passed with build SBTS00_ENB_9999_230601_000007

    No Operation


CB010544-A-A1_2 Cell configuration with RACH outside PS BWP inside Initial BWP
    [Tags]    A-A1_2    MANUAL
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to validate that after configuring RACH inside Initial BWP but outside PowerSaving BWP
    ...  and feature CB010544 is disabled, then alarm on the affected cell is raised with Fault ID 7516: Incorrect cell parameter configuration.
    ...  After feature CB010544 activation (NRCELL-1.actInitialBWPFlexibility = true) alarm is cleared.
    ...
    ...  TEST DESCRIPTION
    ...
    ...  1. NRCELL-1 is enabled and without alarms
    ...  2. Set NRCELL-1.msg1FrequencyStart to 60 (PS BWP size is 51 PRB, initial BWP size is 106 PRBs)
    ...  3. Verify that alarm is raised on NRCELL-1 with Fault ID 7516: Incorrect cell parameter configuration
    ...  4. Verify that NRCELL-1 is degraded
    ...  5. Set NRCELL-1.actInitialBWPFlexibility to true
    ...  6. Verify that NRCELL-1 is not degraded and alarm is cleared
    ...  7. Set NRCELL-1.msg1FrequencyStart to 26
    ...  8. Set NRCELL-1.actInitialBWPFlexibility to false
    ...  9. Verify that NRCELL-1 is not degraded and without alarms
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with 2 SA TDD cells (band n78)
    ...  - NRCELL-1.actPowerSavingBWP = true
    ...  - NRCELL-1.actInitialBWPFlexibility = false
    ...  - NRCELL-1.nrarfcn = 636666
    ...  - NRCELL-1.gscnOrSsPbchArfcn = 7853
    ...  - NRCELL-1.msg1FrequencyStart = 26
    ...  - NRCELL-1.cellBwpList =
    ...    - cellBwpId: '0'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-5'     initial BWP - 40MHZ
    ...    - cellBwpId: '1'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-44'    default dedicated BWP - 100MHZ
    ...    - cellBwpId: '2'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-50'    Power Saving BWP - 20MHZ
    ...  - NRCELL-2 - default config
    ...
    ...  == Postconditions ==
    ...  NRCELL-1 is not degraded and without alarms
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with 2 simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_19340;5G_RAN_OP_2624;5G_CP_ARC_ALG_10798;5G_CP_ARC_ALG_6948;
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...
    ...  == HISTORY ==
    ...     [30.05.2022] - TC Create
    ...     [02.06.2023] - TC passed with build SBTS00_ENB_9999_230601_000007

    No Operation


CB010544-A-A1_3 Cell configuration with RACH inside PS BWP
    [Tags]    A-A1_3    MANUAL
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to validate that after configuring RACH inside Initial BWP and inside PowerSaving BWP
    ...  and feature CB010544 is enabled, then alarm is not raised.
    ...
    ...  TEST DESCRIPTION
    ...
    ...  1. NRCELL-1 is enabled and without alarms
    ...  2. Set NRCELL-1.actInitialBWPFlexibility to true
    ...  3. Verify that NRCELL-1 is not degraded and without alarms
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - gNB2 up and running with 2 SA TDD cells (band n78)
    ...  - NRCELL-1.actPowerSavingBWP = true
    ...  - NRCELL-1.actInitialBWPFlexibility = false
    ...  - NRCELL-1.nrarfcn = 636666
    ...  - NRCELL-1.gscnOrSsPbchArfcn = 7853
    ...  - NRCELL-1.msg1FrequencyStart = 26
    ...  - NRCELL-1.cellBwpList =
    ...    - cellBwpId: '0'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-5'     initial BWP - 40MHZ
    ...    - cellBwpId: '1'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-44'    default dedicated BWP - 100MHZ
    ...    - cellBwpId: '2'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-50'    Power Saving BWP - 20MHZ
    ...  - NRCELL-2 - default config
    ...
    ...  == Postconditions ==
    ...  NRCELL-1 is not degraded and without alarms
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with 2 simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_19340;5G_RAN_OP_2624;5G_CP_ARC_ALG_10798;5G_CP_ARC_ALG_6948;
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...
    ...  == HISTORY ==
    ...     [30.05.2022] - TC Create
    ...     [02.06.2023] - TC passed with build SBTS00_ENB_9999_230601_000007

    No Operation
