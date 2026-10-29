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
...         This Test Plan is covering feature part CB010544-B Feature interaction handling for full flexibility setting for initial BWP
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
...      [05.09.2023] - Create Test Suite
...      [11.09.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=893194)

Resource    resources/CB010544-common_keywords.robot
Resource    resources/CB010544_setup_and_teardowns.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO
...    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Suite Setup    Run setup    ute_ca=True    internal_mirroring=True

Suite Teardown    Run Suite Teardown

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_n78_n77_CA_TDD_SANSA.lua
${SCF}=                   ${CURDIR}/../../../../../custom-config/Krakow/CB010544/scf_1AEQE_1AEQK_CA_SANSA_BWP_100F_88S_50PS_BF_2beamset.xml
${AP_XML}=                ${CURDIR}/../../../../../custom-config/Krakow/CB010544/iphy_1AEQE_1AEQK.xml
${SKIP_COUNTERS}=         ${FALSE}
${rtpm}=                  ${TRUE}

&{NRCELL_1_BWP}=    ID=1    SMALL_BW=80    LARGE_BW=100
&{NRCELL_2_BWP}=    ID=2    SMALL_BW=80    LARGE_BW=100

*** Test Cases ***
CB010544-B_1 Interaction with CB008541 - BFR for small BWP UE when RACH is outside PS BWP
    [Tags]    B_1
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Test case purpose is to confirm feature interaction when UE performs the BWP switch to PS-BWP with Smaller BWP configured
    ...  (feature CB007552 & CB008541) and when the Flexibility is necessary because the RACH is outside the PS-BWP with Beam failure recovery
    ...  for checking that the UE will be switched back to Smaller BWP.
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
    ...  - gNB2 up and running with 2 SA TDD cells, NRCELL-1 (band n78) and NRCELL-2 (band n77)
    ...  - NRCELL-1.chBw = 100Mz
    ...  - NRCELL-1.cellTechnology = TDD
    ...  - NRCELL-1.actPowerSavingBWP = true
    ...  - NRCELL-1.actInitialBWPFlexibility = true
    ...  - NRCELL-1.actEnhMultipleDedicatedBWPs  = true (feature CB008541)
    ...  - NRCELL-1.actMultipleDedicatedBWPs = true (feature CB007552)
    ...  - NRCELL-1.nrarfcn = 636666
    ...  - NRCELL-1.gscnOrSsPbchArfcn = 7853
    ...  - NRCELL-1.msg1FrequencyStart = 60
    ...   (NRCELL-1.msg1frequencyStart is outside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-50 (RACH is outside the PS-BWP, >51))
    ...   (NRCELL-1.msg1frequencyStart is inside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-5 (RACH is inside the initial BWP, <106))
    ...  - NRCELL-1.ueConnectionEstablishmentMode = useDedicatedBwp
    ...  - NRCELL-1.cellBwpList =
    ...    - cellBwpId: '0'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-6'     initial BWP - 80MHZ
    ...    - cellBwpId: '1'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-100'    default dedicated BWP - 100MHZ
    ...    - cellBwpId: '2'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-50'    Power Saving BWP - 20MHZ
    ...    - cellBwpId: '3'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-88'    small dedicated BWP - 80MHZ
    ...
    ...  - NRCELL-2 - default config
    ...
    ...  - NRPMRNL-1.nrRTPMMeasurementsList = [55351 NR Dynamic BWP, 55305 NR Beamforming]
    ...  - NRPMRNL-1.miNrBeamforming = 5min
    ...  - NRPMRNL-1.miNrPowerSavingBwp = 5min
    ...
    ...  - UEs 1-9 are supporting PS-BWP with large BWP 100MHz
    ...  - UEs 10-12 are not supporting PS-BWP (only bwp-SameNumerology IE set)
    ...  - UEs 13-15 are not supporting PS-BWP (only bwp-SwitchingDelay IE set)
    ...  - UEs 16-20 are supporting PS-BWP with small BWP 80MHz
    ...
    ...  == POSTCONDITION ==
    ...  NRCELL-1 is enabled, not degraded and without alarms
    ...  BFR procedure is successfully finished, Transmission in DL occur on target beam.
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated 1x AEQE (band n78) and 1x AEQK (band n77) radio modules
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_19348;CB_FIM_35535;CB_FIM_39047
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
    ...    - USCB010544-B#1 CB008541 interaction : PS-BWP switch with Smaller BWP when RACH is not in PS-BWP (with Alternate scenario)
    ...
    ...  == HISTORY ==
    ...  [05.09.2023] - Create Test Suite
    ...  [11.09.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=893194)

    [Setup]  Prepare test environment CB010544-B_1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Set Beam Control Testmode profiles for BFR on egate

    Beamforming (2 beams): Attach UE16 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP without RACH
    Verify that UE16 is configured with small BWP profile after ICS to NRCELL-1
    Activate Beam Control Testmode on egate for UE16

    # Run small traffic so UE is on PS BWP#2
    Run DL traffic to switch to dedicated BWP then run smaller traffic to switch to PS-BWP for UE16

    Trigger Beam Failure Recovery on egate for UE16 and expect RRC Reconfiguration
    Verify that UE16 is configured with small BWP profile in RRC Reconfiguration after BFR at NRCELL-1

    Wait Until Keyword Succeeds    10s    2s    Verify 100kbps DL traffic on PDU-1 QFI-1 for UE16


    #Alternate scenario
    Beamforming (2 beams): Attach UE17 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP without RACH
    Verify that UE17 is configured with small BWP profile after ICS to NRCELL-1
    Activate Beam Control Testmode on egate for UE17

    # Run small traffic so UE is on PS BWP#1
    Run bigger DL traffic on UE17 and wait 5 seconds and verify change to dedicated BWP

    Trigger Beam Failure Recovery on egate for UE17 without PS BWP and without RRC Reconfiguration

    Wait Until Keyword Succeeds    10s    2s    Verify 5Mbps DL traffic on PDU-1 QFI-1 for UE17


    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Check RTPM counter: NRCELL-1 MAX_UE_ACTIVE_PWR_SAVING_BWP (M55351C00001) is equal 2

    # This histogram indicates the distribution of the serving Beam ID (BI) which UE was using before beam recovery was started.
    ...  Check RTPM counter: NRCELL-1 BEAM_RECOVERY_BEAM_ID_0 (M55305C09001) is equal 2

    #This histogram indicates the distribution of the serving Beam ID (BI) which UE was using before beam recovery was started for successful beam
    #recoveries.
    ...  Check RTPM counter: NRCELL-1 SUCC_BEAM_RECOVERY_BEAM_ID_0 (M55305C10001) is equal 2

    [Teardown]  Basic cleanup


