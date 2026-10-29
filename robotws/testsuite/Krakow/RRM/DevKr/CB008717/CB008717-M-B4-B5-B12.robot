*** Settings ***
Documentation
...      COPYRIGHT:
...      Nokia Networks
...
...      INTRODUCTION: This subfeature introduces successful establishment of MN terminated split bearer - additional content.
...      One NR-DC-SN cell, that can act as PSCell in NR-DC, is successfully activated. After Initial Context Setup,
...      NR DC establishment is attempted for NR DC eligible UEs, MN terminated Split Bearer Addition procedure is
...      successfully completed and bearer type is successfully changed from MCG to MN terminated split bearer.
...
...      TEST SET NAME: CB008717-M Mobility on PCell
...
...      TESTING SCOPE:
...      CB008717-A NR-DC Cell Activation for a Secondary Node
...      CB008717-B Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers
...      CB008717-C UE Release due to AMF Context Release
...      CB008717-D Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers, additional content
...      CB008717-E UE Release without bearer takeback
...      CB008717-G Cell Management for Secondary Node
...      CB008717-H Configuration and Reception of A4 measurements
...      CB008717-I Successful Measurement based PSCell Addition
...      CB008717-J Interaction with event A4
...      CB008717-M Mobilty on PCell
...
...      CONTACTS:
...      CFAM Leader        : Lukasz Juszczak       (Nokia - PL/Krakow) ,lukasz.juszczak@nokia.com.
...      ET owner (LPO/APO) : Karolina Zwierz       (Nokia - PL/Krakow) <karolina.zwierz@nokia.com>
...      Entity Testing L3  : Konrad Krzyzak        (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
...                           Karolina Sroczyk      (Nokia - PL/Krakow) <karolina.sroczyk@nokia.com>
...                           Michal Szymakowski    (Nokia - PL/Krakow) <michal.szymakowski@nokia.com>
...                           Grzegorz Szymik       (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
...                           Agnieszka Wlodarczyk  (Nokia - PL/Krakow) <agnieszka.wlodarczyk@nokia.com>
...
...      MAINTAINER:
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      REFERENCES:    CFAM link:             https://gates.nsn-net.net/view/000268d5#o=5621
...                     FTS link:              https://nokia.sharepoint.com/:w:/r/sites/mn-ran-productization/RAN%20Productization%20WoW/_layouts/15/
...                                            Doc.aspx?sourcedoc=%7B7E508D0C-5E99-4494-90F6-1AF2B64456B4%7D&file=CB008717_FeatureTestStrategy.docx&
...                                            wdLOR=c2FBA36C5-B1BE-4FA4-B2C8-F755C3E4AECD&action=default&mobileredirect=true
...                     L3 ET Test Plan:       https://confluence.ext.net.nokia.com/display/M5FC/CB008717-M+Sub+feature+refinement#CB008717MSubfeatur
...                                            erefinement-EntityItemCB008717-M
...
...      HISTORY:
...      History, current status and TC description is available in repository:
...      https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
...
...      [28.09.2023] - Create Test Suite
...      [11.10.2023] - Approved by EFS
...      [11.10.2023] - Review closed

Resource    ./resources/CB008717-common_keywords.robot
Library     ./resources/message_verifiers.py

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SKIPRUN    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
    ...    CLOUD_5G_I_BOO_AP_LOO

Suite Setup    Run Keywords
...            Enable UU Messaging On Simulated Nodes    AND
...            Run Setup  ute-ca=True  faf=2  GBR_nonGBR=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/M/6c_FDD_n66_n5_FR2_n260_n261_NRDC.lua
${SCFC}=                   Krakow/CB008717/DE/SCFC_FS_6C_n5_n66_n260_n261.xml
${AP_XML}=                 Krakow/CB008717/DE/iphy_FS_6c_n5_n66_n260_n261.xml

&{NRCELL_ID_TO_PHYSCELL_ID}=  1=50  2=51  3=52  4=53  5=54  6=55

*** Test Cases ***
CB008717-M-B4_Configure_NR_DC_A4_meas_after_incoming_inter_gNB_XN_based_handover_plus_B5_and_B12_insuffienct_capability_and_UE_capability_enquiry
    [Documentation]
    ...  DESCRIPTION: This user scenario describes the gNB behavior that inter-frequency A4 measurement for NR-DC PSCell Addition shall be configured
    ...  upon intra-gNB intra-DU handover completion. During incoming handover, UE is identified as FWA UE and gNB blocks A2/A3/A5 measurements on UE
    ...  Four separate cases are included in the following scenario:
    ...  - DRX feature is enabled and UE1 is not independent gap capable (gapUE is needed) - after handover completion, NR-DC A4 measurements are
    ...    activated with measGap on UE1 and DRX is not setup on UE1. UE1 is not configured with measurements like A2/A3/A5 for mobility purposes
    ...    and redirection.
    ...  - DRX feature is enabled and UE5 is independent gap capable (no measGap needed) - after handover completion, NR-DC A4 measurements are
    ...    activated without measGap on UE5 and DRX is setup on UE5. UE5 is not configured with measurements like A2/A3/A5 for mobility purposes
    ...    and redirection - additionally this case covers US CB008717-M-B5:
    ...    - UE5 has not sufficient capabilities and after handover completion on Cell2 (NR-DC feature enabled) gNB finds that UE5 NR Capability
    ...      is not sufficient and UE-CapabilityRequestFilterCommon -> mrdc-Request -> includeNR-DC IE will be included into UECapabilityEnquiry
    ...      to request support for NR-DC in band combinations and including feature set combinations which are applicable to NR-DC
    ...      in the UECapabilityInformation message.
    ...  - This case covers US CB008717-M-B12: UE6 has not sufficient capabilities and after handover completion on Cell1 (NR-DC feature disabled),
    ...    gNB finds that NR-DC feature is enabled on Cell2. Therefore, if UE6 NR Capability is not sufficient UE-CapabilityRequestFilterCommon
    ...    -> mrdc-Request -> includeNR-DC IE will be included into UECapabilityEnquiry to request support for NR-DC in band combinations
    ...    and including feature set combinations which are applicable to NR-DC in the UECapabilityInformation message.
    ...  - UE7 is configured as non-FWA UE (UE indexToRFSP is not present in identifiedFwaUeList). Therefore, after handover completion, NR-DC A4
    ...    measurements are not activated and measurements like A2/A3/A5 for mobility purposes and redirection are configured.
    ...  - This case covers US CB008717-HA-B2b: non-FWA UE2 does not have NR-DC eligible PDU session configured. After XN handover completion,
    ...    A4 retryTimer is not started for UE. After NR-DC eligible PDU session configuration, A4 retryTimer is not started and
    ...    A4 measurements are not installed for UE.
    ...  - This case covers US CB008717-HA-B2a: FWA UE3 with no NRDC eligible PDU session. After XN based handover completion,
    ...    gNB does not try to activate NR-DC A4 measurements, but starts A4 retryTimer instead. After A4 retryTimer expires,
    ...    gNB restarts A4 retryTimer for the UE3. Then gNB successfully setups NR-DC eligible PDU session at UE and after A4
    ...    RetryTimer expires, gNB configures NR-DC A4 inter-frequency measurements on UE3.
    ...
    ...  PRECONDITION:
    ...  - For real gNB-2 the same preconditions as in CB008717-D-B1c scenario with addition to:
    ...    - NRBTS/NRCELL-2 simulated on AHFIB radio module - NR_BAND: n66
    ...    - NRBTS/NRCELL-3 simulated on AWEUB radio module - NR_BAND: n260
    ...    - NRBTS/NRCELL-6 simulated on AWEUB radio module - NR_BAND: n261
    ...    - NRBTS/NRCELL-1 simulated on AHFIB radio module - NR_BAND: n66
    ...    - Two FR1 cells (NRBTS/NRCELL-1 and NRBTS/NRCELL-2) are active in pure SA mode of operation:
    ...      - NRBTS/NRCELL-1 does not have NR-DC enabled
    ...      - NRBTS/NRCELL-2 has NR-DC enabled
    ...    - Two FR2 cells (NRBTS/NRCELL-3 and NRBTS/NRCELL-6) are active in pure NR-DC-SN mode of operation with enabled NR-DC
    ...    - NRBTS.actInterFreqHoSA is set to true
    ...    - NRBTS.actIntraFreqHoSA is set to true
    ...    - NRBTS.actInterRatHoSA is set to true
    ...    - NRBTS.actIntraNrNgHo is set to sourceAndTarget
    ...    - NRBTS.actInterRatHoFromEutraToSA is set to true
    ...    - NRBTS.actFullRRCConfigurationSaHo is set to false
    ...    - NRBTS.actForceFullRRCConfigurationSaHo is set to false
    ...    - MOC configuration supports handover between NRCELL-1 and NRCELL-2
    ...    - MOC configuration supports handover between sim gNB3 and real gNB2 with NRCELL-1 and NRCELL-2
    ...    - MOC configuration supports handover between sim eNB1 and real gNB2 with NRCELL-1 and NRCELL-2
    ...    - NRBTS/identifiedFwaUeList:
    ...      - 1: 87
    ...    - NRBTS/actRfspIndex is set to true
    ...    - NRBTS/NRCELL-2/actCDrx is set to true
    ...    - NRBTS/NRCELL-2/measGapSelectionSA is set to favourUeThroughput
    ...    - NRBTS/NRCELL-2/gapOffset is set to 0
    ...  - All real gNB2, sim gNB3 and sim eNB1 are up and running
    ...  - XN link is established between real gNB2 and sim gNB3
    ...  - Above full handover configuration is made for A2/A3/A5 measurements configuration purpose
    ...  - UE-NR-Capability the same as in CB008717-D-B1c scenario with addition to:
    ...    - UE1:
    ...      - measAndMobParameters/measAndMobParameters-Common/independentGapConfig is not present
    ...    - UE5:
    ...      - measAndMobParameters/measAndMobParameters-Common/independentGapConfig is set to supported
    ...      - nonCriticalExtension/nonCriticalExtension/receivedFilters/capabilityRequestFilterCommon/mrdc-Request/includeNR-DC - is not present
    ...    - UE6:
    ...      - the same capabilities as UE5
    ...    - UE3:
    ...      - the same capabilities as UE5
    ...    - UE2, UE7:
    ...      - set indexToRFSP to 88 via amf_ue_ics_param egate command
    ...
    ...  POSTCONDITION:
    ...  - UE1 is in RRC-CONNECTED state on NRCELL-2 with NR-DC setup with NRCELL-3
    ...  - UE2 is in RRC-CONNECTED state on NRCELL-2 without A4 NR-DC measurement configured
    ...  - UE3 is in RRC-CONNECTED state on NRCELL-2 with NR-DC setup with NRCELL-3
    ...  - UE5 is in RRC-CONNECTED state on NRCELL-2 with NR-DC setup with NRCELL-3
    ...  - UE6 is in RRC-CONNECTED state on NRCELL-2 without A4 NR-DC measurement configured
    ...  - UE7 is in RRC-CONNECTED state on NRCELL-2 without A4 NR-DC measurement configured
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_LO (ASIL + 2xABIO)
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_17706, 5G_RAN_USR_RRM_17173, 5G_RAN_USR_RRM_18586, 5G_RAN_USR_RRM_21795
    ...       *BACKLOG ID: FCA_5G_L2L3-148049, FCA_5G_L2L3-148047, FCA_5G_L2L3-181356, FCA_5G_L2L3-198515
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...  Test owner         : Grzegorz Szymik   (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS    (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  Related CFAM US: 5G_RAN_USR_RRM_17415, 5G_RAN_USR_RRM_18584
    ...  CFAM link:       https://gates.nsn-net.net/view/000268d5#o=5621
    ...  FTS link:        https://nokia.sharepoint.com/:w:/r/sites/mn-ran-productization/RAN%20Productization%20WoW/_layouts/15/
    ...                   Doc.aspx?sourcedoc=%7B7E508D0C-5E99-4494-90F6-1AF2B64456B4%7D&file=CB008717_FeatureTestStrategy.docx&
    ...                   wdLOR=c2FBA36C5-B1BE-4FA4-B2C8-F755C3E4AECD&action=default&mobileredirect=true
    ...  L3 ET Test Plan: https://confluence.ext.net.nokia.com/display/M5FC/CB008717-M+Sub+feature+refinement#CB008717MSubfeaturerefinement-
    ...  EntityItemCB008717-M
    ...
    ...  HISTORY:
    ...  History, current status and TC description is available in repository:
    ...  https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
    ...
    ...  [28.09.23] - Create first Test Case shape
    ...  [11.10.23] - Final TC shape
    ...  [11.10.23] - Review closed

    [Tags]  M-B4-B5-B12

    [Setup]  Prepare test environment for M-B4-B5-B12

    # ------------ UE1 part - sufficient UE caps, no UECapabilityEnquiry, DRX not activated after HO ------------

    Attach UE1 with ICS to simulated gNB3 with ICS and indexToRFSP equal 87
    Run 20MBps UL and DL traffic on UE1 PDU1 QFI1 and wait 5 seconds
    Set expected messages flows to check UECapabilityEnquiry request for UE1, gNB2 and AMF1
    Set expected messages flows to check A4 activation without DRX after incoming inter-gNB XN HO for UE1
    Trigger UE1 handover from sim_gNB to gNB2 NRCELL-2
    Verify that expected message flows for UECapabilityEnquiry request occured for UE1, gNB2 and AMF1
    Verify expected messages flows to check A4 activation without DRX after incoming inter-gNB XN HO for UE1

    Verify in UECapabilityEnquiry that includeNR-DC IE is not present for UE1
    Verify that A2,A3,A5 measurements are not configured for UE1 in 1 out of 2 RRCReconfiguration message
    Verify that A4 measurements are configured in 2 out of 3 UEContextModificationRequest message
    Verify that UEContextModificationResponse_2 of 3 contains measGapConfig for gNB2
    Verify that 2 out of 2 RRCReconfiguration contains measGapConfig=setup for UE1
    Verify that A4 measurements are configured for UE1 in 2 out of 2 RRCReconfiguration message
    Verify that A2,A3,A5 measurements are not configured for UE1 in 2 out of 2 RRCReconfiguration message

    ${meas_id}=    Wait for NRDC A4 activation and get measID for UE1 and NRCELL-3

    Set expected messages flows for A4 measurement based PSCell addition with DRX for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=${meas_id} for NR-DC PSCell addition with phycell_id=52 nrsrp_nr=86 nrsrq_nr=31
    Verify expected messages flows for A4 measurement based PSCell addition with DRX for UE1, gNB2 and AMF1
    Verify that UE1 was successfully configured NR-DC for NRCELL-3 with DRX for gNB2
    Verify 20Mbps UL and DL traffic on PDU-1 QFI-1 for UE1

    # --- UE2 part - non-FWA UE - HO with no NR-DC eligible PDU session - A4 is not installed after eligible PDU session setup --------

    Attach UE2 with ICS to simulated gNB3 with ICS and indexToRFSP equal 88
    Add to UE2 PDU1 session QoS flows with 5QI from list [4] and delete QoS flows with 5QI from list []
    Set expected messages flows to check UECapabilityEnquiry request for UE2, gNB2 and AMF1
    Set expected messages flows to check A4 measurements are NOT configured after incoming inter-gNB XN HO for UE2
    Trigger UE2 handover from sim_gNB to gNB2 NRCELL-2
    Verify that expected message flows for UECapabilityEnquiry request occured for UE2, gNB2 and AMF1
    Verify expected messages flows to check A4 measurements are NOT configured after incoming inter-gNB XN HO for UE2
    Add NR-DC eligible PDU sesion for non FWA UE2 and expect A4 measurements are not configured
    Verify that A4 measurements are not configured for UE2 in 1 out of 2 RRCReconfiguration message

    #------------------------------------- UE3 part -HA part A4 Retry Timer -------------------------------------

    Attach UE3 with ICS to simulated gNB3 with ICS and indexToRFSP equal 87
    Add to UE3 PDU1 session QoS flows with 5QI from list [4] and delete QoS flows with 5QI from list []

    Set expected messages flows to check UECapabilityEnquiry request for UE3, gNB2 and AMF1
    Set expected messages flows to check not A4 activation without DRX after incoming inter-gNB XN HO for UE3
    Trigger UE3 handover from sim_gNB to gNB2 NRCELL-2
    Verify that expected message flows for UECapabilityEnquiry request occured for UE3, gNB2 and AMF1
    Verify expected messages flows to check not A4 activation without DRX after incoming inter-gNB XN HO for UE3

    Get occurence time of RRCReconfigurationComplete after Handover for UE3

    Expect that A4 measurements are not configured after retryTimer expiry for UE3
    Verify that A4 measurements are not configured after retryTimer expiry for UE3

    Expect that A4 measurements are configured after adding eligible PDU session for UE3
    Reset QoS Flow settings on SMF
    Add to UE3 second PDU session after ICS
    Verify that A4 measurements are configured after adding eligible PDU session for UE3
    Verify that A4 measurements are configured in 3 out of 4 UEContextModificationRequest message
    Verify that A4 measurements are not configured for UE3 in 1 out of 2 RRCReconfiguration message
    Verify that A4 measurements are configured for UE3 in 2 out of 2 RRCReconfiguration message

    Get occurence time of RRCReconfiguration with A4 measurements after handover for UE3 and verify if difference is equal 20s

    Sleep  5
    ${meas_id}=  Wait until keyword succeeds    30s    2s
    ...  Get measId matching reportConfig and measObjectId with eventA4 and NRCELL-3 for UE3
    Set Test Variable  ${meas_id}

    Set expected messages flows for A4 measurement based PSCell addition for UE3, gNB2 and AMF1
    UE3 sends A4 measurement with id=${meas_id} for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE3, gNB2 and AMF1
    Verify that UE3 was successfully configured NR-DC for NRCELL-3 for gNB2

    # ------------ UE5 part - insufficient UE caps, UECapabilityEnquiry required, DRX activated after HO ------------

    Attach UE5 with ICS to simulated gNB3 with ICS and indexToRFSP equal 87

    Set expected messages flows to check UECapabilityEnquiry request for UE5, gNB2 and AMF1
    Set expected messages flows to check A4 activation with DRX after incoming inter-gNB XN HO for UE5
    Trigger UE5 handover from sim_gNB to gNB2 NRCELL-2
    Verify that expected message flows for UECapabilityEnquiry request occured for UE5, gNB2 and AMF1
    Verify expected messages flows to check A4 activation with DRX after incoming inter-gNB XN HO for UE5

    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE5
    Verify in UECapabilityEnquiry that message includes request for bands:n66,n5,n260,n261 for UE5
    Verify that A2,A3,A5 measurements are not configured for UE5 in 1 out of 3 RRCReconfiguration message
    Verify that A4 measurements are configured in 3 out of 7 UEContextModificationRequest message
    Verify that UEContextModificationResponse_3 of 7 does not contain measGapConfig for gNB2
    Verify that 2 out of 3 RRCReconfiguration does not contain measGapConfig for UE5
    Verify that A4 measurements are configured for UE5 in 2 out of 3 RRCReconfiguration message
    Verify that A2,A3,A5 measurements are not configured for UE5 in 2 out of 3 RRCReconfiguration message
    Verify that UEContextModificationRequest_5 of 7 contains DRXCycle for gNB2
    Verify that UEContextModificationResponse_5 of 7 contains drx-Config eq setup for gNB2
    Verify that 3 out of 3 RRCReconfiguration contains drx-Config eq setup for UE5

    ${meas_id}=    Wait for NRDC A4 activation and get measID for UE5 and NRCELL-3

    Set expected messages flows for A4 measurement based PSCell addition without DRX for UE5, gNB2 and AMF1
    UE5 sends A4 measurement id=${meas_id} for NR-DC PSCell addition with phycell_id=52 nrsrp_nr=86 nrsrq_nr=31
    Verify expected messages flows for A4 measurement based PSCell addition without DRX for UE5, gNB2 and AMF1
    Verify that UE5 was successfully configured NR-DC for NRCELL-3 for gNB2

    # ------------ UE6 part - attach on NRCELL-1 (NRDC disabled) - A4 is not installed and A2/A3/A5 are installed, UECapabilityEnquiry required ----

    Attach UE6 with ICS to simulated gNB3 with ICS and indexToRFSP equal 87

    Set expected messages flows to check UECapabilityEnquiry request for UE6, gNB2 and AMF1
    Set expected messages flows to check A2/A3/A5 activation without DRX after incoming inter-gNB XN HO for UE6
    Trigger UE6 handover from sim_gNB to gNB2 NRCELL-1
    Verify that expected message flows for UECapabilityEnquiry request occured for UE6, gNB2 and AMF1
    Verify expected messages flows to check A2/A3/A5 activation without DRX after incoming inter-gNB XN HO for UE6

    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE6
    Verify in UECapabilityEnquiry that message includes request for bands:n66,n5,n260,n261 for UE6
    Verify that A4 measurements are not configured for UE6 in RRCReconfiguration message
    Verify that A2,A3,A5 measurements are configured for UE6 in RRCReconfiguration message

    # ------------ UE7 part - non-FWA UE - after HO A4 is not installed and A2/A3/A5 are installed ------------

    Attach UE7 with ICS to simulated gNB3 with ICS and indexToRFSP equal 88

    Set expected messages flows to check UECapabilityEnquiry request for UE7, gNB2 and AMF1
    Set expected messages flows to check A2/A3/A5 activation with DRX after incoming inter-gNB XN HO for UE7
    Trigger UE7 handover from sim_gNB to gNB2 NRCELL-2
    Verify that expected message flows for UECapabilityEnquiry request occured for UE7, gNB2 and AMF1
    Verify expected messages flows to check A2/A3/A5 activation with DRX after incoming inter-gNB XN HO for UE7

    Verify in UECapabilityEnquiry that includeNR-DC IE is not present for UE7
    Verify that A4 measurements are not configured for UE7 in 1 out of 2 RRCReconfiguration message
    Verify that A2,A3,A5 measurements are configured for UE7 in 1 out of 2 RRCReconfiguration message
    Verify that UEContextModificationRequest_2 of 4 contains DRXCycle for gNB2
    Verify that UEContextModificationResponse_2 of 4 contains drx-Config eq setup for gNB2
    Verify that 2 out of 2 RRCReconfiguration contains drx-Config eq setup for UE7

    [Teardown]    Cleanup after test M-B4-B5-B12
