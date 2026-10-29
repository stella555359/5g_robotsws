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
...      [18.10.2023] - change TL type

Resource    ./resources/CB010544-common_keywords.robot
Resource    ./resources/CB010544_setup_and_teardowns.robot
Resource        ../../../resources/robot/configuration_id.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_O_E_AP_LOO
...    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Suite Setup    Run setup    ute_ca=True    internal_mirroring=True

Suite Teardown    Run Suite Teardown

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_TDD_SANSA.lua
${SCF}=                   ${CURDIR}/../../../../../custom-config/Bangalore/RRM/ET/CB010544/scf_2AEQE_SANSA_ASOE.xml
${AP_XML}=                ${CURDIR}/../../../../../custom-config/Bangalore/RRM/ET/CB010544/iphy_2AEQE_gscn_7853_ASOE.xml
${SKIP_COUNTERS}=         ${FALSE}
${rtpm}=                  ${TRUE}
&{NRCELL_1_BWP}=    ID=1    SMALL_BW=80    LARGE_BW=100
&{NRCELL_2_BWP}=    ID=2    SMALL_BW=80    LARGE_BW=100

*** Test Cases ***
CB010544-B_3 Interaction with CB008574 - RRC Reestablishment during XN HO when RACH is outside PS BWP
    [Tags]    B_3    SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the interaction with UE power saving and purpose is to verify if the configuration is correct in the
    ...  first RRC Reconfiguration message after gNB responding RRC Reestablishment during XN handover.
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
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-5'     initial BWP - 40MHZ
    ...    - cellBwpId: '1'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-44'    default dedicated BWP - 100MHZ
    ...    - cellBwpId: '2'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-50'    Power Saving BWP - 20MHZ
    ...
    ...  - Proper relations (MO NRCELL-1/NRREL-1) created: NRCELL-1 -> NRCELL-2
    ...
    ...  - NRCELL-2 - will be used as SCell for UE
    ...  - NRCELL-2.chBw = 100Mz
    ...  - NRCELL-2.cellTechnology = TDD
    ...  - NRCELL-2.actPowerSavingBWP = true
    ...  - NRCELL-2.actInitialBWPFlexibility = true
    ...  - NRCELL-2.nrarfcn = 650000
    ...  - NRCELL-2.gscnOrSsPbchArfcn = 7992
    ...  - NRCELL-2.msg1FrequencyStart = 60
    ...   (NRCELL-2.msg1frequencyStart is outside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-50 (RACH is outside the PS-BWP, >51))
    ...   (NRCELL-2.msg1frequencyStart is inside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-5 (RACH is inside the initial BWP, <106))
    ...  - NRCELL-2.ueConnectionEstablishmentMode = useDedicatedBwp
    ...  - NRCELL-2.cellBwpList =
    ...    - cellBwpId: '0'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-5'     initial BWP - 40MHZ
    ...    - cellBwpId: '1'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-44'    default dedicated BWP - 100MHZ
    ...    - cellBwpId: '2'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-50'    Power Saving BWP - 20MHZ
    ...
    ...  - NRPMRNL-1.nrRTPMMeasurementsList = [55351 NR Dynamic BWP, 55305 NR Beamforming]
    ...  - NRPMRNL-1.miNrBeamforming = 5min
    ...  - NRPMRNL-1.miNrPowerSavingBwp = 5min
    ...
    ...  - NRBTS-1.actInterGnbRREPreparedCell = true (for real gNB2) (feature CB008574)
    ...  - NRBTS-1.actInterGnbRREPreparedCell = true (as AirPhone parameter for sim gNB3) (feature CB008574)
    ...
    ...  - NRBTS-1.rrcReestabTypeSA = 1 (sameGNB) (for real gNB2) (feature 5GC000732)
    ...  - NRBTS-1.actIntraFreqHoSA = true (5GC000704 is enabled for Xn handover)
    ...  - NRBTS-1.actInterFreqHoSA = true (5GC000706 is enabled for Xn handover)
    ...
    ...  - UEs 1-9 are supporting PS-BWP with large BWP 100MHz
    ...  - UEs 10-12 are not supporting PS-BWP (only bwp-SameNumerology IE set)
    ...  - UEs 13-15 are not supporting PS-BWP (only bwp-SwitchingDelay IE set)
    ...
    ...  == POSTCONDITION ==
    ...  NRCELL-1 and NRCELL-2 are enabled, not degraded and without alarms
    ...  BWP configuration is correct
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
    ...  REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_21001;CB_FIM_35535;CB_FIM_39048
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
    ...    - USCB010544-B#4 CB008574 interaction : RRC Reestablishment with PS-BWP and no RACH-Config
    ...
    ...  == HISTORY ==
    ...  [05.09.2023] - Create Test Suite
    ...  [11.09.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=893194)

    [Setup]  Prepare test environment CB010544-B_3

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Prepare RRC Reestablishment during XN HO for UE1 on egate
    Attach UE1 to simulated gNB3 CELL-1 with inter gNB Handover setup and PDU session set
    # Run small traffic so UE could switch to PS BWP after HO
    Run 100kbps UL and DL traffic on UE1 PDU1 QFI1 and wait 5 seconds
    Verify 100kbps UL and DL traffic on PDU-1 QFI-1 for UE1

    Perform RRC Reestablishment during XN HO for UE1 and verify that UE is configured with PS-BWP and RACH is not present in PS-BWP

    Verify 100kbps UL and DL traffic on PDU-1 QFI-1 for UE1
    Run DL traffic to switch to dedicated BWP then run smaller traffic to switch to PS-BWP for UE1
    Verify 100kbps UL and DL traffic on PDU-1 QFI-1 for UE1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Check RTPM counter: NRCELL-1 MAX_UE_ACTIVE_PWR_SAVING_BWP (M55351C00001) is equal 1

    [Teardown]    Run Keywords   Basic cleanup
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting


