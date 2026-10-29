*** Settings ***
Documentation
...      COPYRIGHT:
...      Nokia Networks
...
...      INTRODUCTION: This sub-feature introduces successful procedure of A4 NR-DC measurements installation upon
...      incoming intra-gNB, inter-gNB XN based, inter-gNB NG based and inter-RAT handovers.
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
...      [29.09.2023] - Create Test Suite
...      [06.10.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=895430)

Resource    ./resources/CB008717-common_keywords.robot
Library     ./resources/message_verifiers.py

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SKIPRUN    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
    ...    CLOUD_5G_I_BOO_AP_LOO

Suite Setup    Run Keywords
...            Enable UU Messaging On Simulated Nodes    AND
...            Run Setup  ute-ca=True  faf=2    GBR_nonGBR=True
*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/M/6c_FDD_n66_n5_FR2_n260_n261_NRDC.lua
${SCFC}=                   Krakow/CB008717/DE/SCFC_FS_6C_n5_n66_n260_n261.xml
${AP_XML}=                 Krakow/CB008717/DE/iphy_FS_6c_n5_n66_n260_n261.xml

&{NRCELL_ID_TO_PHYSCELL_ID}=  1=50  2=51  3=52  4=53  5=54  6=55

*** Test Cases ***
CB008717-M-B8_B9_B12_EC1_Configure_NR-DC_A4_measurement_after_interRAT_handover
    [Documentation]
    ...  DESCRIPTION: This user scenario describes the gNB behavior that inter-frequency A4 measurement for NR-DC PSCell
    ...  Addition should/should not be configured upon inter RAT handover completion. During incoming handover, UE is
    ...  identified as FWA UE and gNB blocks A2/A3/A5 measurements on UE.
    ...  Five separate cases are included in test:
    ...     - UE1 has sufficient UE-NR-Capabilities for NR-DC support -> after inter RAT handover completion, NR-DC A4 measurements
    ...       are activated and UE1 is not configured with other measurements (A2/A3/A5). UE1 covers CB008717-M-B8a scenario.
    ...     - UE2 has insufficient UE-NR-Capabilities for NR-DC support -> after inter RAT handover completion, gNB finds that UE2
    ...       UE-NR-Capabilities are not sufficient and UE-CapabilityRequestFilterCommon->mrdc->Request->includeNR-DC IE will be
    ...       included in UECapabilityEnquiry to request support for NR-DC in band combinations and including feature set combinations
    ...       which are applicable to NR-DC in the UECapabilityInformation message. NR-DC A4 measurements are activated and UE2 is not
    ...       configured with other measurements (A2/A3/A5). UE2 covers CB008717-M-B9a scenario.
    ...     - UE8 has not sufficient UE-NR-Capabilities for NR-DC support and after inter RAT handover completion on Cell1 (NR-DC feature
    ...       disabled), gNB finds that NR-DC feature is enabled on Cell2. Therefore, if UE3 NR Capability is not sufficient
    ...       UE-CapabilityRequestFilterCommon -> mrdc-Request -> includeNR-DC IE will be included into UECapabilityEnquiry to request
    ...       support for NR-DC in band combinations and including feature set combinations which are applicable to NR-DC in the
    ...       UECapabilityInformation message. UE3 covers CB008717-M-B12 Alt2 scenario.
    ...     - For UE8, after inter RAT handover completion, NR-DC A4 measurements for NR-DC PSCell Addition shall not be configured
    ...       due to there is no matched NR-DC band combination between gNB and UE4. UE4 covers CB008717-M-EC1 scenario.
    ...     - UE3 FWA with no NRDC eligible PDU session. After interRAT handover completion, gNB does not try to activate NR-DC A4
    ...       measurements, but starts A4 retryTimer instead. After A4 retryTimer expires, gNB restarts A4 retryTimer for the UE3.
    ...       Then gNB successfully setups NR-DC eligible PDU session at UE and after A4 RetryTimer expires, gNB configures NR-DC
    ...       A4 inter-frequency measurements on UE3.
    ...
    ...  PRECONDITION:
    ...  - For real gNB-2 the same preconditions as in CB008717-D-B1c scenario with addition to:
    ...  - NRBTS/NRCELL-2 simulated on AHFIB radio module - NR_BAND: n66
    ...  - NRBTS/NRCELL-3 simulated on AWEUB radio module - NR_BAND: n260
    ...  - NRBTS/NRCELL-6 simulated on AWEUB radio module - NR_BAND: n261
    ...  - NRBTS/NRCELL-1 simulated on AHFIB radio module - NR_BAND: n66
    ...  - Two FR1 cells (NRBTS/NRCELL-1 and NRBTS/NRCELL-2) are active in pure SA mode of operation:
    ...  - NRBTS/NRCELL-1 does not have NR-DC enabled
    ...  - NRBTS/NRCELL-2 has NR-DC enabled
    ...  - Two FR2 cells (NRBTS/NRCELL-3 and NRBTS/NRCELL-6) are active in pure NR-DC-SN mode of operation with enabled NR-DC
    ...  - NRBTS.actInterFreqHoSA is set to true
    ...  - NRBTS.actIntraFreqHoSA is set to true
    ...  - NRBTS.actInterRatHoSA is set to true
    ...  - NRBTS.actIntraNrNgHo is set to sourceAndTarget
    ...  - NRBTS.actInterRatHoFromEutraToSA is set to true
    ...  - MOC configuration supports handover between NRCELL-1 and NRCELL-2
    ...  - MOC configuration supports handover between sim gNB3 and real gNB2 with NRCELL-1 and NRCELL-2
    ...  - MOC configuration supports handover between sim eNB1 and real gNB2 with NRCELL-1 and NRCELL-2
    ...  - NRBTS/identifiedFwaUeList:
    ...  - 1: 87
    ...  - NRBTS/actRfspIndex is set to true
    ...  - NRBTS/NRCELL-2/actCDrx is set to true
    ...  - NRBTS/NRCELL-2/measGapSelectionSA is set to favourUeThroughput
    ...  - NRBTS/NRCELL-2/gapOffset is set to 0
    ...  - All real gNB2, sim gNB3 and sim eNB1 are up and running
    ...  - XN link is established between real gNB2 and sim gNB3
    ...  - X2 link is established between real gNB2 and sim eNB1
    ...  - Above full handover configuration is made for A2/A3/A5 measurements configuration purpose
    ...  - UE-NR-Capability the same as in CB008717-D-B1c scenario with addition to:
    ...    - UE9: UE is NR-DC capable, but there is no UE supported NR-DC PSCell candidate in target gNB (NR_BAND: n66)
    ...
    ...  POSTCONDITION:
    ...  - UE1 is in RRC-CONNECTED state on real gNB2 NRCELL-2 with NR-DC setup with NRCELL-3
    ...  - UE2 is in RRC-CONNECTED state on real gNB2 NRCELL-2 with NR-DC setup with NRCELL-3
    ...  - UE3 is in RRC-CONNECTED state on real gNB2 NRCELL-2 with NR-DC setup with NRCELL-3
    ...  - UE8 is in RRC-CONNECTED state on real gNB2 NRCELL-2 without NR-DC setup
    ...  - UE9 is in RRC-CONNECTED state on real gNB2 NRCELL-2 without NR-DC setup
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_LO (ASIL + 2xABIO)
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_15835;5G_RAN_USR_RRM_17118;5G_RAN_USR_RRM_17174;5G_RAN_USR_RRM_17283
    ...                                5G_RAN_USR_RRM_17118;5G_RAN_USR_RRM_17709;5G_RAN_USR_RRM_18586;5G_RAN_USR_RRM_21795
    ...       *BACKLOG ID: FCA_5G_L2L3-148043;FCA_5G_L2L3-148042;FCA_5G_L2L3-181356;FCA_5G_L2L3-198515
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...  Test owner         : Michal Szymakowski    (Nokia - PL/Krakow) <michal.szymakowski@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS    (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  Related CFAM US: #ToDo
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
    ...  [29.09.23] - Create first Test Case shape
    ...  [06.10.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=895430)
    ...  [06.12.2023] - Add CB008717-HA-B2a part

    [Tags]  M-B8-B9-B12-EC1

    [Setup]  Prepare test environment for inter RAT handover

    # ------------ UE1 part - sufficient UE caps, no UECapabilityEnquiry, DRX not activated after HO ------------
#    Log To Console    UE1 -> CB008717-M-B8a
#
#    Attach UE1 without ICS to gNB2 cell1
#    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
#    Run 20MBps UL and DL traffic on UE1 PDU1 QFI1 and wait 5 seconds
#
#    Perform inter RAT handover to LTE for UE1
#
#    Set indexToRFSP for UE1 to 87 using DL NAS Transport message
#
#    get_active_measurements     UE_1
#    Set expected messages flows to check UECapabilityEnquiry request for UE1, gNB2 and AMF1
#    Set expected messages flows to check A4 activation without DRX after interRAT HO for UE1
#    Perform inter-RAT handover from LTE to 5G for UE1 to gNB2 cell2
#    Verify that expected message flows for UECapabilityEnquiry request DID NOT occure for UE1, gNB2 and AMF1
#    Verify expected messages flows to check A4 activation without DRX after interRAT HO for UE1
#    Verify that indexToRFSP-87 is present in HandoverRequest message for UE1
#
#    Verify that A2,A3,A5 measurements are not configured for UE1 in 1 out of 2 RRCReconfiguration message
#    Verify that A4 measurements are configured in 1 out of 3 UEContextModificationRequest message
#    Verify that UEContextModificationResponse_1 of 3 contains measGapConfig for gNB2
#    Verify that 2 out of 2 RRCReconfiguration contains measGapConfig=setup for UE1
#    Verify that A4 measurements are configured for UE1 in 1 out of 2 RRCReconfiguration message
#    Verify that A2,A3,A5 measurements are not configured for UE1 in 1 out of 2 RRCReconfiguration message
#
#    Sleep  5
#    ${meas_id}=  Wait until keyword succeeds    30s    2s
#    ...  Get measId matching reportConfig and measObjectId with eventA4 and NRCELL-3 for UE1
#    Set Test Variable  ${meas_id}
#
#    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
#    UE1 sends A4 measurement with id=${meas_id} for NR-DC PSCell addition
#    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
#    Verify that UE1 was successfully configured NR-DC for NRCELL-3 for gNB2
#    Verify 20Mbps UL and DL traffic on PDU-1 QFI-1 for UE1

    # ------------ UE2 part - insufficient UE caps, UECapabilityEnquiry, DRX not activated after HO ------------
    Log To Console    UE2 -> CB008717-M-B9a

    Set UE2 InterRAT insufficient NRDC capability with independentGapConfig in ue_param
    Attach UE2 without ICS to gNB2 cell1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 87
    Run 20MBps UL and DL traffic on UE2 PDU1 QFI1 and wait 5 seconds
    Perform inter RAT handover to LTE for UE2

    # workaround for CapabilityEnquiry message after interRAT Handover
    Set UE2 InterRAT sufficient NRDC capability with independentGapConfig in ue_param

    Set indexToRFSP for UE2 to 87 using DL NAS Transport message

    get_active_measurements     UE_2
    Set expected messages flows to check UECapabilityEnquiry request for UE2, gNB2 and AMF1
    Set expected messages flows to check A4 activation without DRX after interRAT HO for UE2
    Perform inter-RAT handover from LTE to 5G for UE2 to gNB2 cell2
    Verify that expected message flows for UECapabilityEnquiry request occured for UE2, gNB2 and AMF1
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE2
    Verify in UECapabilityEnquiry that message includes request for bands:n66,n5,n260,n261 for UE2
    Verify expected messages flows to check A4 activation without DRX after interRAT HO for UE2
    Verify that indexToRFSP-87 is present in HandoverRequest message for UE2

    Verify that A2,A3,A5 measurements are not configured for UE2 in 1 out of 2 RRCReconfiguration message
    Verify that A4 measurements are configured in 2 out of 3 UEContextModificationRequest message
    Verify that UEContextModificationResponse_2 of 3 contains measGapConfig for gNB2
    Verify that 2 out of 2 RRCReconfiguration contains measGapConfig=setup for UE2
    Verify that A4 measurements are configured for UE2 in 1 out of 2 RRCReconfiguration message
    Verify that A2,A3,A5 measurements are not configured for UE2 in 1 out of 2 RRCReconfiguration message

    Sleep  5
    ${meas_id}=  Wait until keyword succeeds    30s    2s
    ...  Get measId matching reportConfig and measObjectId with eventA4 and NRCELL-3 for UE2
    Set Test Variable  ${meas_id}

    Set expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    UE2 sends A4 measurement with id=${meas_id} for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    Verify that UE2 was successfully configured NR-DC for NRCELL-3 for gNB2
    Verify 20Mbps UL and DL traffic on PDU-1 QFI-1 for UE2

    # ------------ UE8 part - insufficient UE caps, UECapabilityEnquiry, HO to FF not supported cell ------------
    Log To Console    UE8 -> CB008717-M-B12a

    Set UE8 InterRAT insufficient NRDC capability in ue_param
    Attach UE8 without ICS to gNB2 cell1
    Add to UE8 initial PDU session with ICS and indexToRFSP equal 87
    Run 20MBps UL and DL traffic on UE8 PDU1 QFI1 and wait 5 seconds
    Perform inter RAT handover to LTE for UE8

    Set indexToRFSP for UE8 to 87 using DL NAS Transport message

    get_active_measurements     UE_8
    Set expected messages flows to check UECapabilityEnquiry request for UE8, gNB2 and AMF1
    Set expected messages flows to check NOT A4 activation after interRAT HO for UE8
    Perform inter-RAT handover from LTE to 5G for UE8 to gNB2 cell1
    Verify expected messages flows to check NOT A4 activation after interRAT HO for UE8

    Verify that expected message flows for UECapabilityEnquiry request occured for UE8, gNB2 and AMF1
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE8
    Verify in UECapabilityEnquiry that message includes request for bands:n66,n5,n260,n261 for UE8
    Verify that indexToRFSP-87 is present in HandoverRequest message for UE8

    Verify that A4 measurements are not configured after inter-RAT HO for UE8 in mobilityFromEUTRACommand message
    Verify that A2,A3,A5 measurements are configured after inter-RAT HO for UE8 in mobilityFromEUTRACommand message
    Verify 20Mbps UL and DL traffic on PDU-1 QFI-1 for UE8

    #------------ UE9 part - insufficient UE caps, UECapabilityEnquiry, HO to FF not supported cell ------------
#    Log To Console    UE9 -> CB008717-M-EC1
#
#    Attach UE9 without ICS to gNB2 cell1
#    Add to UE9 initial PDU session with ICS and indexToRFSP equal 87
#    Run 20MBps UL and DL traffic on UE9 PDU1 QFI1 and wait 5 seconds
#    Perform inter RAT handover to LTE for UE9
#
#    Set indexToRFSP for UE9 to 87 using DL NAS Transport message
#    get_active_measurements     UE_9
#    Set expected messages flows to check UECapabilityEnquiry request for UE9, gNB2 and AMF1
#    Set expected messages flows to check NOT A2/A3/A4/A5 activation after interRAT HO for UE9
#    Perform inter-RAT handover from LTE to 5G for UE9 to gNB2 cell2
#
#    Verify that indexToRFSP-87 is present in HandoverRequest message for UE9
#    Verify that expected message flows for UECapabilityEnquiry request DID NOT occure for UE9, gNB2 and AMF1
#    Verify expected messages flows to check NOT A2/A3/A4/A5 activation after interRAT HO for UE9
#    Verify that A4 measurements are not configured after inter-RAT HO for UE9 in mobilityFromEUTRACommand message
#    Verify that A2,A3,A5 measurements are NOT configured after inter-RAT HO for UE9 in mobilityFromEUTRACommand message
#    Verify 20Mbps UL and DL traffic on PDU-1 QFI-1 for UE9
#
     # ------------------------------------- UE3 part -HA part A4 Retry Timer -------------------------------------
#    Log To Console    UE3 -> CB008717-HA
#
#    Attach UE3 without ICS to gNB2 cell1
#    Add to UE3 initial PDU session with ICS and indexToRFSP equal 87
#    Add to UE3 PDU1 session QoS flows with 5QI from list [4] and delete QoS flows with 5QI from list []
#	 Run 20MBps UL and DL traffic on UE3 PDU1 QFI1 and wait 5 seconds
#    Perform inter RAT handover to LTE for UE3
#    Set indexToRFSP for UE3 to 87 using DL NAS Transport message
#
#    get_active_measurements     UE_3
#    Set expected messages flows to check UECapabilityEnquiry request for UE3, gNB2 and AMF1
#    Set expected messages flows to check NOT A2/A3/A4/A5 activation after interRAT HO for UE3
#    Perform inter-RAT handover from LTE to 5G for UE3 to gNB2 cell2
#
#    Verify that expected message flows for UECapabilityEnquiry request DID NOT occure for UE3, gNB2 and AMF1
#    Verify that indexToRFSP-87 is present in HandoverRequest message for UE3
#    Verify expected messages flows to check NOT A2/A3/A4/A5 activation after interRAT HO for UE3
#
#    Get occurence time of RRCReconfigurationComplete after Handover for UE3
#
#    Expect that A4 measurements are not configured after retryTimer expiry for UE3
#    Verify that A4 measurements are not configured after retryTimer expiry for UE3
#
#    Expect that A4 measurements are configured after adding eligible PDU session for UE3
#    Reset QoS Flow settings on SMF
#    Add to UE3 second PDU session after ICS
#    Verify that A4 measurements are configured after adding eligible PDU session for UE3
#    Verify that A4 measurements are configured in 3 out of 4 UEContextModificationRequest message
#    Verify that A4 measurements are not configured for UE3 in 1 out of 2 RRCReconfiguration message
#    Verify that A4 measurements are configured for UE3 in 2 out of 2 RRCReconfiguration message
#
#    Get occurence time of RRCReconfiguration with A4 measurements after handover for UE3 and verify if difference is equal 20s
#
#    Sleep  5
#    ${meas_id}=  Wait until keyword succeeds    30s    2s
#    ...  Get measId matching reportConfig and measObjectId with eventA4 and NRCELL-3 for UE3
#    Set Test Variable  ${meas_id}
#
#    Set expected messages flows for A4 measurement based PSCell addition for UE3, gNB2 and AMF1
#    UE3 sends A4 measurement with id=${meas_id} for NR-DC PSCell addition
#    Verify expected messages flows for A4 measurement based PSCell addition for UE3, gNB2 and AMF1
#    Verify that UE3 was successfully configured NR-DC for NRCELL-3 for gNB2
#    Verify 20Mbps UL and DL traffic on PDU-1 QFI-1 for UE3


    [Teardown]    Cleanup after test M-B8-B9-B12-EC1
