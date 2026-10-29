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
...         [28.07.2023] - Create Test Suite
...         [28.08.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=891858)
...         [17.10.2023] - change TL type

Resource    resources/CB010544-common_keywords.robot
Resource    resources/CB010544_setup_and_teardowns.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_MP_AP_LO
...    SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    ute_ca=True    internal_mirroring=True

Suite Teardown    Run Suite Teardown

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_TDD_SANSA.lua
${SCF}=                   ${CURDIR}/../../../../../custom-config/Krakow/CB010544/scf_2AEQE_SANSA_ABIP.xml
${AP_XML}=                ${CURDIR}/../../../../../custom-config/Krakow/CB010544/iphy_2AEQE_gscn_7853.xml
${SKIP_COUNTERS}=         ${FALSE}
${rtpm}=                  ${TRUE}

*** Test Cases ***
CB010544-A-A2_1 UE Attach - RACH inside PS BWP
    [Tags]    A-A2_1    SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Test case purpose is to confirm legacy behaviour during attach of supporting and not supporting PS-BWP UEs
    ...  when RACH is configured inside Power Saving BWP.
    ...
    ...  Proper configuration (RRC Reconfiguration message) of UE supporting Power Saving BWP capabilities after ICS:
    ...  BWP-Downlink
    ...   bwp-Id: 2
    ...    bwp-Common
    ...    bwp-Dedicated
    ...  BWP-Uplink
    ...   bwp-Id: 2
    ...    bwp-Common with RACH configuration
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
    ...  - NRCELL-1.actInitialBWPFlexibility = false
    ...  - NRCELL-1.nrarfcn = 636666
    ...  - NRCELL-1.gscnOrSsPbchArfcn = 7853
    ...  - NRCELL-1.msg1FrequencyStart = 26
    ...   (NRCELL-1.msg1frequencyStart is inside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-50 (RACH is inside the PS-BWP, <51))
    ...  - NRCELL-1.ueConnectionEstablishmentMode = useDedicatedBwp
    ...  - NRCELL-1.cellBwpList =
    ...    - cellBwpId: '0'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-5'     initial BWP - 40MHZ, BWP#0
    ...    - cellBwpId: '1'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-44'    default dedicated BWP - 100MHZ, BWP#1
    ...    - cellBwpId: '2'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-50'    Power Saving BWP - 20MHZ, BWP#2
    ...  - NRCELL-2 - default config
    ...
    ...  - NRBTS-1.actMultipleDedicatedBWPs = false
    ...
    ...  - NRPMRNL-1.nrRTPMMeasurementsList = [55351 NR Dynamic BWP, 55305 NR Beamforming]
    ...  - NRPMRNL-1.miNrBeamforming = 5min
    ...  - NRPMRNL-1.miNrPowerSavingBwp = 5min
    ...
    ...  - UEs 1-9 are supporting PS-BWP
    ...  - UEs 10-12 are not supporting PS-BWP (only bwp-SameNumerology IE set)
    ...  - UEs 13-15 are not supporting PS-BWP (only bwp-SwitchingDelay IE set)
    ...
    ...  == POSTCONDITION ==
    ...  NRCELL-1 is enabled, not degraded and without alarms
    ...  UEs are able to attach to NRCELL-1 with or without PS-BWP configured according to their capabilities
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
    ...  REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_19340;CB_FIM_35535;
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
    ...  [28.07.2023] - Create Test Suite
    ...  [28.08.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=891858)

    [Setup]  Prepare test environment CB010544-A-A2_1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Attach UE1 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP with RACH setup in PS-BWP
    Attach UE10 to gNB2 NRCELL-1 and verify that UE is configured only with large BWP

    Run DL traffic to switch to dedicated BWP then run smaller traffic to switch to PS-BWP for UE1

    Run 50Mbps DL traffic on UE10 PDU1 QFI1 and wait 5 seconds
    Verify 50Mbps DL traffic on PDU-1 QFI-1 for UE10

    Detach and kill UE1
    Detach and kill UE10

    Activate CB010544 feature flag in NRCELL-1

    Attach UE2 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP with RACH setup in PS-BWP
    Attach UE3 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP with RACH setup in PS-BWP
    Attach UE13 to gNB2 NRCELL-1 and verify that UE is configured only with large BWP

    Run DL traffic to switch to dedicated BWP then run smaller traffic to switch to PS-BWP for UE2
    Run UL traffic to switch to dedicated BWP then run smaller traffic to switch to PS-BWP for UE3

    Run 50Mbps DL traffic on UE13 PDU1 QFI1 and wait 5 seconds
    Verify 50Mbps DL traffic on PDU-1 QFI-1 for UE13

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Check RTPM counter: NRCELL-1 MAX_UE_ACTIVE_PWR_SAVING_BWP (M55351C00001) is equal 2

    [Teardown]  Basic cleanup