CB010544-B_4 Interaction with CB008574 - RRC Reestablishment during NG HO when RACH is outside PS BWP
    [Tags]    B_4
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the interaction with UE power saving and purpose is to verify if the configuration is correct in the
    ...  first RRC Reconfiguration message after gNB responding RRC Reestablishment during NG handover.
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
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-5'     initial BWP - 40MHZ
    ...    - cellBwpId: '1'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-44'    default dedicated BWP - 100MHZ
    ...    - cellBwpId: '2'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-50'    Power Saving BWP - 20MHZ
    ...
    ...  - Proper relations (MO NRCELL-1/NRREL-1) created: NRCELL-1 -> NRCELL-2
    ...
    ...  - NRCELL-2 - will be used as SCell for UE
    ...  - NRCELL-2.chBw = 100Mz
    ...  - NRCELL-2.cellTechnology = TDD
    ...  - NRCELL-2.actPowerSavingBWP = true
    ...  - NRCELL-2.actInitialBWPFlexibility = true
    ...  - NRCELL-2.nrarfcn = 650000
    ...  - NRCELL-2.gscnOrSsPbchArfcn = 7992
    ...  - NRCELL-2.msg1FrequencyStart = 60
    ...   (NRCELL-2.msg1frequencyStart is outside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-50 (RACH is outside the PS-BWP, >51))
    ...   (NRCELL-2.msg1frequencyStart is inside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-5 (RACH is inside the initial BWP, <106))
    ...  - NRCELL-2.ueConnectionEstablishmentMode = useDedicatedBwp
    ...  - NRCELL-2.cellBwpList =
    ...    - cellBwpId: '0'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-5'     initial BWP - 40MHZ
    ...    - cellBwpId: '1'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-44'    default dedicated BWP - 100MHZ
    ...    - cellBwpId: '2'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-50'    Power Saving BWP - 20MHZ
    ...
    ...  - NRPMRNL-1.nrRTPMMeasurementsList = [55351 NR Dynamic BWP, 55305 NR Beamforming]
    ...  - NRPMRNL-1.miNrBeamforming = 5min
    ...  - NRPMRNL-1.miNrPowerSavingBwp = 5min
    ...
    ...  - NRBTS-1.actInterGnbRREPreparedCell = true (for real gNB2) (feature CB008574)
    ...  - NRBTS-1.rrcReestabTypeSA = 1 (for real gNB2) (feature 5GC000732)
    ...  - NRBTS-1.actIntraNrNgHo = sourceAndTarget (CB008806 is enabled for NG handover)
    ...  - NRBTS-1.NRADJGNB - created for NG handover
    ...  - NRBTS-1.NRADJNRCELL - created for NG handover
    ...  - NRCELL-1.NRREL-1.handoverAllowedSA = allowed
    ...
    ...  - UEs 1-9 are supporting PS-BWP with large BWP 100MHz
    ...  - UEs 10-12 are not supporting PS-BWP (only bwp-SameNumerology IE set)
    ...  - UEs 13-15 are not supporting PS-BWP (only bwp-SwitchingDelay IE set)
    ...
    ...  == POSTCONDITION ==
    ...  NRCELL-1 and NRCELL-2 are enabled, not degraded and without alarms
    ...  BWP configuration is correct
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
    ...  REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_21001;CB_FIM_35535;CB_FIM_39048
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
    ...    - USCB010544-B#4 CB008574 interaction : RRC Reestablishment with PS-BWP and no RACH-Config (alternate scenario)
    ...
    ...  == HISTORY ==
    ...  [05.09.2023] - Create Test Suite
    ...  [11.09.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=893194)

    [Setup]  Prepare test environment CB010544-B_4

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Prepare RRC Reestablishment during NG HO for UE1 on egate
    Attach UE1 to simulated gNB3 CELL-1 with inter gNB Handover setup and PDU session set
    # Run small traffic so UE could switch to PS BWP after HO
    Run 100kbps UL and DL traffic on UE1 PDU1 QFI1 and wait 5 seconds
    Verify 100kbps UL and DL traffic on PDU-1 QFI-1 for UE1

    Perform RRC Reestablishment during NG HO for UE1 and verify that UE is configured with PS-BWP and RACH is not present in PS-BWP

    Verify 100kbps UL and DL traffic on PDU-1 QFI-1 for UE1
    Run DL traffic to switch to dedicated BWP then run smaller traffic to switch to PS-BWP for UE1
    Verify 100kbps UL and DL traffic on PDU-1 QFI-1 for UE1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Check RTPM counter: NRCELL-1 MAX_UE_ACTIVE_PWR_SAVING_BWP (M55351C00001) is equal 1

    [Teardown]  Run Keywords  Basic cleanup
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting
