*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         This subfeature introduces successful establishment of MN terminated split bearer. One NR-DC-SN cell, that can
...         act as PSCell in NR-DC, is successfully activated. After Initial Context Setup/PDU Session Resource Setup, NR DC
...         establishment is attempted for NR DC eligible UEs, MN terminated Split Bearer Addition procedure is successfully
...         completed and Successful bearer type is changed from MCG to MN terminated split bearer.
...
...      == TEST SET NAME ==
...         CB008717-B Successful Blind PSCell Addition for a single UE after ICS having only non-GBR bearer with TDD PCell
...
...      == TESTING SPLIT==
...         CB008717-A NR-DC Cell Activation for a Secondary Node
...         CB008717-B Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers
...         CB008717-C UE Release due to AMF Context Release
...         CB008717-D Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers, additional content
...         CB008717-E UE Release without bearer takeback
...         CB008717-G Cell Management for Secondary Node
...         CB008717-H Configuration and Reception of A4 measurements
...         CB008717-I Successful Measurement based PSCell Addition
...         CB008717-J Interaction with event A4
...         CB008717-M Mobilty on PCell
...
...      == AUTHORS ==
...       - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...       - Agnieszka Wlodarczyk <agnieszka.wlodarczyk@nokia.com>
...       - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...       - Adrianna Zenczak <adrianna.zenczak@nokia.com>
...       - Malgorzata Konior <malgorzata.konior@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...       - CB008717 CFAM
...
...      == HISTORY ==
...         [05.09.2022] - Create Test Suite
...         [26.09.2022] - Review closed

Resource    ./resources/CB008717-common_keywords.robot

Force Tags    CRT    RAN_5G    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Suite Setup  Run Setup  ute-ca=True  GBR_nonGBR=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/D/2c_FDD_n66_FR2_n258_NRDC.lua
${SCFC}=                   Krakow/CB008717/D/SCFC_FS_D_B1a_FDD_n66_n258.xml
${AP_XML}=                 Krakow/CB008717/D/iphy_FS_2c_n66_n258.xml

*** Test Cases ***
CB008717-D-B4d_PSCell_Addition_for_UE_having_multiple_PDU_sessions_highest_AMBR_PDU_chosen
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  This test scenario describes establishment of MN terminated split bearer for UEs with multiple PDU sessions.
    ...  PDU session for split bearer is selected based on AMBR.
    ...
    ...  == Precondition: ==
    ...  - gNB with CB008717 enabled
    ...  - NRHOIF related to band n258 of NRCELL-1
    ...  - NRBTS/NRDRB-13/nsaDrbParam/fiveqiValueList is set to 170
    ...  - NRBTS/NRDRB-18/nsaDrbParam/fiveqiValueList is set to 4
    ...  - NRBTS/NRDRB-13/nsaDrbParam/ulDataPath is set to ulOverNr
    ...  - NRBTS/NRDRB-18/nsaDrbParam/ulDataPath is set to ulOverNr
    ...  - NRBTS/NRDRB-13/nsaDrbParam/dlDataSplitMode is set to dlOverF1UX2U
    ...  - NRBTS/NRDRB-18/nsaDrbParam/dlDataSplitMode is set to dlOverF1UX2U
    ...  - NRBTS/NRDRB-13/resType is set to nonGBR
    ...  - NRBTS/NRDRB-18/resType is set to GBR
    ...  - NRCELL-2.actNonVoNRGbrService = true
    ...  - UE-NR-Capability for UE1, UE2, UE3 same as in CB008717-D-B1a, UEs are split capable
    ...  - PDU sessions for UEs are configured as follows:
    ...       UE1:
    ...        PDU1 with 1 non-GBR QoS Flow, AMBR_DL=100Kbps AMBR_UL=300Kbps
    ...        PDU2 with 1 non-GBR QoS Flow, AMBR_DL=200Kbps AMBR_UL=200Kbps
    ...        PDU3 with 1 non-GBR QoS Flow, AMBR_DL=200Kbps AMBR_UL=100Kbps
    ...       UE2:
    ...        PDU1 with 1 non-GBR QoS Flow, AMBR_DL=100Kbps AMBR_UL=100Kbps
    ...        PDU2 with 1 GBR QoS Flow,     AMBR_DL=300Kbps AMBR_UL=100Kbps
    ...        PDU3 with 1 non-GBR QoS Flow, AMBR_DL=200Kbps AMBR_UL=100Kbps
    ...       UE3:
    ...        PDU1 with 1 non-GBR QoS Flow, AMBR_DL=100Kbps AMBR_UL=100Kbps
    ...        PDU2 with 1 non-GBR QoS Flow, AMBR_DL=100Kbps AMBR_UL=100Kbps
    ...        PDU3 with 1 non-GBR QoS Flow, AMBR_DL=100Kbps AMBR_UL=100Kbps
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_KLLL (ASIK + 3xABIL)
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...     5G_RAN_USR_RRM_15959
    ...  == REQUIRED LOGS ==
    ...  - NGAP, F1AP, E1AP, RRC
    ...  == CONTACTS ==
    ...  Malgorzata Konior <malgorzata.konior@nokia.com>
    ...  Karolina Sroczyk <karolina.sroczyk@nokia.com>
    ...  == REFERENCES ==
    ...  CB008717 CFAM:
    ...  - CB008717-D-B4d PSCell Addition for UE having multiple PDU sessions highest AMBR PDU chosen
    ...  HISTORY:
    ...  [18.01.2023] - Create Test Case
    ...  [25.01.2023] - TC add to CRT after review completed

    [Tags]   D_B4d-1

    [Setup]  Prepare test environment D_B4d

    Attach UE1 without ICS to gNB2 cell2
    Set AMBR params for UE1 PDU:1 AMBR-DL:100Kbps AMBR-UL:300Kbps