CB010544-A-A2_2 UE Attach - RACH outside PS BWP inside Initial BWP
    [Tags]    A-A2_2    SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Test case purpose is to confirm behaviour during UE attach when RACH is configured outside Power Saving BWP.
    ...  UEs supporting PS-BWP are configured with PS-BWP without RACH config during First RRC Reconfiguration.
    ...  UEs not supporting PS-BWP are not configured with PS-BWP.
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
    ...  - NRCELL-2 - default config
    ...
    ...  - NRBTS-1.actMultipleDedicatedBWPs = false
    ...
    ...  - NRPMRNL-1.nrRTPMMeasurementsList = [55351 NR Dynamic BWP, 55305 NR Beamforming]
    ...  - NRPMRNL-1.miNrBeamforming = 5min
    ...  - NRPMRNL-1.miNrPowerSavingBwp = 5min
    ...
    ...  - UEs 1-9 are supporting PS-BWP
    ...  - UEs 10-12 are not supporting PS-BWP (only bwp-SameNumerology IE set)
    ...  - UEs 13-15 are not supporting PS-BWP (only bwp-SwitchingDelay IE set)
    ...
    ...  == POSTCONDITION ==
    ...  NRCELL-1 is enabled, not degraded and without alarms
    ...  UEs are able to attach to NRCELL-1 with or without PS-BWP configured according to their capabilities
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
    ...  [28.07.2023] - Create Test Suite
    ...  [28.08.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=891858)

    [Setup]  Prepare test environment CB010544-A-A2_2

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Attach UE1 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP and RACH is not present in PS-BWP
    Attach UE10 to gNB2 NRCELL-1 and verify that UE is configured only with large BWP

    Run DL traffic to switch to dedicated BWP then run smaller traffic to switch to PS-BWP for UE1

    Run 50Mbps DL traffic on UE10 PDU1 QFI1 and wait 5 seconds
    Verify 50Mbps DL traffic on PDU-1 QFI-1 for UE10

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Check RTPM counter: NRCELL-1 MAX_UE_ACTIVE_PWR_SAVING_BWP (M55351C00001) is equal 1

    [Teardown]  Basic cleanup


