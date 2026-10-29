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
...      [11.10.2023] - Create Test Suite
...      [16.10.2023] - Approved by EFS during review

Resource    ./resources/CB008717-common_keywords.robot
Library     ./resources/message_verifiers.py

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SKIPRUN    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
    ...    CLOUD_5G_I_BOO_AP_LOO

Suite Setup    Run Keywords
...            Enable UU Messaging On Simulated Nodes    AND
...            Run Setup  ute-ca=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/M/6c_FDD_n66_n5_FR2_n260_n261_NRDC.lua
${SCFC}=                   Krakow/CB008717/DE/SCFC_FS_6C_n5_n66_n260_n261.xml
${AP_XML}=                 Krakow/CB008717/DE/iphy_FS_6c_n5_n66_n260_n261.xml

&{NRCELL_ID_TO_PHYSCELL_ID}=  1=50  2=51  3=52  4=53  5=54  6=55

*** Test Cases ***
CB008717-M-B13_B14_Not_configure_A3_A5_A2_on_FWA_UE_during_ICS
    [Documentation]
    ...  DESCRIPTION: This user scenario describes the gNB behavior that if UE is identified as FWA UE then gNB blocks A2/A3/A5
    ...               measurements on such UE.
    ...               Scenario covers optimize and not optimize Initial Context Setup procedure.
    ...
    ...  PRECONDITION:
    ...  - For real gNB-2 the same preconditions as in CB008717-M-B4 scenario UE-NR-Capability the same as in CB008717-M-B4
    ...
    ...  POSTCONDITION:
    ...  - UE1 is in RRC-CONNECTED state on NRCELL-2 with NR-DC setup with NRCELL-3
    ...  - UE2 is in RRC-CONNECTED state on NRCELL-2 without A4 NR-DC measurement configured
    ...  - UE3 is in RRC-CONNECTED state on NRCELL-2 with NR-DC setup with NRCELL-3
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_LO (ASIL + 2xABIO)
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_17415, 5G_RAN_USR_RRM_18584
    ...       *BACKLOG ID: FCA_5G_L2L3-178732, FCA_5G_L2L3-178732
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP
    ...
    ...  CONTACTS:
    ...  Test owner         : Konrad Krzyzak   (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS    (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  Related CFAM US: CB008717-M#B13, CB008717-M#B13_Alt2, CB008717-M#B14
    ...  CFAM link:       https://gates.nsn-net.net/view/000268d5#o=5621
    ...  FTS link:        https://nokia.sharepoint.com/:w:/r/sites/mn-ran-productization/RAN%20Productization%20WoW/_layouts/15/
    ...                   Doc.aspx?sourcedoc=%7B7E508D0C-5E99-4494-90F6-1AF2B64456B4%7D&file=CB008717_FeatureTestStrategy.docx&
    ...                   wdLOR=c2FBA36C5-B1BE-4FA4-B2C8-F755C3E4AECD&action=default&mobileredirect=true
    ...  L3 ET Test Plan: https://confluence.ext.net.nokia.com/display/M5FC/CB008717-M+Sub+feature+refinement
    ...  EntityItem: M-B13a/M-B13a_alt2/M-B14
    ...
    ...  HISTORY:
    ...  History, current status and TC description is available in repository:
    ...  https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
    ...
    ...  [11.10.23] - Create Test Case draft
    ...  [18.10.23] - Final TC shape after review

    [Tags]  M-B13-B14

    [Setup]  Prepare test environment for M-B13-B14

    # ------------ UE1 part - sufficient UE caps, no UECapabilityEnquiry, MGAP setup ------------

    Set ${sufficient_n5_n66_n260_n261_with_interRAT} UECaps for UE1
    Attach UE1 without ICS to gNB2 cell2
    Set expected messages flows for NRDC A4 measurements for UE1 with sufficient UECaps and gNB2
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for NRDC A4 measurements for UE1 with sufficient UECaps and gNB2
    Verify that UE1 performed ICS optimized
    Verify that AMF1 NGAP InitialContextSetup contains indexToRSFP equal 87

    Verify that UEContextSetupRequest contains no A2,A3,A5 measurements for UE1 and gNB2
    Verify that measurements are not activated for UE1 in 1 out of 2 RRCReconfiguration message

    Verify that A4 measurements are configured in 3 out of 3 UEContextModificationRequest message
    Verify that UEContextModificationRequest_3 of 3 does not contain measGapConfig for gNB2
    Verify that UEContextModificationResponse_3 of 3 contains measGapConfig for gNB2
    Verify that 2 out of 2 RRCReconfiguration contains measGapConfig=setup for UE1
    Verify that A4 measurements are configured for UE1 in 2 out of 2 RRCReconfiguration message

    Run 20MBps UL and DL traffic on UE1 PDU1 QFI1 and wait 5 seconds

    ${meas_id}=    Wait for NRDC A4 activation and get measID for UE1 and NRCELL-3

    Set expected messages flows for A4 measurement based PSCell addition with DRX for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=${meas_id} for NR-DC PSCell addition with phycell_id=52 nrsrp_nr=86 nrsrq_nr=31
    Verify expected messages flows for A4 measurement based PSCell addition with DRX for UE1, gNB2 and AMF1
    Verify in 1 out of 2 RRCReconfiguration for UE1 that SCG contains CGI eq 1 and PCI eq 52 for SCG
    Verify 20Mbps UL and DL traffic on PDU-1 QFI-1 for UE1

# ------------ UE2 part - sufficient UE caps, no UECapabilityEnquiry, nonFWA UE ------------

    Set ${sufficient_n5_n66_n260_n261_with_interRAT} UECaps for UE2
    Attach UE2 without ICS to gNB2 cell2
    Set expected messages flows to check if A4 measurements are not configured for UE2, gNB2 and AMF1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 99
    Verify that A4 measurements not configured for UE2 with sufficient UECaps and A2,A3,A4 not blocked, gNB2 and AMF1
    Verify that UE2 performed ICS optimized
    Verify that AMF1 NGAP InitialContextSetup contains indexToRSFP equal 99

    Verify that UEContextSetupRequest contains A2,A3,A5 measurements for UE2 and gNB2
    Verify that measurements are activated for UE2 in 1 out of 2 RRCReconfiguration message

    Verify that measurements are not configured in 3 out of 3 UEContextModificationRequest message
    Verify that UEContextModificationRequest_3 of 3 does not contain measGapConfig for gNB2
    Verify that 2 out of 2 RRCReconfiguration contains drx-Config eq setup for UE2

    # ------------ UE3 part - no UE caps in ICS, UECapabilityEnquiry, MGAP setup ------------

    Exclude UECaps from ICS for UE3 and include indexToRFSP eq 87
    Attach UE3 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE3, gNB2 and AMF1
    Add to UE3 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE3, gNB2 and AMF1
    Verify that UE3 performed ICS non optimized without UECap container
    Verify that AMF1 NGAP InitialContextSetup contains indexToRSFP equal 87

    Verify that UEContextSetupRequest contains no A2,A3,A5 measurements for UE3 and gNB2
    Verify that measurements are not activated for UE3 in 1 out of 2 RRCReconfiguration message

    Verify that A4 measurements are configured in 3 out of 3 UEContextModificationRequest message
    Verify that UEContextModificationRequest_3 of 3 does not contain measGapConfig for gNB2
    Verify that UEContextModificationResponse_3 of 3 contains measGapConfig for gNB2
    Verify that 2 out of 2 RRCReconfiguration contains measGapConfig=setup for UE3
    Verify that A4 measurements are configured for UE3 in 2 out of 2 RRCReconfiguration message

    Run 20MBps UL and DL traffic on UE3 PDU1 QFI1 and wait 5 seconds

    ${meas_id}=    Wait for NRDC A4 activation and get measID for UE3 and NRCELL-3

    Set expected messages flows for A4 measurement based PSCell addition with DRX for UE3, gNB2 and AMF1
    UE3 sends A4 measurement id=${meas_id} for NR-DC PSCell addition with phycell_id=52 nrsrp_nr=86 nrsrq_nr=31
    Verify expected messages flows for A4 measurement based PSCell addition with DRX for UE3, gNB2 and AMF1
    Verify in 1 out of 2 RRCReconfiguration for UE3 that SCG contains CGI eq 1 and PCI eq 52 for SCG
    Verify 20Mbps UL and DL traffic on PDU-1 QFI-1 for UE3

    [Teardown]    Cleanup after test M-B13-B14