#    Add to UE1 initial PDU session with ICS
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Set AMBR params for UE1 PDU:2 AMBR-DL:200Kbps AMBR-UL:200Kbps
    Add to UE1 second PDU session after ICS
    Set AMBR params for UE1 PDU:3 AMBR-DL:200Kbps AMBR-UL:100Kbps
    Add to UE1 third PDU session after ICS

    Set expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Exclude UECaps from ICS for UE1 and include indexToRFSP eq 87

    Trigger UE1 to enter and exit idle mode
    Verify expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Verify that AMF1 NGAP InitialContextSetup contains 3 PDU sessions

    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    Verify in 1 out of 2 that BearerContextModificationRequest PDU-Session-ID-2 is set according to ICS for gNB2
    Verify in 1 out of 2 that BearerContextModificationResponse PDU-Session-ID-2 is set according to ICS for gNB2

    Attach UE2 without ICS to gNB2 cell2
    Set AMBR params for UE2 PDU:1 AMBR-DL:100Kbps AMBR-UL:100Kbps
#    Add to UE2 initial PDU session with ICS
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 87
    Set one PDU session with 1 GBR QoS Flow for UE2
    Set AMBR params for UE2 PDU:2 AMBR-DL:300Kbps AMBR-UL:100Kbps
    Add to UE2 second PDU session after ICS
    Reset QoS Flow settings on SMF
    Set AMBR params for UE2 PDU:3 AMBR-DL:200Kbps AMBR-UL:100Kbps
    Add to UE2 third PDU session after ICS

    Set expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
    Exclude UECaps from ICS for UE2 and include indexToRFSP eq 87

    Trigger UE2 to enter and exit idle mode
    Verify expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
    Verify that AMF1 NGAP InitialContextSetup contains 3 PDU sessions

    Set expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    UE2 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    Verify in 1 out of 2 that BearerContextModificationRequest PDU-Session-ID-3 is set according to ICS for gNB2
    Verify in 1 out of 2 that BearerContextModificationResponse PDU-Session-ID-3 is set according to ICS for gNB2

    Attach UE3 without ICS to gNB2 cell2
    Set AMBR params for UE3 PDU:1 AMBR-DL:100Kbps AMBR-UL:100Kbps
#    Add to UE3 initial PDU session with ICS
    Add to UE3 initial PDU session with ICS and indexToRFSP equal 87
    Set AMBR params for UE3 PDU:2 AMBR-DL:100Kbps AMBR-UL:100Kbps
    Add to UE3 second PDU session after ICS
    Set AMBR params for UE3 PDU:3 AMBR-DL:100Kbps AMBR-UL:100Kbps
    Add to UE3 third PDU session after ICS

    Set expected messages flows for A4 measurement configuration for UE3, gNB2 and AMF1
    Exclude UECaps from ICS for UE3 and include indexToRFSP eq 87

    Trigger UE3 to enter and exit idle mode
    Verify expected messages flows for A4 measurement configuration for UE3, gNB2 and AMF1
    Verify that AMF1 NGAP InitialContextSetup contains 3 PDU sessions

    Set expected messages flows for A4 measurement based PSCell addition for UE3, gNB2 and AMF1
    UE3 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE3, gNB2 and AMF1
    Verify in 1 out of 2 that BearerContextModificationRequest PDU-Session-ID-1 is set according to ICS for gNB2
    Verify in 1 out of 2 that BearerContextModificationResponse PDU-Session-ID-1 is set according to ICS for gNB2

    [Teardown]  Cleanup after test D-B4d