CB010544-A-A3_1 UE HO - RACH inside PS BWP
    [Tags]    A-A3_1    SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Test case purpose is to verify behavior of BWP configurations during Intra-gNB and Inter-gNB HO scenarios when RACH is present in the
    ...  Power saving BWP. UEs supporting PS-BWP are configured with PS-BWP during HO.
    ...  UEs not supporting PS-BWP are not configured with PS-BWP.
    ...
    ...  Proper configuration (RRC Reconfiguration message) of UE supporting Power Saving BWP capabilities after HO:
    ...  BWP-Downlink
    ...   bwp-Id: 2
    ...    bwp-Common
    ...    bwp-Dedicated
    ...  BWP-Uplink
    ...   bwp-Id: 2
    ...    bwp-Common with RACH configuration
    ...    bwp-Dedicated
    ...
    ...  == PRECONDITION ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO with simulated 2x AEQE
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - NR cells are up and connected to AMF1
    ...  - gNB2 up and running with 2 SA TDD cells (band n78)
    ...  - gNB3 - simulated, up and running with 1 SA TDD cell (band n78)
    ...  - NRCELL-1.chBw = 100Mz
    ...  - NRCELL-1.cellTechnology = TDD
    ...  - NRCELL-1.actPowerSavingBWP = true
    ...  - NRCELL-1.actInitialBWPFlexibility = false
    ...  - NRCELL-1.nrarfcn = 636666
    ...  - NRCELL-1.gscnOrSsPbchArfcn = 7853
    ...  - NRCELL-1.msg1FrequencyStart = 26
    ...   (NRCELL-1.msg1frequencyStart is inside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-50 (RACH is inside the PS-BWP, <51))
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
    ...  - NRCELL-2.actInitialBWPFlexibility = false
    ...  - NRCELL-2.nrarfcn = 636666
    ...  - NRCELL-2.gscnOrSsPbchArfcn = 7853
    ...  - NRCELL-2.msg1FrequencyStart = 26
    ...   (NRCELL-2.msg1frequencyStart is inside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-50 (RACH is inside the PS-BWP, <51))
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
    ...  - NRBTS-1.dlBufferEmptyRatioFromPsBwp = 80 - to be adjusted during test
    ...  - NRBTS-1.dlBufferEmptyRatioToPsBwp = 90 - to be adjusted during test
    ...  - NRBTS-1.dlRateThresholdFromPsBwp = 35 - to be adjusted during test
    ...  - NRBTS-1.dlRateThresholdToPsBwp = 30 - to be adjusted during test
    ...
    ...  - Proper relations (MO NRREL) created: NRCELL-1 -> NRCELL-2, NRCELL-2 -> NRCELL-1, NRCELL-1 -> SIM CELL 1 - ???
    ...  - Proper relation between gNB3 (sim) and gNB2 (real)
    ...
    ...  - NRPMRNL-1.nrRTPMMeasurementsList = [55351 NR Dynamic BWP, 55305 NR Beamforming]
    ...  - NRPMRNL-1.miNrBeamforming = 5min
    ...  - NRPMRNL-1.miNrPowerSavingBwp = 5min
    ...
    ...  - UEs 1-9 are supporting PS-BWP
    ...  - UEs 10-12 are not supporting PS-BWP (only bwp-SameNumerology IE set)
    ...  - UEs 13-15 are not supporting PS-BWP (only bwp-SwitchingDelay IE set)
    ...  - All UEs are starting on NRCELL-1 or Cell 1 in simulated gNB3
    ...
    ...  == POSTCONDITION ==
    ...  NRCELL-1 and NRCELL-2 are enabled, not degraded and without alarms
    ...  UEs are able to attach to NRCELL-1 and NRCELL-2 with or without PS-BWP configured according to their capabilities
    ...  UEs successfully performs intra and inter gNB handovers
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
    ...  REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_19340;CB_FIM_35535;
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
    ...    Alternate scenarios:
    ...     - UE Access through intra-gnb HO (instead of SA Initial access) with UE in the larger BWP in the source cell.
    ...     - UE Access through intra-gnb HO (instead of SA Initial access) with UE in the power saving BWP in the source cell.
    ...     - inter-gnb HO with feature 5GC000937 & CB010544 not activated in the source gnb and activated on the target gnb,
    ...       the UE must be configured with both large and power saving BWP in the target gnb
    ...
    ...  == HISTORY ==
    ...  [28.07.2023] - Create Test Suite
    ...  [28.08.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=891858)

    [Setup]  Prepare test environment CB010544-A-A3_1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    # A - Intra gNB HO Cell-1 -> Cell-2, UE supporting/not supporting PS-BWP, UE is on large BWP#1
    Attach UE1 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP with RACH setup in PS-BWP
    Attach UE10 to gNB2 NRCELL-1 and verify that UE is configured only with large BWP

    # Run big traffic so UE is on large BWP#1
    Run bigger UL traffic on UE1 and wait 0 seconds and verify change to dedicated BWP
    Run 10Mbps DL traffic on UE10 PDU1 QFI1 and wait 5 seconds
    Verify 5Mbps UL traffic on PDU-1 QFI-1 for UE1
    Verify 10Mbps DL traffic on PDU-1 QFI-1 for UE10

    Perform intra-gNB HO from gNB2 cell1 to cell2 for UE1 and verify that UE is configured with PS-BWP with RACH setup in PS-BWP
    Perform intra-gNB HO from gNB2 cell1 to cell2 for UE10 and verify that UE is configured only with large BWP

    Verify 5Mbps UL traffic on PDU-1 QFI-1 for UE1
    Verify 10Mbps DL traffic on PDU-1 QFI-1 for UE10

    Run small UL traffic on UE1 and wait 0 seconds and verify change to PS-BWP

    # B - Intra gNB HO Cell-1 -> Cell-2, UE supporting PS-BWP, UE is on PS BWP#2
    Attach UE2 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP with RACH setup in PS-BWP

    # Run small traffic so UE is on PS BWP#2
    Run DL traffic to switch to dedicated BWP then run smaller traffic to switch to PS-BWP for UE2
    Perform intra-gNB HO from gNB2 cell1 to cell2 for UE2 and verify that UE is configured with PS-BWP with RACH setup in PS-BWP

    Verify 100kbps DL traffic on PDU-1 QFI-1 for UE2

    # C - Inter gNB HO, sim gNB Cell-1 -> real gNB Cell-1, UE supporting/not supporting PS-BWP
    Attach UE3 to simulated gNB3 CELL-1 with inter gNB Handover setup and PDU session set
    Run 10Mbps DL traffic on UE3 PDU1 QFI1 and wait 5 seconds
    Verify 10Mbps DL traffic on PDU-1 QFI-1 for UE3

    Perform XN HO from gNB3 cell1 to gNB2 cell1 for UE3 and verify that UE is configured with PS-BWP with RACH setup in PS-BWP
    Verify 10Mbps DL traffic on PDU-1 QFI-1 for UE3
    Run small DL traffic on UE3 and wait 0 seconds and verify change to PS-BWP

    Attach UE11 to simulated gNB3 CELL-1 with inter gNB Handover setup and PDU session set
    Run 10Mbps UL traffic on UE11 PDU1 QFI1 and wait 5 seconds
    Verify 10Mbps UL traffic on PDU-1 QFI-1 for UE11

    Perform XN HO from gNB3 cell1 to gNB2 cell1 for UE11 and verify that UE is configured only with large BWP
    Verify 10Mbps UL traffic on PDU-1 QFI-1 for UE11


    Activate CB010544 feature flag in NRCELL-1

    # D - Intra gNB HO Cell-1 -> Cell-2, UE supporting/not supporting PS-BWP, UE is on large BWP#1
    Attach UE4 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP with RACH setup in PS-BWP
    Attach UE12 to gNB2 NRCELL-1 and verify that UE is configured only with large BWP

    # Run big traffic so UE is on large BWP#1
    Run bigger DL traffic on UE4 and wait 0 seconds and verify change to dedicated BWP
    Run 10Mbps DL traffic on UE12 PDU1 QFI1 and wait 5 seconds
    Verify 5Mbps DL traffic on PDU-1 QFI-1 for UE4
    Verify 10Mbps DL traffic on PDU-1 QFI-1 for UE12

    Perform intra-gNB HO from gNB2 cell1 to cell2 for UE4 and verify that UE is configured with PS-BWP with RACH setup in PS-BWP
    Perform intra-gNB HO from gNB2 cell1 to cell2 for UE12 and verify that UE is configured only with large BWP

    Verify 5Mbps DL traffic on PDU-1 QFI-1 for UE4
    Verify 10Mbps DL traffic on PDU-1 QFI-1 for UE12

    # E - Intra gNB HO Cell-2 -> Cell-1, UE supporting/not supporting PS-BWP  is on large BWP#1
    Perform intra-gNB HO from gNB2 cell2 to cell1 for UE4 and verify that UE is configured with PS-BWP with RACH setup in PS-BWP
    Perform intra-gNB HO from gNB2 cell2 to cell1 for UE12 and verify that UE is configured only with large BWP

    Verify 5Mbps DL traffic on PDU-1 QFI-1 for UE4
    Verify 10Mbps DL traffic on PDU-1 QFI-1 for UE12
    Run small DL traffic on UE4 and wait 0 seconds and verify change to PS-BWP

    # F - Intra gNB HO Cell-1 -> Cell-2, UE supporting, UE is on PS BWP#2
    Attach UE5 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP with RACH setup in PS-BWP

    # Run small traffic so UE is on PS BWP#2
    Run UL traffic to switch to dedicated BWP then run smaller traffic to switch to PS-BWP for UE5
    Verify 100kbps UL traffic on PDU-1 QFI-1 for UE5

    Perform intra-gNB HO from gNB2 cell1 to cell2 for UE5 and verify that UE is configured with PS-BWP with RACH setup in PS-BWP

    Verify 100kbps UL traffic on PDU-1 QFI-1 for UE5

    # G - Inter gNB HO, sim gNB Cell-1 -> real gNB Cell-1, UE supporting/not supporting PS-BWP (UE supporting PS-BWP goes to BWP#2 on real NRCELL-1)
    Attach UE6 to simulated gNB3 CELL-1 with inter gNB Handover setup and PDU session set
    Run 100kbps DL traffic on UE6 PDU1 QFI1 and wait 5 seconds
    Verify 100kbps DL traffic on PDU-1 QFI-1 for UE6

    Perform XN HO from gNB3 cell1 to gNB2 cell1 for UE6 and verify that UE is configured with PS-BWP with RACH setup in PS-BWP
    Verify 100kbps DL traffic on PDU-1 QFI-1 for UE6
    Run DL traffic to switch to dedicated BWP then run smaller traffic to switch to PS-BWP for UE6

    Attach UE13 to simulated gNB3 CELL-1 with inter gNB Handover setup and PDU session set

    Run 100kbps UL traffic on UE13 PDU1 QFI1 and wait 5 seconds
    Verify 100kbps UL traffic on PDU-1 QFI-1 for UE13

    Perform XN HO from gNB3 cell1 to gNB2 cell1 for UE13 and verify that UE is configured only with large BWP
    Verify 100kbps UL traffic on PDU-1 QFI-1 for UE13

    Execute egate command    cmd=ue_disp

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Check RTPM counter: NRCELL-1 MAX_UE_ACTIVE_PWR_SAVING_BWP (M55351C00001) is equal 2
    ...  Check RTPM counter: NRCELL-2 MAX_UE_ACTIVE_PWR_SAVING_BWP (M55351C00001) is equal 3

    [Teardown]  Basic cleanup