CB010544-B_2 Interaction with CB008541 - BFR for small BWP UE in CA when RACH is outside PS BWP
    [Tags]    B_2    SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Test case purpose is to check if interaction with CB008541 works properly when PCell and SCell use a Smaller BWP.
    ...  UE performs the BWP switch to PS-BWP with Smaller BWP configured in the PCell and the SCell when the Flexibility is necessary because
    ...  the RACH is outside the PS-BWP with Beam failure recovery for checking that the UE will be back to the PowerSaving BWP.
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
    ...  - gNB2 classical - real hardware - ASIL + ABIO with simulated 1x AEQE and 1x AEQK
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - NR cells are up and connected to AMF1
    ...  - gNB2 up and running with 2 SA TDD cells, NRCELL-1 (band n78) acts as PCell and NRCELL-2 (band n77) acts as SCell
    ...  - NRCELL-1.chBw = 100Mz
    ...  - NRCELL-1.cellTechnology = TDD
    ...  - NRCELL-1.actPowerSavingBWP = true
    ...  - NRCELL-1.actInitialBWPFlexibility = true
    ...  - NRCELL-1.actEnhMultipleDedicatedBWPs  = true (feature CB008541)
    ...  - NRCELL-1.actMultipleDedicatedBWPs = true (feature CB007552)
    ...  - NRCELL-1.allowUnsuppBcOrBcs = 2 "accept unknown BCSs"
    ...  - NRCELL-1.nrarfcn = 636666
    ...  - NRCELL-1.gscnOrSsPbchArfcn = 7853
    ...  - NRCELL-1.msg1FrequencyStart = 60
    ...   (NRCELL-1.msg1frequencyStart is outside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-50 (RACH is outside the PS-BWP, >51))
    ...   (NRCELL-1.msg1frequencyStart is inside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-5 (RACH is inside the initial BWP, <106))
    ...  - NRCELL-1.ueConnectionEstablishmentMode = useDedicatedBwp
    ...  - NRCELL-1.cellBwpList =
    ...    - cellBwpId: '0'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-6'     initial BWP - 80MHZ
    ...    - cellBwpId: '1'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-100'    default dedicated BWP - 100MHZ
    ...    - cellBwpId: '2'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-50'    Power Saving BWP - 20MHZ
    ...    - cellBwpId: '3'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-88'    small dedicated BWP - 80MHZ
    ...
    ...  - Proper relations (MO NRCELL-1/NRREL-1) created: NRCELL-1 -> NRCELL-2
    ...  - NRCELL-1/NRREL-1.sCellAdditionMethod = blind (relation to NRCELL-2)
    ...
    ...  - NRCELL-2 - will be used as SCell for UE
    ...  - NRCELL-2.chBw = 100Mz
    ...  - NRCELL-2.cellTechnology = TDD
    ...  - NRCELL-2.actPowerSavingBWP = true
    ...  - NRCELL-2.actInitialBWPFlexibility = true
    ...  - NRCELL-2.actEnhMultipleDedicatedBWPs  = true (feature CB008541)
    ...  - NRCELL-2.actMultipleDedicatedBWPs = true (feature CB007552)
    ...  - NRCELL-2.nrarfcn = 650000
    ...  - NRCELL-2.gscnOrSsPbchArfcn = 7992
    ...  - NRCELL-2.msg1FrequencyStart = 60
    ...   (NRCELL-2.msg1frequencyStart is outside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-50 (RACH is outside the PS-BWP, >51))
    ...   (NRCELL-2.msg1frequencyStart is inside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-5 (RACH is inside the initial BWP, <106))
    ...  - NRCELL-2.ueConnectionEstablishmentMode = useDedicatedBwp
    ...  - NRCELL-2.cellBwpList =
    ...    - cellBwpId: '0'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-6'     initial BWP - 80MHZ
    ...    - cellBwpId: '1'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-100'    default dedicated BWP - 100MHZ
    ...    - cellBwpId: '2'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-50'    Power Saving BWP - 20MHZ
    ...    - cellBwpId: '3'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-88'    small dedicated BWP - 80MHZ
    ...
    ...  - NRPMRNL-1.nrRTPMMeasurementsList = [55351 NR Dynamic BWP, 55305 NR Beamforming]
    ...  - NRPMRNL-1.miNrBeamforming = 5min
    ...  - NRPMRNL-1.miNrPowerSavingBwp = 5min
    ...
    ...  - NRBTS-1/NRDU-1.carrierAggregationSupportList = ca_Fr1Tdd_Sa
    ...  - NRBTS-1.actBcsCheck = 1 "enabled_FR1"
    ...  - NRBTS-1.rejectSuppBcs = 0 "none"
    ...
    ...  - UEs 1-9 are supporting PS-BWP with large BWP 100MHz
    ...  - UEs 10-12 are not supporting PS-BWP (only bwp-SameNumerology IE set)
    ...  - UEs 13-15 are not supporting PS-BWP (only bwp-SwitchingDelay IE set)
    ...  - UEs 16-20 are supporting PS-BWP with small BWP 80MHz, CA capabilities and band combinations CA_n77A-n78A
    ...
    ...  == POSTCONDITION ==
    ...  NRCELL-1 and NRCELL-2 are enabled, not degraded and without alarms
    ...  BFR procedure is successfully finished, Transmission in DL occur on target beam.
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated 1x AEQE (band n78) and 1x AEQK (band n77) radio modules
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_19349;CB_FIM_35535;CB_FIM_39047
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
    ...    - USCB010544-B#2 CB008541 interaction : PS-BWP switch in CA using Smaller BWP when RACH is not in the PS-BWP
    ...
    ...  == HISTORY ==
    ...  [05.09.2023] - Create Test Suite
    ...  [11.09.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=893194)

    [Setup]  Prepare test environment CB010544-B_2

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Set Beam Control Testmode profiles for BFR on egate

    Attach UE16 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP without RACH and SCell configuration with small BWP
    Activate Beam Control Testmode on egate for UE16

    # Run small traffic so UE is on PS BWP#2
    Run DL traffic to switch to dedicated BWP then run smaller traffic to switch to PS-BWP for UE16

    Trigger Beam Failure Recovery on egate for UE16 and expect RRC Reconfiguration
    Verify that UE16 is configured with small BWP profile in RRC Reconfiguration after BFR at NRCELL-1

    Wait Until Keyword Succeeds    10s    2s    Verify 100kbps DL traffic on PDU-1 QFI-1 for UE16


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
