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
...         [04.09.2023] - Create Test Suite
...         [11.09.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=893194)

Resource    resources/CB010544-common_keywords.robot
Resource    resources/CB010544_setup_and_teardowns.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO
...    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Suite Setup    Run setup    ute_ca=True    internal_mirroring=True

Suite Teardown    Run Suite Teardown

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_TDD_SANSA.lua
${SCF}=                   ${CURDIR}/../../../../../custom-config/Krakow/CB010544/scf_2AEQE_beamset_2.xml
${AP_XML}=                ${CURDIR}/../../../../../custom-config/Krakow/CB010544/iphy_2AEQE_gscn_7853.xml
${SKIP_COUNTERS}=         ${FALSE}
${rtpm}=                  ${TRUE}

*** Test Cases ***
CB010544-A-A4_1 single Beam Failure Recovery - RACH outside PS BWP inside Initial BWP
    [Tags]    A-A4_1
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Test case purpose is to confirm Beam failure recovery for a UE configured with both large and power saving BWP when the Flexibility setting
    ...  is necessary and RACH is not in the Power saving BWP.
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
    ...  - NRCELL-2.chBw = 100Mz
    ...  - NRCELL-2.cellTechnology = TDD
    ...  - NRCELL-2.actPowerSavingBWP = true
    ...  - NRCELL-2.actInitialBWPFlexibility = true
    ...  - NRCELL-2.nrarfcn = 636666
    ...  - NRCELL-2.gscnOrSsPbchArfcn = 7853
    ...  - NRCELL-2.msg1FrequencyStart = 36
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
    ...  BFR procedure is successfully finished, Transmission in DL and UL occur on target beam.
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
    ...  REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_19649;CB_FIM_35535;5G_CP_IF_NTW_10496;
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
    ...    - USCB010544-A#2 Beam failure recovery (BFR) via PRACH when UE on PS-BWP with no RACH configuration
    ...
    ...  == HISTORY ==
    ...  [04.09.2023] - Created TC
    ...  [11.09.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=893194)

    [Setup]  Prepare test environment CB010544-A-A4_1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Set Beam Control Testmode profiles for BFR on egate

    # A - RACH outside PS BWP
    Activate Beam Control Testmode on egate for UE1
    Beamforming (2 beams): Attach UE1 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP without RACH
    Run DL traffic to switch to dedicated BWP then run smaller traffic to switch to PS-BWP for UE1

    Trigger Beam Failure Recovery on egate for UE1 and expect RRC Reconfiguration
    Verify for UE1 that in RRCReconfiguration only spCellConfig with firstActiveDownlinkBWP-Id and firstActiveUplinkBWP-Id is present
    Verify for UE1 that F1AP UEContextModificationRequired contains Cause radioNetwork: action-desirable-for-radio-reasons
    Verify 100kbps DL traffic on PDU-1 QFI-1 for UE1

    Detach and kill UE1


    # B - RACH inside PS BWP, checking legacy, cell-2
    Activate Beam Control Testmode on egate for UE2
    Beamforming (2 beams): Attach UE2 to gNB2 NRCELL-2 and verify that UE is configured with PS-BWP with RACH
    Run DL traffic to switch to dedicated BWP then run smaller traffic to switch to PS-BWP for UE2

    Trigger Beam Failure Recovery on egate for UE2 with PS BWP and without RRC Reconfiguration
    Wait Until Keyword Succeeds    10s    2s    Verify 100kbps DL traffic on PDU-1 QFI-1 for UE2

    Detach and kill UE2

    # C - RACH outside PS BWP, UE not supporting PS BWP, cell-1
    Activate Beam Control Testmode on egate for UE10
    Beamforming (2 beams): Attach UE10 to gNB2 NRCELL-1 and verify that UE is configured only with large BWP

    Run 100kbps UL and DL traffic on UE10 PDU1 QFI1 and wait 5 seconds
    Verify 100kbps UL and DL traffic on PDU-1 QFI-1 for UE10

    Trigger Beam Failure Recovery on egate for UE10 without PS BWP and without RRC Reconfiguration
    Verify 100kbps UL and DL traffic on PDU-1 QFI-1 for UE10

    Detach and kill UE10

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Check RTPM counter: NRCELL-1 MAX_UE_ACTIVE_PWR_SAVING_BWP (M55351C00001) is equal 1
    ...  Check RTPM counter: NRCELL-2 MAX_UE_ACTIVE_PWR_SAVING_BWP (M55351C00001) is equal 1

    # This histogram indicates the distribution of the serving Beam ID (BI) which UE was using before beam recovery was started.
    ...  Check RTPM counter: NRCELL-1 BEAM_RECOVERY_BEAM_ID_0 (M55305C09001) is equal 2
    ...  Check RTPM counter: NRCELL-2 BEAM_RECOVERY_BEAM_ID_0 (M55305C09001) is equal 1

    #This histogram indicates the distribution of the serving Beam ID (BI) which UE was using before beam recovery was started for successful beam
    #recoveries.
    ...  Check RTPM counter: NRCELL-1 SUCC_BEAM_RECOVERY_BEAM_ID_0 (M55305C10001) is equal 2
    ...  Check RTPM counter: NRCELL-2 SUCC_BEAM_RECOVERY_BEAM_ID_0 (M55305C10001) is equal 1

    [Teardown]  Basic cleanup