CB010544-A-A3_2 UE HO - RACH outside PS BWP
    [Tags]    A-A3_2    CONFIGS_Krakow/CB010544/2AEQE.yaml
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Test case purpose is to verify behavior of BWP configurations during Intra-gNB and Inter-gNB HO scenarios when RACH is present in the
    ...  Power saving BWP. UEs supporting PS-BWP are configured with PS-BWP without RACH config during HO.
    ...  UEs not supporting PS-BWP are not configured with PS-BWP.
    ...
    ...  Proper configuration (RRC Reconfiguration message) of UE supporting Power Saving BWP capabilities after HO:
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
    ...  - gNB3 - simulated, up and running with 1 SA TDD cell (band n78)
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
    ...  - NRCELL-2.actInitialBWPFlexibility = false
    ...  - NRCELL-2.nrarfcn = 636666
    ...  - NRCELL-2.gscnOrSsPbchArfcn = 7853
    ...  - NRCELL-2.msg1FrequencyStart = 26
    ...   (NRCELL-2.msg1frequencyStart is inside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-50 (RACH is inside the PS-BWP, <51))
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
    ...  - NRBTS-1.dlBufferEmptyRatioFromPsBwp = 80 - to be adjusted during test
    ...  - NRBTS-1.dlBufferEmptyRatioToPsBwp = 90 - to be adjusted during test
    ...  - NRBTS-1.dlRateThresholdFromPsBwp = 35 - to be adjusted during test
    ...  - NRBTS-1.dlRateThresholdToPsBwp = 30 - to be adjusted during test
    ...
    ...  - Proper relations (MO NRREL) created: NRCELL-1 -> NRCELL-2, NRCELL-2 -> NRCELL-1, NRCELL-1 -> SIM CELL 1 - ???
    ...  - Proper relation between gNB3 (sim) and gNB2 (real)
    ...
    ...  - NRPMRNL-1.nrRTPMMeasurementsList = [55351 NR Dynamic BWP, 55305 NR Beamforming]
    ...  - NRPMRNL-1.miNrBeamforming = 5min
    ...  - NRPMRNL-1.miNrPowerSavingBwp = 5min
    ...
    ...  - UEs 1-9 are supporting PS-BWP
    ...  - UEs 10-12 are not supporting PS-BWP (only bwp-SameNumerology IE set)
    ...  - UEs 13-15 are not supporting PS-BWP (only bwp-SwitchingDelay IE set)
    ...  - All UEs are starting on NRCELL-1 or Cell 1 in simulated gNB3
    ...
    ...  == POSTCONDITION ==
    ...  NRCELL-1 and NRCELL-2 are enabled, not degraded and without alarms
    ...  UEs are able to attach to NRCELL-1 and NRCELL-2 with or without PS-BWP configured according to their capabilities
    ...  UEs successfully performs intra and inter gNB handovers
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with 2 simulated AEQE radio modules
    ...  - UE configured in SA, TDD,
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_19340;CB_FIM_35535;5G_L3_16407;5G_L3_16949;5G_CP_ARC_ALG_10798
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
    ...    Alternate scenarios:
    ...     - UE Access through intra-gnb HO (instead of SA Initial access) with UE in the larger BWP in the source cell.
    ...     - UE Access through intra-gnb HO (instead of SA Initial access) with UE in the power saving BWP in the source cell.
    ...     - inter-gnb HO with feature 5GC000937 & CB010544 not activated in the source gnb and activated on the target gnb,
    ...       the UE must be configured with both large and power saving BWP in the target gnb
    ...
    ...  == HISTORY ==
    ...  [28.07.2023] - Create Test Suite
    ...  [28.08.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=891858)

    [Setup]  Prepare test environment CB010544-A-A3_2

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    # A - Intra gNB HO Cell-1 -> Cell-2, UE supporting/not supporting PS-BWP is on large BWP#1
    Attach UE1 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP and RACH is not present in PS-BWP
    Attach UE10 to gNB2 NRCELL-1 and verify that UE is configured only with large BWP

    Run bigger UL traffic on UE1 and wait 0 seconds and verify change to dedicated BWP
    Run 10Mbps DL traffic on UE10 PDU1 QFI1 and wait 5 seconds
    Verify 5Mbps UL traffic on PDU-1 QFI-1 for UE1
    Verify 10Mbps DL traffic on PDU-1 QFI-1 for UE10

    Perform intra-gNB HO from gNB2 cell1 to cell2 for UE1 and verify that UE is configured with PS-BWP with RACH setup in PS-BWP
    Perform intra-gNB HO from gNB2 cell1 to cell2 for UE10 and verify that UE is configured only with large BWP

    Verify 5Mbps UL traffic on PDU-1 QFI-1 for UE1
    Verify 10Mbps DL traffic on PDU-1 QFI-1 for UE10

    # B - Intra gNB HO Cell-2 -> Cell-1, UE supporting/not supporting PS-BWP is on large BWP#1
    Perform intra-gNB HO from gNB2 cell2 to cell1 for UE1 and verify that UE is configured with PS-BWP with RACH release in PS-BWP
    Perform intra-gNB HO from gNB2 cell2 to cell1 for UE10 and verify that UE is configured only with large BWP

    Verify 5Mbps UL traffic on PDU-1 QFI-1 for UE1
    Verify 10Mbps DL traffic on PDU-1 QFI-1 for UE10

    Run small UL traffic on UE1 and wait 0 seconds and verify change to PS-BWP

    # C - Intra gNB HO Cell-1 -> Cell-2, UE supporting PS-BWP is on PS BWP#2
    Attach UE2 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP and RACH is not present in PS-BWP

    Run DL traffic to switch to dedicated BWP then run smaller traffic to switch to PS-BWP for UE2
    Perform intra-gNB HO from gNB2 cell1 to cell2 for UE2 and verify that UE is configured with PS-BWP with RACH setup in PS-BWP
    Verify 100kbps DL traffic on PDU-1 QFI-1 for UE2

    # D - Intra gNB HO Cell-2 -> Cell-1, UE supporting PS-BWP is on PS BWP#2
    Perform intra-gNB HO from gNB2 cell2 to cell1 for UE2 and verify that UE is configured with PS-BWP with RACH release in PS-BWP
    Verify 100kbps DL traffic on PDU-1 QFI-1 for UE2

    # E - Inter gNB HO, sim gNB Cell-1 -> real gNB Cell-1, UE supporting/not supporting PS-BWP
    Attach UE3 to simulated gNB3 CELL-1 with inter gNB Handover setup and PDU session set
    Run 10Mbps DL traffic on UE3 PDU1 QFI1 and wait 5 seconds
    Verify 10Mbps DL traffic on PDU-1 QFI-1 for UE3

    Perform XN HO from gNB3 cell1 to gNB2 cell1 for UE3 and verify that UE is configured with PS-BWP and RACH is not present in PS-BWP
    Verify 10Mbps DL traffic on PDU-1 QFI-1 for UE3
    Run small DL traffic on UE3 and wait 0 seconds and verify change to PS-BWP

    Attach UE11 to simulated gNB3 CELL-1 with inter gNB Handover setup and PDU session set
    Run 10Mbps UL traffic on UE11 PDU1 QFI1 and wait 5 seconds
    Verify 10Mbps UL traffic on PDU-1 QFI-1 for UE11

    Perform XN HO from gNB3 cell1 to gNB2 cell1 for UE11 and verify that UE is configured only with large BWP
    Verify 10Mbps UL traffic on PDU-1 QFI-1 for UE11


    # Activate CB010544 feature on NRCELL-2, move RACH outside PS-BWP in NRCELL-2
    Change NRCELL-2.actInitialBWPFlexibility to True and NRCELL-2.msg1FrequencyStart to 60


    # F - Intra gNB HO Cell-1 -> Cell-2 with 1 UE supporting PS-BWP, UE is on large BWP#1
    Attach UE4 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP and RACH is not present in PS-BWP
    Run bigger DL traffic on UE4 and wait 5 seconds and verify change to dedicated BWP
    Verify 5Mbps DL traffic on PDU-1 QFI-1 for UE4

    Perform intra-gNB HO from gNB2 cell1 to cell2 for UE4 and verify that UE is configured with PS-BWP and RACH is not present in PS-BWP
    Verify 5Mbps DL traffic on PDU-1 QFI-1 for UE4
    Run small DL traffic on UE4 and wait 0 seconds and verify change to PS-BWP

    # G - Intra gNB HO  Cell-1 -> Cell-2 with 2 UEs supporting PS-BWP, UEs are on PS BWP#2
    Attach UE5 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP and RACH is not present in PS-BWP
    Attach UE6 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP and RACH is not present in PS-BWP

    Run DL traffic to switch to dedicated BWP then run smaller traffic to switch to PS-BWP for UE5
    Run DL traffic to switch to dedicated BWP then run smaller traffic to switch to PS-BWP for UE6

    Perform intra-gNB HO from gNB2 cell1 to cell2 for UE5 and verify that UE is configured with PS-BWP and RACH is not present in PS-BWP
    Perform intra-gNB HO from gNB2 cell1 to cell2 for UE6 and verify that UE is configured with PS-BWP and RACH is not present in PS-BWP

    Verify 100kbps DL traffic on PDU-1 QFI-1 for UE5
    Verify 100kbps DL traffic on PDU-1 QFI-1 for UE6

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Check RTPM counter: NRCELL-1 MAX_UE_ACTIVE_PWR_SAVING_BWP (M55351C00001) is equal 5
    ...  Check RTPM counter: NRCELL-2 MAX_UE_ACTIVE_PWR_SAVING_BWP (M55351C00001) is equal 3

    [Teardown]  Basic cleanup
