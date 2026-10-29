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
...      TEST SET NAME: CB008717-D Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers, additional content
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
...      CFAM Leader        :
...      ET owner (LPO/APO) : Karolina Zwierz       (Nokia - PL/Krakow) <karolina.zwierz@nokia.com>
...      Entity Testing L3  : Konrad Krzyzak        (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
...                           Karolina Sroczyk      (Nokia - PL/Krakow) <karolina.sroczyk@nokia.com>
...                           Grzegorz Szymik       (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
...                           Agnieszka Wlodarczyk  (Nokia - PL/Krakow) <agnieszka.wlodarczyk@nokia.com>
...
...      MAINTAINER:
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      REFERENCES:    CFAM link:             https://gates.nsn-net.net/view/00025f8e#o=720
...                     FTS link:              https://nokia.sharepoint.com/sites/mn-ran-productization/RAN%20Productization%20WoW/Shared%20Documents
...                                            /Forms/AllItems.aspx?RootFolder=%2Fsites%2Fmn%2Dran%2Dproductization%2FRAN%20Productization%20WoW%2FSh
...                                            ared%20Documents%2F6%2E%20Feature%20Documents%2FCB008600%2DCB008799%2FCB008717
...                     L3 ET Test Plan:       https://confluence.ext.net.nokia.com/display/M5FC/CB008717-D+Sub+feature+refinement
...
...      HISTORY:
...      History, current status and TC description is available in repository:
...      https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
...
...      [07.08.2023] - Create Test Suite
...      [10.08.2023] - Approved by EFS

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

*** Test Cases ***
CB008717-M-B6_Configure_NR_DC_A4_meas_after_incoming_inter_gNB_NG_based_handover_plus_B7_and_B12_insuffienct_capability_and_UE_capability_enquiry
    [Documentation]
    ...  DESCRIPTION:
    ...  This user scenario describes the gNB behavior that inter-frequency A4 measurement for NR-DC PSCell Addition shall
    ...  be configured upon inter-gNB NG based handover completion. During incoming handover, UE is identified as FWA UE
    ...  and gNB blocks A2/A3/A5 measurements on UE.
    ...  Four separate cases are included in the following scenario:
    ...  - UE1 has sufficient UE-NR-Capabilities, DRX feature is disabled and UE1 is independent gap capable.
    ...    After handover completion, NR-DC A4 measurements are activated without measGap and DRX is NOT setup on UE1
    ...    UE1 is not configured with measurements like A2/A3/A5. UE1 covers CB008717-M-B6a scenario.
    ...
    ...  - UE2 has sufficient UE-NR-Capabilities, DRX feature is enabled and UE2 is independent gap capable.
    ...    After handover completion, NR-DC A4 measurements are activated without measGap and DRX is setup on UE2.
    ...    UE2 is not configured with measurements like A2/A3/A5. UE2 covers CB008717-M-B6a - Alternative 2 scenario.
    ...
    ...  - UE5 has insufficient UE-NR-Capabilities, DRX feature is disabled and UE5 is independent gap capable.
    ...    After handover completion gNB finds that UE5 UE-NR-Capabilities are not sufficient - includeNR-DC will be
    ...    included in UECapabilityEnquiry, NR-DC A4 measurements are activated without measGap and DRX is NOT setup on UE5.
    ...    UE5 is not configured with measurements like A2/A3/A5. UE5 covers CB008717-M-B7a scenario.
    ...
    ...  - UE6 has insufficient UE-NR-Capabilities, DRX feature is disabled and UE6 is independent gap capable.
    ...    After handover completion on Cell1 (NR-DC feature disabled) gNB finds that NR-DC feature is enabled on Cell2,
    ...    gNB finds that UE6 UE-NR-Capabilities are not sufficient - includeNR-DC will be included in UECapabilityEnquiry.
    ...    UE6 is not configured with measurements like A2/A3/A4/A5. UE6 covers CB008717-M-B12 scenario.
    ...
    ...  - This case covers US CB008717-HA-B2b: non-FWA UE3 does not have NR-DC eligible PDU session configured. After
    ...    NG handover completion, A4 retryTimer is not started for UE. After NR-DC eligible PDU session configuration,
    ...    A4 retryTimer is not started and A4 measurements are not installed for UE.
    ...
    ...  - This case covers US CB008717-HA-B2a: FWA UE4 with no NRDC eligible PDU session. After NG based handover completion,
    ...    gNB does not try to activate NR-DC A4 measurements, but starts A4 retryTimer instead. After A4 retryTimer expires,
    ...    gNB restarts A4 retryTimer for the UE4. Then gNB successfully setups NR-DC eligible PDU session at UE and after A4
    ...    RetryTimer expires, gNB configures NR-DC A4 inter-frequency measurements on UE4.
    ...
    ...  PRECONDITION:
    ...  Same preconditions as in CB008717-M-B4 scenario with addition to:
    ...  UE-NR-Capability the same as UE1 in CB008717-D-B1c scenario with addition to:
    ...  UE5: includeNR-DC - is not present
    ...  UE6: includeNR-DC - is not present
    ...  UE3: non-FWA - set indexToRFSP to 88 via amf_ue_ics_param egate command
    ...  UE4: includeNR-DC - is not present
    ...
    ...  POSTCONDITION:
    ...  UE1, UE2, UE4, UE5 is in RRC-CONNECTED state on real gNB2 NRCELL-2 with NR-DC setup
    ...  UE3, UE6 are in RRC-CONNECTED state on real gNB2 NRCELL-1 without A4 NR-DC measurement configured
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_LO (ASIL + 2xABIO)
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_18586, 5G_RAN_USR_RRM_15835;5G_RAN_USR_RRM_17118;5G_RAN_USR_RRM_17283;
    ...                               5G_RAN_USR_RRM_21795
    ...       *BACKLOG ID: FCA_5G_L2L3-148045, FCA_5G_L2L3-148044, FCA_5G_L2L3-181356, FCA_5G_L2L3-198515
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...  Test owner         : Karolina Sroczyk  (Nokia - PL/Krakow) <karolina.sroczyk@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS    (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  Related CFAM US:
    ...  CFAM link:       https://gates.nsn-net.net/view/00025f8e#o=720
    ...  FTS link:        https://nokia.sharepoint.com/sites/mn-ran-productization/RAN%20Productization%20WoW/Shared%20Documents
    ...                   /Forms/AllItems.aspx?RootFolder=%2Fsites%2Fmn%2Dran%2Dproductization%2FRAN%20Productization%20WoW%2FSh
    ...                   ared%20Documents%2F6%2E%20Feature%20Documents%2FCB008600%2DCB008799%2FCB008717
    ...  L3 ET Test Plan: https://confluence.ext.net.nokia.com/display/M5FC/CB008717-D+Sub+feature+refinement
    ...
    ...  HISTORY:
    ...  History, current status and TC description is available in repository:
    ...
    ...  [22.09.2023] - Create first Test Case shape
    ...  [06.10.2023] - Approved by (Lukasz Juszczak, https://collab.ext.net.nokia.com/ui#review:id=894577)
    ...  [06.12.2023] - Add CB008717-HA-B2a part

    [Tags]  M-B6

    [Setup]  Prepare test environment M-B6-B7-B12

    #-------------------------------- UE5 - insufficient capy - no DRX, independent gap capable ------------------------

    Attach UE5 with ICS to simulated gNB3 with ICS and indexToRFSP equal 87
    Run 20MBps UL and DL traffic on UE5 PDU1 QFI1 and wait 5 seconds

    Set expected messages flows to check UECapabilityEnquiry request for UE5, gNB2 and AMF1
    Set expected messages flows to check A4 activation without DRX after incoming intra-gNB NG HO for UE5
    Trigger UE5 handover from sim_gNB to gNB2 NRCELL-2
    Verify that expected message flows for UECapabilityEnquiry request occured for UE5, gNB2 and AMF1
    Verify expected messages flows to check A4 activation without DRX after incoming intra-gNB NG HO for UE5

    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE5
    Verify in UECapabilityEnquiry that message includes request for bands:n66,n5,n260,n261 for UE5
    Verify that A2,A3,A5 measurements are not configured for UE5 in 1 out of 2 RRCReconfiguration message
    Verify that A4 measurements are configured in 3 out of 4 UEContextModificationRequest message
    Verify that UEContextModificationResponse_3 of 4 does not contain measGapConfig for gNB2
    Verify that 2 out of 2 RRCReconfiguration does not contain measGapConfig for UE5
    Verify that A2,A3,A5 measurements are not configured for UE5 in 2 out of 2 RRCReconfiguration message
    Verify that A4 measurements are configured for UE5 in 2 out of 2 RRCReconfiguration message

    ${meas_id}=  Wait until keyword succeeds    20s    2s
    ...  Get measId matching reportConfig and measObjectId with eventA4 and NRCELL-3 for UE5
    Set Test Variable  ${meas_id}
    Sleep    2

    Set expected messages flows for A4 measurement based PSCell addition for UE5, gNB2 and AMF1
    UE5 sends A4 measurement id=${meas_id} for NR-DC PSCell addition with phycell_id=52 nrsrp_nr=86 nrsrq_nr=31
    Verify expected messages flows for A4 measurement based PSCell addition for UE5, gNB2 and AMF1
    Verify that UE5 was successfully configured NR-DC for gNB2
    Verify 20Mbps UL and DL traffic on PDU-1 QFI-1 for UE5

    #-------------------------------- UE6 - insufficient capy - no DRX, HO to cell with disabled NRDC ------------------

    Configure  {'MOC': 'NRBTS', 'ID': '1', 'actFullRRCConfigurationSaHo': 'enabled'}
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'actForceFullRRCConfigurationSaHo': 'enabled'}
    Attach UE6 with ICS to simulated gNB3 with ICS and indexToRFSP equal 87

    Set expected messages flows to check UECapabilityEnquiry request for UE6, gNB2 and AMF1
    Set expected messages flows to check A4 are NOT activated after incoming intra-gNB NG HO for UE6
    Trigger UE6 handover from sim_gNB to gNB2 NRCELL-1
    Verify that expected message flows for UECapabilityEnquiry request occured for UE6, gNB2 and AMF1
    Verify expected messages flows to check A4 are NOT activated after incoming intra-gNB NG HO for UE6

    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE6
    Verify in UECapabilityEnquiry that message includes request for bands:n66,n5,n260,n261 for UE6
    Verify that A2,A3,A5 measurements are activated for UE6 in RRCReconfiguration message
    Verify that fullConfig is setup for UE6 in RRCReconfiguration message
    Verify that measurements are not removed for UE6 in RRCReconfiguration message

    Configure  {'MOC': 'NRBTS', 'ID': '1', 'actFullRRCConfigurationSaHo': 'disabled'}
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'actForceFullRRCConfigurationSaHo': 'disabled'}

    #-------------------------------- UE1 - sufficient capy - no DRX, independent gap capable --------------------------

    Set ${sufficient_n5_n66_n260_n261_with_interRAT_independent_gap} UECaps for UE1
    Attach UE1 with ICS to simulated gNB3 with ICS and indexToRFSP equal 87

    Set expected messages flows to check UECapabilityEnquiry request for UE1, gNB2 and AMF1
    Set expected messages flows to check A4 activation without DRX after incoming intra-gNB NG HO for UE1
    Trigger UE1 handover from sim_gNB to gNB2 NRCELL-2
    Verify that expected message flows for UECapabilityEnquiry request DID NOT occure for UE1, gNB2 and AMF1
    Verify expected messages flows to check A4 activation without DRX after incoming intra-gNB NG HO for UE1

    Verify that A2,A3,A5 measurements are not configured for UE1 in 1 out of 2 RRCReconfiguration message
    Verify that A4 measurements are configured in 2 out of 4 UEContextModificationRequest message
    Verify that UEContextModificationResponse_2 of 4 does not contain measGapConfig for gNB2
    Verify that 2 out of 2 RRCReconfiguration does not contain measGapConfig for UE1
    Verify that A2,A3,A5 measurements are not configured for UE1 in 2 out of 2 RRCReconfiguration message
    Verify that A4 measurements are configured for UE1 in 2 out of 2 RRCReconfiguration message

    ${meas_id}=  Wait until keyword succeeds    20s    2s
    ...  Get measId matching reportConfig and measObjectId with eventA4 and NRCELL-3 for UE1
    Set Test Variable  ${meas_id}
    Sleep    2

    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=${meas_id} for NR-DC PSCell addition with phycell_id=52 nrsrp_nr=86 nrsrq_nr=31
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    Verify that UE1 was successfully configured NR-DC for gNB2

    #-------------------------------- UE2 - sufficient capy - DRX, independent gap capable -----------------------------

    Configure  {'MOC': 'NRCELL', 'ID': '2', 'actCDrx': 'true'}
    Set ${sufficient_n5_n66_n260_n261_with_interRAT_independent_gap} UECaps for UE2
    Attach UE2 with ICS to simulated gNB3 with ICS and indexToRFSP equal 87
    Run 20MBps UL and DL traffic on UE2 PDU1 QFI1 and wait 5 seconds

    Set expected messages flows to check UECapabilityEnquiry request for UE2, gNB2 and AMF1
    Set expected messages flows to check A4 activation with DRX after incoming intra-gNB NG HO for UE2
    Trigger UE2 handover from sim_gNB to gNB2 NRCELL-2
    Verify that expected message flows for UECapabilityEnquiry request DID NOT occure for UE2, gNB2 and AMF1
    Verify expected messages flows to check A4 activation with DRX after incoming intra-gNB NG HO for UE2

    Verify that A2,A3,A5 measurements are not configured for UE2 in 1 out of 3 RRCReconfiguration message
    Verify that A4 measurements are configured in 2 out of 4 UEContextModificationRequest message
    Verify that UEContextModificationResponse_2 of 4 does not contain measGapConfig for gNB2
    Verify that 2 out of 3 RRCReconfiguration does not contain measGapConfig for UE2
    Verify that A2,A3,A5 measurements are not configured for UE2 in 2 out of 3 RRCReconfiguration message
    Verify that A4 measurements are configured for UE2 in 2 out of 3 RRCReconfiguration message
    Verify that UEContextModificationRequest_4 of 4 contains DRXCycle for gNB2
    Verify that UEContextModificationResponse_4 of 4 contains drx-Config eq setup for gNB2
    Verify that 3 out of 3 RRCReconfiguration contains drx-Config eq setup for UE2

    ${meas_id}=  Wait until keyword succeeds    20s    2s
    ...  Get measId matching reportConfig and measObjectId with eventA4 and NRCELL-3 for UE2
    Set Test Variable  ${meas_id}
    Sleep    2

    Set expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    UE2 sends A4 measurement id=${meas_id} for NR-DC PSCell addition with phycell_id=52 nrsrp_nr=86 nrsrq_nr=31
    Verify expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    Verify that UE2 was successfully configured NR-DC for gNB2
    Verify 20Mbps UL and DL traffic on PDU-1 QFI-1 for UE2


    # --- UE3 part - non-FWA UE - HO with no NR-DC eligible PDU session - A4 is not installed after eligible PDU session setup --------

    Attach UE3 with ICS to simulated gNB3 with ICS and indexToRFSP equal 88
    Add to UE3 PDU1 session QoS flows with 5QI from list [4] and delete QoS flows with 5QI from list []
    Run 20MBps UL and DL traffic on UE3 PDU1 QFI1 and wait 5 seconds
    Set expected messages flows to check A4 are NOT activated after incoming intra-gNB NG HO for UE3
    Trigger UE3 handover from sim_gNB to gNB2 NRCELL-2
    Verify expected messages flows to check A4 are NOT activated after incoming intra-gNB NG HO for UE3
    Add NR-DC eligible PDU sesion for non FWA UE3 and expect A4 measurements are not configured
    Verify that A4 measurements are not configured for UE3 in 1 out of 2 RRCReconfiguration message

    #------------------------------------- UE4 part -HA part A4 Retry Timer -------------------------------------

    Set ${sufficient_n5_n66_n260_n261_with_interRAT_independent_gap} UECaps for UE4
    Attach UE4 with ICS to simulated gNB3 with ICS and indexToRFSP equal 87
    Add to UE4 PDU1 session QoS flows with 5QI from list [4] and delete QoS flows with 5QI from list []

    Set expected messages flows to check UECapabilityEnquiry request for UE4, gNB2 and AMF1
    Set expected messages flows to check A4 are NOT activated after incoming intra-gNB NG HO for UE4
    Trigger UE4 handover from sim_gNB to gNB2 NRCELL-2
    Verify that expected message flows for UECapabilityEnquiry request DID NOT occure for UE4, gNB2 and AMF1
    Verify expected messages flows to check A4 are NOT activated after incoming intra-gNB NG HO for UE4
    Verify that A2,A3,A5 measurements are not configured for UE4 in 1 out of 2 RRCReconfiguration message

    Get occurence time of RRCReconfigurationComplete after Handover for UE4

    Expect that A4 measurements are not configured after retryTimer expiry for UE4
    Verify that A4 measurements are not configured after retryTimer expiry for UE4

    Expect that A4 measurements are configured after adding eligible PDU session for UE4
    Reset QoS Flow settings on SMF
    Add to UE4 second PDU session after ICS
    Verify that A4 measurements are configured after adding eligible PDU session for UE4
    Verify that A4 measurements are configured in 3 out of 4 UEContextModificationRequest message
    Verify that A4 measurements are not configured for UE4 in 1 out of 2 RRCReconfiguration message
    Verify that A4 measurements are configured for UE4 in 2 out of 2 RRCReconfiguration message

    Get occurence time of RRCReconfiguration with A4 measurements after handover for UE4 and verify if difference is equal 20s

    Sleep  5
    ${meas_id}=  Wait until keyword succeeds    30s    2s
    ...  Get measId matching reportConfig and measObjectId with eventA4 and NRCELL-3 for UE4
    Set Test Variable  ${meas_id}

    Set expected messages flows for A4 measurement based PSCell addition for UE4, gNB2 and AMF1
    UE4 sends A4 measurement with id=${meas_id} for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE4, gNB2 and AMF1
    Verify that UE4 was successfully configured NR-DC for gNB2

    [Teardown]    Cleanup after test M-B6-B7-B12