CB010544-A-A4_2 sub-sequent Beam Failure Recovery - RACH outside PS BWP inside Initial BWP
    [Tags]    A-A4_2    SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Test case purpose is to confirm Beam failure recovery for a UE configured with both large and power saving BWP when the Flexibility setting
    ...  is necessary and RACH is not in the Power saving BWP.
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
    ...  - NRCELL-2.msg1FrequencyStart = 36
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
    ...  BFR procedure is successfully finished, Transmission in DL and UL occur on target beam.
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
    ...  REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_19649;CB_FIM_35535;5G_CP_IF_NTW_10496;
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
    ...    - USCB010544-A#2 Beam failure recovery (BFR) via PRACH when UE on PS-BWP with no RACH configuration
    ...     Alternate Scenario 1
    ...     If 5G-UE conducts another BFR during above procedure at any time by sending a Random Access Preamble on another target beam
    ...     in the same SUBCELLGRP, gNB stops old BFR and processes new one
    ...
    ...  == HISTORY ==
    ...  [04.09.2023] - Created TC
    ...  [11.09.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=893194)


    [Setup]  Prepare test environment CB010544-A-A4_2

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Set Beam Control Testmode profiles for BFR retrigger on egate

    Activate Beam Control Testmode on egate for UE1
    Beamforming (2 beams): Attach UE1 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP without RACH
    Run DL traffic to switch to dedicated BWP then run smaller traffic to switch to PS-BWP for UE1

    Trigger Beam Failure Recovery on egate for UE1 and expect RRC Reconfiguration
    Verify for UE1 that in RRCReconfiguration only spCellConfig with firstActiveDownlinkBWP-Id and firstActiveUplinkBWP-Id is present
    Verify for UE1 that F1AP UEContextModificationRequired contains Cause radioNetwork: action-desirable-for-radio-reasons
    Verify 100kbps DL traffic on PDU-1 QFI-1 for UE1

    Detach and kill UE1

    # Check in SYSLOG:
    # INF/.uplane/L2-PS/src/dl/sch/pre/rach/RaProcedure.cpp[359] handlePrachPreamble: ... beamId=1 2ndBeamId=0 nrCellIdentity=16385 subcellIndex=0
    # INF/.uplane/L2-PS/src/dl/sch/pre/rach/RaProcedure.cpp[359] handlePrachPreamble: ... beamId=2 2ndBeamId=1 nrCellIdentity=16385 subcellIndex=0
    # ERR/.uplane/L2-PS/src/ul/sch/pre/rach/RaProcedure.cpp[690] handleDuplicateMacCeCrnti: ... macCeCrnti has already ongoing procedure ...

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Check RTPM counter: NRCELL-1 MAX_UE_ACTIVE_PWR_SAVING_BWP (M55351C00001) is equal 1

    # This histogram indicates the distribution of the serving Beam ID (BI) which UE was using before beam recovery was started.
    ...  Check RTPM counter: NRCELL-1 BEAM_RECOVERY_BEAM_ID_0 (M55305C09001) is equal 1

    #This histogram indicates the distribution of the serving Beam ID (BI) which UE was using before beam recovery was started for successful beam
    #recoveries.
    ...  Check RTPM counter: NRCELL-1 SUCC_BEAM_RECOVERY_BEAM_ID_0 (M55305C10001) is equal 1

    [Teardown]  Basic cleanup
