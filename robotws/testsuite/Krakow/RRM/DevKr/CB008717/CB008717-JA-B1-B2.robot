*** Settings ***
Documentation
...      COPYRIGHT:
...      Nokia Networks
...
...      INTRODUCTION: Activation/Deactivation of A4 based measurements and A4 retryTimer due to RRC Re-establishment to a different
...      or the same cell for FWA UE.
...
...      TEST SET NAME: CB008717-J Interaction with event A4
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
...      CFAM Leader        : Agnieszka Wlodarczyk        (Nokia - PL/Krakow) <agnieszka.wlodarczyk@nokia.com>
...      ET owner (LPO/APO) : Karolina Zwierz             (Nokia - PL/Krakow) <karolina.zwierz@nokia.com>
...      Entity Testing L3  : Konrad Krzyzak              (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
...                           Karolina Sroczyk-Konefal    (Nokia - PL/Krakow) <karolina.sroczyk@nokia.com>
...                           Michal Szymakowski          (Nokia - PL/Krakow) <michal.szymakowski@nokia.com>
...                           Grzegorz Szymik             (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
...
...
...      MAINTAINER:
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      REFERENCES:    CFAM link:             https://gates.nsn-net.net/view/000268d5#o=5621
...                     FTS link:              https://nokia.sharepoint.com/:w:/r/sites/mn-ran-productization/RAN%20Productization%20WoW/_layouts/15/
...                                            Doc.aspx?sourcedoc=%7B7E508D0C-5E99-4494-90F6-1AF2B64456B4%7D&file=CB008717_FeatureTestStrategy.docx&
...                                            wdLOR=c2FBA36C5-B1BE-4FA4-B2C8-F755C3E4AECD&action=default&mobileredirect=true
...                     L3 ET Test Plan:       https://confluence.ext.net.nokia.com/display/M5FC/CB008717-JA+Sub+feature+refinement
...
...      HISTORY:
...      History, current status and TC description is available in repository:
...      https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
...
...      [07.12.2023] - Create Test Suite
...      [20.12.2023] - Approved review by EFS

Resource    ./resources/CB008717-common_keywords.robot
Library     ./resources/message_verifiers.py

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD     VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
    ...    CLOUD_5G_I_BOO_AP_LOO

Suite Setup    Run Keywords
...            Enable UU Messaging On Simulated Nodes    AND
...            Run Setup  ute-ca=True  faf=0    GBR_nonGBR=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/M/6c_FDD_n66_n5_FR2_n260_n261_NRDC.lua
${SCFC}=                   Krakow/CB008717/DE/SCFC_FS_6C_n5_n66_n260_n261.xml
${AP_XML}=                 Krakow/CB008717/DE/iphy_FS_6c_n5_n66_n260_n261.xml

&{NRCELL_ID_TO_PHYSCELL_ID}=  1=50  2=51  3=52  4=53  5=54  6=55

*** Test Cases ***
CB008717-JA-B1_B2_A4retryTimer_start_after_RRCReestablishment_to_different_cell_or_serving_cell
    [Documentation]
    ...  DESCRIPTION:
    ...  This user scenario describes the behavior when A4 retryTimer is started after successful RRC Re-establishment to a different cell
    ...  for FWA UE when:
    ...  -	NR-DC A4supervisionTimer is running and A4 measurements are configured on the UE before RRC reestablishment; NR-DC eligible PDU
    ...     Session is established for UE1
    ...  -	NR-DC A4retryTimer is running and A4 measurements are NOT configured on the UE before RRC reestablishment; NR-DC eligible PDU
    ...     Session is established for UE2 and not established for UE3
    ...  This user scenario describes the behavior when A4 retryTimer is started after successful RRC Re-establishment to the same serving cell
    ...  for FWA UE when:
    ...  -	NR-DC A4supervisionTimer is running and A4 measurements are configured on the UE before RRC reestablishment; NR-DC eligible PDU
    ...     Session is established for UE4
    ...  -	NR-DC A4retryTimer is running and A4 measurements are NOT configured on the UE before RRC reestablishment; NR-DC eligible PDU
    ...  Session is established for UE5
    ...
    ...  PRECONDITION:
    ...  The same preconditions as in CB008717-M-B2a scenario with addition to:
    ...  - NRBTS/NRCELL-2/a4RetryTimer is set to 10s
    ...  - NRBTS/NRCELL-2/rrcReestabTypeSA is set to sameGNB
    ...  - NRBTS/actPucchF3BasedTaGrantsRed is set to false (due to AP limitation)
    ...  - Two FR1 cells (NRCELL-1 and NRCELL-2) are active in pure SA mode of operation with NR-DC enabled on both cells
    ...
    ...  POSTCONDITION:
    ...  - UE1 is in RRC-CONNECTED state on real gNB2 NRCELL-1 with NR-DC setup with NRCELL-3
    ...  - UE2 is in RRC-CONNECTED state on real gNB2 NRCELL-1 with NR-DC setup with NRCELL-3
    ...  - UE3 is in RRC-CONNECTED state on real gNB2 NRCELL-1 with NR-DC setup with NRCELL-3
    ...  - UE4 is in RRC-CONNECTED state on real gNB2 NRCELL-2 with NR-DC setup with NRCELL-3
    ...  - UE5 is in RRC-CONNECTED state on real gNB2 NRCELL-2 with NR-DC setup with NRCELL-3
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_LO (ASIL + 2xABIO)
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_21876, 5G_RAN_USR_RRM_21877
    ...       *BACKLOG ID: FCA_5G_L2L3-131753, 5G_RAN_USR_RRM_21877
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...  Test owner         : Konrad Krzyzak   (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS    (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  Related CFAM US: 5G_RAN_USR_RRM_21876, 5G_RAN_USR_RRM_21877
    ...  CFAM link:       https://gates.nsn-net.net/view/000268d5#o=5621
    ...  FTS link:        https://nokia.sharepoint.com/:w:/r/sites/mn-ran-productization/RAN%20Productization%20WoW/_layouts/15/
    ...                   Doc.aspx?sourcedoc=%7B7E508D0C-5E99-4494-90F6-1AF2B64456B4%7D&file=CB008717_FeatureTestStrategy.docx&
    ...                   wdLOR=c2FBA36C5-B1BE-4FA4-B2C8-F755C3E4AECD&action=default&mobileredirect=true
    ...  L3 ET Test Plan: https://confluence.ext.net.nokia.com/display/M5FC/CB008717-JA+Sub+feature+refinement
    ...
    ...  HISTORY:
    ...  History, current status and TC description is available in repository:
    ...  https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
    ...
    ...  [07.12.23] - Create first Test Case shape
    ...  [15.01.24] - Start TC shape
	...  [24.01.24] - Final TC shape for CRT after review

    [Tags]  JA-B1-B2

    [Setup]  Prepare test environment for JA-B1abc-B2ab

    #-------------------------------------------UE1-------------------------------------------

    Attach UE1 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Verify that A4 measurements are configured for UE1 after first PDU session setup
    Get occurence time of RRCReconfiguration after ICS for UE1

    Set expected message flows for RRCReestablishment procedure without ICS check for UE1, gNB2 and AMF1
    UE1 sends RRC Reestablishment Request to NRCELL-1
    Verify expected messages flows for RRCReestablishment procedure without ICS check for UE1, gNB2 and AMF1
    Verify that A4 measurements are not configured for UE1 in RRCReconfiguration message
    Verify that A4 measurements are not configured in 1 out of 2 UEContextModificationRequest message
    Get occurence time of RRCReconfiguration after RRCReestablishment procedure for UE1 and verify if difference is less than 10s

    Expect that A4 measurements are not configured 5s after a4supervisionTimer stops for UE1
    Verify that A4 measurements are not configured 5s after a4supervisionTimer stops for UE1

    Set expected messages flows to check that A4 measurements are installed after retryTimer value passes for UE1
    Verify expected messages flows to check that A4 measurements are installed after retryTimer value passes for UE1
    Verify that A4 measurements are configured for UE1 in RRCReconfiguration message
    Get occurence time of RRCReconfiguration with A4measurements installed for UE1 and verify if diff eq 15s

    ${meas_id}=  Wait until keyword succeeds    20s    2s
    ...  Get measId matching reportConfig and measObjectId with eventA4 and NRCELL-3 for UE1
    Set Test Variable  ${meas_id}
    Sleep    1

    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=${meas_id} for NR-DC PSCell addition with phycell_id=52 nrsrp_nr=86 nrsrq_nr=31
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    Verify that UE1 was successfully configured NR-DC for NRCELL-3 for gNB2

    #-------------------------------------------UE2-------------------------------------------

    Attach UE2 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
    Verify that A4 measurements are configured for UE2 after first PDU session setup
    Get occurence time of RRCReconfiguration after ICS for UE2

    Wait until a4supervisionTimer value passes and retryTimer starts

    Set expected message flows for RRCReestablishment procedure without ICS check for UE2, gNB2 and AMF1
    UE2 sends RRC Reestablishment Request to NRCELL-1
    Verify expected messages flows for RRCReestablishment procedure without ICS check for UE2, gNB2 and AMF1
    Verify that A4 measurements are not configured for UE2 in RRCReconfiguration message
    Verify that A4 measurements are not configured in 1 out of 2 UEContextModificationRequest message
    Get occurence time of RRCReconfiguration after RRCReestablishment procedure for UE2 and verify if difference is more than 10s

    Expect that A4 measurements are not configured 5s after retryTimer stops for UE2
    Verify that A4 measurements are not configured 5s after retryTimer stops for UE2

    Set expected messages flows to check that A4 measurements are installed after retryTimer value passes for UE2
    Verify expected messages flows to check that A4 measurements are installed after retryTimer value passes for UE2
    Verify that A4 measurements are configured for UE2 in RRCReconfiguration message
    Get occurence time of RRCReconfiguration with A4measurements installed for UE2 and verify if diff eq 25s

    ${meas_id}=  Wait until keyword succeeds    20s    2s
    ...  Get measId matching reportConfig and measObjectId with eventA4 and NRCELL-3 for UE2
    Set Test Variable  ${meas_id}
    Sleep    1

    Set expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    UE2 sends A4 measurement id=${meas_id} for NR-DC PSCell addition with phycell_id=52 nrsrp_nr=86 nrsrq_nr=31
    Verify expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    Verify that UE2 was successfully configured NR-DC for NRCELL-3 for gNB2

    #-------------------------------------------UE3-------------------------------------------

    Prepare NrDc UE3 candidate with 1 PDU sessions with 1 non-GBR and 1 GBR QoS Flow
    Set expected messages flows to check if A4 not configured after ICS with sufficient caps and no NRDC eligible PDU for UE3, AMF1
    Trigger UE3 idle mode exit
    Verify expected messages flows to check if A4 not configured after ICS with sufficient caps and no NRDC eligible PDU for UE3, AMF1
    Verify that A4 measurements are not configured for UE3, gNB2 and AMF1 in RRCReconfiguration message
    Get occurence time of RRCReconfiguration after ICS for UE3

    Wait until a4supervisionTimer value passes and retryTimer starts

    Set expected message flows for RRCReestablishment procedure without ICS check for UE3, gNB2 and AMF1
    UE3 sends RRC Reestablishment Request to NRCELL-1
    Verify expected messages flows for RRCReestablishment procedure without ICS check for UE3, gNB2 and AMF1
    Verify that A4 measurements are not configured for UE3 in RRCReconfiguration message
    Verify that A4 measurements are not configured in 1 out of 2 UEContextModificationRequest message
    Get occurence time of RRCReconfiguration after RRCReestablishment procedure for UE3 and verify if difference is more than 10s

    Expect that A4 measurements are not configured 5s after retryTimer stops for UE3
    Verify that A4 measurements are not configured 5s after retryTimer stops for UE3

    Expect that A4 measurements are configured after adding eligible PDU session for UE3
    Reset QoS Flow settings on SMF
    Modify PDU1 session by deleting 1 GBR QoS Flow for UE3
    Verify that A4 measurements are configured after adding eligible PDU session for UE3
    Verify that A4 measurements are not configured for UE3 in 1 out of 2 RRCReconfiguration message
    Verify that A4 measurements are configured for UE3 in 2 out of 2 RRCReconfiguration message

    Get occurence time of 1 out of 2 RRCReconfiguration with A4measurements installed for UE3 and verify if diff eq 20s

    ${meas_id}=  Wait until keyword succeeds    20s    2s
    ...  Get measId matching reportConfig and measObjectId with eventA4 and NRCELL-3 for UE3
    Set Test Variable  ${meas_id}
    Sleep    1

    Set expected messages flows for A4 measurement based PSCell addition for UE3, gNB2 and AMF1
    UE3 sends A4 measurement id=${meas_id} for NR-DC PSCell addition with phycell_id=52 nrsrp_nr=86 nrsrq_nr=31
    Verify expected messages flows for A4 measurement based PSCell addition for UE3, gNB2 and AMF1
    Verify that UE3 was successfully configured NR-DC for NRCELL-3 for gNB2

    #-------------------------------------------UE4-------------------------------------------

    Attach UE4 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE4, gNB2 and AMF1
    Add to UE4 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE4, gNB2 and AMF1
    Verify that A4 measurements are configured for UE4 after first PDU session setup
    Get occurence time of RRCReconfiguration after ICS for UE4

    Set expected message flows for RRCReestablishment procedure without ICS check for UE4, gNB2 and AMF1
    UE4 sends RRC Reestablishment Request to NRCELL-2
    Verify expected messages flows for RRCReestablishment procedure without ICS check for UE4, gNB2 and AMF1
    Verify that A4 measurements are not configured for UE4 in RRCReconfiguration message
    Verify that A4 measurements are not configured in 1 out of 2 UEContextModificationRequest message
    Get occurence time of RRCReconfiguration after RRCReestablishment procedure for UE4 and verify if difference is less than 10s

    Expect that A4 measurements are not configured 5s after a4supervisionTimer stops for UE4
    Verify that A4 measurements are not configured 5s after a4supervisionTimer stops for UE4

    Set expected messages flows to check that A4 measurements are installed after retryTimer value passes for UE4
    Verify expected messages flows to check that A4 measurements are installed after retryTimer value passes for UE4
    Verify that A4 measurements are configured for UE4 in RRCReconfiguration message
    Get occurence time of RRCReconfiguration with A4measurements installed for UE4 and verify if diff eq 15s

    ${meas_id}=  Wait until keyword succeeds    20s    2s
    ...  Get measId matching reportConfig and measObjectId with eventA4 and NRCELL-3 for UE4
    Set Test Variable  ${meas_id}
    Sleep    1

    Set expected messages flows for A4 measurement based PSCell addition for UE4, gNB2 and AMF1
    UE4 sends A4 measurement id=${meas_id} for NR-DC PSCell addition with phycell_id=52 nrsrp_nr=86 nrsrq_nr=31
    Verify expected messages flows for A4 measurement based PSCell addition for UE4, gNB2 and AMF1
    Verify that UE4 was successfully configured NR-DC for NRCELL-3 for gNB2

    #-------------------------------------------UE5-------------------------------------------

    Attach UE5 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE5, gNB2 and AMF1
    Add to UE5 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE5, gNB2 and AMF1
    Verify that A4 measurements are configured for UE5 after first PDU session setup
    Get occurence time of RRCReconfiguration after ICS for UE5

    Wait until a4supervisionTimer value passes and retryTimer starts

    Set expected message flows for RRCReestablishment procedure to serving cell without ICS for UE5, gNB2 and AMF1
    UE5 sends RRC Reestablishment Request to NRCELL-2
    Verify expected message flows for RRCReestablishment procedure to serving cell without ICS for UE5, gNB2 and AMF1
    Verify that A4 measurements are not configured for UE5 in RRCReconfiguration message
    Verify that measObjects and ReportConfigs are not removed for UE5 in RRCReconfiguration message
    Get occurence time of RRCReconfiguration after RRCReestablishment procedure for UE5 and verify if difference is more than 10s

    Expect that A4 measurements are not configured 5s after retryTimer stops for UE5
    Verify that A4 measurements are not configured 5s after retryTimer stops for UE5

    Set expected messages flows to check that A4 measurements are installed after retryTimer value passes for UE5
    Verify expected messages flows to check that A4 measurements are installed after retryTimer value passes for UE5
    Verify that A4 measurements are configured with reused MeasObject and ReportConfig for UE5 in RRCReconfiguration message
    Get occurence time of RRCReconfiguration with A4measurements installed for UE5 and verify if diff eq 25s

    ${meas_id}=  Wait until keyword succeeds    20s    2s
    ...  Get measId matching reportConfig and measObjectId with eventA4 and NRCELL-3 for UE5
    Set Test Variable  ${meas_id}
    Sleep    1

    Set expected messages flows for A4 measurement based PSCell addition for UE5, gNB2 and AMF1
    UE5 sends A4 measurement id=${meas_id} for NR-DC PSCell addition with phycell_id=52 nrsrp_nr=86 nrsrq_nr=31
    Verify expected messages flows for A4 measurement based PSCell addition for UE5, gNB2 and AMF1
    Verify that UE5 was successfully configured NR-DC for NRCELL-3 for gNB2

    [Teardown]    Cleanup after test JA-B1abc-B2ab
