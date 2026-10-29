*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB010544: UE power saving: Full flexible setting of Initial BWP respect to PS BWP
...         The feature removes restrictions concerning the feature 5GC000937 allowing PRACH frequency position outside
...         the Power Saving Bandwidth Part (PS-BWP). With this feature, it will be possible to:
...         - Remove RACH configuration at RRC level for the PowerSaving BWP (PS-BWP)
...         - Take into account the implicit BWP switch in case of Beam Failure Recovery if UE active BWP has no RACH configuration (PS-BWP)
...         - Performs a new BWP switch procedure via RRC reconfiguration (different to nominal DCI-based BWP switch used by feature 5GC000937)
...           to the nominal BWP (BWP#1) after the BFR if the RACH config is not present
...         - CP will be able to detect automatically if the RACH config requires to be outside the dedicated BWP
...           (sending the BWP config without RACH-ConfigCommon to UP)
...         Concerning the new RRC reconfiguration for BWP switch:
...         - UP will be able to initiate a BWP switch after BFR depending on the BWP config if RACH-ConfigCommon is not present
...           in the dedicated BWP, send a RRC reconfiguration for BWP switch request to CP-RT
...         - CP will be able to send RRC reconfiguration when receiving the request from UP
...
...         The main purpose of the feature is to give the possibility to have the PRACH channel outside the PowerSaving BWP.
...         Other restrictions such as startPRB of BWPs remain the same (no change required).
...
...         Beam Failure Recovery (BFR) procedure if RACH is not configured in the active BWP :
...         Following the 3GPP 38.321 – chapter 5.15, if PRACH occasions are not configured for the active UL BWP,
...         the UE switches to its initialUplinkBWP.
...         When the UE detects a Beam Failure, a Random Access is initiated on the initial BWP.
...         UP checks if the CRNTI received in the MSG3 is known and that the active BWP has no RACH-Config.
...         In that case, UP sends the message "RRC reconfiguration for BWP switch request" to CP-RT with the target BWP-Id.
...         During this phase, UP uses the common channels (SRB1) in order to communicate with the UE.
...         CP-RT sends the "RRC Reconfiguration" with IE "firstActiveUplinkBWP-Id" and "firstActiveDownlinkBWP-Id" using the target BWP-Id to the UE.
...         CP-RT has to stop on-going RRC procedures if required during this phase.
...         CP-RT responds to UP with a "RRC Reconfiguration for BWP switch complete".
...         When UP detects the RRC Reconfiguration sent by CP-RT, a timer is initiated in order to consider the ending for BWP switch (as CNI-81991).
...
...         The feature doesn't apply to FDD.
...         The feature doesn't apply to FR2.
...         The feature doesn't apply to UEs in NSA mode.
...         (same as 5GC000937 feature)
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
...      == TESTING SCOPE ==
...         This Test Plan is covering feature part CB010544-A Full flexibility setting for initial BWP
...
...      == CONTACTS ==
...         - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...         - Konrad Bem <konrad.bem@nokia.com>
...
...      == MAINTAINER ==
...         - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...         - Konrad Bem <konrad.bem@nokia.com>
...
...      == REFERENCES ==
...         CB010544 CFAM - https://gates.nsn-net.net/view/00026c2b#o=0
...
...      == HISTORY ==
...         [04.10.2023] - Create Test Suite
...         [04.10.2023] - Review closed

Resource    resources/CB010544-common_keywords.robot
Resource    resources/CB010544_setup_and_teardowns.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO
...    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Suite Setup    Run setup    ute_ca=True    internal_mirroring=True

Suite Teardown    Run Suite Teardown

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_TDD_SANSA.lua
${SCF}=                   ${CURDIR}/../../../../../custom-config/Krakow/CB010544/scf_2AEQE_RRC_Inactive.xml
${AP_XML}=                ${CURDIR}/../../../../../custom-config/Krakow/CB010544/iphy_2AEQE_gscn_7853.xml
${SKIP_COUNTERS}=         ${FALSE}
${rtpm}=                  ${TRUE}

*** Test Cases ***
CB010544-Robustness_1 Setting various values of RACH frequency start
    [Tags]    Robustness_1    SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Test case purpose is to confirm behaviour during UE attach when RACH is configured outside Power Saving BWP and with various values of RACH
    ...  frequency start. Test verifies also that WEBEM online modification of NRBTS/NRCELL.msg1FrequencyStart parameter triggers inernal checks
    ...  and raises alarm for incorrect values.
    ...  UEs supporting PS-BWP are configured with PS-BWP without RACH config during First RRC Reconfiguration.
    ...
    ...  Proper configuration (RRC Reconfiguration message) of UE supporting Power Saving BWP capabilities after ICS:
    ...  BWP-Downlink
    ...   bwp-Id: 2
    ...    bwp-Common
    ...    bwp-Dedicated
    ...  BWP-Uplink
    ...   bwp-Id: 2
    ...    bwp-Common without RACH configuration
    ...    bwp-Dedicated
    ...
    ...  TEST DESCRIPTION
    ...
    ...  Set NRCELL-1.msg1FrequencyStart = 24
    ...  Check that NRCELL-1 is enabled and degraded
    ...  Alarm "7114 CELL SERVICE PROBLEM" with fault "7516 Incorrect cell parameter configuration" is present with cause: msg1FrequencyStart is
    ...  outside of the accepted range, long PUCCH case; Min limit of msg1FrequencyStart: 26; Max limit of msg1FrequencyStart: 90; Start CRB of
    ...  Initial BWP: 0; Size of Initial BWP [PRBs]: 106;
    ...
    ...  Set NRCELL-1.msg1FrequencyStart = 26
    ...  Check that NRCELL-1 is enabled and not degraded, there are no alarms
    ...  Attach UE1 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP and RACH is present in PS-BWP
    ...  Run small DL traffic and verify switch to PS-BWP for UE1
    ...  Deregister UE1
    ...
    ...  Set NRCELL-1.msg1FrequencyStart = 40
    ...  Check that NRCELL-1 is enabled and not degraded, there are no alarms
    ...  Attach UE1 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP and RACH is not present in PS-BWP
    ...  Run small DL traffic and verify switch to PS-BWP for UE1
    ...  Deregister UE1
    ...
    ...  Set NRCELL-1.msg1FrequencyStart = 90
    ...  Check that NRCELL-1 is enabled and not degraded, there are no alarms
    ...  Attach UE1 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP and RACH is not present in PS-BWP
    ...  Run small DL traffic and verify switch to PS-BWP for UE1
    ...  Deregister UE1
    ...
    ...  Set NRCELL-1.msg1FrequencyStart = 91
    ...  Check that NRCELL-1 is enabled and degraded
    ...  Alarm "7114 CELL SERVICE PROBLEM" with fault "7516 Incorrect cell parameter configuration" is present with cause: msg1FrequencyStart is
    ...  outside of the accepted range, long PUCCH case; Min limit of msg1FrequencyStart: 26; Max limit of msg1FrequencyStart: 90; Start CRB of
    ...  Initial BWP: 0; Size of Initial BWP [PRBs]: 106;
    ...
    ...  Set NRCELL-1.msg1FrequencyStart = 100
    ...  Check that NRCELL-1 is enabled and degraded
    ...  Alarm "7114 CELL SERVICE PROBLEM" with fault "7516 Incorrect cell parameter configuration" is present with cause: msg1FrequencyStart is
    ...  outside of the accepted range, long PUCCH case; Min limit of msg1FrequencyStart: 26; Max limit of msg1FrequencyStart: 90; Start CRB of
    ...  Initial BWP: 0; Size of Initial BWP [PRBs]: 106;
    ...
    ...  Set NRCELL-1.msg1FrequencyStart = 120
    ...  Check that NRCELL-1 is enabled and degraded
    ...  Alarm "7114 CELL SERVICE PROBLEM" with fault "7516 Incorrect cell parameter configuration" is present with cause: msg1FrequencyStart is
    ...  outside of the accepted range, long PUCCH case; Min limit of msg1FrequencyStart: 26; Max limit of msg1FrequencyStart: 90; Start CRB of
    ...  Initial BWP: 0; Size of Initial BWP [PRBs]: 106;
    ...
    ...  == PRECONDITION ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO with simulated 2x AEQE
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - NR cells are up and connected to AMF1
    ...  - gNB2 up and running with 2 SA TDD cells (band n78)
    ...  - NRCELL-1.chBw = 100Mz
    ...  - NRCELL-1.cellTechnology = TDD
    ...  - NRCELL-1.actPowerSavingBWP = true
    ...  - NRCELL-1.actInitialBWPFlexibility = true
    ...  - NRCELL-1.nrarfcn = 636666
    ...  - NRCELL-1.gscnOrSsPbchArfcn = 7853
    ...  - NRCELL-1.msg1FrequencyStart = 60
    ...   (NRCELL-1.msg1frequencyStart is outside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-50 (RACH is outside the PS-BWP, >51))
    ...   (NRCELL-1.msg1frequencyStart is inside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-5 (RACH is inside the initial BWP, <106))
    ...  - NRCELL-1.ueConnectionEstablishmentMode = useDedicatedBwp
    ...  - NRCELL-1.cellBwpList =
    ...    - cellBwpId: '0'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-5'     initial BWP - 40MHZ, BWP#0
    ...    - cellBwpId: '1'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-44'    default dedicated BWP - 100MHZ, BWP#1
    ...    - cellBwpId: '2'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-50'    Power Saving BWP - 20MHZ, BWP#2
    ...
    ...  - NRCELL-2.chBw = 100Mz
    ...  - NRCELL-2.cellTechnology = TDD
    ...  - NRCELL-2.actPowerSavingBWP = true
    ...  - NRCELL-2.actInitialBWPFlexibility = true
    ...  - NRCELL-2.nrarfcn = 636666
    ...  - NRCELL-2.gscnOrSsPbchArfcn = 7853
    ...  - NRCELL-2.msg1FrequencyStart = 60
    ...   (NRCELL-2.msg1frequencyStart is outside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-50 (RACH is outside the PS-BWP, >51))
    ...   (NRCELL-2.msg1frequencyStart is inside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-5 (RACH is inside the initial BWP, <106))
    ...  - NRCELL-2.ueConnectionEstablishmentMode = useDedicatedBwp
    ...  - NRCELL-2.cellBwpList =
    ...    - cellBwpId: '0'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-5'     initial BWP - 40MHZ, BWP#0
    ...    - cellBwpId: '1'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-44'    default dedicated BWP - 100MHZ, BWP#1
    ...    - cellBwpId: '2'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-50'    Power Saving BWP - 20MHZ, BWP#2
    ...
    ...  - NRBTS-1.actMultipleDedicatedBWPs = false
    ...
    ...  - NRPMRNL-1.nrRTPMMeasurementsList = [55351 NR Dynamic BWP, 55305 NR Beamforming]
    ...  - NRPMRNL-1.miNrBeamforming = 5min
    ...  - NRPMRNL-1.miNrPowerSavingBwp = 5min
    ...
    ...  - UEs 1-9 are supporting PS-BWP
    ...
    ...  == POSTCONDITION ==
    ...  NRCELL-1 and NRCELL-2 are enabled, not degraded and without alarms
    ...  UEs are able to attach to NRCELL-1 and NRCELL-2 without PS-BWP configured when configuration is correct
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with 2 simulated AEQE radio modules
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_19340;CB_FIM_35535;5G_L3_16407;5G_L3_16949;
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...  - Konrad Bem <konrad.bem@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...    - USCB010544-A#1 Single-UE Switch to power saving BWP and switch to initial BWP when RACH is not in the PS-BWP
    ...
    ...  == HISTORY ==
    ...  [04.10.2023] - Create Test Suite
    ...  [04.10.2023] - Review closed

    # Manual Test Description above
    No operation


CB010544-Robustness_2 Interaction with RRC Reestablishment and CB008255 RRC Inactive for various values of RACH frequency start outside PS-BWP
    [Tags]    Robustness_2
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Test case purpose is to confirm behaviour of CB010544 during interaction with RRC Reestablishment and CB008225 RRC Inactive.
    ...  UE attach when RACH is configured outside Power Saving BWP with various values of RACH frequency start set and procedures of
    ...  RRC Reestablishment and RRC Inactive are verified.
    ...  UEs supporting PS-BWP are configured with PS-BWP without RACH config during First RRC Reconfiguration.
    ...
    ...  Proper configuration (RRC Reconfiguration message) of UE supporting Power Saving BWP capabilities after ICS:
    ...  BWP-Downlink
    ...   bwp-Id: 2
    ...    bwp-Common
    ...    bwp-Dedicated
    ...  BWP-Uplink
    ...   bwp-Id: 2
    ...    bwp-Common without RACH configuration
    ...    bwp-Dedicated
    ...
    ...  == PRECONDITION ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO with simulated 2x AEQE
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - NR cells are up and connected to AMF1
    ...  - gNB2 up and running with 2 SA TDD cells (band n78)
    ...  - NRCELL-1.chBw = 100Mz
    ...  - NRCELL-1.cellTechnology = TDD
    ...  - NRCELL-1.actPowerSavingBWP = true
    ...  - NRCELL-1.actInitialBWPFlexibility = true
    ...  - NRCELL-1.nrarfcn = 636666
    ...  - NRCELL-1.gscnOrSsPbchArfcn = 7853
    ...  - NRCELL-1.msg1FrequencyStart = 60
    ...   (NRCELL-1.msg1frequencyStart is outside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-50 (RACH is outside the PS-BWP, >51))
    ...   (NRCELL-1.msg1frequencyStart is inside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-5 (RACH is inside the initial BWP, <106))
    ...  - NRCELL-1.ueConnectionEstablishmentMode = useDedicatedBwp
    ...  - NRCELL-1.cellBwpList =
    ...    - cellBwpId: '0'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-5'     initial BWP - 40MHZ, BWP#0
    ...    - cellBwpId: '1'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-44'    default dedicated BWP - 100MHZ, BWP#1
    ...    - cellBwpId: '2'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-50'    Power Saving BWP - 20MHZ, BWP#2
    ...
    ...  - NRCELL-2.chBw = 100Mz
    ...  - NRCELL-2.cellTechnology = TDD
    ...  - NRCELL-2.actPowerSavingBWP = true
    ...  - NRCELL-2.actInitialBWPFlexibility = true
    ...  - NRCELL-2.nrarfcn = 636666
    ...  - NRCELL-2.gscnOrSsPbchArfcn = 7853
    ...  - NRCELL-2.msg1FrequencyStart = 60
    ...   (NRCELL-2.msg1frequencyStart is outside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-50 (RACH is outside the PS-BWP, >51))
    ...   (NRCELL-2.msg1frequencyStart is inside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-5 (RACH is inside the initial BWP, <106))
    ...  - NRCELL-2.ueConnectionEstablishmentMode = useDedicatedBwp
    ...  - NRCELL-2.cellBwpList =
    ...    - cellBwpId: '0'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-5'     initial BWP - 40MHZ, BWP#0
    ...    - cellBwpId: '1'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-44'    default dedicated BWP - 100MHZ, BWP#1
    ...    - cellBwpId: '2'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-50'    Power Saving BWP - 20MHZ, BWP#2
    ...
    ...  - NRBTS-1.actMultipleDedicatedBWPs = false
    ...
    ...  - NRPMRNL-1.nrRTPMMeasurementsList = [55351 NR Dynamic BWP, 55305 NR Beamforming]
    ...  - NRPMRNL-1.miNrBeamforming = 5min
    ...  - NRPMRNL-1.miNrPowerSavingBwp = 5min
    ...
    ...  - UEs 1-9 are supporting PS-BWP
    ...
    ...  == POSTCONDITION ==
    ...  NRCELL-1 and NRCELL-2 are enabled, not degraded and without alarms
    ...  UEs are able to attach to NRCELL-1 and NRCELL-2 without PS-BWP configured when configuration is correct
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with 2 simulated AEQE radio modules
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_19340;CB_FIM_35535;5G_L3_16407;5G_L3_16949;
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...  - Konrad Bem <konrad.bem@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...    - USCB010544-A#1 Single-UE Switch to power saving BWP and switch to initial BWP when RACH is not in the PS-BWP
    ...
    ...  == HISTORY ==
    ...  [04.10.2023] - Create Test Suite
    ...  [04.10.2023] - Review closed

     [Setup]  Prepare test environment CB010544-Robustness_2

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Test msg1FreequencyStart value 45 in interaction with RRC Reestablishment and RRC Inactive
    Test msg1FreequencyStart value 51 in interaction with RRC Reestablishment and RRC Inactive
    Test msg1FreequencyStart value 60 in interaction with RRC Reestablishment and RRC Inactive
    Test msg1FreequencyStart value 90 in interaction with RRC Reestablishment and RRC Inactive

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Check RTPM counter: NRCELL-1 MAX_UE_ACTIVE_PWR_SAVING_BWP (M55351C00001) is equal 2

    [Teardown]  Basic cleanup
