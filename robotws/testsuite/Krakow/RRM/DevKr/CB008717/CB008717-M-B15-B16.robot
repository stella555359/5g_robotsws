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
...      [19.10.2023] - Create Test Suite
...      [24.10.2023] - Approved by EFS
...      [24.10.2023] - Review closed

Resource    ./resources/CB008717-common_keywords.robot
Library     ./resources/message_verifiers.py

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
    ...    CLOUD_5G_I_BOO_AP_LOO

Suite Setup    Run Keywords
...            Enable UU Messaging On Simulated Nodes    AND
...            Run Setup  ute-ca=True  faf=2

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/M/6c_FDD_n66_n5_FR2_n260_n261_NRDC.lua
${SCFC}=                   Krakow/CB008717/DE/SCFC_FS_6C_n5_n66_n260_n261.xml
${AP_XML}=                 Krakow/CB008717/DE/iphy_FS_6c_n5_n66_n260_n261.xml

&{NRCELL_ID_TO_PHYSCELL_ID}=  1=50  2=51  3=52  4=53  5=54  6=55

*** Test Cases ***
CB008717-M-B16_Not_configure_A3_A5_A2_on_FWA_UE_during_the_first_PDU_Session_Resource_Setup_Request
    [Documentation]
    ...  DESCRIPTION: This user scenario describes the gNB behavior that if UE is identified as FWA UE then gNB blocks A2/A3/A5 measurements
    ...  on such UE. Scenario covers not optimize Initial Context Setup procedure without PDU session included in ICS_request. gNB determines
    ...  to bloc A2/A3/A5 when gNB starts the first PDU Session Resource Setup procedure. Additionally test covers verification that gNB blocks
    ...  A2/A3/A5 during incoming Xn handover for FWA UEs.
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
    ...      - NRBTS/NRCELL-1/NRHOIF-1 is not set
    ...      - NRBTS/NRCELL-2/NRHOIF-1/a4MeasNrDcEnabled is set none
    ...      - NRBTS/NRCELL-2/NRHOIF-2/a4MeasNrDcEnabled is set none
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
    ...  - UE-NR-Capability the same as in CB008717-D-B1c scenario
    ...
    ...  POSTCONDITION:
    ...  - UE1 is in RRC-CONNECTED state on NRCELL-2 without A4 NR-DC measurement configured
    ...  - UE5 is in RRC-CONNECTED state on NRCELL-2 without A4 NR-DC measurement configured
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_LO (ASIL + 2xABIO)
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_21444, 5G_RAN_USR_RRM_21964
    ...       *BACKLOG ID: FCA_5G_L2L3-184146, FCA_5G_L2L3-148049
    ...  REQUIRED LOGS: NGAP, RRC, F1AP, E1AP, XNAP
    ...
    ...  CONTACTS:
    ...  Test owner         : Grzegorz Szymik   (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS    (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  Related CFAM US: 5G_RAN_USR_RRM_21444, 5G_RAN_USR_RRM_21964
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
    ...  [19.10.23] - Create first Test Case shape
    ...  [24.10.23] - Final TC shape
    ...  [24.10.23] - Review closed

    [Tags]  M-B15-B16

    [Setup]  Prepare test environment for M-B15-B16

    # ------------ UE1 part - FWA UE, a4MeasNrDcEnabled set to none, PDU Session Setup after ICS, no A4/A2/A3/A5 measurements ------------

    Set indexToRFSP to 87 for UE1
    Attach UE1 to gNB2 cell2 with ICS without PDU session
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE1
    Verify in UECapabilityEnquiry that message includes request for bands:n66,n5,n260,n261 for UE1

    Set expected messages flows to check no A4 and A2/A3/A5 activation with DRX after first PDU session setup for UE1
    Add to UE1 initial PDU session after ICS
    Verify expected messages flows to check no A4 and A2/A3/A5 activation with DRX after first PDU session setup for UE1

    Verify that A4 measurements are not configured for UE1 in 1 out of 2 RRCReconfiguration message
    Verify that A2,A3,A5 measurements are not configured for UE1 in 1 out of 2 RRCReconfiguration message
    Verify that UEContextModificationRequest_3 of 5 contains DRXCycle for gNB2
    Verify that UEContextModificationResponse_3 of 5 contains drx-Config eq setup for gNB2
    Verify that 2 out of 2 RRCReconfiguration contains drx-Config eq setup for UE1

    # ------------ UE5 part - FWA UE, a4MeasNrDcEnabled set to none, no A4/A2/A3/A5 measurements after XN HO ------------

    Attach UE5 with ICS to simulated gNB3 with ICS and indexToRFSP equal 87

    Set expected messages flows to check UECapabilityEnquiry request for UE5, gNB2 and AMF1
    Set expected messages flows to check no A4 and A2/A3/A5 activation with DRX after incoming inter-gNB XN HO for UE5
    Trigger UE5 handover from sim_gNB to gNB2 NRCELL-2
    Verify that expected message flows for UECapabilityEnquiry request occured for UE5, gNB2 and AMF1
    Verify expected messages flows to check no A4 and A2/A3/A5 activation with DRX after incoming inter-gNB XN HO for UE5

    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE5
    Verify in UECapabilityEnquiry that message includes request for bands:n66,n5,n260,n261 for UE5
    Verify that A4 measurements are not configured for UE5 in 1 out of 2 RRCReconfiguration message
    Verify that A2,A3,A5 measurements are not configured for UE5 in 1 out of 2 RRCReconfiguration message
    Verify that UEContextModificationRequest_3 of 5 contains DRXCycle for gNB2
    Verify that UEContextModificationResponse_3 of 5 contains drx-Config eq setup for gNB2
    Verify that 2 out of 2 RRCReconfiguration contains drx-Config eq setup for UE5

    [Teardown]    Cleanup after test M-B15-B16
